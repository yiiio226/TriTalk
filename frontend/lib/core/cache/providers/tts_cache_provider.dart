import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../cache_manager.dart';
import '../cache_constants.dart';
import '../../data/local/storage_key_service.dart';

/// Cache provider for TTS audio files.
///
/// Manages the cache directory: {documentsDir}/{userId}/tts_cache/
/// Files are named using messageId: {messageId}.wav
class TtsCacheProvider implements CacheProvider {
  @override
  CacheType get type => CacheType.ttsCache;

  /// Get the TTS cache directory for the current user.
  Future<Directory> _getCacheDir() async {
    final cacheDir = await getApplicationDocumentsDirectory();
    final storageKey = StorageKeyService();
    return Directory(
      storageKey.getUserScopedPath(cacheDir.path, CacheConstants.ttsCacheDir),
    );
  }

  @override
  Future<bool> hasCache(String id) async {
    try {
      final cacheDir = await _getCacheDir();
      final safeFileName = id.replaceAll(RegExp(r'[^a-zA-Z0-9-_]'), '_');
      final file = File('${cacheDir.path}/$safeFileName.wav');
      return file.existsSync();
    } catch (e) {
      debugPrint('TtsCacheProvider: Error checking cache: $e');
      return false;
    }
  }

  /// Get the cache file path for a specific id.
  /// Returns null if the file doesn't exist.
  Future<String?> getCachePath(String id) async {
    try {
      final cacheDir = await _getCacheDir();
      final safeFileName = id.replaceAll(RegExp(r'[^a-zA-Z0-9-_]'), '_');
      final file = File('${cacheDir.path}/$safeFileName.wav');
      if (await file.exists()) {
        return file.path;
      }
      return null;
    } catch (e) {
      debugPrint('TtsCacheProvider: Error getting cache path: $e');
      return null;
    }
  }

  @override
  Future<void> clearCache(String? id) async {
    try {
      final cacheDir = await _getCacheDir();
      if (!await cacheDir.exists()) return;

      if (id != null) {
        // Clear specific file
        final safeFileName = id.replaceAll(RegExp(r'[^a-zA-Z0-9-_]'), '_');
        final file = File('${cacheDir.path}/$safeFileName.wav');
        if (await file.exists()) {
          await file.delete();
          debugPrint('TtsCacheProvider: Deleted cache file: $safeFileName.wav');
        }
      } else {
        // Clear all files in directory
        await for (final entity in cacheDir.list()) {
          if (entity is File && entity.path.endsWith('.wav')) {
            await entity.delete();
          }
        }
        debugPrint('TtsCacheProvider: Cleared all TTS cache');
      }
    } catch (e) {
      debugPrint('TtsCacheProvider: Error clearing cache: $e');
    }
  }

  @override
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDir();
      if (!await cacheDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in cacheDir.list()) {
        if (entity is File && entity.path.endsWith('.wav')) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('TtsCacheProvider: Error getting cache size: $e');
      return 0;
    }
  }

  /// Get the count of cached files.
  Future<int> getCacheCount() async {
    try {
      final cacheDir = await _getCacheDir();
      if (!await cacheDir.exists()) return 0;

      int count = 0;
      await for (final entity in cacheDir.list()) {
        if (entity is File && entity.path.endsWith('.wav')) {
          count++;
        }
      }
      return count;
    } catch (e) {
      debugPrint('TtsCacheProvider: Error getting cache count: $e');
      return 0;
    }
  }
}
