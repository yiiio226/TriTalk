class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? translation; // For C-04
  final ReviewFeedback? feedback;  // For F-01
  final MessageAnalysis? analysis; // For AI message analysis
  final bool isLoading; // Transient: Loading state for pending messages
  final bool isAnimated; // Transient: Whether to animate the text appearance

  Message({
    required this.id,
    required this.content,
    required this.isUser,
    required this.timestamp,
    this.translation,
    this.feedback,
    this.analysis,
    this.isLoading = false,
    this.isAnimated = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'translation': translation,
      'feedback': feedback?.toJson(),
      'analysis': analysis?.toJson(),
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
      analysis: json['analysis'] != null
          ? MessageAnalysis.fromJson(json['analysis'])
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

class GrammarPoint {
  final String structure;
  final String explanation;
  final String example;

  GrammarPoint({
    required this.structure,
    required this.explanation,
    required this.example,
  });

  Map<String, dynamic> toJson() {
    return {
      'structure': structure,
      'explanation': explanation,
      'example': example,
    };
  }

  factory GrammarPoint.fromJson(Map<String, dynamic> json) {
    return GrammarPoint(
      structure: json['structure'] ?? '',
      explanation: json['explanation'] ?? '',
      example: json['example'] ?? '',
    );
  }
}

class VocabularyItem {
  final String word;
  final String definition;
  final String example;
  final String? level;

  VocabularyItem({
    required this.word,
    required this.definition,
    required this.example,
    this.level,
  });

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'definition': definition,
      'example': example,
      'level': level,
    };
  }

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      word: json['word'] ?? '',
      definition: json['definition'] ?? '',
      example: json['example'] ?? '',
      level: json['level'],
    );
  }
}

class MessageAnalysis {
  final List<GrammarPoint> grammarPoints;
  final List<VocabularyItem> vocabulary;
  final String sentenceStructure;
  final String overallSummary;

  MessageAnalysis({
    required this.grammarPoints,
    required this.vocabulary,
    required this.sentenceStructure,
    required this.overallSummary,
  });

  Map<String, dynamic> toJson() {
    return {
      'grammar_points': grammarPoints.map((g) => g.toJson()).toList(),
      'vocabulary': vocabulary.map((v) => v.toJson()).toList(),
      'sentence_structure': sentenceStructure,
      'overall_summary': overallSummary,
    };
  }

  factory MessageAnalysis.fromJson(Map<String, dynamic> json) {
    return MessageAnalysis(
      grammarPoints: (json['grammar_points'] as List<dynamic>?)
              ?.map((g) => GrammarPoint.fromJson(g))
              .toList() ??
          [],
      vocabulary: (json['vocabulary'] as List<dynamic>?)
              ?.map((v) => VocabularyItem.fromJson(v))
              .toList() ??
          [],
      sentenceStructure: json['sentence_structure'] ?? '',
      overallSummary: json['overall_summary'] ?? '',
    );
  }
}
