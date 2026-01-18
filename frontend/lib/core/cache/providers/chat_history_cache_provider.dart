import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cache_manager.dart';
import '../cache_constants.dart';
import '../../data/local/storage_key_service.dart';

/// Cache provider for chat history data.
///
/// Uses SharedPreferences with key format: {userId}_chat_history_{sceneKey}
/// Data is stored as JSON strings containing message arrays.
class ChatHistoryCacheProvider implements CacheProvider {
  @override
  CacheType get type => CacheType.chatHistory;

  /// Get the full cache key for a scene.
  String _getFullKey(String sceneKey) {
    final storageKey = StorageKeyService();
    return storageKey.getUserScopedKey(
      '${CacheConstants.chatHistoryPrefix}$sceneKey',
    );
  }

  @override
  Future<bool> hasCache(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = _getFullKey(id);
      return prefs.containsKey(key);
    } catch (e) {
      debugPrint('ChatHistoryCacheProvider: Error checking cache: $e');
      return false;
    }
  }

  @override
  Future<void> clearCache(String? id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = StorageKeyService();

      if (id != null) {
        // Clear specific scene's chat history
        final key = _getFullKey(id);
        final updatedAtKey = storageKey.getUserScopedKey(
          '${CacheConstants.chatHistoryPrefix}${id}_updated_at',
        );
        await prefs.remove(key);
        await prefs.remove(updatedAtKey);
        debugPrint('ChatHistoryCacheProvider: Removed cache for scene: $id');
      } else {
        // Clear all chat history for current user
        final allKeys = prefs.getKeys().toList();
        final userId = storageKey.currentUserId;
        final prefix = '${userId}_${CacheConstants.chatHistoryPrefix}';

        for (final key in allKeys) {
          if (key.startsWith(prefix)) {
            await prefs.remove(key);
          }
        }
        debugPrint('ChatHistoryCacheProvider: Cleared all chat history cache');
      }
    } catch (e) {
      debugPrint('ChatHistoryCacheProvider: Error clearing cache: $e');
    }
  }

  @override
  Future<int> getCacheSize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final storageKey = StorageKeyService();
      final userId = storageKey.currentUserId;
      final prefix = '${userId}_${CacheConstants.chatHistoryPrefix}';
      int totalSize = 0;

      for (final key in allKeys) {
        if (key.startsWith(prefix)) {
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
      debugPrint('ChatHistoryCacheProvider: Error getting cache size: $e');
      return 0;
    }
  }

  /// Get the count of cached scenes.
  Future<int> getCacheCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allKeys = prefs.getKeys();
      final storageKey = StorageKeyService();
      final userId = storageKey.currentUserId;
      final prefix = '${userId}_${CacheConstants.chatHistoryPrefix}';

      // Count unique scenes (exclude _updated_at keys)
      return allKeys
          .where(
            (key) => key.startsWith(prefix) && !key.endsWith('_updated_at'),
          )
          .length;
    } catch (e) {
      debugPrint('ChatHistoryCacheProvider: Error getting cache count: $e');
      return 0;
    }
  }
}
