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
  final bool isFeedbackLoading; // Transient: Whether feedback is being analyzed
  final List<String>? hints; // For persisting suggested replies
  final bool hasPendingError; // Whether this message failed to send and needs retry
  
  // Voice message fields
  final String? audioPath;  // Local path to audio file
  final int? audioDuration; // Duration in seconds
  final VoiceFeedback? voiceFeedback; // Pronunciation feedback

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
    this.isFeedbackLoading = false,
    this.hints,
    this.hasPendingError = false,
    this.audioPath,
    this.audioDuration,
    this.voiceFeedback,
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
      'hints': hints,
      'audioPath': audioPath,
      'audioDuration': audioDuration,
      'voiceFeedback': voiceFeedback?.toJson(),
      'hasPendingError': hasPendingError,
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
      hints: (json['hints'] as List<dynamic>?)?.cast<String>(),
      audioPath: json['audioPath'],
      audioDuration: json['audioDuration'],
      voiceFeedback: json['voiceFeedback'] != null
          ? VoiceFeedback.fromJson(json['voiceFeedback'])
          : null,
      hasPendingError: json['hasPendingError'] ?? false,
    );
  }
  
  // Helper method to check if this is a voice message
  bool get isVoiceMessage => audioPath != null && audioPath!.isNotEmpty;
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
  final List<StructureSegment> sentenceBreakdown;
  final String overallSummary;
  final String? pragmaticAnalysis;
  final List<String> emotionTags;
  final List<IdiomItem> idioms;

  MessageAnalysis({
    required this.grammarPoints,
    required this.vocabulary,
    required this.sentenceStructure,
    this.sentenceBreakdown = const [],
    required this.overallSummary,
    this.pragmaticAnalysis,
    this.emotionTags = const [],
    this.idioms = const [],
  });

  MessageAnalysis copyWith({
    List<GrammarPoint>? grammarPoints,
    List<VocabularyItem>? vocabulary,
    String? sentenceStructure,
    List<StructureSegment>? sentenceBreakdown,
    String? overallSummary,
    String? pragmaticAnalysis,
    List<String>? emotionTags,
    List<IdiomItem>? idioms,
  }) {
    return MessageAnalysis(
      grammarPoints: grammarPoints ?? this.grammarPoints,
      vocabulary: vocabulary ?? this.vocabulary,
      sentenceStructure: sentenceStructure ?? this.sentenceStructure,
      sentenceBreakdown: sentenceBreakdown ?? this.sentenceBreakdown,
      overallSummary: overallSummary ?? this.overallSummary,
      pragmaticAnalysis: pragmaticAnalysis ?? this.pragmaticAnalysis,
      emotionTags: emotionTags ?? this.emotionTags,
      idioms: idioms ?? this.idioms,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'grammar_points': grammarPoints.map((g) => g.toJson()).toList(),
      'vocabulary': vocabulary.map((v) => v.toJson()).toList(),
      'sentence_structure': sentenceStructure,
      'sentence_breakdown': sentenceBreakdown.map((s) => s.toJson()).toList(),
      'overall_summary': overallSummary,
      'pragmatic_analysis': pragmaticAnalysis,
      'emotion_tags': emotionTags,
      'idioms_slang': idioms.map((i) => i.toJson()).toList(),
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
      sentenceBreakdown: (json['sentence_breakdown'] as List<dynamic>?)
              ?.map((s) => StructureSegment.fromJson(s))
              .toList() ??
          [],
      overallSummary: json['overall_summary'] ?? '',
      pragmaticAnalysis: json['pragmatic_analysis'],
      emotionTags: (json['emotion_tags'] as List<dynamic>?)?.cast<String>() ?? [],
      idioms: (json['idioms_slang'] as List<dynamic>?)
              ?.map((i) => IdiomItem.fromJson(i))
              .toList() ??
          [],
    );
  }
}

class StructureSegment {
  final String text;
  final String tag;

  StructureSegment({required this.text, required this.tag});

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'tag': tag,
    };
  }

  factory StructureSegment.fromJson(Map<String, dynamic> json) {
    return StructureSegment(
      text: json['text'] ?? '',
      tag: json['tag'] ?? '',
    );
  }
}

class IdiomItem {
  final String text;
  final String explanation;
  final String type;

  IdiomItem({
    required this.text,
    required this.explanation,
    required this.type,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'explanation': explanation,
      'type': type,
    };
  }

  factory IdiomItem.fromJson(Map<String, dynamic> json) {
    return IdiomItem(
      text: json['text'] ?? '',
      explanation: json['explanation'] ?? '',
      type: json['type'] ?? 'Idiom',
    );
  }
}

class ShadowResult {
  final int score;
  final int intonationScore;
  final int pronunciationScore;
  final String feedback;

  ShadowResult({
    required this.score,
    required this.intonationScore,
    required this.pronunciationScore,
    required this.feedback,
  });

  factory ShadowResult.fromJson(Map<String, dynamic> json) {
    final details = json['details'] ?? {};
    return ShadowResult(
      score: json['score'] ?? 0,
      intonationScore: details['intonation_score'] ?? 0,
      pronunciationScore: details['pronunciation_score'] ?? 0,
      feedback: details['feedback'] ?? '',
    );
  }
}

class VoiceWord {
  final String word;
  final int score;
  
  VoiceWord({required this.word, required this.score});
  
  factory VoiceWord.fromJson(Map<String, dynamic> json) => VoiceWord(
    word: json['word'] ?? '',
    score: json['score'] ?? 0,
  );

  Map<String, dynamic> toJson() => {'word': word, 'score': score};
}

class ErrorFocus {
  final String word;
  final String userIpa;
  final String correctIpa;
  final String tip;

  ErrorFocus({required this.word, required this.userIpa, required this.correctIpa, required this.tip});

  factory ErrorFocus.fromJson(Map<String, dynamic> json) => ErrorFocus(
    word: json['word'] ?? '',
    userIpa: json['user_ipa'] ?? '',
    correctIpa: json['correct_ipa'] ?? '',
    tip: json['tip'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'word': word, 'user_ipa': userIpa, 'correct_ipa': correctIpa, 'tip': tip,
  };
}

class VoiceFeedback {
  final int pronunciationScore;  // 0-100
  final String correctedText;     // Corrected pronunciation text
  final String nativeExpression;  // Native way to say it
  final String feedback;          // Detailed feedback
  final List<VoiceWord>? sentenceBreakdown;
  final ErrorFocus? errorFocus;

  VoiceFeedback({
    required this.pronunciationScore,
    required this.correctedText,
    required this.nativeExpression,
    required this.feedback,
    this.sentenceBreakdown,
    this.errorFocus,
  });

  Map<String, dynamic> toJson() {
    return {
      'pronunciation_score': pronunciationScore,
      'corrected_text': correctedText,
      'native_expression': nativeExpression,
      'feedback': feedback,
      'sentence_breakdown': sentenceBreakdown?.map((e) => e.toJson()).toList(),
      'error_focus': errorFocus?.toJson(),
    };
  }

  factory VoiceFeedback.fromJson(Map<String, dynamic> json) {
    return VoiceFeedback(
      pronunciationScore: json['pronunciation_score'] ?? 0,
      correctedText: json['corrected_text'] ?? '',
      nativeExpression: json['native_expression'] ?? '',
      feedback: json['feedback'] ?? '',
      sentenceBreakdown: (json['sentence_breakdown'] as List?)
          ?.map((e) => VoiceWord.fromJson(e))
          .toList(),
      errorFocus: json['error_focus'] != null 
          ? ErrorFocus.fromJson(json['error_focus']) 
          : null,
    );
  }
}

