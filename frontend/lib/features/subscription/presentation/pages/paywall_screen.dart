import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:frontend/core/design/app_design_system.dart';
import 'package:frontend/core/utils/l10n_ext.dart';
import 'package:frontend/features/subscription/data/services/revenue_cat_service.dart';
import 'package:frontend/features/subscription/domain/models/subscription_tier.dart';
import 'package:frontend/features/subscription/presentation/widgets/paywall_skeleton_loader.dart';
import 'package:frontend/features/subscription/presentation/pages/subscription_success_screen.dart';
import 'package:frontend/features/subscription/presentation/widgets/pulsing_badge.dart';

/// Paywall screen for displaying subscription options
///
class PaywallScreen extends StatefulWidget {
  final bool showProOnly;

  const PaywallScreen({super.key, this.showProOnly = false});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _error;
  bool _isYearly = true; // Default to yearly for better value
  late SubscriptionTier _selectedTier;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _selectedTier = SubscriptionTier.pro;
    
    // Initialize fade animation for page entrance
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    
    RevenueCatService().addListener(_onRevenueCatUpdate);
    _loadOfferings();
    
    // Start entrance animation after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _fadeController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
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
      return const PaywallSkeletonLoader();
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
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // Background Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topRight,
                    radius: 1.3,
                    colors: [
                      AppColors.secondary.withOpacity(0.6),
                      Colors.white,
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),

            // Scrollable Content
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  24,
                  MediaQuery.of(context).padding.top +
                      60, // Top padding for header
                  24,
                  320, // Increased bottom padding for scrolling space
                ),
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
                  if (!widget.showProOnly) ...[
                    _buildToggleSwitch(),
                    const SizedBox(height: 32),
                  ] else ...[
                    // Add some spacing if toggle is hidden
                    const SizedBox(height: 16),
                  ],

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
                        padding: const EdgeInsets.symmetric(horizontal: 8),
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

          // Fixed Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[100],
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          CupertinoIcons.xmark,
                          color: AppColors.ln900,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          offset: const Offset(0, 8),
                          blurRadius: 24,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Start 7-Day Free Trial",
                          style: AppTypography.button.copyWith(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(
                          CupertinoIcons.arrow_right,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
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
                        PulsingBadge(
                          text: "SAVE 40%",
                          backgroundColor: AppColors.lg100,
                          textColor: AppColors.lg800,
                        ),
                      ],
                    ],
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
      width: 240, // Fixed comfortable width for two options
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.ln100,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Stack(
        children: [
          // The Sliding Indicator
          AnimatedAlign(
            alignment: _selectedTier == SubscriptionTier.plus
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            child: Container(
              width: 116, // (240 - 8) / 2
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
          // The Text Labels
          Row(
            children: [
              _buildToggleOption("Plus", SubscriptionTier.plus),
              _buildToggleOption("Pro", SubscriptionTier.pro),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String text, SubscriptionTier tier) {
    final isSelected = _selectedTier == tier;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTier = tier),
        behavior: HitTestBehavior.translucent, // Ensure entire area is tappable
        child: Container(
          alignment: Alignment.center,
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: AppTypography.button.copyWith(
              fontSize: 15, // Slightly larger
              color: isSelected ? AppColors.ln900 : AppColors.ln500,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            child: Text(text),
          ),
        ),
      ),
    );
  }

  Widget _buildProCard(Package package, Package? monthly, Package? yearly) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.1),
            offset: const Offset(0, 8),
            blurRadius: 32,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: PulsingBadge(
              text: "MOST POPULAR",
              backgroundColor: AppColors.secondary,
              textColor: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(AppRadius.xl),
                bottomLeft: Radius.circular(AppRadius.lg),
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
                _buildFeatureLine("Unlimited Conversations"),
                _buildFeatureLine("100 Pronunciation Checks / day"),
                _buildFeatureLine("Unlimited Grammar Analyses"),
                _buildFeatureLine("Unlimited AI Message Reads"),
                _buildFeatureLine("Pitch Contour Analysis"),
                _buildFeatureLine("Unlimited Custom Scenarios"),
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
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            offset: const Offset(0, 8),
            blurRadius: 32,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Plus",
            style: AppTypography.headline3.copyWith(color: AppColors.ln900),
          ),
          const SizedBox(height: 24),
          _buildFeatureLine("Unlimited Conversations"),
          _buildFeatureLine("20 Pronunciation Checks / day"),
          _buildFeatureLine("Unlimited Grammar Analyses"),
          _buildFeatureLine("100 AI Message Reads / day"),
          _buildFeatureLine("Pitch Contour Analysis"),
          _buildFeatureLine("30 Custom Scenarios"),
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

    // SIMULATION LOGIC: Skip actual payment flow
    // Determine tier from package ID
    final isPlus = package.identifier.contains('plus');
    final tier = isPlus ? SubscriptionTier.plus : SubscriptionTier.pro;

    // Artificial delay to simulate network request
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Update global state via service
    RevenueCatService().debugSimulatePurchase(tier);

    setState(() => _isPurchasing = false);

    // Navigate to success screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriptionSuccessScreen(tier: tier),
      ),
    );
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
