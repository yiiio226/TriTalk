import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:frontend/core/cache/providers/feature_quota_cache_provider.dart';
import 'package:frontend/features/subscription/data/services/revenue_cat_service.dart';
import 'package:frontend/features/subscription/domain/models/feature_quota_status.dart';
import 'package:frontend/features/subscription/domain/models/paid_feature.dart';
import 'package:frontend/features/subscription/domain/models/subscription_tier.dart';
import 'package:frontend/features/subscription/domain/services/usage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase-backed implementation of [UsageService].
///
/// This implementation:
/// 1. Uses local cache for synchronous quota checks (zero latency)
/// 2. Syncs with Supabase RPC for persistent tracking
/// 3. Follows Optimistic UI pattern (local-first, server-reconcile)
/// 4. Handles daily reset via lazy evaluation
///
/// See: feature_quota_system_design.md for full design details.
class UsageServiceImpl with WidgetsBindingObserver implements UsageService {
  final FeatureQuotaCacheProvider _cacheProvider;
  final SupabaseClient _supabase;
  final RevenueCatService _revenueCat;

  /// In-memory cache for fast access.
  FeatureQuotaCache? _memoryCache;

  /// Whether the service has been initialized.
  bool _initialized = false;

  /// Cached tier from last sync, used to detect actual tier changes.
  SubscriptionTier? _lastKnownTier;

  /// Debounce timer to prevent rapid consecutive syncs.
  Timer? _syncDebounceTimer;

  UsageServiceImpl({
    required FeatureQuotaCacheProvider cacheProvider,
    required SupabaseClient supabase,
    RevenueCatService? revenueCat,
  }) : _cacheProvider = cacheProvider,
       _supabase = supabase,
       _revenueCat = revenueCat ?? RevenueCatService();

  // ============================================
  // Initialization & Lifecycle
  // ============================================

  @override
  bool get isInitialized => _initialized;

  @override
  Future<void> initialize() async {
    if (_initialized) return;

    debugPrint('UsageServiceImpl: Initializing...');

    // 1. Hydrate from local cache first (instant UI)
    _memoryCache = _cacheProvider.loadCache();
    debugPrint(
      'UsageServiceImpl: Loaded ${_memoryCache?.features.length ?? 0} features from cache',
    );

    // 2. Register for lifecycle events
    WidgetsBinding.instance.addObserver(this);

    // 3. Listen for subscription changes from RevenueCat
    _lastKnownTier = _revenueCat.currentTier;
    _revenueCat.addListener(_onSubscriptionChanged);

    _initialized = true;

    // 4. Sync from server in background (don't block)
    _syncFromServerAsync();
  }

  /// Dispose resources.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _revenueCat.removeListener(_onSubscriptionChanged);
    _syncDebounceTimer?.cancel();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('UsageServiceImpl: App resumed, syncing from server...');
      _syncFromServerAsync();
    }
  }

  /// Async wrapper for syncFromServer (fire and forget).
  void _syncFromServerAsync() {
    syncFromServer().catchError((e) {
      debugPrint('UsageServiceImpl: Background sync error: $e');
    });
  }

  /// Handler for RevenueCat subscription changes.
  ///
  /// Only triggers sync when the subscription tier actually changes,
  /// with debouncing to prevent rapid consecutive syncs.
  void _onSubscriptionChanged() {
    final newTier = _revenueCat.currentTier;

    // Only sync if tier actually changed (not just offerings refresh, etc.)
    if (newTier == _lastKnownTier) {
      debugPrint('UsageServiceImpl: RevenueCat notified but tier unchanged');
      return;
    }

    debugPrint(
      'UsageServiceImpl: Tier changed from ${_lastKnownTier?.name} to ${newTier.name}',
    );
    _lastKnownTier = newTier;

    // Debounce: cancel any pending sync and schedule a new one
    _syncDebounceTimer?.cancel();
    _syncDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      _syncFromServerWithRetry();
    });
  }

  /// Sync from server with retry logic to handle Webhook delays.
  ///
  /// The RevenueCat SDK updates faster than the backend Webhook,
  /// so we retry if the backend tier doesn't match the expected tier.
  Future<void> _syncFromServerWithRetry({int retryCount = 0}) async {
    const maxRetries = 3;
    const retryDelay = Duration(seconds: 2);

    try {
      await syncFromServer();

      // Check if backend tier matches expected tier from RevenueCat
      final expectedTier = _revenueCat.currentTier;
      final cachedTier = _getTierFromCache();

      if (cachedTier != null &&
          expectedTier != cachedTier &&
          retryCount < maxRetries) {
        // Backend hasn't caught up yet (Webhook delay), retry
        debugPrint(
          'UsageServiceImpl: Tier mismatch (expected: ${expectedTier.name}, '
          'got: ${cachedTier.name}), retry ${retryCount + 1}/$maxRetries in 2s',
        );
        await Future.delayed(retryDelay);
        await _syncFromServerWithRetry(retryCount: retryCount + 1);
      } else if (cachedTier != null && expectedTier == cachedTier) {
        debugPrint(
          'UsageServiceImpl: Tier consistent with backend (${cachedTier.name})',
        );
      }
    } catch (e) {
      debugPrint('UsageServiceImpl: Sync with retry error: $e');
      // Fail silently - keep using local cache (Optimistic UI)
    }
  }

  /// Extract the subscription tier from the current cache.
  SubscriptionTier? _getTierFromCache() {
    final tierString = _memoryCache?.tier;
    if (tierString == null) return null;
    return SubscriptionTier.values.firstWhere(
      (t) => t.name == tierString,
      orElse: () => SubscriptionTier.free,
    );
  }

  // ============================================
  // New Quota-Aware API
  // ============================================

  @override
  FeatureQuotaStatus? getQuotaStatus(PaidFeature feature) {
    final featureKey = _getFeatureKey(feature);
    FeatureQuotaStatus? status;

    // Try memory cache first
    if (_memoryCache != null) {
      final cached = _memoryCache!.features[featureKey];
      if (cached != null) {
        status = _applyDailyReset(cached);
      }
    }

    // Fall back to disk cache
    status ??= _cacheProvider.getFeatureStatus(featureKey);

    if (status != null) {
      final remaining = status.limit == -1
          ? 'Unlimited'
          : (status.limit - status.used).toString();
      debugPrint(
        'UsageServiceImpl: 📊 Quota Status [${feature.name}]\n'
        '  • Used: ${status.used}\n'
        '  • Limit: ${status.limit == -1 ? "∞" : status.limit}\n'
        '  • Remaining: $remaining\n'
        '  • Period: ${status.period}',
      );
    } else {
      debugPrint(
        'UsageServiceImpl: ⚠️ Quota Status [${feature.name}] -> Not found (Defaulting to fallback)',
      );
    }

    return status;
  }

  @override
  int getQuotaLimit(PaidFeature feature) {
    final status = getQuotaStatus(feature);
    if (status != null) {
      return status.limit;
    }

    // Fall back to hardcoded defaults
    return _getFallbackLimit(feature);
  }

  @override
  bool canUse(PaidFeature feature) {
    final status = getQuotaStatus(feature);
    if (status == null) {
      // No cache, allow (fail-open for UX)
      return true;
    }
    return status.canUse;
  }

  @override
  Future<TrackUsageResult> trackUsage(
    PaidFeature feature, {
    int amount = 1,
  }) async {
    final featureKey = _getFeatureKey(feature);

    // 1. Optimistic local update
    final currentStatus = getQuotaStatus(feature);
    if (currentStatus != null && !currentStatus.canUse) {
      return TrackUsageResult.quotaExceeded();
    }

    final newUsed = (currentStatus?.used ?? 0) + amount;
    final period = currentStatus?.refreshRule == 'static'
        ? 'lifetime'
        : _getTodayUtcString();

    final optimisticStatus = FeatureQuotaStatus(
      used: newUsed,
      limit: currentStatus?.limit ?? _getFallbackLimit(feature),
      period: period,
      refreshRule: currentStatus?.refreshRule ?? 'daily',
    );

    // Update memory cache
    if (_memoryCache != null) {
      _memoryCache = _memoryCache!.copyWithFeature(
        featureKey,
        optimisticStatus,
      );
    }

    // Update disk cache (don't await, fire-and-forget for speed)
    _cacheProvider.updateFeature(featureKey, optimisticStatus);

    // 2. Async server sync
    try {
      final response = await _supabase.rpc(
        'track_feature_usage',
        params: {'feature': featureKey, 'amount': amount},
      );

      if (response is Map<String, dynamic>) {
        final success = response['success'] as bool? ?? false;
        final remaining = response['remaining'] as int? ?? 0;
        final message = response['message'] as String?;

        if (!success) {
          // Server rejected (quota exceeded)
          // Force update local state to match server
          debugPrint('UsageServiceImpl: Server rejected trackUsage: $message');

          // Reload from server to get accurate state
          await syncFromServer();

          return TrackUsageResult.failed(message ?? 'Quota exceeded');
        }

        return TrackUsageResult.succeeded(remaining);
      }

      return TrackUsageResult.succeeded(optimisticStatus.remaining);
    } catch (e) {
      // Network error - keep optimistic state (fail-open)
      debugPrint('UsageServiceImpl: trackUsage network error: $e');
      return TrackUsageResult.succeeded(optimisticStatus.remaining);
    }
  }

  @override
  Future<void> syncFromServer() async {
    try {
      debugPrint('UsageServiceImpl: Syncing from server...');

      final response = await _supabase.rpc('get_user_quota_status');

      if (response is! List) {
        debugPrint(
          'UsageServiceImpl: Unexpected response type: ${response.runtimeType}',
        );
        return;
      }

      final features = <String, FeatureQuotaStatus>{};
      for (final row in response) {
        if (row is Map<String, dynamic>) {
          final featureKey = row['feature_key'] as String?;
          if (featureKey == null) continue;

          features[featureKey] = FeatureQuotaStatus(
            used: row['used_count'] as int? ?? 0,
            limit: row['quota_limit'] as int? ?? 0,
            period: row['refresh_period'] == 'daily'
                ? _getTodayUtcString()
                : 'lifetime',
            refreshRule: row['refresh_period'] as String? ?? 'daily',
          );
        }
      }

      final currentTier = _revenueCat.currentTier.name;
      _memoryCache = FeatureQuotaCache(
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        tier: currentTier,
        features: features,
      );

      await _cacheProvider.saveCache(_memoryCache!);

      debugPrint(
        'UsageServiceImpl: Synced ${features.length} features from server',
      );
    } catch (e) {
      debugPrint('UsageServiceImpl: syncFromServer error: $e');
      // Fail silently - keep using local cache
    }
  }

  // ============================================
  // Helper Methods
  // ============================================

  /// Convert PaidFeature enum to database key.
  String _getFeatureKey(PaidFeature feature) {
    switch (feature) {
      case PaidFeature.dailyConversation:
        return 'daily_conversation';
      case PaidFeature.voiceInput:
        return 'voice_input';
      case PaidFeature.speechAssessment:
        return 'speech_assessment';
      case PaidFeature.wordPronunciation:
        return 'word_pronunciation';
      case PaidFeature.grammarAnalysis:
        return 'grammar_analysis';
      case PaidFeature.ttsSpeak:
        return 'tts_speak';
      case PaidFeature.customScenarios:
        return 'custom_scenarios';
      case PaidFeature.pitchAnalysis:
        return 'pitch_analysis';
    }
  }

  /// Apply daily reset if period is outdated.
  FeatureQuotaStatus _applyDailyReset(FeatureQuotaStatus status) {
    if (status.refreshRule != 'daily') return status;

    final todayUtc = _getTodayUtcString();
    if (status.period != todayUtc) {
      return status.copyWithUsed(0);
    }
    return status;
  }

  /// Get today's date as UTC string (YYYY-MM-DD).
  String _getTodayUtcString() {
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Fallback limits when cache is not available.
  int _getFallbackLimit(PaidFeature feature) {
    final tier = _revenueCat.currentTier;

    switch (feature) {
      case PaidFeature.dailyConversation:
      case PaidFeature.voiceInput:
      case PaidFeature.grammarAnalysis:
        if (tier == SubscriptionTier.pro || tier == SubscriptionTier.plus) {
          return -1;
        }
        return 3;

      case PaidFeature.speechAssessment:
        if (tier == SubscriptionTier.pro) return 100;
        if (tier == SubscriptionTier.plus) return 20;
        return 3;

      case PaidFeature.ttsSpeak:
        if (tier == SubscriptionTier.pro) return -1;
        if (tier == SubscriptionTier.plus) return 100;
        return 3;

      case PaidFeature.wordPronunciation:
        if (tier == SubscriptionTier.free) return 10;
        return -1; // Unlimited

      case PaidFeature.customScenarios:
        if (tier == SubscriptionTier.pro) return -1;
        if (tier == SubscriptionTier.plus) return 30;
        return 0; // Free cannot create

      case PaidFeature.pitchAnalysis:
        if (tier == SubscriptionTier.free) return 0;
        return -1; // Unlimited for Plus/Pro
    }
  }
}
