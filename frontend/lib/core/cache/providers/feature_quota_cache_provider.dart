import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frontend/core/cache/cache_constants.dart';
import 'package:frontend/core/cache/cache_manager.dart';
import 'package:frontend/core/data/local/storage_key_service.dart';
import 'package:frontend/features/subscription/domain/models/feature_quota_status.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cache provider for feature quota data.
///
/// Stores user's feature usage limits and counts in SharedPreferences.
/// Follows the CacheManager architecture pattern.
///
/// Key format: {userId}_feature_quota_v1
/// Value format: JSON string of [FeatureQuotaCache]
class FeatureQuotaCacheProvider implements CacheProvider {
  final SharedPreferences _prefs;
  final StorageKeyService _storageKey;

  FeatureQuotaCacheProvider({
    required SharedPreferences prefs,
    required StorageKeyService storageKey,
  }) : _prefs = prefs,
       _storageKey = storageKey;

  @override
  CacheType get type => CacheType.featureQuota;

  /// Get the cache key for current user.
  String get _cacheKey =>
      _storageKey.getUserScopedKey(CacheConstants.featureQuotaPrefix);

  // ============================================
  // CacheProvider Interface
  // ============================================

  @override
  Future<bool> hasCache(String id) async {
    // For this provider, we just check if any quota data exists
    final key = _cacheKey;
    return _prefs.containsKey(key);
  }

  @override
  Future<void> clearCache(String? id) async {
    try {
      final key = _cacheKey;
      await _prefs.remove(key);
      debugPrint('FeatureQuotaCacheProvider: Cleared cache for key: $key');
    } catch (e) {
      debugPrint('FeatureQuotaCacheProvider: Error clearing cache: $e');
    }
  }

  @override
  Future<int> getCacheSize() async {
    try {
      final key = _cacheKey;
      final data = _prefs.getString(key);
      return data?.length ?? 0;
    } catch (e) {
      return 0;
    }
  }

  // ============================================
  // Quota-Specific Methods
  // ============================================

  /// Load quota cache from SharedPreferences.
  ///
  /// Returns null if no cache exists or if parsing fails.
  FeatureQuotaCache? loadCache() {
    try {
      final key = _cacheKey;
      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return FeatureQuotaCache.fromJson(json);
    } catch (e) {
      debugPrint('FeatureQuotaCacheProvider: Error loading cache: $e');
      return null;
    }
  }

  /// Save quota cache to SharedPreferences.
  Future<bool> saveCache(FeatureQuotaCache cache) async {
    try {
      final key = _cacheKey;
      final jsonString = jsonEncode(cache.toJson());
      await _prefs.setString(key, jsonString);
      debugPrint('FeatureQuotaCacheProvider: Saved cache to key: $key');
      return true;
    } catch (e) {
      debugPrint('FeatureQuotaCacheProvider: Error saving cache: $e');
      return false;
    }
  }

  /// Update a single feature in the cache.
  ///
  /// This is used for optimistic updates after trackUsage.
  Future<bool> updateFeature(
    String featureKey,
    FeatureQuotaStatus status,
  ) async {
    try {
      var cache = loadCache();
      if (cache == null) {
        debugPrint('FeatureQuotaCacheProvider: No cache to update');
        return false;
      }

      cache = cache.copyWithFeature(featureKey, status);
      return await saveCache(cache);
    } catch (e) {
      debugPrint('FeatureQuotaCacheProvider: Error updating feature: $e');
      return false;
    }
  }

  /// Get status for a single feature.
  ///
  /// Automatically handles daily reset:
  /// - If refreshRule is 'daily' and period is not today (UTC),
  ///   returns a copy with used = 0.
  FeatureQuotaStatus? getFeatureStatus(String featureKey) {
    final cache = loadCache();
    if (cache == null) return null;

    final status = cache.features[featureKey];
    if (status == null) return null;

    // Handle daily reset
    if (status.refreshRule == 'daily') {
      final todayUtc = _getTodayUtcString();
      if (status.period != todayUtc) {
        // Period is outdated, treat as reset
        return status.copyWithUsed(0);
      }
    }

    return status;
  }

  /// Get today's date as UTC string (YYYY-MM-DD).
  String _getTodayUtcString() {
    final now = DateTime.now().toUtc();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  /// Check if cached tier matches current tier.
  ///
  /// Returns false if cache is empty or tier doesn't match.
  bool isCacheTierValid(String currentTier) {
    final cache = loadCache();
    if (cache == null) return false;
    return cache.tier == currentTier;
  }
}
