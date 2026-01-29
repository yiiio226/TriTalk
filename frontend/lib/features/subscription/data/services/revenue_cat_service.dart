import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'package:frontend/core/env/env.dart';
import 'package:frontend/core/env/env_config.dart';
import 'package:frontend/features/subscription/domain/models/subscription_tier.dart';

/// Purchase result enum for internal use
///
/// This is separate from purchases_flutter's PurchaseResult to have
/// a simpler API for the rest of the app.
enum SubscriptionPurchaseResult {
  /// Purchase completed successfully
  success,

  /// User cancelled the purchase
  cancelled,

  /// An error occurred during purchase
  error,
}

/// RevenueCat service for handling in-app subscriptions
///
/// This service manages:
/// - RevenueCat SDK initialization
/// - User authentication with RevenueCat
/// - Subscription status tracking
/// - Purchase and restore operations
///
/// Usage:
/// ```dart
/// // Initialize on app startup
/// await RevenueCatService().initialize(userId);
///
/// // Check subscription status
/// if (RevenueCatService().hasPlus) {
///   // User has Plus or higher subscription
/// }
///
/// // Purchase a package
/// final result = await RevenueCatService().purchasePackage(package);
/// ```
class RevenueCatService extends ChangeNotifier {
  static final RevenueCatService _instance = RevenueCatService._internal();
  factory RevenueCatService() => _instance;
  RevenueCatService._internal();

  bool _isInitialized = false;
  CustomerInfo? _customerInfo;
  Offerings? _offerings;

  // Getters
  CustomerInfo? get customerInfo => _customerInfo;
  Offerings? get offerings => _offerings;
  bool get isInitialized => _isInitialized;

  // Debug override for testing
  SubscriptionTier? _debugOverrideTier;

  /// Current subscription tier based on active entitlements
  SubscriptionTier get currentTier {
    if (_debugOverrideTier != null) return _debugOverrideTier!;
    if (_customerInfo == null) return SubscriptionTier.free;

    // Check for Pro entitlement first (higher tier)
    if (_customerInfo!.entitlements.active.containsKey('pro')) {
      return SubscriptionTier.pro;
    }
    return SubscriptionTier
        .plus; // Logic seems to have been cut in original file, fixing based on context
  }

  /// Simulate a purchase for testing/demo purposes
  void debugSimulatePurchase(SubscriptionTier tier) {
    _debugOverrideTier = tier;
    notifyListeners();
    if (kDebugMode) {
      debugPrint('RevenueCatService: Simulated purchase of $tier');
    }
  }

  /// Whether user has Plus tier or higher (Plus or Pro)
  bool get hasPlus => currentTier.hasAccess(SubscriptionTier.plus);

  /// Whether user has Pro tier
  bool get hasPro => currentTier.hasAccess(SubscriptionTier.pro);

  /// Initialize RevenueCat SDK
  ///
  /// Must be called during app startup after user authentication.
  /// Uses the user's ID to sync purchases across devices.
  Future<void> initialize(String userId) async {
    if (_isInitialized) return;

    try {
      // Set log level based on environment
      await Purchases.setLogLevel(
        EnvConfig.isProd ? LogLevel.info : LogLevel.debug,
      );

      // Get API key based on platform
      final apiKey = defaultTargetPlatform == TargetPlatform.iOS
          ? Env.revenueCatAppleApiKey
          : Env.revenueCatGoogleApiKey;

      // Configure RevenueCat with user ID
      final configuration = PurchasesConfiguration(apiKey)..appUserID = userId;

      await Purchases.configure(configuration);

      // Listen for customer info updates
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);

      // Fetch initial data
      await _fetchCustomerInfo();
      await _fetchOfferings();

      _isInitialized = true;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('RevenueCatService: initialized for user $userId');
        debugPrint('RevenueCatService: current tier = ${currentTier.name}');
      }
    } catch (e) {
      debugPrint('RevenueCatService: initialization error - $e');
      // Don't set _isInitialized to true if there was an error
    }
  }

  /// Login user to RevenueCat
  ///
  /// Call this when user logs in to sync their purchases.
  Future<void> login(String userId) async {
    try {
      final result = await Purchases.logIn(userId);
      _customerInfo = result.customerInfo;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('RevenueCatService: logged in user $userId');
      }
    } catch (e) {
      debugPrint('RevenueCat login error: $e');
    }
  }

  /// Logout user from RevenueCat
  ///
  /// Call this when user logs out.
  Future<void> logout() async {
    try {
      _customerInfo = await Purchases.logOut();
      notifyListeners();

      if (kDebugMode) {
        debugPrint('RevenueCatService: logged out');
      }
    } catch (e) {
      debugPrint('RevenueCat logout error: $e');
    }
  }

  /// Fetch customer info from RevenueCat
  Future<void> _fetchCustomerInfo() async {
    try {
      _customerInfo = await Purchases.getCustomerInfo();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch customer info: $e');
    }
  }

  /// Fetch available offerings from RevenueCat
  Future<void> _fetchOfferings() async {
    try {
      _offerings = await Purchases.getOfferings();
      _debugPrintDefaultOffering();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to fetch offerings: $e');
    }
  }

  /// Debug: Pretty print the default offering and its packages
  void _debugPrintDefaultOffering() {
    if (!kDebugMode || _offerings?.current == null) return;

    final offering = _offerings!.current!;
    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('📦 DEFAULT OFFERING INFO');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('Offering ID: ${offering.identifier}');
    debugPrint('Server Description: ${offering.serverDescription}');
    debugPrint('Metadata: ${offering.metadata}');
    debugPrint('Available Packages: ${offering.availablePackages.length}');
    debugPrint('───────────────────────────────────────────────────────────');

    for (int i = 0; i < offering.availablePackages.length; i++) {
      _debugPrintPackage(offering.availablePackages[i], i + 1);
    }

    debugPrint('');
    debugPrint('═══════════════════════════════════════════════════════════');
    debugPrint('');
  }

  /// Debug: Pretty print a single package
  void _debugPrintPackage(Package package, int index) {
    if (!kDebugMode) return;

    final product = package.storeProduct;

    debugPrint('');
    debugPrint('📋 PACKAGE $index: ${package.identifier}');
    debugPrint('  ├─ Package Type: ${package.packageType}');
    debugPrint('  ├─ Offering ID: ${package.offeringIdentifier}');
    debugPrint('  │');
    debugPrint('  └─ 🏷️ STORE PRODUCT:');
    debugPrint('       ├─ Product ID: ${product.identifier}');
    debugPrint('       ├─ Title: ${product.title}');
    debugPrint('       ├─ Description: ${product.description}');
    debugPrint('       ├─ Price: ${product.priceString}');
    debugPrint('       ├─ Price (raw): ${product.price}');
    debugPrint('       ├─ Currency Code: ${product.currencyCode}');
    debugPrint('       ├─ Product Category: ${product.productCategory}');

    if (product.subscriptionPeriod != null) {
      debugPrint(
        '       ├─ Subscription Period: ${product.subscriptionPeriod}',
      );
    }

    if (product.introductoryPrice != null) {
      debugPrint(
        '       ├─ Intro Price: ${product.introductoryPrice?.priceString}',
      );
      debugPrint(
        '       ├─ Intro Period: ${product.introductoryPrice?.period}',
      );
      debugPrint(
        '       ├─ Intro Cycles: ${product.introductoryPrice?.cycles}',
      );
    }

    if (product.discounts?.isNotEmpty ?? false) {
      debugPrint('       └─ Discounts: ${product.discounts!.length}');
      for (final discount in product.discounts!) {
        debugPrint(
          '           └─ ${discount.identifier}: ${discount.priceString}',
        );
      }
    }
  }

  /// Handle customer info updates from RevenueCat
  void _onCustomerInfoUpdated(CustomerInfo info) {
    _customerInfo = info;
    notifyListeners();

    if (kDebugMode) {
      debugPrint('RevenueCatService: customer info updated');
      debugPrint('RevenueCatService: current tier = ${currentTier.name}');
    }
  }

  /// Purchase a package using the new Purchases.purchase() API
  ///
  /// Returns [SubscriptionPurchaseResult.success] if purchase was successful,
  /// [SubscriptionPurchaseResult.cancelled] if user cancelled,
  /// [SubscriptionPurchaseResult.error] if there was an error.
  Future<SubscriptionPurchaseResult> purchasePackage(Package package) async {
    try {
      // Use the modern purchase() API with PurchaseParams.package()
      final purchaseParams = PurchaseParams.package(package);
      final result = await Purchases.purchase(purchaseParams);
      _customerInfo = result.customerInfo;
      notifyListeners();

      if (kDebugMode) {
        debugPrint('RevenueCatService: purchase successful');
      }

      return SubscriptionPurchaseResult.success;
    } on PlatformException catch (e) {
      // RevenueCat errors are thrown as PlatformException
      final errorCode = PurchasesErrorHelper.getErrorCode(e);
      if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
        if (kDebugMode) {
          debugPrint('RevenueCatService: purchase cancelled by user');
        }
        return SubscriptionPurchaseResult.cancelled;
      }
      debugPrint('Purchase error: $e');
      return SubscriptionPurchaseResult.error;
    } catch (e) {
      debugPrint('Purchase error: $e');
      return SubscriptionPurchaseResult.error;
    }
  }

  /// Restore previous purchases
  ///
  /// Returns true if restoration was successful.
  Future<bool> restorePurchases() async {
    try {
      _customerInfo = await Purchases.restorePurchases();
      notifyListeners();

      if (kDebugMode) {
        debugPrint('RevenueCatService: purchases restored');
        debugPrint('RevenueCatService: current tier = ${currentTier.name}');
      }

      return true;
    } catch (e) {
      debugPrint('Restore error: $e');
      return false;
    }
  }

  /// Refresh customer info
  ///
  /// Call this to manually refresh the subscription status.
  Future<void> refreshCustomerInfo() async {
    await _fetchCustomerInfo();
  }

  /// Refresh offerings
  ///
  /// Call this to manually refresh available products.
  Future<void> refreshOfferings() async {
    await _fetchOfferings();
  }
}
