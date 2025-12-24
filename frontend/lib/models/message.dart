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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'translation': translation,
      'feedback': feedback?.toJson(),
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      content: json['content'],
      isUser: json['isUser'],
      timestamp: DateTime.parse(json['timestamp']),
      translation: json['translation'],
      feedback: json['feedback'] != null 
          ? ReviewFeedback.fromJson(json['feedback']) 
          : null,
    );
  }
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

  Map<String, dynamic> toJson() {
    return {
      'is_perfect': isPerfect,
      'corrected_text': correctedText,
      'native_expression': nativeExpression,
      'explanation': explanation,
      'example_answer': exampleAnswer,
    };
  }

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
