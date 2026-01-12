import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../models/message.dart';
import '../../scenes/data/scene_service.dart';
import '../../../core/data/local/storage_key_service.dart';

enum SyncStatus { synced, syncing, offline }

class ChatHistoryService {
  static final ChatHistoryService _instance = ChatHistoryService._internal();
  factory ChatHistoryService() => _instance;
  ChatHistoryService._internal() {
    _loadBookmarks();
  }

  final _supabase = Supabase.instance.client;

  // Sync status notifier
  final syncStatus = ValueNotifier<SyncStatus>(SyncStatus.synced);

  // Local cache
  final Map<String, List<Message>> _histories = {};
  final List<BookmarkedConversation> _bookmarks = [];
  final bookmarksNotifier = ValueNotifier<List<BookmarkedConversation>>([]);

  // Load messages for a scene (local first, then cloud)
  Future<List<Message>> getMessages(String sceneKey) async {
    // Return from cache if available
    if (_histories.containsKey(sceneKey)) {
      return List.from(_histories[sceneKey]!);
    }

    // Try to load from local storage first
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = StorageKeyService();
      final key = storageKey.getUserScopedKey('chat_history_$sceneKey');
      final jsonString = prefs.getString(key);

      if (jsonString != null) {
        final List<dynamic> messagesJson = json.decode(jsonString);
        final messages = messagesJson
            .map((json) => Message.fromJson(json as Map<String, dynamic>))
            .toList();
        _histories[sceneKey] = messages;

        // Try to sync from cloud in background (don't wait)
        _loadFromCloud(sceneKey);

        return List.from(messages);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading from local storage: $e');
      }
    }

    // Try to load from Supabase as fallback
    await _loadFromCloud(sceneKey);

    return List.from(_histories[sceneKey] ?? []);
  }

  // Force refresh from cloud with smart timeout fallback
  // Use this when opening chat screens to ensure fresh data from other devices
  // Falls back to local cache after 2s timeout for better offline experience
  Future<List<Message>> getMessagesWithSync(String sceneKey) async {
    // First, try to load from local storage to have fallback data ready
    List<Message> localMessages = [];

    if (_histories.containsKey(sceneKey)) {
      localMessages = List.from(_histories[sceneKey]!);
    } else {
      // Load from SharedPreferences if not in memory cache
      try {
        final prefs = await SharedPreferences.getInstance();
        final storageKey = StorageKeyService();
        final key = storageKey.getUserScopedKey('chat_history_$sceneKey');
        final jsonString = prefs.getString(key);

        if (jsonString != null) {
          final List<dynamic> messagesJson = json.decode(jsonString);
          localMessages = messagesJson
              .map((json) => Message.fromJson(json as Map<String, dynamic>))
              .toList();
          _histories[sceneKey] = localMessages;
        }
      } catch (e) {
        debugPrint('Error loading local messages: $e');
      }
    }

    // Try to sync from cloud with short timeout (2 seconds)
    // This balances fresh data with good offline/slow network experience
    try {
      await _loadFromCloud(sceneKey).timeout(
        const Duration(seconds: 2),
        onTimeout: () {
          debugPrint('Cloud sync timeout for $sceneKey, using local cache');
          // Continue with background sync (don't await)
          _loadFromCloud(sceneKey)
              .then((_) {
                debugPrint('Background sync completed for $sceneKey');
              })
              .catchError((e) {
                debugPrint('Background sync failed: $e');
              });
        },
      );
    } catch (e) {
      debugPrint('Cloud sync failed for $sceneKey: $e, using local cache');
    }

    // Return the latest data (either from successful cloud sync or local cache)
    return List.from(_histories[sceneKey] ?? localMessages);
  }

  // Load from cloud (background operation)
  Future<void> _loadFromCloud(String sceneKey) async {
    try {
      syncStatus.value = SyncStatus.syncing;
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        syncStatus.value = SyncStatus.synced;
        return;
      }

      final response = await _supabase
          .from('chat_history')
          .select('messages, updated_at')
          .eq('user_id', userId)
          .eq('scene_key', sceneKey)
          .maybeSingle()
          .timeout(const Duration(seconds: 5)); // Add timeout

      final localMessages = _histories[sceneKey] ?? [];

      // IMPROVED MERGE STRATEGY with timestamp-based conflict resolution
      if (response != null && response['messages'] != null) {
        final List<dynamic> messagesJson = response['messages'];
        final cloudMessages = messagesJson
            .map((json) => Message.fromJson(json as Map<String, dynamic>))
            .toList();

        // Get cloud update timestamp
        final cloudUpdatedAt = response['updated_at'] != null
            ? DateTime.parse(response['updated_at'] as String)
            : null;

        // Get local update timestamp from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final storageKey = StorageKeyService();
        final localUpdatedAtStr = prefs.getString(
          storageKey.getUserScopedKey('chat_history_${sceneKey}_updated_at'),
        );
        final localUpdatedAt = localUpdatedAtStr != null
            ? DateTime.parse(localUpdatedAtStr)
            : null;

        // Decision logic:
        // 1. If cloud has timestamp and it's newer, trust cloud
        // 2. If cloud has more or equal messages, use cloud
        // 3. If local has more messages but cloud is newer, trust cloud (deletion case)
        // 4. Otherwise keep local

        if (cloudUpdatedAt != null && localUpdatedAt != null) {
          // Both have timestamps - use the newer one
          if (cloudUpdatedAt.isAfter(localUpdatedAt) ||
              cloudUpdatedAt.isAtSameMomentAs(localUpdatedAt)) {
            _histories[sceneKey] = cloudMessages;
            await _saveToLocal(sceneKey, cloudMessages);
            await prefs.setString(
              storageKey.getUserScopedKey(
                'chat_history_${sceneKey}_updated_at',
              ),
              cloudUpdatedAt.toIso8601String(),
            );
            debugPrint(
              'Cloud is newer, using cloud data (${cloudMessages.length} messages)',
            );
          } else {
            debugPrint(
              'Local is newer, keeping local data (${localMessages.length} messages)',
            );
          }
        } else if (cloudMessages.length >= localMessages.length) {
          // No timestamp or cloud has more/equal messages
          _histories[sceneKey] = cloudMessages;
          await _saveToLocal(sceneKey, cloudMessages);
          if (cloudUpdatedAt != null) {
            final storageKeyForTimestamp = StorageKeyService();
            await prefs.setString(
              storageKeyForTimestamp.getUserScopedKey(
                'chat_history_${sceneKey}_updated_at',
              ),
              cloudUpdatedAt.toIso8601String(),
            );
          }
        } else {
          // Local has more data and no timestamp to compare
          debugPrint(
            'Local has more messages (${localMessages.length}) than cloud (${cloudMessages.length}), keeping local',
          );
        }
      } else {
        // Cloud returned null/empty - this could mean explicit deletion
        // Check if there's a record in the database at all
        final checkResponse = await _supabase
            .from('chat_history')
            .select('id')
            .eq('user_id', userId)
            .eq('scene_key', sceneKey)
            .maybeSingle();

        if (checkResponse == null) {
          // No record exists in cloud - this is an explicit deletion
          // Clear local data to sync with cloud deletion
          _histories.remove(sceneKey);
          await _saveToLocal(sceneKey, []);
          final prefsForDelete = await SharedPreferences.getInstance();
          final storageKeyForDelete = StorageKeyService();
          await prefsForDelete.remove(
            storageKeyForDelete.getUserScopedKey(
              'chat_history_${sceneKey}_updated_at',
            ),
          );
          debugPrint(
            'Cloud has no record - clearing local data (explicit deletion)',
          );
        } else {
          // Record exists but messages is null/empty - keep local if it has data
          debugPrint(
            'Cloud record exists but empty, keeping local data if available',
          );
        }
      }

      syncStatus.value = SyncStatus.synced;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading from cloud (non-critical): $e');
      }
      syncStatus.value = SyncStatus.offline;
    }
  }

  // Sync entire message list to cloud (recommended method)
  Future<void> syncMessages(String sceneKey, List<Message> messages) async {
    // Update cache
    _histories[sceneKey] = List.from(messages);

    // Save to local storage immediately (always succeeds)
    await _saveToLocal(sceneKey, messages);

    // Move scene to top on local activity
    SceneService().moveSceneToTop(sceneKey);

    // Sync to cloud
    syncStatus.value = SyncStatus.syncing;
    _syncToCloud(sceneKey)
        .then((_) {
          syncStatus.value = SyncStatus.synced;
        })
        .catchError((e) {
          if (kDebugMode) {
            debugPrint('Background cloud sync failed (non-critical): $e');
          }
          syncStatus.value = SyncStatus.offline;
        });
  }

  // Save to local storage
  Future<void> _saveToLocal(String sceneKey, List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = StorageKeyService();
      final key = storageKey.getUserScopedKey('chat_history_$sceneKey');
      final messagesJson = messages.map((m) => m.toJson()).toList();
      await prefs.setString(key, json.encode(messagesJson));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving to local storage: $e');
      }
    }
  }

  // Add message (deprecated - use syncMessages)
  Future<void> addMessage(String sceneKey, Message message) async {
    if (!_histories.containsKey(sceneKey)) {
      await getMessages(sceneKey);
    }

    _histories[sceneKey]!.add(message);
    await _saveToLocal(sceneKey, _histories[sceneKey]!);

    // Move scene to top when new message is added
    SceneService().moveSceneToTop(sceneKey);

    syncStatus.value = SyncStatus.syncing;
    _syncToCloud(sceneKey)
        .then((_) {
          syncStatus.value = SyncStatus.synced;
        })
        .catchError((e) {
          if (kDebugMode) {
            debugPrint('Sync failed: $e');
          }
          syncStatus.value = SyncStatus.offline;
        });
  }

  // Update message (deprecated - use syncMessages)
  Future<void> updateMessage(
    String sceneKey,
    int index,
    Message message,
  ) async {
    if (_histories.containsKey(sceneKey) &&
        index >= 0 &&
        index < _histories[sceneKey]!.length) {
      _histories[sceneKey]![index] = message;
      await _saveToLocal(sceneKey, _histories[sceneKey]!);

      // Move scene to top when message is updated (e.g., AI response completed)
      SceneService().moveSceneToTop(sceneKey);

      syncStatus.value = SyncStatus.syncing;
      _syncToCloud(sceneKey)
          .then((_) {
            syncStatus.value = SyncStatus.synced;
          })
          .catchError((e) {
            if (kDebugMode) {
              debugPrint('Sync failed: $e');
            }
            syncStatus.value = SyncStatus.offline;
          });
    }
  }

  // Clear history locally and in cloud
  Future<void> clearHistory(String sceneKey) async {
    _histories.remove(sceneKey);

    // Clear from local storage including timestamp
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = StorageKeyService();
      await prefs.remove(storageKey.getUserScopedKey('chat_history_$sceneKey'));
      await prefs.remove(
        storageKey.getUserScopedKey('chat_history_${sceneKey}_updated_at'),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing local storage: $e');
      }
    }

    // Try to clear from cloud - DELETE the entire record
    // This ensures other devices recognize it as an explicit deletion
    syncStatus.value = SyncStatus.syncing;
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _supabase
            .from('chat_history')
            .delete()
            .eq('user_id', userId)
            .eq('scene_key', sceneKey)
            .timeout(const Duration(seconds: 5));

        debugPrint('Cleared conversation from cloud: $sceneKey');
      }
      syncStatus.value = SyncStatus.synced;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error clearing from cloud (non-critical): $e');
      }
      syncStatus.value = SyncStatus.offline;
    }
  }

  // Delete specific messages locally and in cloud
  Future<void> deleteMessages(String sceneKey, List<String> messageIds) async {
    if (messageIds.isEmpty) return;

    // Remove messages from local cache
    if (_histories.containsKey(sceneKey)) {
      _histories[sceneKey] = _histories[sceneKey]!
          .where((msg) => !messageIds.contains(msg.id))
          .toList();

      // Save updated list to local storage
      await _saveToLocal(sceneKey, _histories[sceneKey]!);
    }

    // Try to delete from cloud
    syncStatus.value = SyncStatus.syncing;
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        // Fetch current messages from cloud
        final response = await _supabase
            .from('chat_history')
            .select('messages')
            .eq('user_id', userId)
            .eq('scene_key', sceneKey)
            .maybeSingle()
            .timeout(const Duration(seconds: 5));

        if (response != null && response['messages'] != null) {
          final List<dynamic> messagesJson = response['messages'];
          final cloudMessages = messagesJson
              .map((json) => Message.fromJson(json as Map<String, dynamic>))
              .toList();

          // Filter out deleted messages
          final filteredMessages = cloudMessages
              .where((msg) => !messageIds.contains(msg.id))
              .toList();

          // Update cloud with filtered messages
          final messagesJsonFiltered = filteredMessages
              .map((m) => m.toJson())
              .toList();
          final now = DateTime.now();

          await _supabase
              .from('chat_history')
              .upsert({
                'user_id': userId,
                'scene_key': sceneKey,
                'messages': messagesJsonFiltered,
                'updated_at': now.toIso8601String(),
              }, onConflict: 'user_id,scene_key')
              .timeout(const Duration(seconds: 10));

          // Save timestamp locally for conflict resolution
          final prefs = await SharedPreferences.getInstance();
          final storageKey = StorageKeyService();
          await prefs.setString(
            storageKey.getUserScopedKey('chat_history_${sceneKey}_updated_at'),
            now.toIso8601String(),
          );

          debugPrint(
            'Deleted ${messageIds.length} messages from cloud: $sceneKey',
          );
        }
      }
      syncStatus.value = SyncStatus.synced;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting from cloud (non-critical): $e');
      }
      syncStatus.value = SyncStatus.offline;
    }
  }

  // Sync messages to Supabase (background operation)
  Future<void> _syncToCloud(String sceneKey) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final messages = _histories[sceneKey] ?? [];
      final messagesJson = messages.map((m) => m.toJson()).toList();
      final now = DateTime.now();

      await _supabase
          .from('chat_history')
          .upsert({
            'user_id': userId,
            'scene_key': sceneKey,
            'messages': messagesJson,
            'updated_at': now.toIso8601String(),
          }, onConflict: 'user_id,scene_key')
          .timeout(const Duration(seconds: 10)); // Add timeout

      // Save timestamp locally for conflict resolution
      final prefs = await SharedPreferences.getInstance();
      final storageKey = StorageKeyService();
      await prefs.setString(
        storageKey.getUserScopedKey('chat_history_${sceneKey}_updated_at'),
        now.toIso8601String(),
      );
    } catch (e) {
      // Don't print error - this is expected when offline
      rethrow; // Let caller handle with catchError
    }
  }

  // Bookmark functionality (keeping local for now)
  void addBookmark(
    String title,
    String preview,
    String date,
    String sceneKey,
    List<Message> messages,
  ) {
    // Check if a bookmark with the same sceneKey already exists
    final existingIndex = _bookmarks.indexWhere((b) => b.sceneKey == sceneKey);

    final BookmarkedConversation bookmark;
    if (existingIndex != -1) {
      // Update existing bookmark
      bookmark = BookmarkedConversation(
        id: _bookmarks[existingIndex].id, // Keep the same ID
        title: title,
        preview: preview,
        date: date,
        sceneKey: sceneKey,
        messages: List.from(messages),
      );
      _bookmarks[existingIndex] = bookmark;
    } else {
      // Create new bookmark
      bookmark = BookmarkedConversation(
        id: const Uuid().v4(),
        title: title,
        preview: preview,
        date: date,
        sceneKey: sceneKey,
        messages: List.from(messages),
      );
      _bookmarks.add(bookmark);
    }

    // Save to local
    _updateNotifier();
    _saveBookmarksToLocal();

    // Sync to cloud
    _syncBookmarkToCloud(bookmark);
  }

  void _updateNotifier() {
    bookmarksNotifier.value = List.unmodifiable(_bookmarks);
  }

  Future<void> _loadBookmarks() async {
    // 1. Load from local storage immediately for UI
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = StorageKeyService();
      final jsonString = prefs.getString(
        storageKey.getUserScopedKey('bookmarked_conversations'),
      );
      if (jsonString != null) {
        final List<dynamic> list = json.decode(jsonString);
        final loaded = list
            .map((e) => BookmarkedConversation.fromJson(e))
            .toList();

        // Deduplicate by sceneKey - keep only the first occurrence
        final Map<String, BookmarkedConversation> uniqueBookmarks = {};
        for (final bookmark in loaded) {
          if (!uniqueBookmarks.containsKey(bookmark.sceneKey)) {
            uniqueBookmarks[bookmark.sceneKey] = bookmark;
          }
        }

        _bookmarks.clear();
        _bookmarks.addAll(uniqueBookmarks.values);
        _updateNotifier();

        // Save back to local if we removed duplicates
        if (uniqueBookmarks.length < loaded.length) {
          _saveBookmarksToLocal();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading local bookmarks: $e');
      }
    }

    // 2. Sync from cloud in background
    await _loadBookmarksFromCloud();
  }

  Future<void> _saveBookmarksToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storageKey = StorageKeyService();
      final jsonString = json.encode(
        _bookmarks.map((e) => e.toJson()).toList(),
      );
      await prefs.setString(
        storageKey.getUserScopedKey('bookmarked_conversations'),
        jsonString,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error saving bookmarks locally: $e');
      }
    }
  }

  Future<void> _loadBookmarksFromCloud() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('bookmarked_conversations')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final cloudBookmarks = (response as List)
          .map((e) => BookmarkedConversation.fromJson(e))
          .toList();

      // Deduplicate by sceneKey - keep only the first (most recent) occurrence
      final Map<String, BookmarkedConversation> uniqueBookmarks = {};
      for (final bookmark in cloudBookmarks) {
        if (!uniqueBookmarks.containsKey(bookmark.sceneKey)) {
          uniqueBookmarks[bookmark.sceneKey] = bookmark;
        }
      }

      // Simple merge: trust cloud if available, or just use cloud list
      if (uniqueBookmarks.isNotEmpty) {
        _bookmarks.clear();
        _bookmarks.addAll(uniqueBookmarks.values);
        _updateNotifier();
        _saveBookmarksToLocal(); // Update local cache
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading bookmarks from cloud: $e');
      }
    }
  }

  Future<void> _syncBookmarkToCloud(BookmarkedConversation bookmark) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      await _supabase.from('bookmarked_conversations').upsert({
        ...bookmark.toJson(),
        'user_id': userId,
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error syncing bookmark to cloud: $e');
      }
    }
  }

  // Method to remove a bookmark
  Future<void> removeBookmark(String bookmarkId) async {
    _bookmarks.removeWhere((b) => b.id == bookmarkId);
    _updateNotifier();
    _saveBookmarksToLocal();

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId != null) {
        await _supabase
            .from('bookmarked_conversations')
            .delete()
            .eq('id', bookmarkId)
            .eq('user_id', userId);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error deleting bookmark from cloud: $e');
      }
    }
  }

  List<BookmarkedConversation> getBookmarks() {
    return List.unmodifiable(_bookmarks);
  }
}

class BookmarkedConversation {
  final String id;
  final String title;
  final String preview;
  final String date;
  final String sceneKey;
  final List<Message> messages;

  BookmarkedConversation({
    required this.id,
    required this.title,
    required this.preview,
    required this.date,
    required this.sceneKey,
    required this.messages,
  });

  factory BookmarkedConversation.fromJson(Map<String, dynamic> json) {
    return BookmarkedConversation(
      id: json['id'] as String,
      title: json['title'] as String,
      preview: json['preview'] as String,
      date: json['date'] as String,
      sceneKey:
          json['scene_key'] ?? json['sceneKey'] as String, // Handle both casing
      messages:
          (json['messages'] as List?)
              ?.map((m) => Message.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'preview': preview,
      'date': date,
      'scene_key': sceneKey,
      'messages': messages.map((m) => m.toJson()).toList(),
    };
  }
}
