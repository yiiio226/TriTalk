import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service to generate user-scoped storage keys for local data isolation.
/// This ensures that when users switch accounts, their local data is separated.
class StorageKeyService {
  static final StorageKeyService _instance = StorageKeyService._internal();
  factory StorageKeyService() => _instance;
  StorageKeyService._internal();

  final _supabase = Supabase.instance.client;

  static const String _migrationCompleteKey = 'storage_migration_v1_complete';

  /// Get the current user's ID, or 'anonymous' if not logged in.
  String get currentUserId => _supabase.auth.currentUser?.id ?? 'anonymous';

  /// Generate a user-scoped key for SharedPreferences.
  /// Format: {userId}_{baseKey}
  /// Example: 'abc123_chat_history_scene1'
  String getUserScopedKey(String baseKey) {
    return '${currentUserId}_$baseKey';
  }

  /// Generate a user-scoped directory path for file storage.
  /// Format: {basePath}/{userId}/{subPath}
  /// Example: '/Documents/abc123/tts_cache/message.mp3'
  String getUserScopedPath(String basePath, String subPath) {
    return '$basePath/$currentUserId/$subPath';
  }

  /// Check if the user is currently authenticated.
  bool get isAuthenticated => _supabase.auth.currentUser != null;

  /// List of all base keys that need migration.
  /// These are the old keys without userId prefix.
  static const List<String> _keysToMigrate = [
    'bookmarked_conversations',
    'custom_scenes_v1',
    'scene_order_v1',
    'scene_activity_v1',
    'hidden_standard_scenes',
    'vocab_items_v2',
    'saved_sentences',
    'saved_vocabulary',
    'native_language',
    'target_language',
  ];

  /// Prefix patterns for chat history keys that need migration.
  /// These match keys like 'chat_history_scene1' and 'chat_history_scene1_updated_at'.
  static const List<String> _chatHistoryPrefixes = ['chat_history_'];

  /// Migrate old storage keys (without userId prefix) to new user-scoped keys.
  /// This should be called once after user login.
  /// Returns true if migration was performed, false if already migrated.
  Future<bool> migrateOldDataIfNeeded() async {
    if (!isAuthenticated) {
      debugPrint('StorageKeyService: Cannot migrate - user not authenticated');
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = currentUserId;
    final userMigrationKey = '${userId}_$_migrationCompleteKey';

    // Check if migration already completed for this user
    if (prefs.getBool(userMigrationKey) == true) {
      debugPrint(
        'StorageKeyService: Migration already complete for user $userId',
      );
      return false;
    }

    debugPrint('StorageKeyService: Starting migration for user $userId');
    int migratedCount = 0;

    // 1. Migrate known static keys
    for (final baseKey in _keysToMigrate) {
      if (await _migrateKey(prefs, baseKey, userId)) {
        migratedCount++;
      }
    }

    // 2. Migrate dynamic chat history keys
    final allKeys = prefs.getKeys();
    for (final oldKey in allKeys) {
      // Skip keys that already have a userId prefix (contain underscore after UUID pattern)
      if (_isAlreadyUserScoped(oldKey)) {
        continue;
      }

      // Check if it's a chat history key
      for (final prefix in _chatHistoryPrefixes) {
        if (oldKey.startsWith(prefix)) {
          if (await _migrateKey(prefs, oldKey, userId)) {
            migratedCount++;
          }
          break;
        }
      }
    }

    // 3. Migrate TTS cache directory
    await _migrateTtsCacheDirectory(userId);

    // Mark migration as complete for this user
    await prefs.setBool(userMigrationKey, true);

    debugPrint(
      'StorageKeyService: Migration complete. Migrated $migratedCount keys for user $userId',
    );
    return migratedCount > 0;
  }

  /// Check if a key already has a userId prefix.
  bool _isAlreadyUserScoped(String key) {
    // UUID pattern: 8-4-4-4-12 hex characters
    // Check if key starts with a UUID-like pattern followed by underscore
    final uuidPattern = RegExp(
      r'^[a-f0-9]{8}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{4}-[a-f0-9]{12}_',
    );
    return uuidPattern.hasMatch(key);
  }

  /// Migrate a single key from old format to new user-scoped format.
  Future<bool> _migrateKey(
    SharedPreferences prefs,
    String oldKey,
    String userId,
  ) async {
    final newKey = '${userId}_$oldKey';

    // Check if old key exists
    if (!prefs.containsKey(oldKey)) {
      return false;
    }

    // Check if new key already exists (don't overwrite)
    if (prefs.containsKey(newKey)) {
      debugPrint(
        'StorageKeyService: New key already exists, skipping: $newKey',
      );
      return false;
    }

    // Get the value from old key
    final Object? value = prefs.get(oldKey);
    if (value == null) {
      return false;
    }

    // Copy to new key based on type
    if (value is String) {
      await prefs.setString(newKey, value);
    } else if (value is int) {
      await prefs.setInt(newKey, value);
    } else if (value is double) {
      await prefs.setDouble(newKey, value);
    } else if (value is bool) {
      await prefs.setBool(newKey, value);
    } else if (value is List<String>) {
      await prefs.setStringList(newKey, value);
    } else {
      debugPrint(
        'StorageKeyService: Unknown type for key $oldKey: ${value.runtimeType}',
      );
      return false;
    }

    debugPrint('StorageKeyService: Migrated $oldKey -> $newKey');

    // Note: We don't delete the old key to allow rollback if needed
    // Old keys can be cleaned up in a future version

    return true;
  }

  /// Migrate old TTS cache directory to user-scoped directory.
  Future<void> _migrateTtsCacheDirectory(String userId) async {
    try {
      final cacheDir = await getApplicationDocumentsDirectory();
      final oldTtsDir = Directory('${cacheDir.path}/tts_cache');
      final newTtsDir = Directory('${cacheDir.path}/$userId/tts_cache');

      if (await oldTtsDir.exists() && !await newTtsDir.exists()) {
        // Create new user-scoped directory
        await newTtsDir.create(recursive: true);

        // Copy files from old directory to new
        await for (final entity in oldTtsDir.list()) {
          if (entity is File) {
            final fileName = entity.path.split('/').last;
            await entity.copy('${newTtsDir.path}/$fileName');
          }
        }

        debugPrint('StorageKeyService: Migrated TTS cache directory');
        // Note: We don't delete the old directory to allow rollback
      }
    } catch (e) {
      debugPrint('StorageKeyService: Error migrating TTS cache: $e');
    }
  }

  /// Clean up old migration data (call this in a future version when confident).
  /// This removes the old keys without userId prefix.
  Future<void> cleanupOldData() async {
    final prefs = await SharedPreferences.getInstance();

    // Remove known static keys
    for (final baseKey in _keysToMigrate) {
      if (prefs.containsKey(baseKey)) {
        await prefs.remove(baseKey);
        debugPrint('StorageKeyService: Removed old key: $baseKey');
      }
    }

    // Remove dynamic chat history keys (without userId prefix)
    final allKeys = prefs
        .getKeys()
        .toList(); // Create a copy to avoid modification during iteration
    for (final oldKey in allKeys) {
      if (_isAlreadyUserScoped(oldKey)) {
        continue;
      }
      for (final prefix in _chatHistoryPrefixes) {
        if (oldKey.startsWith(prefix)) {
          await prefs.remove(oldKey);
          debugPrint('StorageKeyService: Removed old key: $oldKey');
          break;
        }
      }
    }

    // Remove old TTS cache directory
    try {
      final cacheDir = await getApplicationDocumentsDirectory();
      final oldTtsDir = Directory('${cacheDir.path}/tts_cache');
      if (await oldTtsDir.exists()) {
        await oldTtsDir.delete(recursive: true);
        debugPrint('StorageKeyService: Removed old TTS cache directory');
      }
    } catch (e) {
      debugPrint('StorageKeyService: Error removing old TTS cache: $e');
    }
  }
}
