class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? translation; // For C-04
  final ReviewFeedback? feedback;  // For F-01

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.translation,
    this.feedback,
  });
}

class ReviewFeedback {
  final List<int> highlightIndices;
  final String optimizedText;
  final String reason;

  ReviewFeedback({
    required this.highlightIndices,
    required this.optimizedText,
    required this.reason,
  });

  factory ReviewFeedback.fromJson(Map<String, dynamic> json) {
    return ReviewFeedback(
      highlightIndices: List<int>.from(json['highlight_indices']),
      optimizedText: json['optimized_text'],
      reason: json['explanation'],
    );
  }
}
