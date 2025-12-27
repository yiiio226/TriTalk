import '../models/message.dart';

class ChatHistoryService {
  static final ChatHistoryService _instance = ChatHistoryService._internal();
  factory ChatHistoryService() => _instance;
  ChatHistoryService._internal();

  // Key: Scene Title (or unique ID if available)
  // Value: List of messages for that scene
  final Map<String, List<Message>> _histories = {};

  final List<BookmarkedConversation> _bookmarks = [];

  List<Message> getMessages(String sceneKey) {
    if (!_histories.containsKey(sceneKey)) {
      _histories[sceneKey] = [];
    }
    return _histories[sceneKey]!;
  }

  void addMessage(String sceneKey, Message message) {
    if (!_histories.containsKey(sceneKey)) {
      _histories[sceneKey] = [];
    }
    _histories[sceneKey]!.add(message);
  }

  void updateMessage(String sceneKey, int index, Message message) {
    if (_histories.containsKey(sceneKey) && 
        index >= 0 && 
        index < _histories[sceneKey]!.length) {
      _histories[sceneKey]![index] = message;
    }
  }
  
  void clearHistory(String sceneKey) {
     _histories.remove(sceneKey);
  }

  void addBookmark(String title, String preview, String date, String sceneKey, List<Message> messages) {
    final newBookmark = BookmarkedConversation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      preview: preview,
      date: date,
      sceneKey: sceneKey,
      messages: List.from(messages), // Store a copy
    );
    _bookmarks.insert(0, newBookmark); // Add to top
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
