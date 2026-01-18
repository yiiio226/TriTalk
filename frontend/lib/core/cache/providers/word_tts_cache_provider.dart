import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../cache_manager.dart';

/// Cache provider for word pronunciation audio files.
///
/// Manages the cache directory: {documentsDir}/word_tts_cache/{language}/
/// Files are named using MD5 hash: {hash}.wav
class WordTtsCacheProvider implements CacheProvider {
  @override
  CacheType get type => CacheType.wordTts;

  /// Get the base word TTS cache directory.
  Future<Directory> _getBaseCacheDir() async {
    final cacheDir = await getApplicationDocumentsDirectory();
    return Directory('${cacheDir.path}/word_tts_cache');
  }

  /// Get cache directory for a specific language.
  Future<Directory> _getLangCacheDir(String language) async {
    final baseDir = await _getBaseCacheDir();
    return Directory('${baseDir.path}/$language');
  }

  /// Generate cache key for a word (MD5 hash, first 16 chars).
  String _getCacheKey(String word) {
    final bytes = utf8.encode(word.toLowerCase().trim());
    final digest = md5.convert(bytes);
    return digest.toString().substring(0, 16);
  }

  @override
  Future<bool> hasCache(String id) async {
    try {
      // id format: "{language}:{word}" or just "{word}" (defaults to en-US)
      final parts = id.split(':');
      final language = parts.length > 1 ? parts[0] : 'en-US';
      final word = parts.length > 1 ? parts[1] : parts[0];

      final langDir = await _getLangCacheDir(language);
      final cacheKey = _getCacheKey(word);
      final file = File('${langDir.path}/$cacheKey.wav');
      return file.existsSync();
    } catch (e) {
      debugPrint('WordTtsCacheProvider: Error checking cache: $e');
      return false;
    }
  }

  /// Check if cache exists for a specific word and language.
  Future<bool> hasCacheForWord(String word, {String language = 'en-US'}) async {
    return hasCache('$language:$word');
  }

  /// Get cache file path for a specific word.
  Future<String?> getCachePath(String word, {String language = 'en-US'}) async {
    try {
      final langDir = await _getLangCacheDir(language);
      final cacheKey = _getCacheKey(word);
      final file = File('${langDir.path}/$cacheKey.wav');
      if (await file.exists()) {
        return file.path;
      }
      return null;
    } catch (e) {
      debugPrint('WordTtsCacheProvider: Error getting cache path: $e');
      return null;
    }
  }

  @override
  Future<void> clearCache(String? id) async {
    try {
      if (id != null) {
        // Clear specific word cache
        final parts = id.split(':');
        final language = parts.length > 1 ? parts[0] : 'en-US';
        final word = parts.length > 1 ? parts[1] : parts[0];

        final langDir = await _getLangCacheDir(language);
        final cacheKey = _getCacheKey(word);
        final file = File('${langDir.path}/$cacheKey.wav');
        if (await file.exists()) {
          await file.delete();
          debugPrint('WordTtsCacheProvider: Deleted cache file: $cacheKey.wav');
        }
      } else {
        // Clear all word TTS cache
        final baseDir = await _getBaseCacheDir();
        if (await baseDir.exists()) {
          await baseDir.delete(recursive: true);
          debugPrint('WordTtsCacheProvider: Cleared all word TTS cache');
        }
      }
    } catch (e) {
      debugPrint('WordTtsCacheProvider: Error clearing cache: $e');
    }
  }

  /// Clear cache for a specific language.
  Future<void> clearCacheForLanguage(String language) async {
    try {
      final langDir = await _getLangCacheDir(language);
      if (await langDir.exists()) {
        await langDir.delete(recursive: true);
        debugPrint(
          'WordTtsCacheProvider: Cleared cache for language: $language',
        );
      }
    } catch (e) {
      debugPrint('WordTtsCacheProvider: Error clearing language cache: $e');
    }
  }

  @override
  Future<int> getCacheSize() async {
    try {
      final baseDir = await _getBaseCacheDir();
      if (!await baseDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in baseDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.wav')) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('WordTtsCacheProvider: Error getting cache size: $e');
      return 0;
    }
  }

  /// Get cache size for a specific language.
  Future<int> getCacheSizeForLanguage(String language) async {
    try {
      final langDir = await _getLangCacheDir(language);
      if (!await langDir.exists()) return 0;

      int totalSize = 0;
      await for (final entity in langDir.list()) {
        if (entity is File && entity.path.endsWith('.wav')) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('WordTtsCacheProvider: Error getting language cache size: $e');
      return 0;
    }
  }

  /// Get the count of cached files.
  Future<int> getCacheCount() async {
    try {
      final baseDir = await _getBaseCacheDir();
      if (!await baseDir.exists()) return 0;

      int count = 0;
      await for (final entity in baseDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.wav')) {
          count++;
        }
      }
      return count;
    } catch (e) {
      debugPrint('WordTtsCacheProvider: Error getting cache count: $e');
      return 0;
    }
  }
}
