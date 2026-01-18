class Message {
  final String id;
  final String content;
  final bool isUser;
  final DateTime timestamp;
  final String? translation; // For C-04
  final ReviewFeedback? feedback; // For F-01
  final MessageAnalysis? analysis; // For AI message analysis
  final bool isLoading; // Transient: Loading state for pending messages
  final bool isAnimated; // Transient: Whether to animate the text appearance
  final bool isFeedbackLoading; // Transient: Whether feedback is being analyzed
  final bool
  isAnalyzing; // Transient: Whether user message is being analyzed (for manual analysis trigger)
  final List<String>? hints; // For persisting suggested replies
  final bool
  hasPendingError; // Whether this message failed to send and needs retry
  final bool
  isSelected; // Transient: Whether this message is selected in multi-select mode

  // Voice message fields
  final String? audioPath; // Local path to audio file
  final int? audioDuration; // Duration in seconds
  final VoiceFeedback?
  voiceFeedback; // Pronunciation feedback for user voice messages

  // Shadowing practice result for AI messages
  final VoiceFeedback? shadowingFeedback;
  final String? shadowingAudioPath; // Local path to shadowing recording

  // TTS audio cache for AI messages (Listen button)
  final String? ttsAudioPath; // Local path to cached TTS audio file

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
    this.isAnalyzing = false,
    this.hints,
    this.hasPendingError = false,
    this.isSelected = false,
    this.audioPath,
    this.audioDuration,
    this.voiceFeedback,
    this.shadowingFeedback,
    this.shadowingAudioPath,
    this.ttsAudioPath,
  });

  Message copyWith({
    String? id,
    String? content,
    bool? isUser,
    DateTime? timestamp,
    String? translation,
    ReviewFeedback? feedback,
    MessageAnalysis? analysis,
    bool? isLoading,
    bool? isAnimated,
    bool? isFeedbackLoading,
    bool? isAnalyzing,
    List<String>? hints,
    bool? hasPendingError,
    bool? isSelected,
    String? audioPath,
    int? audioDuration,
    VoiceFeedback? voiceFeedback,
    VoiceFeedback? shadowingFeedback,
    String? shadowingAudioPath,
    String? ttsAudioPath,
  }) {
    return Message(
      id: id ?? this.id,
      content: content ?? this.content,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      translation: translation ?? this.translation,
      feedback: feedback ?? this.feedback,
      analysis: analysis ?? this.analysis,
      isLoading: isLoading ?? this.isLoading,
      isAnimated: isAnimated ?? this.isAnimated,
      isFeedbackLoading: isFeedbackLoading ?? this.isFeedbackLoading,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      hints: hints ?? this.hints,
      hasPendingError: hasPendingError ?? this.hasPendingError,
      isSelected: isSelected ?? this.isSelected,
      audioPath: audioPath ?? this.audioPath,
      audioDuration: audioDuration ?? this.audioDuration,
      voiceFeedback: voiceFeedback ?? this.voiceFeedback,
      shadowingFeedback: shadowingFeedback ?? this.shadowingFeedback,
      shadowingAudioPath: shadowingAudioPath ?? this.shadowingAudioPath,
      ttsAudioPath: ttsAudioPath ?? this.ttsAudioPath,
    );
  }

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
      'shadowingFeedback': shadowingFeedback?.toJson(),
      'shadowingAudioPath': shadowingAudioPath,
      'ttsAudioPath': ttsAudioPath,
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
      shadowingFeedback: json['shadowingFeedback'] != null
          ? VoiceFeedback.fromJson(json['shadowingFeedback'])
          : null,
      shadowingAudioPath: json['shadowingAudioPath'],
      ttsAudioPath: json['ttsAudioPath'],
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
  final String
  explanation; // Kept for backward compatibility, same as grammarExplanation
  final String exampleAnswer;

  // New specific explanation fields
  final String? grammarExplanation;
  final String? nativeExpressionReason;
  final String? exampleAnswerReason;

  ReviewFeedback({
    required this.isPerfect,
    required this.correctedText,
    required this.nativeExpression,
    required this.explanation,
    required this.exampleAnswer,
    this.grammarExplanation,
    this.nativeExpressionReason,
    this.exampleAnswerReason,
  });

  Map<String, dynamic> toJson() {
    return {
      'is_perfect': isPerfect,
      'corrected_text': correctedText,
      'native_expression': nativeExpression,
      'explanation': explanation,
      'grammar_explanation': grammarExplanation,
      'native_expression_reason': nativeExpressionReason,
      'example_answer': exampleAnswer,
      'example_answer_reason': exampleAnswerReason,
    };
  }

  factory ReviewFeedback.fromJson(Map<String, dynamic> json) {
    // For backward compatibility: use grammar_explanation if available, otherwise fall back to explanation
    final grammarExp = json['grammar_explanation'] as String?;
    final oldExp = json['explanation'] as String? ?? '';

    return ReviewFeedback(
      isPerfect: json['is_perfect'] ?? false,
      correctedText: json['corrected_text'] ?? '',
      nativeExpression: json['native_expression'] ?? '',
      explanation:
          grammarExp ??
          oldExp, // Use new field if available, otherwise old field
      exampleAnswer: json['example_answer'] ?? '',
      grammarExplanation: grammarExp ?? oldExp,
      nativeExpressionReason: json['native_expression_reason'] as String?,
      exampleAnswerReason: json['example_answer_reason'] as String?,
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
  final String? partOfSpeech;

  VocabularyItem({
    required this.word,
    required this.definition,
    required this.example,
    this.level,
    this.partOfSpeech,
  });

  Map<String, dynamic> toJson() {
    return {
      'word': word,
      'definition': definition,
      'example': example,
      'level': level,
      'part_of_speech': partOfSpeech,
    };
  }

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      word: json['word'] ?? '',
      definition: json['definition'] ?? '',
      example: json['example'] ?? '',
      level: json['level'],
      partOfSpeech: json['part_of_speech'],
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
      grammarPoints:
          (json['grammar_points'] as List<dynamic>?)
              ?.map((g) => GrammarPoint.fromJson(g))
              .toList() ??
          [],
      vocabulary:
          (json['vocabulary'] as List<dynamic>?)
              ?.map((v) => VocabularyItem.fromJson(v))
              .toList() ??
          [],
      sentenceStructure: json['sentence_structure'] ?? '',
      sentenceBreakdown:
          (json['sentence_breakdown'] as List<dynamic>?)
              ?.map((s) => StructureSegment.fromJson(s))
              .toList() ??
          [],
      overallSummary: json['overall_summary'] ?? '',
      pragmaticAnalysis: json['pragmatic_analysis'],
      emotionTags:
          (json['emotion_tags'] as List<dynamic>?)?.cast<String>() ?? [],
      idioms:
          (json['idioms_slang'] as List<dynamic>?)
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
    return {'text': text, 'tag': tag};
  }

  factory StructureSegment.fromJson(Map<String, dynamic> json) {
    return StructureSegment(text: json['text'] ?? '', tag: json['tag'] ?? '');
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
    return {'text': text, 'explanation': explanation, 'type': type};
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

  factory VoiceWord.fromJson(Map<String, dynamic> json) =>
      VoiceWord(word: json['word'] ?? '', score: json['score'] ?? 0);

  Map<String, dynamic> toJson() => {'word': word, 'score': score};
}

class ErrorFocus {
  final String word;
  final String userIpa;
  final String correctIpa;
  final String tip;

  ErrorFocus({
    required this.word,
    required this.userIpa,
    required this.correctIpa,
    required this.tip,
  });

  factory ErrorFocus.fromJson(Map<String, dynamic> json) => ErrorFocus(
    word: json['word'] ?? '',
    userIpa: json['user_ipa'] ?? '',
    correctIpa: json['correct_ipa'] ?? '',
    tip: json['tip'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'word': word,
    'user_ipa': userIpa,
    'correct_ipa': correctIpa,
    'tip': tip,
  };
}

/// Phoneme-level feedback from Azure pronunciation assessment
class AzurePhonemeFeedback {
  final String phoneme; // IPA phoneme symbol
  final double accuracyScore; // 0-100

  AzurePhonemeFeedback({required this.phoneme, required this.accuracyScore});

  factory AzurePhonemeFeedback.fromJson(Map<String, dynamic> json) =>
      AzurePhonemeFeedback(
        phoneme: json['phoneme'] ?? '',
        accuracyScore: (json['accuracy_score'] as num?)?.toDouble() ?? 0.0,
      );

  Map<String, dynamic> toJson() => {
    'phoneme': phoneme,
    'accuracy_score': accuracyScore,
  };

  /// Traffic light level based on score
  String get level {
    if (accuracyScore > 80) return 'perfect';
    if (accuracyScore >= 60) return 'warning';
    return 'error';
  }
}

/// Word-level feedback from Azure pronunciation assessment (Traffic Light)
class AzureWordFeedback {
  final String text;
  final double score; // 0-100
  final String level; // perfect, warning, error, missing
  final String errorType; // None, Omission, Insertion, Mispronunciation
  final List<AzurePhonemeFeedback> phonemes;

  AzureWordFeedback({
    required this.text,
    required this.score,
    required this.level,
    required this.errorType,
    this.phonemes = const [],
  });

  factory AzureWordFeedback.fromJson(Map<String, dynamic> json) =>
      AzureWordFeedback(
        text: json['text'] ?? '',
        score: (json['score'] as num?)?.toDouble() ?? 0.0,
        level: json['level'] ?? 'error',
        errorType: json['error_type'] ?? 'None',
        phonemes:
            (json['phonemes'] as List?)
                ?.map((p) => AzurePhonemeFeedback.fromJson(p))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
    'text': text,
    'score': score,
    'level': level,
    'error_type': errorType,
    'phonemes': phonemes.map((p) => p.toJson()).toList(),
  };

  /// Whether this word has pronunciation issues
  bool get hasIssue => level != 'perfect';
}

class VoiceFeedback {
  final int pronunciationScore; // 0-100 (overall or Azure score)
  final String correctedText; // Corrected pronunciation text (LLM)
  final String nativeExpression; // Native way to say it (LLM)
  final String feedback; // Detailed feedback (LLM)
  final List<VoiceWord>? sentenceBreakdown; // LLM-based word breakdown
  final ErrorFocus? errorFocus; // LLM-based error focus

  // Azure pronunciation assessment data (precise phoneme-level)
  final double? azureAccuracyScore; // 0-100
  final double? azureFluencyScore; // 0-100
  final double? azureCompletenessScore; // 0-100
  final double? azureProsodyScore; // 0-100 (optional)
  final List<AzureWordFeedback>?
  azureWordFeedback; // Traffic Light word feedback

  // Smart segments based on natural pauses (from Azure Break data)
  final List<SmartSegmentFeedback>? smartSegments;

  VoiceFeedback({
    required this.pronunciationScore,
    required this.correctedText,
    required this.nativeExpression,
    required this.feedback,
    this.sentenceBreakdown,
    this.errorFocus,
    // Azure fields (optional)
    this.azureAccuracyScore,
    this.azureFluencyScore,
    this.azureCompletenessScore,
    this.azureProsodyScore,
    this.azureWordFeedback,
    this.smartSegments,
  });

  /// Create a copy with updated Azure data
  VoiceFeedback copyWithAzureData({
    int? pronunciationScore,
    double? azureAccuracyScore,
    double? azureFluencyScore,
    double? azureCompletenessScore,
    double? azureProsodyScore,
    List<AzureWordFeedback>? azureWordFeedback,
    List<SmartSegmentFeedback>? smartSegments,
  }) {
    return VoiceFeedback(
      pronunciationScore: pronunciationScore ?? this.pronunciationScore,
      correctedText: correctedText,
      nativeExpression: nativeExpression,
      feedback: feedback,
      sentenceBreakdown: sentenceBreakdown,
      errorFocus: errorFocus,
      azureAccuracyScore: azureAccuracyScore ?? this.azureAccuracyScore,
      azureFluencyScore: azureFluencyScore ?? this.azureFluencyScore,
      azureCompletenessScore:
          azureCompletenessScore ?? this.azureCompletenessScore,
      azureProsodyScore: azureProsodyScore ?? this.azureProsodyScore,
      azureWordFeedback: azureWordFeedback ?? this.azureWordFeedback,
      smartSegments: smartSegments ?? this.smartSegments,
    );
  }

  /// Whether Azure pronunciation data is available
  bool get hasAzureData =>
      azureWordFeedback != null && azureWordFeedback!.isNotEmpty;

  /// Whether smart segments are available
  bool get hasSmartSegments =>
      smartSegments != null && smartSegments!.isNotEmpty;

  /// Get words with pronunciation issues (from Azure data)
  List<AzureWordFeedback> get problemWords =>
      azureWordFeedback?.where((w) => w.hasIssue).toList() ?? [];

  Map<String, dynamic> toJson() {
    return {
      'pronunciation_score': pronunciationScore,
      'corrected_text': correctedText,
      'native_expression': nativeExpression,
      'feedback': feedback,
      'sentence_breakdown': sentenceBreakdown?.map((e) => e.toJson()).toList(),
      'error_focus': errorFocus?.toJson(),
      // Azure data
      'azure_accuracy_score': azureAccuracyScore,
      'azure_fluency_score': azureFluencyScore,
      'azure_completeness_score': azureCompletenessScore,
      'azure_prosody_score': azureProsodyScore,
      'azure_word_feedback': azureWordFeedback?.map((w) => w.toJson()).toList(),
      'smart_segments': smartSegments?.map((s) => s.toJson()).toList(),
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
      // Azure data
      azureAccuracyScore: (json['azure_accuracy_score'] as num?)?.toDouble(),
      azureFluencyScore: (json['azure_fluency_score'] as num?)?.toDouble(),
      azureCompletenessScore: (json['azure_completeness_score'] as num?)
          ?.toDouble(),
      azureProsodyScore: (json['azure_prosody_score'] as num?)?.toDouble(),
      azureWordFeedback: (json['azure_word_feedback'] as List?)
          ?.map((w) => AzureWordFeedback.fromJson(w))
          .toList(),
      smartSegments: (json['smart_segments'] as List?)
          ?.map((s) => SmartSegmentFeedback.fromJson(s))
          .toList(),
    );
  }
}

/// Smart segment feedback for targeted practice
/// Represents a portion of text that should be practiced together based on natural pauses
class SmartSegmentFeedback {
  final String text; // The text content of this segment
  final int startIndex; // Start word index (inclusive)
  final int endIndex; // End word index (inclusive)
  final double score; // Average pronunciation score for this segment (0-100)
  final bool hasError; // If segment contains red/yellow words (score < 80)
  final int wordCount; // Number of words in segment

  SmartSegmentFeedback({
    required this.text,
    required this.startIndex,
    required this.endIndex,
    required this.score,
    required this.hasError,
    required this.wordCount,
  });

  factory SmartSegmentFeedback.fromJson(Map<String, dynamic> json) {
    return SmartSegmentFeedback(
      text: json['text'] ?? '',
      startIndex: json['start_index'] ?? 0,
      endIndex: json['end_index'] ?? 0,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      hasError: json['has_error'] ?? false,
      wordCount: json['word_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'start_index': startIndex,
    'end_index': endIndex,
    'score': score,
    'has_error': hasError,
    'word_count': wordCount,
  };

  /// Traffic light level based on score
  String get level {
    if (score > 80) return 'perfect';
    if (score >= 60) return 'warning';
    return 'error';
  }
}
