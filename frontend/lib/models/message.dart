class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? translation; // For C-04
  final Feedback? feedback;  // For F-01

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.translation,
    this.feedback,
  });
}

class Feedback {
  final List<int> highlightIndices;
  final String optimizedText;
  final String reason;

  Feedback({
    required this.highlightIndices,
    required this.optimizedText,
    required this.reason,
  });
}
