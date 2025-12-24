import '../models/message.dart';

class ChatHistoryService {
  static final ChatHistoryService _instance = ChatHistoryService._internal();
  factory ChatHistoryService() => _instance;
  ChatHistoryService._internal();

  // Key: Scene Title (or unique ID if available)
  // Value: List of messages for that scene
  final Map<String, List<Message>> _histories = {};

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
    // Since we return the reference list in getMessages, direct addition to that list works too,
    // but this method is good for encapsulation if we change implementation later.
  }
  
  void clearHistory(String sceneKey) {
     _histories.remove(sceneKey);
  }
}
