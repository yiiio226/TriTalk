import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/message.dart';

class ChatHistoryService {
  static final ChatHistoryService _instance = ChatHistoryService._internal();
  factory ChatHistoryService() => _instance;
  ChatHistoryService._internal();

  final _supabase = Supabase.instance.client;

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
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await _supabase
          .from('chat_history')
          .select('messages')
          .eq('user_id', userId)
          .eq('scene_key', sceneKey)
          .maybeSingle()
          .timeout(const Duration(seconds: 5)); // Add timeout

      if (response != null && response['messages'] != null) {
        final List<dynamic> messagesJson = response['messages'];
        final messages = messagesJson
            .map((json) => Message.fromJson(json as Map<String, dynamic>))
            .toList();
        _histories[sceneKey] = messages;
        
        // Save to local storage
        await _saveToLocal(sceneKey, messages);
      }
    } catch (e) {
      print('Error loading from cloud (non-critical): $e');
      // Don't throw - offline mode is OK
    }
  }

  // Sync entire message list (local first, then cloud)
  Future<void> syncMessages(String sceneKey, List<Message> messages) async {
    // Update cache
    _histories[sceneKey] = List.from(messages);
    
    // Save to local storage immediately (always succeeds)
    await _saveToLocal(sceneKey, messages);
    
    // Try to sync to cloud in background (don't block on failure)
    _syncToCloud(sceneKey).catchError((e) {
      print('Background cloud sync failed (non-critical): $e');
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
    _syncToCloud(sceneKey).catchError((e) => print('Sync failed: $e'));
  }

  // Update message (deprecated - use syncMessages)
  Future<void> updateMessage(String sceneKey, int index, Message message) async {
    if (_histories.containsKey(sceneKey) &&
        index >= 0 &&
        index < _histories[sceneKey]!.length) {
      _histories[sceneKey]![index] = message;
      await _saveToLocal(sceneKey, _histories[sceneKey]!);
      _syncToCloud(sceneKey).catchError((e) => print('Sync failed: $e'));
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
    
    // Try to clear from cloud (don't block on failure)
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
    } catch (e) {
      print('Error clearing from cloud (non-critical): $e');
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
          'updated_at': DateTime.now().toIso8601String(),
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
      id: DateTime.now().millisecondsSinceEpoch.toString(),
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
