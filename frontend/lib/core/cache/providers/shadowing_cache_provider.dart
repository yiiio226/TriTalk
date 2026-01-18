import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cache_manager.dart';

/// Cache provider for shadowing practice data.
///
/// Uses SharedPreferences with key format: shadow_v2_{sourceType}_{sourceId}
/// Data is stored as JSON strings containing practice results.
class ShadowingCacheProvider implements CacheProvider {
  static const String _cachePrefix = 'shadow_v2_';

  @override
  CacheType get type => CacheType.shadowCache;

  @override
  Future<bool> hasCache(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // id format: "{sourceType}_{sourceId}"
      final key = '$_cachePrefix$id';
      return prefs.containsKey(key);
    } catch (e) {
      debugPrint('ShadowingCacheProvider: Error checking cache: $e');
      return false;
    }
  }

  /// Check if cache exists for a specific source type and id.
  Future<bool> hasCacheForSource(String sourceType, String sourceId) async {
    return hasCache('${sourceType}_$sourceId');
  }

  @override
  Future<void> clearCache(String? id) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (id != null) {
        // Clear specific key
        final key = '$_cachePrefix$id';
        await prefs.remove(key);
        debugPrint('ShadowingCacheProvider: Removed cache key: $key');
      } else {
        // Clear all shadow cache keys
        final allKeys = prefs.getKeys();
        for (final key in allKeys) {
          if (key.startsWith(_cachePrefix)) {
            await prefs.remove(key);
          }
        }
        debugPrint('ShadowingCacheProvider: Cleared all shadow cache');
      }
    } catch (e) {
      debugPrint('ShadowingCacheProvider: Error clearing cache: $e');
    }
  }

  @override
  Future<int> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      int totalSize = 0;

      for (final key in allKeys) {
        if (key.startsWith(_cachePrefix)) {
          final value = prefs.getString(key);
          if (value != null) {
            // Estimate size: string length in UTF-8 bytes + key length
            totalSize += utf8.encode(value).length;
            totalSize += utf8.encode(key).length;
          }
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('ShadowingCacheProvider: Error getting cache size: $e');
      return 0;
    }
  }

  /// Get the count of cached items.
  Future<int> getCacheCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      return allKeys.where((key) => key.startsWith(_cachePrefix)).length;
    } catch (e) {
      debugPrint('ShadowingCacheProvider: Error getting cache count: $e');
      return 0;
    }
  }
}
