import 'package:frontend/features/subscription/domain/models/feature_quota_status.dart';
import 'package:frontend/features/subscription/domain/models/paid_feature.dart';

/// Service interface to track usage of paid features.
///
/// The implementation follows an **Optimistic UI** pattern:
/// 1. Local checks are synchronous and non-blocking
/// 2. Server sync happens asynchronously in the background
/// 3. Conflicts are resolved by server authority (server wins)
///
/// Implementation should be in data layer, connecting to:
/// - Supabase RPC for server-side quota management
/// - SharedPreferences for local caching (via FeatureQuotaCacheProvider)
/// - App lifecycle for resume-time sync
abstract class UsageService {
  // ============================================
  // New Quota-Aware API
  // ============================================

  /// Get the complete quota status for a feature.
  ///
  /// This is a **synchronous** operation that reads from local cache.
  /// Returns null if the feature is not found in cache.
  ///
  /// The returned status automatically handles daily reset:
  /// - If [refreshRule] is 'daily' and [period] is not today (UTC),
  ///   the [used] count is treated as 0.
  FeatureQuotaStatus? getQuotaStatus(PaidFeature feature);

  /// Get the quota limit for a feature.
  ///
  /// Returns -1 for unlimited, 0 for blocked, positive int for limit.
  /// Uses cached value, falls back to hardcoded defaults if not cached.
  int getQuotaLimit(PaidFeature feature);

  /// Check if the user can use a feature (quota not exhausted).
  ///
  /// This is a **synchronous, non-blocking** check using local cache.
  /// Automatically handles daily reset logic.
  bool canUse(PaidFeature feature);

  /// Track feature usage with optimistic update.
  ///
  /// This method:
  /// 1. **Immediately** increments the local cache (optimistic)
  /// 2. **Asynchronously** calls the server RPC to persist
  /// 3. **Handles conflicts** by accepting server authority
  ///
  /// Returns a [TrackUsageResult] with:
  /// - [success]: Whether the usage was allowed
  /// - [remaining]: Remaining quota after this usage
  /// - [message]: Error message if failed
  ///
  /// Even if the server request fails (network error), the local state
  /// is optimistically updated (fail-open for UX). The hard guard is
  /// on the backend API layer.
  Future<TrackUsageResult> trackUsage(PaidFeature feature, {int amount = 1});

  /// Force sync quota status from server.
  ///
  /// This should be called:
  /// - On app startup (after hydrating from local cache)
  /// - When app resumes from background
  /// - When subscription tier changes
  ///
  /// Returns silently on network errors (fail-safe).
  Future<void> syncFromServer();

  /// Check if the service is initialized and ready.
  bool get isInitialized;

  /// Initialize the service: load local cache, then sync from server.
  ///
  /// This should be called during app bootstrap.
  Future<void> initialize();
}
