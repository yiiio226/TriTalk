import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/shadowing_practice.dart';

/// Cache service for shadowing practice data
///
/// Uses SharedPreferences for local storage with cache key format:
/// `shadow_v2_{source_type}_{source_id}`
///
/// No user_id in cache key since local cache is inherently user-specific.
class ShadowingCacheService {
  static const String _cachePrefix = 'shadow_v2_';

  static final ShadowingCacheService _instance =
      ShadowingCacheService._internal();
  factory ShadowingCacheService() => _instance;
  ShadowingCacheService._internal();

  /// Generate cache key from source type and source id
  static String _generateKey(String sourceType, String sourceId) {
    return '$_cachePrefix${sourceType}_$sourceId';
  }

  /// Get cached practice data
  Future<ShadowingCacheData?> get(String sourceType, String sourceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _generateKey(sourceType, sourceId);
      final jsonString = prefs.getString(key);

      if (jsonString == null) return null;

      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return ShadowingCacheData.fromJson(json);
    } catch (e) {
      // If cache read fails, return null (will fetch from server)
      return null;
    }
  }

  /// Save practice data to cache
  Future<void> set(
    String sourceType,
    String sourceId,
    ShadowingCacheData data,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _generateKey(sourceType, sourceId);
      final jsonString = jsonEncode(data.toJson());
      await prefs.setString(key, jsonString);
    } catch (e) {
      // Silently fail on cache write errors
    }
  }

  /// Remove cached data for a specific source
  Future<void> remove(String sourceType, String sourceId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _generateKey(sourceType, sourceId);
      await prefs.remove(key);
    } catch (e) {
      // Silently fail on cache remove errors
    }
  }

  /// Clear all shadow cache (for logout, etc.)
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      for (final key in allKeys) {
        if (key.startsWith(_cachePrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      // Silently fail on cache clear errors
    }
  }
}

/// Data structure for cached shadowing practice
///
/// Stores the practice result along with timestamp metadata
class ShadowingCacheData {
  final ShadowingPractice practice;
  final DateTime practicedAt;
  final DateTime?
  syncedAt; // When this was synced to cloud (null if not synced)

  ShadowingCacheData({
    required this.practice,
    required this.practicedAt,
    this.syncedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'practice': practice.toJson(),
      'practiced_at': practicedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  factory ShadowingCacheData.fromJson(Map<String, dynamic> json) {
    return ShadowingCacheData(
      practice: ShadowingPractice.fromJson(json['practice']),
      practicedAt: DateTime.parse(json['practiced_at']),
      syncedAt: json['synced_at'] != null
          ? DateTime.parse(json['synced_at'])
          : null,
    );
  }
}
