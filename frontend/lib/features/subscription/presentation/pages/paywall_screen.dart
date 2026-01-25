import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:ui';
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
      backgroundColor: AppColors.lightBackground,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topRight,
                  radius: 1.3,
                  colors: [AppColors.secondary.withOpacity(0.6), Colors.white],
                  stops: const [0.0, 0.7],
                ),
              ),
            ),
          ),

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
                        const SizedBox(height: 16),
                        Text(
                          "Unlock Your Full Potential",
                          style: AppTypography.headline2.copyWith(
                            color: AppColors.ln900,
                            letterSpacing: -0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Master language with AI-powered practice",
                          style: AppTypography.body1.copyWith(
                            color: AppColors.ln500,
                            height: 1.5,
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
                        // Restore Purchase
                        TextButton(
                          onPressed: _isPurchasing ? null : _restorePurchases,
                          child: Text(
                            context.l10n.subscription_restore,
                            style: AppTypography.body2.copyWith(
                              color: AppColors.ln500,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        // Legal Links
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                // TODO: Navigate to Privacy Policy
                              },
                              child: Text(
                                "Privacy Policy",
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Text(
                                "•",
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.ln400,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // TODO: Navigate to Terms of Service
                              },
                              child: Text(
                                "Terms of Service",
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Recurring billing, cancel anytime.",
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
            child: _buildStickyFooter(
              _selectedTier == SubscriptionTier.pro ? proMonthly : plusMonthly,
              _selectedTier == SubscriptionTier.pro ? proYearly : plusYearly,
            ),
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

  Widget _buildStickyFooter(Package? monthlyPackage, Package? yearlyPackage) {
    final activePackage = _isYearly ? yearlyPackage : monthlyPackage;

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
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (monthlyPackage != null && yearlyPackage != null) ...[
                _buildBillingOption(yearlyPackage, true),
                const SizedBox(height: 12),
                _buildBillingOption(monthlyPackage, false),
                const SizedBox(height: 16),
              ],

              if (activePackage != null)
                GestureDetector(
                  onTap: _isPurchasing
                      ? null
                      : () => _purchasePackage(activePackage),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _selectedTier == SubscriptionTier.pro
                          ? "Start 7-Day Free Trial"
                          : "Subscribe",
                      style: AppTypography.button.copyWith(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillingOption(Package package, bool isYearlyOption) {
    // Logic: Yearly = Green (Savings), Monthly = Blue (Standard)
    // Simplified logic: Selected = Primary (Black), Unselected = White
    final bool isSelected = _isYearly == isYearlyOption;
    final product = package.storeProduct;

    // Unified selected styles
    final Color activeBg = AppColors.lightBackground;
    final Color activeBorder = AppColors.primary;
    final Color activeText = AppColors.primary;
    final Color activeIcon = AppColors.primary;

    // Calculate monthly equivalent for yearly
    String subtitle = "";
    if (isYearlyOption) {
      final monthlyPrice = product.price / 12;
      subtitle =
          "${product.currencyCode} ${monthlyPrice.toStringAsFixed(2)} / mo";
    }

    return GestureDetector(
      onTap: () {
        setState(() => _isYearly = isYearlyOption);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? activeBg : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? activeBorder : AppColors.ln200,
            width: isSelected ? 1 : 1,
          ),
          boxShadow: isSelected ? AppShadows.sm : [],
        ),
        child: Row(
          children: [
            // Radio Circle
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? activeIcon : AppColors.ln300,
                  width: isSelected ? 6 : 1.5,
                ),
                color: Colors.white, // Inner dot always white
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isYearlyOption ? "Yearly" : "Monthly",
                        style: AppTypography.subtitle1.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.ln900,
                        ),
                      ),
                      if (isYearlyOption) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.lg100,
                            borderRadius: BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Text(
                            "SAVE 40%",
                            style: AppTypography.overline.copyWith(
                              color: AppColors.lg800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (isSelected && isYearlyOption)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        "Best Value",
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  product.priceString,
                  style: AppTypography.subtitle1.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.ln900,
                  ),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.ln500,
                    ),
                  ),
              ],
            ),
          ],
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
          _buildTierToggleButton("Plus", SubscriptionTier.plus),
          _buildTierToggleButton("Pro", SubscriptionTier.pro),
        ],
      ),
    );
  }

  Widget _buildTierToggleButton(String text, SubscriptionTier tier) {
    final isSelected = _selectedTier == tier;
    return GestureDetector(
      onTap: () => setState(() => _selectedTier = tier),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: AppTypography.button.copyWith(
            color: isSelected ? AppColors.ln900 : AppColors.ln500,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildProCard(Package package, Package? monthly, Package? yearly) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(
          AppRadius.xl,
        ), // Match SceneCard radius
        border: Border.all(color: AppColors.ln200),
        boxShadow: AppShadows.sm, // Match SceneCard shadow
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(AppRadius.xl), // Update corner
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
                Text(
                  "Pro",
                  style: AppTypography.headline3.copyWith(
                    color: AppColors.ln900,
                  ),
                ),
                const SizedBox(height: 24),
                _buildFeatureLine("100 Conversations / day"),
                _buildFeatureLine("100 Pronunciation Checks / day"),
                _buildFeatureLine("100 Grammar Analyses / day"),
                _buildFeatureLine("100 AI Message Reads / day"),
                _buildFeatureLine("Pitch Contour Analysis"),
                _buildFeatureLine("50 Custom Scenarios"),
                _buildFeatureLine("Multi-device Sync"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlusCard(Package package, Package? monthly, Package? yearly) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppRadius.xl), // Match SceneCard
        border: Border.all(color: AppColors.ln200),
        boxShadow: AppShadows.sm, // Match SceneCard
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Plus",
            style: AppTypography.headline3.copyWith(color: AppColors.ln900),
          ),
          const SizedBox(height: 24),
          _buildFeatureLine("20 Conversations / day"),
          _buildFeatureLine("20 Pronunciation Checks / day"),
          _buildFeatureLine("20 Grammar Analyses / day"),
          _buildFeatureLine("20 AI Message Reads / day"),
          _buildFeatureLine("Pitch Contour Analysis"),
          _buildFeatureLine("10 Custom Scenarios"),
          _buildFeatureLine("Multi-device Sync"),
        ],
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
