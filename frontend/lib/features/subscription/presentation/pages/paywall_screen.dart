import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:frontend/core/design/app_design_system.dart';
import 'package:frontend/core/utils/l10n_ext.dart';
import 'package:frontend/features/subscription/data/services/revenue_cat_service.dart';
import 'package:frontend/features/subscription/domain/models/subscription_tier.dart';

/// Paywall screen for displaying subscription options
///
/// This screen shows the available subscription tiers (Plus and Pro)
/// with monthly and yearly options. Users can purchase subscriptions
/// or restore previous purchases.
class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _error;
  bool _isYearly = true; // Default to yearly for better value
  SubscriptionTier _selectedTier = SubscriptionTier.pro; // Default to Pro

  @override
  void initState() {
    super.initState();
    RevenueCatService().addListener(_onRevenueCatUpdate);
    _loadOfferings();
  }

  @override
  void dispose() {
    RevenueCatService().removeListener(_onRevenueCatUpdate);
    super.dispose();
  }

  void _onRevenueCatUpdate() {
    if (mounted) {
      setState(() {
        // Trigger rebuild to update UI based on new offering/customer info
      });
      // If we were loading or had error, retry fetching offerings if initialized now
      if (RevenueCatService().isInitialized && (_isLoading || _error != null)) {
        _loadOfferings();
      }
    }
  }

  Future<void> _loadOfferings() async {
    final service = RevenueCatService();

    // Safety check: Don't attempt to use SDK if not configured
    if (!service.isInitialized) {
      if (mounted) setState(() => _isLoading = true);
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Ensure we have latest info
      await service.refreshOfferings();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Error loading plans: $_error"),
              TextButton(onPressed: _loadOfferings, child: const Text("Retry")),
            ],
          ),
        ),
      );
    }

    final offerings = RevenueCatService().offerings;
    final currentOffering = offerings?.current;
    final packages = currentOffering?.availablePackages ?? [];

    // DEBUG LOGGING
    if (kDebugMode) {
      print("💰 Paywall Debug: Found ${packages.length} packages");
      for (var p in packages) {
        print("   - ${p.identifier} (Product: ${p.storeProduct.identifier})");
      }
    }

    // Find packages
    var plusMonthly = packages.firstWhereOrNull(
      (p) => _matchesProduct(p, 'tritalkplusmonthly'),
    );
    var plusYearly = packages.firstWhereOrNull(
      (p) => _matchesProduct(p, 'tritalkplusyearly'),
    );
    var proMonthly = packages.firstWhereOrNull(
      (p) => _matchesProduct(p, 'tritalkpromonthly'),
    );
    var proYearly = packages.firstWhereOrNull(
      (p) => _matchesProduct(p, 'tritalkproyearly'),
    );

    // FALLBACK FOR DEVELOPMENT / TESTING
    // If no products found, create mock packages so UI can be reviewed
    if (packages.isEmpty) {
      // Create mock StoreProduct
      final mockProductPlusMonth = StoreProduct(
        'tritalkplusmonthly',
        'Plus Monthly',
        'Plus',
        9.99,
        '\$9.99',
        'USD',
      );
      final mockProductPlusYear = StoreProduct(
        'tritalkplusyearly',
        'Plus Yearly',
        'Plus',
        71.99,
        '\$71.99',
        'USD',
      );
      final mockProductProMonth = StoreProduct(
        'tritalkpromonthly',
        'Pro Monthly',
        'Pro',
        24.99,
        '\$24.99',
        'USD',
      );
      final mockProductProYear = StoreProduct(
        'tritalkproyearly',
        'Pro Yearly',
        'Pro',
        179.99,
        '\$179.99',
        'USD',
      );

      // Create a mock context.
      // PresentedOfferingContext usually requires offeringIdentifier, placementIdentifier, and targetingContext.
      // We'll pass dummy values for the strings and null for the targeting context if allowed,
      // or empty strings/objects.
      // Based on typical definition: PresentedOfferingContext(this.offeringIdentifier, this.placementIdentifier, this.targetingContext)
      final mockContext = PresentedOfferingContext(
        'mock_offering',
        'mock_placement',
        null,
      );

      plusMonthly = Package(
        'tritalkplusmonthly',
        PackageType.monthly,
        mockProductPlusMonth,
        mockContext,
      );
      plusYearly = Package(
        'tritalkplusyearly',
        PackageType.annual,
        mockProductPlusYear,
        mockContext,
      );
      proMonthly = Package(
        'tritalkpromonthly',
        PackageType.monthly,
        mockProductProMonth,
        mockContext,
      );
      proYearly = Package(
        'tritalkproyearly',
        PackageType.annual,
        mockProductProYear,
        mockContext,
      );
    }

    final activePlus = _isYearly ? plusYearly : plusMonthly;
    final activePro = _isYearly ? proYearly : proMonthly;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(
                          CupertinoIcons.xmark,
                          color: AppColors.ln900,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                      TextButton(
                        onPressed: _isPurchasing ? null : _restorePurchases,
                        child: Text(
                          context.l10n.subscription_restore,
                          style: AppTypography.button.copyWith(
                            color: AppColors.ln500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      24,
                      0,
                      24,
                      180,
                    ), // Added bottom padding for footer
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        Text(
                          "Unlock Your Full Potential",
                          style: AppTypography.headline2.copyWith(
                            color: AppColors.primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Master language with AI-powered practice",
                          style: AppTypography.body1.copyWith(
                            color: AppColors.ln500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 32),

                        // Monthly / Yearly Switch
                        _buildToggleSwitch(),
                        const SizedBox(height: 32),

                        // Selected Card
                        if (_selectedTier == SubscriptionTier.pro &&
                            activePro != null)
                          _buildProCard(activePro, proMonthly, proYearly)
                        else if (_selectedTier == SubscriptionTier.plus &&
                            activePlus != null)
                          _buildPlusCard(activePlus, plusMonthly, plusYearly),

                        const SizedBox(height: 32),

                        // Terms
                        Text(
                          "Recurring billing, cancel anytime.\nBy continuing you agree to our Terms & Privacy Policy.",
                          style: AppTypography.caption.copyWith(
                            color: AppColors.ln400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Sticky Footer
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildStickyFooter(activePlus, activePro),
          ),

          if (_isPurchasing)
            Container(
              color: Colors.black12,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  Widget _buildStickyFooter(Package? activePlus, Package? activePro) {
    final activePackage = _selectedTier == SubscriptionTier.pro
        ? activePro
        : activePlus;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 16,
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTierSelector(),
              const SizedBox(height: 16),
              if (activePackage != null)
                GestureDetector(
                  onTap: _isPurchasing
                      ? null
                      : () => _purchasePackage(activePackage),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _selectedTier == SubscriptionTier.pro
                          ? AppColors.secondary
                          : AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _selectedTier == SubscriptionTier.pro
                          ? "Start 7-Day Free Trial"
                          : "Subscribe",
                      style: AppTypography.button.copyWith(color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTierSelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ln100,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(child: _buildTierOption("Plus", SubscriptionTier.plus)),
          Expanded(child: _buildTierOption("Pro", SubscriptionTier.pro)),
        ],
      ),
    );
  }

  Widget _buildTierOption(String text, SubscriptionTier tier) {
    final isSelected = _selectedTier == tier;
    return GestureDetector(
      onTap: () => setState(() => _selectedTier = tier),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          boxShadow: isSelected ? AppShadows.sm : null,
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: AppTypography.button.copyWith(
            color: isSelected ? AppColors.ln900 : AppColors.ln500,
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.ln100,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton("Monthly", !_isYearly),
          _buildToggleButton("Yearly (-40%)", _isYearly),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _isYearly = text.contains("Yearly")),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: isSelected ? AppShadows.sm : null,
        ),
        child: Text(
          text,
          style: AppTypography.button.copyWith(
            color: isSelected ? AppColors.primary : AppColors.ln500,
          ),
        ),
      ),
    );
  }

  Widget _buildProCard(Package package, Package? monthly, Package? yearly) {
    final product = package.storeProduct;
    // Calculate display price (if yearly, show price per month)
    String pricePerMonth = product.priceString;
    if (_isYearly && yearly != null) {
      // Simple heuristic string formatting, real app should use precise math
      final price = yearly.storeProduct.price;
      pricePerMonth = (price / 12).toStringAsFixed(2);
      // Add currency symbol matching storeProduct if possible, here assuming format
      pricePerMonth = "${product.currencyCode} $pricePerMonth / mo";
    }

    return GestureDetector(
      onTap: _isPurchasing ? null : () => _purchasePackage(package),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primary, // Dark theme
          borderRadius: BorderRadius.circular(AppRadius.lg),
          boxShadow: AppShadows.lg,
        ),
        child: Stack(
          children: [
            // Badge
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(AppRadius.lg),
                    bottomLeft: Radius.circular(AppRadius.lg),
                  ),
                ),
                child: Text(
                  "MOST POPULAR",
                  style: AppTypography.overline.copyWith(color: Colors.white),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        "Pro",
                        style: AppTypography.headline3.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Icon(CupertinoIcons.star_fill, color: AppColors.secondary, size: 20),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _isYearly && yearly != null
                            ? pricePerMonth.split(' ')[1]
                            : product
                                  .priceString, // Hacky extraction, ideal is using formatted price
                        style: AppTypography.headline1.copyWith(
                          color: Colors.white,
                          fontSize: 36,
                        ),
                      ),
                      if (_isYearly)
                        Text(
                          " / mo",
                          style: AppTypography.body1.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                    ],
                  ),
                  if (_isYearly)
                    Text(
                      "Billed ${product.priceString} yearly",
                      style: AppTypography.caption.copyWith(
                        color: Colors.white54,
                      ),
                    ),

                  const SizedBox(height: 24),
                  _buildFeatureLine("100 Conversations / day", isDark: true),
                  _buildFeatureLine(
                    "100 Pronunciation Checks / day",
                    isDark: true,
                  ),
                  _buildFeatureLine("Pitch Contour Analysis", isDark: true),
                  _buildFeatureLine("Unlimited Custom Scenarios", isDark: true),
                  // Removed internal button
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlusCard(Package package, Package? monthly, Package? yearly) {
    final product = package.storeProduct;
    // Calculate display price
    String pricePerMonth = product.priceString;
    if (_isYearly && yearly != null) {
      final price = yearly.storeProduct.price;
      pricePerMonth =
          "${product.currencyCode} ${(price / 12).toStringAsFixed(2)} / mo";
    }

    return GestureDetector(
      onTap: _isPurchasing ? null : () => _purchasePackage(package),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.lightSurface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.ln200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Plus",
              style: AppTypography.headline3.copyWith(color: AppColors.ln900),
            ),
            const SizedBox(height: 8),
            Text(
              _isYearly ? "$pricePerMonth" : product.priceString,
              style: AppTypography.headline3.copyWith(color: AppColors.ln900),
            ),
            if (_isYearly)
              Text(
                "Billed ${product.priceString} yearly",
                style: AppTypography.caption.copyWith(color: AppColors.ln500),
              ),

            const SizedBox(height: 20),
            _buildFeatureLine("20 Conversations / day"),
            _buildFeatureLine("20 Pronunciation Checks / day"),
            _buildFeatureLine("Grammar Analysis"),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureLine(String text, {bool isDark = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.checkmark_alt,
            color: isDark ? AppColors.secondary : AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: AppTypography.body2.copyWith(
                color: isDark ? Colors.white : AppColors.ln900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchasePackage(Package package) async {
    setState(() => _isPurchasing = true);
    final result = await RevenueCatService().purchasePackage(package);
    if (!mounted) return;
    setState(() => _isPurchasing = false);

    if (result == SubscriptionPurchaseResult.success) {
      Navigator.pop(context);
    } else if (result == SubscriptionPurchaseResult.error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Purchase failed. Please try again.')),
      );
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isPurchasing = true);
    final success = await RevenueCatService().restorePurchases();
    if (!mounted) return;
    setState(() => _isPurchasing = false);

    if (success && RevenueCatService().currentTier != SubscriptionTier.free) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'No active subscriptions found.' : 'Restore failed.',
          ),
        ),
      );
    }
  }

  bool _matchesProduct(Package? p, String id) {
    if (p == null) return false;
    final pid = p.storeProduct.identifier;
    return pid == id || pid.startsWith('$id:');
  }
}
