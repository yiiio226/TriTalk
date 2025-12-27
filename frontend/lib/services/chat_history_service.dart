import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

enum SyncStatus { synced, syncing, offline }

class ChatHistoryService {
  static final ChatHistoryService _instance = ChatHistoryService._internal();
  factory ChatHistoryService() => _instance;
  ChatHistoryService._internal();

  final _supabase = Supabase.instance.client;

  // Sync status notifier
  final syncStatus = ValueNotifier<SyncStatus>(SyncStatus.synced);

  // Local cache
  final Map<String, List<Message>> _histories = {};
  final List<BookmarkedConversation> _bookmarks = [];

  // Load messages for a scene (local first, then cloud)
  Future<List<Message>> getMessages(String sceneKey) async {
    // Return from cache if available
    if (_histories.containsKey(sceneKey)) {
      return List.from(_histories[sceneKey]!);
    }

    // Try to load from local storage first
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'chat_history_$sceneKey';
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
      print('Error loading from local storage: $e');
    }

    // Try to load from Supabase as fallback
    await _loadFromCloud(sceneKey);
    
    return List.from(_histories[sceneKey] ?? []);
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
          .select('messages')
          .eq('user_id', userId)
          .eq('scene_key', sceneKey)
          .maybeSingle()
          .timeout(const Duration(seconds: 5)); // Add timeout

      if (response != null && response['messages'] != null) {
        final List<dynamic> messagesJson = response['messages'];
        final cloudMessages = messagesJson
            .map((json) => Message.fromJson(json as Map<String, dynamic>))
            .toList();
        
        // MERGE STRATEGY: Only update if cloud has MORE messages than local
        // This prevents accidental data loss from empty cloud responses
        final localMessages = _histories[sceneKey] ?? [];
        
        if (cloudMessages.length >= localMessages.length) {
          _histories[sceneKey] = cloudMessages;
          
          // Save to local storage
          await _saveToLocal(sceneKey, cloudMessages);
        } else {
          // Local has more data, keep it and push to cloud
          debugPrint('Local has more messages (${ localMessages.length}) than cloud (${cloudMessages.length}), keeping local');
          // Optionally: trigger a sync to cloud here to update it
          // _syncToCloud(sceneKey); // Uncomment if you want to auto-push
        }
      }
      // If response is null or empty, keep local data (don't overwrite with nothing)
      
      syncStatus.value = SyncStatus.synced;
    } catch (e) {
      print('Error loading from cloud (non-critical): $e');
      syncStatus.value = SyncStatus.offline;
    }
  }

  // Sync entire message list to cloud (recommended method)
  Future<void> syncMessages(String sceneKey, List<Message> messages) async {
    // Update cache
    _histories[sceneKey] = List.from(messages);
    
    // Save to local storage immediately (always succeeds)
    await _saveToLocal(sceneKey, messages);
    
    // Sync to cloud
    syncStatus.value = SyncStatus.syncing;
    _syncToCloud(sceneKey).then((_) {
      syncStatus.value = SyncStatus.synced;
    }).catchError((e) {
      print('Background cloud sync failed (non-critical): $e');
      syncStatus.value = SyncStatus.offline;
    });
  }

  // Save to local storage
  Future<void> _saveToLocal(String sceneKey, List<Message> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'chat_history_$sceneKey';
      final messagesJson = messages.map((m) => m.toJson()).toList();
      await prefs.setString(key, json.encode(messagesJson));
    } catch (e) {
      print('Error saving to local storage: $e');
    }
  }

  // Add message (deprecated - use syncMessages)
  Future<void> addMessage(String sceneKey, Message message) async {
    if (!_histories.containsKey(sceneKey)) {
      await getMessages(sceneKey);
    }
    
    _histories[sceneKey]!.add(message);
    await _saveToLocal(sceneKey, _histories[sceneKey]!);
    
    syncStatus.value = SyncStatus.syncing;
    _syncToCloud(sceneKey).then((_) {
      syncStatus.value = SyncStatus.synced;
    }).catchError((e) {
      print('Sync failed: $e');
      syncStatus.value = SyncStatus.offline;
    });
  }

  // Update message (deprecated - use syncMessages)
  Future<void> updateMessage(String sceneKey, int index, Message message) async {
    if (_histories.containsKey(sceneKey) &&
        index >= 0 &&
        index < _histories[sceneKey]!.length) {
      _histories[sceneKey]![index] = message;
      await _saveToLocal(sceneKey, _histories[sceneKey]!);
      
      syncStatus.value = SyncStatus.syncing;
      _syncToCloud(sceneKey).then((_) {
        syncStatus.value = SyncStatus.synced;
      }).catchError((e) {
        print('Sync failed: $e');
        syncStatus.value = SyncStatus.offline;
      });
    }
  }

  // Clear history locally and in cloud
  Future<void> clearHistory(String sceneKey) async {
    _histories.remove(sceneKey);
    
    // Clear from local storage
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('chat_history_$sceneKey');
    } catch (e) {
      print('Error clearing local storage: $e');
    }
    
    // Try to clear from cloud
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
      }
      syncStatus.value = SyncStatus.synced;
    } catch (e) {
      print('Error clearing from cloud (non-critical): $e');
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

      await _supabase.from('chat_history').upsert(
        {
          'user_id': userId,
          'scene_key': sceneKey,
          'messages': messagesJson,
          // Let database trigger handle updated_at automatically
        },
        onConflict: 'user_id,scene_key',
      ).timeout(const Duration(seconds: 10)); // Add timeout
    } catch (e) {
      // Don't print error - this is expected when offline
      rethrow; // Let caller handle with catchError
    }
  }

  // Bookmark functionality (keeping local for now)
  void addBookmark(String title, String preview, String date, String sceneKey,
      List<Message> messages) {
    final newBookmark = BookmarkedConversation(
      id: const Uuid().v4(),
      title: title,
      preview: preview,
      date: date,
      sceneKey: sceneKey,
      messages: List.from(messages),
    );
    _bookmarks.insert(0, newBookmark);
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
}
