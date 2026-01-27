import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/core/cache/providers/feature_quota_cache_provider.dart';
import 'package:frontend/core/data/local/storage_key_service.dart';
import 'package:frontend/core/env/env.dart';
import 'package:frontend/core/initializer/app_initializer.dart';
import 'package:frontend/features/subscription/data/services/revenue_cat_service.dart';
import 'package:frontend/features/subscription/data/services/usage_service_impl.dart';
import 'package:frontend/features/subscription/domain/models/paid_feature.dart';
import 'package:frontend/features/subscription/domain/models/subscription_tier.dart';
import 'package:frontend/features/subscription/domain/services/usage_service.dart';
import 'package:frontend/features/subscription/presentation/paywall_route.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Interceptor for paid feature access control
///
/// This singleton class centralizes logic for:
/// 1. Checking hard Gating (requires Plus/Pro)
/// 2. Checking quota limits (Free vs Plus limits)
/// 3. Showing Paywall if access denied
class FeatureGate {
  final UsageService _usageService;

  // Singleton instance
  static final FeatureGate _instance = FeatureGate._internal();
  factory FeatureGate() => _instance;

  FeatureGate._internal()
    : _usageService = UsageServiceImpl(
        cacheProvider: FeatureQuotaCacheProvider(
          prefs: AppBootstrap.prefs,
          storageKey: StorageKeyService(),
        ),
        supabase: Supabase.instance.client,
      );

  /// Initialize the usage service (load cache, start sync)
  Future<void> initialize() async {
    await _usageService.initialize();
  }

  /// Get the current quota limit for a feature (Source of Truth should be backend)
  /// Returns -1 for unlimited.
  int getQuotaLimit(PaidFeature feature) {
    // 1. Try to read from backend config (not implemented yet)
    // int? remoteLimit = AppConfig.current.getLimit(feature, currentTier);
    // if (remoteLimit != null) return remoteLimit;

    // 2. Local fallback strategy
    final tier = RevenueCatService().currentTier;

    switch (feature) {
      case PaidFeature.dailyConversation:
      case PaidFeature.voiceInput:
      case PaidFeature.speechAssessment:
      case PaidFeature.grammarAnalysis:
      case PaidFeature.ttsSpeak:
        if (tier == SubscriptionTier.pro) return 100;
        if (tier == SubscriptionTier.plus) return 20;
        return 3; // Free limit

      case PaidFeature.wordPronunciation:
        if (tier == SubscriptionTier.free) return 10;
        return -1; // Plus/Pro unlimited

      case PaidFeature.customScenarios:
        if (tier == SubscriptionTier.pro) return 50;
        if (tier == SubscriptionTier.plus) return 10;
        return 0; // Free cannot create

      case PaidFeature.pitchAnalysis:
        // Gate-only feature, no quota limit
        return -1;
    }
  }

  /// Check if the user has access eligibility (ignoring usage count)
  /// Used for UI lock icons.
  bool hasAccess(PaidFeature feature) {
    debugPrint('FeatureGate: Checking access for ${feature.name}');
    final hasPlus = RevenueCatService().hasPlus;

    if (feature == PaidFeature.pitchAnalysis) {
      debugPrint(
        'FeatureGate: ${feature.name} access -> $hasPlus (Requires Plus)',
      );
      return hasPlus; // Requires Plus+
    }
    if (feature == PaidFeature.customScenarios) {
      debugPrint(
        'FeatureGate: ${feature.name} access -> $hasPlus (Requires Plus)',
      );
      return hasPlus; // Requires Plus+ to create/access (based on doc)
    }

    debugPrint('FeatureGate: ${feature.name} access -> true (Quota limited)');
    return true; // Quota-limited features are accessible to all, just limited
  }

  /// Try to perform a restricted action
  ///
  /// Returns [true] if access is granted (user is eligible or upgraded via Paywall),
  /// [false] if access is denied or cancelled.
  ///
  /// Usage:
  /// ```dart
  /// // Style 1: Callback (Synchronous UI actions like Navigation)
  /// FeatureGate().performWithFeatureCheck(
  ///   context,
  ///   feature: PaidFeature.customScenarios,
  ///   onGranted: () => Navigator.pushNamed(context, '...'),
  /// );
  ///
  /// // Style 2: Await (Async API calls)
  /// if (await FeatureGate().performWithFeatureCheck(context, feature: ...)) {
  ///   await chatNotifier.sendChat(text);
  /// }
  /// ```
  ///
  /// Flows:
  /// 1. Check Env.forcePaywall override
  /// 2. Check Feature Access (Gatekeeping) -> Show Paywall
  /// 3. Check Quota Limits -> Show Paywall
  /// 4. Grant Access -> Call [onGranted] (if provided) and return [true]
  Future<bool> performWithFeatureCheck(
    BuildContext context, {
    required PaidFeature feature,
    VoidCallback? onGranted,
    VoidCallback? onPaywallCancelled,
  }) async {
    // 0. Debug: Force Paywall
    if (Env.forcePaywall) {
      await PaywallRoute.show(
        context,
        reason: "\n\n\n✅✅✅Debug: Force Paywall✅✅✅",
      );
      onPaywallCancelled?.call();
      return false;
    }

    // 1. Check Hard Gates
    if (!hasAccess(feature)) {
      await PaywallRoute.show(context, reason: "Unlock ${feature.name}");
      // Check if user subscribed after paywall
      if (hasAccess(feature)) {
        // Track usage after upgrade (async, non-blocking)
        unawaited(_usageService.trackUsage(feature));
        onGranted?.call();
        return true;
      } else {
        onPaywallCancelled?.call();
        return false;
      }
    }

    // 2. Check Quota (Usage)
    if (!_usageService.canUse(feature)) {
      await PaywallRoute.show(
        context,
        reason: "Daily limit reached for ${feature.name}",
      );
      // Re-check after paywall (user might have upgraded)
      if (_usageService.canUse(feature)) {
        // Track usage after upgrade (async, non-blocking)
        unawaited(_usageService.trackUsage(feature));
        onGranted?.call();
        return true;
      } else {
        onPaywallCancelled?.call();
        return false;
      }
    }

    // 3. Track usage (async, non-blocking) before granting access
    unawaited(_usageService.trackUsage(feature));

    // 4. Granted
    onGranted?.call();
    return true;
  }
}
