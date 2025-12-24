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
  final bool isPerfect;
  final String correctedText;
  final String nativeExpression;
  final String explanation;
  final String exampleAnswer;

  ReviewFeedback({
    required this.isPerfect,
    required this.correctedText,
    required this.nativeExpression,
    required this.explanation,
    required this.exampleAnswer,
  });

  factory ReviewFeedback.fromJson(Map<String, dynamic> json) {
    return ReviewFeedback(
      isPerfect: json['is_perfect'] ?? false,
      correctedText: json['corrected_text'] ?? '',
      nativeExpression: json['native_expression'] ?? '',
      explanation: json['explanation'] ?? '',
      exampleAnswer: json['example_answer'] ?? '',
    );
  }
}
