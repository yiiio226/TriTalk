import 'package:frontend/features/chat/domain/models/message.dart';

class ShadowingPractice {
  final String id;
  final String targetText;
  final String sourceType; // 'ai_message', 'native_expression', 'reference_answer', 'custom'
  final String? sourceId;
  final String? sceneKey;
  
  final int pronunciationScore;
  final double? accuracyScore;
  final double? fluencyScore;
  final double? completenessScore;
  final double? prosodyScore;
  
  final List<AzureWordFeedback>? wordFeedback;
  final String? feedbackText;
  final String? audioPath; // Local path only
  
  final DateTime practicedAt;

  ShadowingPractice({
    required this.id,
    required this.targetText,
    required this.sourceType,
    this.sourceId,
    this.sceneKey,
    required this.pronunciationScore,
    this.accuracyScore,
    this.fluencyScore,
    this.completenessScore,
    this.prosodyScore,
    this.wordFeedback,
    this.feedbackText,
    this.audioPath,
    required this.practicedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'target_text': targetText,
      'source_type': sourceType,
      'source_id': sourceId,
      'scene_key': sceneKey,
      'pronunciation_score': pronunciationScore,
      'accuracy_score': accuracyScore,
      'fluency_score': fluencyScore,
      'completeness_score': completenessScore,
      'prosody_score': prosodyScore,
      'word_feedback': wordFeedback?.map((w) => w.toJson()).toList(),
      'feedback_text': feedbackText,
      'audio_path': audioPath,
      'practiced_at': practicedAt.toIso8601String(),
    };
  }

  factory ShadowingPractice.fromJson(Map<String, dynamic> json) {
    return ShadowingPractice(
      id: json['id'],
      targetText: json['target_text'],
      sourceType: json['source_type'],
      sourceId: json['source_id'],
      sceneKey: json['scene_key'],
      pronunciationScore: json['pronunciation_score'],
      accuracyScore: (json['accuracy_score'] as num?)?.toDouble(),
      fluencyScore: (json['fluency_score'] as num?)?.toDouble(),
      completenessScore: (json['completeness_score'] as num?)?.toDouble(),
      prosodyScore: (json['prosody_score'] as num?)?.toDouble(),
      wordFeedback: (json['word_feedback'] as List?)
          ?.map((w) => AzureWordFeedback.fromJson(w))
          .toList(),
      feedbackText: json['feedback_text'],
      audioPath: json['audio_path'],
      practicedAt: DateTime.parse(json['practiced_at']),
    );
  }
}
