// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swagger.models.swagger.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatSendPost$RequestBody _$ChatSendPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ChatSendPost$RequestBody(
  message: json['message'] as String,
  history: (json['history'] as List<dynamic>?)
      ?.map(
        (e) => ChatSendPost$RequestBody$History$Item.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  sceneContext: json['scene_context'] as String,
  nativeLanguage: json['native_language'] as String?,
  targetLanguage: json['target_language'] as String?,
);

Map<String, dynamic> _$ChatSendPost$RequestBodyToJson(
  ChatSendPost$RequestBody instance,
) => <String, dynamic>{
  'message': instance.message,
  'history': instance.history?.map((e) => e.toJson()).toList(),
  'scene_context': instance.sceneContext,
  'native_language': instance.nativeLanguage,
  'target_language': instance.targetLanguage,
};

ChatTranscribePost$RequestBody _$ChatTranscribePost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ChatTranscribePost$RequestBody(audio: json['audio'] as String);

Map<String, dynamic> _$ChatTranscribePost$RequestBodyToJson(
  ChatTranscribePost$RequestBody instance,
) => <String, dynamic>{'audio': instance.audio};

ChatHintPost$RequestBody _$ChatHintPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ChatHintPost$RequestBody(
  message: json['message'] as String?,
  history: (json['history'] as List<dynamic>?)
      ?.map(
        (e) => ChatHintPost$RequestBody$History$Item.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  sceneContext: json['scene_context'] as String,
  targetLanguage: json['target_language'] as String?,
);

Map<String, dynamic> _$ChatHintPost$RequestBodyToJson(
  ChatHintPost$RequestBody instance,
) => <String, dynamic>{
  'message': instance.message,
  'history': instance.history?.map((e) => e.toJson()).toList(),
  'scene_context': instance.sceneContext,
  'target_language': instance.targetLanguage,
};

SceneGeneratePost$RequestBody _$SceneGeneratePost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => SceneGeneratePost$RequestBody(
  description: json['description'] as String,
  tone: json['tone'] as String?,
);

Map<String, dynamic> _$SceneGeneratePost$RequestBodyToJson(
  SceneGeneratePost$RequestBody instance,
) => <String, dynamic>{
  'description': instance.description,
  'tone': instance.tone,
};

ScenePolishPost$RequestBody _$ScenePolishPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ScenePolishPost$RequestBody(description: json['description'] as String);

Map<String, dynamic> _$ScenePolishPost$RequestBodyToJson(
  ScenePolishPost$RequestBody instance,
) => <String, dynamic>{'description': instance.description};

CommonTranslatePost$RequestBody _$CommonTranslatePost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => CommonTranslatePost$RequestBody(
  text: json['text'] as String,
  targetLanguage: json['target_language'] as String,
);

Map<String, dynamic> _$CommonTranslatePost$RequestBodyToJson(
  CommonTranslatePost$RequestBody instance,
) => <String, dynamic>{
  'text': instance.text,
  'target_language': instance.targetLanguage,
};

ChatShadowPost$RequestBody _$ChatShadowPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ChatShadowPost$RequestBody(
  targetText: json['target_text'] as String,
  userAudioText: json['user_audio_text'] as String,
);

Map<String, dynamic> _$ChatShadowPost$RequestBodyToJson(
  ChatShadowPost$RequestBody instance,
) => <String, dynamic>{
  'target_text': instance.targetText,
  'user_audio_text': instance.userAudioText,
};

ChatOptimizePost$RequestBody _$ChatOptimizePost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ChatOptimizePost$RequestBody(
  message: json['message'] as String,
  sceneContext: json['scene_context'] as String,
  history: (json['history'] as List<dynamic>?)
      ?.map(
        (e) => ChatOptimizePost$RequestBody$History$Item.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  targetLanguage: json['target_language'] as String?,
);

Map<String, dynamic> _$ChatOptimizePost$RequestBodyToJson(
  ChatOptimizePost$RequestBody instance,
) => <String, dynamic>{
  'message': instance.message,
  'scene_context': instance.sceneContext,
  'history': instance.history?.map((e) => e.toJson()).toList(),
  'target_language': instance.targetLanguage,
};

ChatMessagesDelete$RequestBody _$ChatMessagesDelete$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ChatMessagesDelete$RequestBody(
  sceneKey: json['scene_key'] as String,
  messageIds:
      (json['message_ids'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
);

Map<String, dynamic> _$ChatMessagesDelete$RequestBodyToJson(
  ChatMessagesDelete$RequestBody instance,
) => <String, dynamic>{
  'scene_key': instance.sceneKey,
  'message_ids': instance.messageIds,
};

UserSyncPost$RequestBody _$UserSyncPost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => UserSyncPost$RequestBody(
  id: json['id'] as String,
  email: json['email'] as String?,
);

Map<String, dynamic> _$UserSyncPost$RequestBodyToJson(
  UserSyncPost$RequestBody instance,
) => <String, dynamic>{'id': instance.id, 'email': instance.email};

ShadowingSavePost$RequestBody _$ShadowingSavePost$RequestBodyFromJson(
  Map<String, dynamic> json,
) => ShadowingSavePost$RequestBody(
  targetText: json['target_text'] as String,
  sourceType: shadowingSavePost$RequestBodySourceTypeFromJson(
    json['source_type'],
  ),
  sourceId: json['source_id'] as String?,
  sceneKey: json['scene_key'] as String?,
  pronunciationScore: (json['pronunciation_score'] as num).toDouble(),
  accuracyScore: (json['accuracy_score'] as num?)?.toDouble(),
  fluencyScore: (json['fluency_score'] as num?)?.toDouble(),
  completenessScore: (json['completeness_score'] as num?)?.toDouble(),
  prosodyScore: (json['prosody_score'] as num?)?.toDouble(),
  wordFeedback: (json['word_feedback'] as List<dynamic>?)
      ?.map(
        (e) => ShadowingSavePost$RequestBody$WordFeedback$Item.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  feedbackText: json['feedback_text'] as String?,
  audioPath: json['audio_path'] as String?,
);

Map<String, dynamic> _$ShadowingSavePost$RequestBodyToJson(
  ShadowingSavePost$RequestBody instance,
) => <String, dynamic>{
  'target_text': instance.targetText,
  'source_type': shadowingSavePost$RequestBodySourceTypeToJson(
    instance.sourceType,
  ),
  'source_id': instance.sourceId,
  'scene_key': instance.sceneKey,
  'pronunciation_score': instance.pronunciationScore,
  'accuracy_score': instance.accuracyScore,
  'fluency_score': instance.fluencyScore,
  'completeness_score': instance.completenessScore,
  'prosody_score': instance.prosodyScore,
  'word_feedback': instance.wordFeedback?.map((e) => e.toJson()).toList(),
  'feedback_text': instance.feedbackText,
  'audio_path': instance.audioPath,
};

HealthGet$Response _$HealthGet$ResponseFromJson(Map<String, dynamic> json) =>
    HealthGet$Response(status: json['status'] as String);

Map<String, dynamic> _$HealthGet$ResponseToJson(HealthGet$Response instance) =>
    <String, dynamic>{'status': instance.status};

ChatSendPost$Response _$ChatSendPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ChatSendPost$Response(
  message: json['message'] as String,
  translation: json['translation'] as String?,
  reviewFeedback: json['review_feedback'] == null
      ? null
      : ChatSendPost$Response$ReviewFeedback.fromJson(
          json['review_feedback'] as Map<String, dynamic>,
        ),
);

Map<String, dynamic> _$ChatSendPost$ResponseToJson(
  ChatSendPost$Response instance,
) => <String, dynamic>{
  'message': instance.message,
  'translation': instance.translation,
  'review_feedback': instance.reviewFeedback?.toJson(),
};

ChatTranscribePost$Response _$ChatTranscribePost$ResponseFromJson(
  Map<String, dynamic> json,
) => ChatTranscribePost$Response(
  text: json['text'] as String,
  rawText: json['raw_text'] as String?,
);

Map<String, dynamic> _$ChatTranscribePost$ResponseToJson(
  ChatTranscribePost$Response instance,
) => <String, dynamic>{'text': instance.text, 'raw_text': instance.rawText};

ChatHintPost$Response _$ChatHintPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ChatHintPost$Response(
  hints:
      (json['hints'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
);

Map<String, dynamic> _$ChatHintPost$ResponseToJson(
  ChatHintPost$Response instance,
) => <String, dynamic>{'hints': instance.hints};

SceneGeneratePost$Response _$SceneGeneratePost$ResponseFromJson(
  Map<String, dynamic> json,
) => SceneGeneratePost$Response(
  title: json['title'] as String,
  aiRole: json['ai_role'] as String,
  userRole: json['user_role'] as String,
  goal: json['goal'] as String,
  description: json['description'] as String,
  initialMessage: json['initial_message'] as String,
  emoji: json['emoji'] as String,
);

Map<String, dynamic> _$SceneGeneratePost$ResponseToJson(
  SceneGeneratePost$Response instance,
) => <String, dynamic>{
  'title': instance.title,
  'ai_role': instance.aiRole,
  'user_role': instance.userRole,
  'goal': instance.goal,
  'description': instance.description,
  'initial_message': instance.initialMessage,
  'emoji': instance.emoji,
};

ScenePolishPost$Response _$ScenePolishPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ScenePolishPost$Response(polishedText: json['polished_text'] as String);

Map<String, dynamic> _$ScenePolishPost$ResponseToJson(
  ScenePolishPost$Response instance,
) => <String, dynamic>{'polished_text': instance.polishedText};

CommonTranslatePost$Response _$CommonTranslatePost$ResponseFromJson(
  Map<String, dynamic> json,
) => CommonTranslatePost$Response(translation: json['translation'] as String);

Map<String, dynamic> _$CommonTranslatePost$ResponseToJson(
  CommonTranslatePost$Response instance,
) => <String, dynamic>{'translation': instance.translation};

ChatShadowPost$Response _$ChatShadowPost$ResponseFromJson(
  Map<String, dynamic> json,
) => ChatShadowPost$Response(
  score: (json['score'] as num).toDouble(),
  details: ChatShadowPost$Response$Details.fromJson(
    json['details'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ChatShadowPost$ResponseToJson(
  ChatShadowPost$Response instance,
) => <String, dynamic>{
  'score': instance.score,
  'details': instance.details.toJson(),
};

ChatOptimizePost$Response _$ChatOptimizePost$ResponseFromJson(
  Map<String, dynamic> json,
) => ChatOptimizePost$Response(optimizedText: json['optimized_text'] as String);

Map<String, dynamic> _$ChatOptimizePost$ResponseToJson(
  ChatOptimizePost$Response instance,
) => <String, dynamic>{'optimized_text': instance.optimizedText};

ChatMessagesDelete$Response _$ChatMessagesDelete$ResponseFromJson(
  Map<String, dynamic> json,
) => ChatMessagesDelete$Response(
  success: json['success'] as bool,
  deletedCount: (json['deleted_count'] as num).toDouble(),
);

Map<String, dynamic> _$ChatMessagesDelete$ResponseToJson(
  ChatMessagesDelete$Response instance,
) => <String, dynamic>{
  'success': instance.success,
  'deleted_count': instance.deletedCount,
};

UserSyncPost$Response _$UserSyncPost$ResponseFromJson(
  Map<String, dynamic> json,
) => UserSyncPost$Response(
  status: json['status'] as String,
  syncedAt: json['synced_at'] as String,
);

Map<String, dynamic> _$UserSyncPost$ResponseToJson(
  UserSyncPost$Response instance,
) => <String, dynamic>{
  'status': instance.status,
  'synced_at': instance.syncedAt,
};

ShadowingSavePost$Response _$ShadowingSavePost$ResponseFromJson(
  Map<String, dynamic> json,
) => ShadowingSavePost$Response(
  success: json['success'] as bool,
  data: ShadowingSavePost$Response$Data.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ShadowingSavePost$ResponseToJson(
  ShadowingSavePost$Response instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data.toJson(),
};

ShadowingHistoryGet$Response _$ShadowingHistoryGet$ResponseFromJson(
  Map<String, dynamic> json,
) => ShadowingHistoryGet$Response(
  success: json['success'] as bool,
  data: ShadowingHistoryGet$Response$Data.fromJson(
    json['data'] as Map<String, dynamic>,
  ),
);

Map<String, dynamic> _$ShadowingHistoryGet$ResponseToJson(
  ShadowingHistoryGet$Response instance,
) => <String, dynamic>{
  'success': instance.success,
  'data': instance.data.toJson(),
};

ChatSendPost$RequestBody$History$Item
_$ChatSendPost$RequestBody$History$ItemFromJson(Map<String, dynamic> json) =>
    ChatSendPost$RequestBody$History$Item(
      role: json['role'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$ChatSendPost$RequestBody$History$ItemToJson(
  ChatSendPost$RequestBody$History$Item instance,
) => <String, dynamic>{'role': instance.role, 'content': instance.content};

ChatHintPost$RequestBody$History$Item
_$ChatHintPost$RequestBody$History$ItemFromJson(Map<String, dynamic> json) =>
    ChatHintPost$RequestBody$History$Item(
      role: json['role'] as String,
      content: json['content'] as String,
    );

Map<String, dynamic> _$ChatHintPost$RequestBody$History$ItemToJson(
  ChatHintPost$RequestBody$History$Item instance,
) => <String, dynamic>{'role': instance.role, 'content': instance.content};

ChatOptimizePost$RequestBody$History$Item
_$ChatOptimizePost$RequestBody$History$ItemFromJson(
  Map<String, dynamic> json,
) => ChatOptimizePost$RequestBody$History$Item(
  role: json['role'] as String,
  content: json['content'] as String,
);

Map<String, dynamic> _$ChatOptimizePost$RequestBody$History$ItemToJson(
  ChatOptimizePost$RequestBody$History$Item instance,
) => <String, dynamic>{'role': instance.role, 'content': instance.content};

ShadowingSavePost$RequestBody$WordFeedback$Item
_$ShadowingSavePost$RequestBody$WordFeedback$ItemFromJson(
  Map<String, dynamic> json,
) => ShadowingSavePost$RequestBody$WordFeedback$Item(
  text: json['text'] as String,
  score: (json['score'] as num).toDouble(),
  level: shadowingSavePost$RequestBody$WordFeedback$ItemLevelFromJson(
    json['level'],
  ),
  errorType: json['error_type'] as String,
  phonemes: (json['phonemes'] as List<dynamic>)
      .map(
        (e) =>
            ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$Item.fromJson(
              e as Map<String, dynamic>,
            ),
      )
      .toList(),
);

Map<String, dynamic> _$ShadowingSavePost$RequestBody$WordFeedback$ItemToJson(
  ShadowingSavePost$RequestBody$WordFeedback$Item instance,
) => <String, dynamic>{
  'text': instance.text,
  'score': instance.score,
  'level': shadowingSavePost$RequestBody$WordFeedback$ItemLevelToJson(
    instance.level,
  ),
  'error_type': instance.errorType,
  'phonemes': instance.phonemes.map((e) => e.toJson()).toList(),
};

ChatSendPost$Response$ReviewFeedback
_$ChatSendPost$Response$ReviewFeedbackFromJson(Map<String, dynamic> json) =>
    ChatSendPost$Response$ReviewFeedback(
      isPerfect: json['is_perfect'] as bool,
      correctedText: json['corrected_text'] as String,
      nativeExpression: json['native_expression'] as String,
      explanation: json['explanation'] as String,
      exampleAnswer: json['example_answer'] as String,
    );

Map<String, dynamic> _$ChatSendPost$Response$ReviewFeedbackToJson(
  ChatSendPost$Response$ReviewFeedback instance,
) => <String, dynamic>{
  'is_perfect': instance.isPerfect,
  'corrected_text': instance.correctedText,
  'native_expression': instance.nativeExpression,
  'explanation': instance.explanation,
  'example_answer': instance.exampleAnswer,
};

ChatShadowPost$Response$Details _$ChatShadowPost$Response$DetailsFromJson(
  Map<String, dynamic> json,
) => ChatShadowPost$Response$Details(
  intonationScore: (json['intonation_score'] as num).toDouble(),
  pronunciationScore: (json['pronunciation_score'] as num).toDouble(),
  feedback: json['feedback'] as String,
);

Map<String, dynamic> _$ChatShadowPost$Response$DetailsToJson(
  ChatShadowPost$Response$Details instance,
) => <String, dynamic>{
  'intonation_score': instance.intonationScore,
  'pronunciation_score': instance.pronunciationScore,
  'feedback': instance.feedback,
};

ShadowingSavePost$Response$Data _$ShadowingSavePost$Response$DataFromJson(
  Map<String, dynamic> json,
) => ShadowingSavePost$Response$Data(
  id: json['id'] as String,
  practicedAt: json['practiced_at'] as String,
);

Map<String, dynamic> _$ShadowingSavePost$Response$DataToJson(
  ShadowingSavePost$Response$Data instance,
) => <String, dynamic>{'id': instance.id, 'practiced_at': instance.practicedAt};

ShadowingHistoryGet$Response$Data _$ShadowingHistoryGet$Response$DataFromJson(
  Map<String, dynamic> json,
) => ShadowingHistoryGet$Response$Data(
  practices: (json['practices'] as List<dynamic>)
      .map(
        (e) => ShadowingHistoryGet$Response$Data$Practices$Item.fromJson(
          e as Map<String, dynamic>,
        ),
      )
      .toList(),
  total: (json['total'] as num).toDouble(),
);

Map<String, dynamic> _$ShadowingHistoryGet$Response$DataToJson(
  ShadowingHistoryGet$Response$Data instance,
) => <String, dynamic>{
  'practices': instance.practices.map((e) => e.toJson()).toList(),
  'total': instance.total,
};

ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$Item
_$ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$ItemFromJson(
  Map<String, dynamic> json,
) => ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$Item(
  phoneme: json['phoneme'] as String,
  accuracyScore: (json['accuracy_score'] as num).toDouble(),
  offset: (json['offset'] as num?)?.toDouble(),
  duration: (json['duration'] as num?)?.toDouble(),
);

Map<String, dynamic>
_$ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$ItemToJson(
  ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$Item instance,
) => <String, dynamic>{
  'phoneme': instance.phoneme,
  'accuracy_score': instance.accuracyScore,
  'offset': instance.offset,
  'duration': instance.duration,
};

ShadowingHistoryGet$Response$Data$Practices$Item
_$ShadowingHistoryGet$Response$Data$Practices$ItemFromJson(
  Map<String, dynamic> json,
) => ShadowingHistoryGet$Response$Data$Practices$Item(
  id: json['id'] as String,
  targetText: json['target_text'] as String,
  sourceType: json['source_type'] as String,
  sourceId: json['source_id'] as String?,
  pronunciationScore: (json['pronunciation_score'] as num).toDouble(),
  accuracyScore: (json['accuracy_score'] as num?)?.toDouble(),
  fluencyScore: (json['fluency_score'] as num?)?.toDouble(),
  completenessScore: (json['completeness_score'] as num?)?.toDouble(),
  prosodyScore: (json['prosody_score'] as num?)?.toDouble(),
  wordFeedback: (json['word_feedback'] as List<dynamic>)
      .map(
        (e) =>
            ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item.fromJson(
              e as Map<String, dynamic>,
            ),
      )
      .toList(),
  feedbackText: json['feedback_text'] as String?,
  audioPath: json['audio_path'] as String?,
  practicedAt: json['practiced_at'] as String,
);

Map<String, dynamic> _$ShadowingHistoryGet$Response$Data$Practices$ItemToJson(
  ShadowingHistoryGet$Response$Data$Practices$Item instance,
) => <String, dynamic>{
  'id': instance.id,
  'target_text': instance.targetText,
  'source_type': instance.sourceType,
  'source_id': instance.sourceId,
  'pronunciation_score': instance.pronunciationScore,
  'accuracy_score': instance.accuracyScore,
  'fluency_score': instance.fluencyScore,
  'completeness_score': instance.completenessScore,
  'prosody_score': instance.prosodyScore,
  'word_feedback': instance.wordFeedback.map((e) => e.toJson()).toList(),
  'feedback_text': instance.feedbackText,
  'audio_path': instance.audioPath,
  'practiced_at': instance.practicedAt,
};

ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item
_$ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemFromJson(
  Map<String, dynamic> json,
) => ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item(
  text: json['text'] as String,
  score: (json['score'] as num).toDouble(),
  level:
      shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevelFromJson(
        json['level'],
      ),
  errorType: json['error_type'] as String,
  phonemes: (json['phonemes'] as List<dynamic>)
      .map(
        (e) =>
            ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$Item.fromJson(
              e as Map<String, dynamic>,
            ),
      )
      .toList(),
);

Map<String, dynamic>
_$ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemToJson(
  ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item instance,
) => <String, dynamic>{
  'text': instance.text,
  'score': instance.score,
  'level':
      shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevelToJson(
        instance.level,
      ),
  'error_type': instance.errorType,
  'phonemes': instance.phonemes.map((e) => e.toJson()).toList(),
};

ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$Item
_$ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$ItemFromJson(
  Map<String, dynamic> json,
) =>
    ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$Item(
      phoneme: json['phoneme'] as String,
      accuracyScore: (json['accuracy_score'] as num).toDouble(),
      offset: (json['offset'] as num?)?.toDouble(),
      duration: (json['duration'] as num?)?.toDouble(),
    );

Map<String, dynamic>
_$ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$ItemToJson(
  ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$Item
  instance,
) => <String, dynamic>{
  'phoneme': instance.phoneme,
  'accuracy_score': instance.accuracyScore,
  'offset': instance.offset,
  'duration': instance.duration,
};
