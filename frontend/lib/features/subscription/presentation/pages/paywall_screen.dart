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

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  /// Load available offerings from RevenueCat
  Future<void> _loadOfferings() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final service = RevenueCatService();
      if (service.offerings == null) {
        await service.refreshOfferings();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final offerings = RevenueCatService().offerings;
    final currentOffering = offerings?.current;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: BackButton(color: AppColors.lightTextPrimary),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || currentOffering == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: BackButton(color: AppColors.lightTextPrimary),
          title: Text(
            context.l10n.subscription_upgrade,
            style: AppTypography.headline4.copyWith(
              color: AppColors.lightTextPrimary,
            ),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.exclamationmark_circle,
                size: 48,
                color: AppColors.lightTextSecondary,
              ),
              const SizedBox(height: 16),
              Text(
                _error ?? context.l10n.subscription_noProductsAvailable,
                style: AppTypography.body1.copyWith(
                  color: AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadOfferings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: Text(context.l10n.chat_retry),
              ),
            ],
          ),
        ),
      );
    }

    // Get packages from the current offering
    final packages = currentOffering.availablePackages;

    // Match products using helper method for cross-platform compatibility
    final plusMonthly = packages.firstWhereOrNull(
      (p) => _matchesProduct(p, 'tritalkplusmonthly'),
    );
    final plusYearly = packages.firstWhereOrNull(
      (p) => _matchesProduct(p, 'tritalkplusyearly'),
    );
    final proMonthly = packages.firstWhereOrNull(
      (p) => _matchesProduct(p, 'tritalkpromonthly'),
    );
    final proYearly = packages.firstWhereOrNull(
      (p) => _matchesProduct(p, 'tritalkproyearly'),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: AppColors.lightTextPrimary),
        title: Text(
          context.l10n.subscription_choosePlan,
          style: AppTypography.headline4.copyWith(
            color: AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isPurchasing ? null : _restorePurchases,
            child: Text(
              context.l10n.subscription_restore,
              style: AppTypography.body2.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Premium Illustration
                  Container(
                    height: 180,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(
                          'assets/images/premium_illustration.png',
                        ),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    context.l10n.subscription_unlockPotential,
                    style: AppTypography.headline1.copyWith(
                      color: AppColors.lightTextPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    context.l10n.subscription_description,
                    textAlign: TextAlign.center,
                    style: AppTypography.body1.copyWith(
                      color: AppColors.lightTextSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Plus Tier Section
                  _buildTierSection(
                    tier: SubscriptionTier.plus,
                    monthlyPackage: plusMonthly,
                    yearlyPackage: plusYearly,
                    features: [
                      context.l10n.subscription_featureUnlimitedMessages,
                      context.l10n.subscription_featureAdvancedFeedback,
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Pro Tier Section
                  _buildTierSection(
                    tier: SubscriptionTier.pro,
                    monthlyPackage: proMonthly,
                    yearlyPackage: proYearly,
                    features: [
                      context.l10n.subscription_featureAllPlusFeatures,
                      context.l10n.subscription_featurePremiumScenarios,
                      context.l10n.subscription_featurePrioritySupport,
                    ],
                    isPrimary: true,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          // Loading overlay
          if (_isPurchasing)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }

  /// Build a subscription tier section
  Widget _buildTierSection({
    required SubscriptionTier tier,
    Package? monthlyPackage,
    Package? yearlyPackage,
    required List<String> features,
    bool isPrimary = false,
  }) {
    final hasPlan = monthlyPackage != null || yearlyPackage != null;
    if (!hasPlan) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: isPrimary
            ? AppColors.primary.withValues(alpha: 0.05)
            : Colors.grey[50],
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isPrimary ? AppColors.primary : Colors.grey[200]!,
          width: isPrimary ? 2 : 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tier header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isPrimary ? AppColors.primary : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tier.displayName,
                  style: AppTypography.subtitle2.copyWith(
                    color: isPrimary ? Colors.white : Colors.grey[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isPrimary) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    context.l10n.subscription_recommended,
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Features list
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    CupertinoIcons.checkmark_alt_circle_fill,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      feature,
                      style: AppTypography.body2.copyWith(
                        color: AppColors.lightTextPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Package options
          if (yearlyPackage != null)
            _buildPackageButton(yearlyPackage, isYearly: true),
          if (monthlyPackage != null) ...[
            const SizedBox(height: 8),
            _buildPackageButton(monthlyPackage, isYearly: false),
          ],
        ],
      ),
    );
  }

  /// Build a package purchase button
  Widget _buildPackageButton(Package package, {required bool isYearly}) {
    final product = package.storeProduct;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isPurchasing ? null : () => _purchasePackage(package),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          backgroundColor: isYearly ? AppColors.primary : Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: isYearly
                ? BorderSide.none
                : BorderSide(color: AppColors.primary),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isYearly
                  ? context.l10n.subscription_yearlyPlan
                  : context.l10n.subscription_monthlyPlan,
              style: AppTypography.button.copyWith(
                color: isYearly ? Colors.white : AppColors.primary,
              ),
            ),
            Text(
              product.priceString,
              style: AppTypography.button.copyWith(
                color: isYearly ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Handle package purchase
  Future<void> _purchasePackage(Package package) async {
    setState(() => _isPurchasing = true);

    final result = await RevenueCatService().purchasePackage(package);

    if (!mounted) return;

    setState(() => _isPurchasing = false);

    switch (result) {
      case SubscriptionPurchaseResult.success:
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.subscription_purchaseSuccess),
            backgroundColor: Colors.green,
          ),
        );
      case SubscriptionPurchaseResult.cancelled:
        // User cancelled, no action needed
        break;
      case SubscriptionPurchaseResult.error:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.subscription_purchaseFailed),
            backgroundColor: Colors.red,
          ),
        );
    }
  }

  /// Handle restore purchases
  Future<void> _restorePurchases() async {
    setState(() => _isPurchasing = true);

    final success = await RevenueCatService().restorePurchases();

    if (!mounted) return;

    setState(() => _isPurchasing = false);

    if (success && RevenueCatService().currentTier != SubscriptionTier.free) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.subscription_purchasesRestored),
          backgroundColor: Colors.green,
        ),
      );
    } else if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.subscription_noPurchasesToRestore)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.subscription_restoreFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Match product ID across platforms
  ///
  /// Apple: identifier == 'tritalkplusmonthly'
  /// Google Play: identifier == 'tritalkplusmonthly:monthly-autorenewing'
  ///
  /// Uses startsWith to ensure cross-platform compatibility
  bool _matchesProduct(Package package, String productId) {
    final identifier = package.storeProduct.identifier;
    return identifier == productId || identifier.startsWith('$productId:');
  }
}
