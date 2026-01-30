// coverage:ignore-file
// ignore_for_file: type=lint

import 'package:json_annotation/json_annotation.dart';
import 'package:collection/collection.dart';

import 'swagger.enums.swagger.dart' as enums;

part 'swagger.models.swagger.g.dart';

@JsonSerializable(explicitToJson: true)
class ChatSendPost$RequestBody {
  const ChatSendPost$RequestBody({
    required this.message,
    this.history,
    required this.sceneContext,
    this.nativeLanguage,
    this.targetLanguage,
  });

  factory ChatSendPost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$ChatSendPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$ChatSendPost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$ChatSendPost$RequestBodyToJson(this);

  @JsonKey(name: 'message')
  final String message;
  @JsonKey(name: 'history')
  final List<ChatSendPost$RequestBody$History$Item>? history;
  @JsonKey(name: 'scene_context')
  final String sceneContext;
  @JsonKey(name: 'native_language')
  final String? nativeLanguage;
  @JsonKey(name: 'target_language')
  final String? targetLanguage;
  static const fromJsonFactory = _$ChatSendPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatSendPost$RequestBody &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(
                  other.message,
                  message,
                )) &&
            (identical(other.history, history) ||
                const DeepCollectionEquality().equals(
                  other.history,
                  history,
                )) &&
            (identical(other.sceneContext, sceneContext) ||
                const DeepCollectionEquality().equals(
                  other.sceneContext,
                  sceneContext,
                )) &&
            (identical(other.nativeLanguage, nativeLanguage) ||
                const DeepCollectionEquality().equals(
                  other.nativeLanguage,
                  nativeLanguage,
                )) &&
            (identical(other.targetLanguage, targetLanguage) ||
                const DeepCollectionEquality().equals(
                  other.targetLanguage,
                  targetLanguage,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(history) ^
      const DeepCollectionEquality().hash(sceneContext) ^
      const DeepCollectionEquality().hash(nativeLanguage) ^
      const DeepCollectionEquality().hash(targetLanguage) ^
      runtimeType.hashCode;
}

extension $ChatSendPost$RequestBodyExtension on ChatSendPost$RequestBody {
  ChatSendPost$RequestBody copyWith({
    String? message,
    List<ChatSendPost$RequestBody$History$Item>? history,
    String? sceneContext,
    String? nativeLanguage,
    String? targetLanguage,
  }) {
    return ChatSendPost$RequestBody(
      message: message ?? this.message,
      history: history ?? this.history,
      sceneContext: sceneContext ?? this.sceneContext,
      nativeLanguage: nativeLanguage ?? this.nativeLanguage,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }

  ChatSendPost$RequestBody copyWithWrapped({
    Wrapped<String>? message,
    Wrapped<List<ChatSendPost$RequestBody$History$Item>?>? history,
    Wrapped<String>? sceneContext,
    Wrapped<String?>? nativeLanguage,
    Wrapped<String?>? targetLanguage,
  }) {
    return ChatSendPost$RequestBody(
      message: (message != null ? message.value : this.message),
      history: (history != null ? history.value : this.history),
      sceneContext: (sceneContext != null
          ? sceneContext.value
          : this.sceneContext),
      nativeLanguage: (nativeLanguage != null
          ? nativeLanguage.value
          : this.nativeLanguage),
      targetLanguage: (targetLanguage != null
          ? targetLanguage.value
          : this.targetLanguage),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChatTranscribePost$RequestBody {
  const ChatTranscribePost$RequestBody({required this.audio});

  factory ChatTranscribePost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$ChatTranscribePost$RequestBodyFromJson(json);

  static const toJsonFactory = _$ChatTranscribePost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$ChatTranscribePost$RequestBodyToJson(this);

  @JsonKey(name: 'audio')
  final String audio;
  static const fromJsonFactory = _$ChatTranscribePost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatTranscribePost$RequestBody &&
            (identical(other.audio, audio) ||
                const DeepCollectionEquality().equals(other.audio, audio)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(audio) ^ runtimeType.hashCode;
}

extension $ChatTranscribePost$RequestBodyExtension
    on ChatTranscribePost$RequestBody {
  ChatTranscribePost$RequestBody copyWith({String? audio}) {
    return ChatTranscribePost$RequestBody(audio: audio ?? this.audio);
  }

  ChatTranscribePost$RequestBody copyWithWrapped({Wrapped<String>? audio}) {
    return ChatTranscribePost$RequestBody(
      audio: (audio != null ? audio.value : this.audio),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChatHintPost$RequestBody {
  const ChatHintPost$RequestBody({
    this.message,
    this.history,
    required this.sceneContext,
    this.targetLanguage,
  });

  factory ChatHintPost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$ChatHintPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$ChatHintPost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$ChatHintPost$RequestBodyToJson(this);

  @JsonKey(name: 'message')
  final String? message;
  @JsonKey(name: 'history')
  final List<ChatHintPost$RequestBody$History$Item>? history;
  @JsonKey(name: 'scene_context')
  final String sceneContext;
  @JsonKey(name: 'target_language')
  final String? targetLanguage;
  static const fromJsonFactory = _$ChatHintPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatHintPost$RequestBody &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(
                  other.message,
                  message,
                )) &&
            (identical(other.history, history) ||
                const DeepCollectionEquality().equals(
                  other.history,
                  history,
                )) &&
            (identical(other.sceneContext, sceneContext) ||
                const DeepCollectionEquality().equals(
                  other.sceneContext,
                  sceneContext,
                )) &&
            (identical(other.targetLanguage, targetLanguage) ||
                const DeepCollectionEquality().equals(
                  other.targetLanguage,
                  targetLanguage,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(history) ^
      const DeepCollectionEquality().hash(sceneContext) ^
      const DeepCollectionEquality().hash(targetLanguage) ^
      runtimeType.hashCode;
}

extension $ChatHintPost$RequestBodyExtension on ChatHintPost$RequestBody {
  ChatHintPost$RequestBody copyWith({
    String? message,
    List<ChatHintPost$RequestBody$History$Item>? history,
    String? sceneContext,
    String? targetLanguage,
  }) {
    return ChatHintPost$RequestBody(
      message: message ?? this.message,
      history: history ?? this.history,
      sceneContext: sceneContext ?? this.sceneContext,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }

  ChatHintPost$RequestBody copyWithWrapped({
    Wrapped<String?>? message,
    Wrapped<List<ChatHintPost$RequestBody$History$Item>?>? history,
    Wrapped<String>? sceneContext,
    Wrapped<String?>? targetLanguage,
  }) {
    return ChatHintPost$RequestBody(
      message: (message != null ? message.value : this.message),
      history: (history != null ? history.value : this.history),
      sceneContext: (sceneContext != null
          ? sceneContext.value
          : this.sceneContext),
      targetLanguage: (targetLanguage != null
          ? targetLanguage.value
          : this.targetLanguage),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class SceneGeneratePost$RequestBody {
  const SceneGeneratePost$RequestBody({
    required this.description,
    this.tone,
    this.targetLanguage,
  });

  factory SceneGeneratePost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$SceneGeneratePost$RequestBodyFromJson(json);

  static const toJsonFactory = _$SceneGeneratePost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$SceneGeneratePost$RequestBodyToJson(this);

  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'tone')
  final String? tone;
  @JsonKey(name: 'target_language')
  final String? targetLanguage;
  static const fromJsonFactory = _$SceneGeneratePost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SceneGeneratePost$RequestBody &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.tone, tone) ||
                const DeepCollectionEquality().equals(other.tone, tone)) &&
            (identical(other.targetLanguage, targetLanguage) ||
                const DeepCollectionEquality().equals(
                  other.targetLanguage,
                  targetLanguage,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(tone) ^
      const DeepCollectionEquality().hash(targetLanguage) ^
      runtimeType.hashCode;
}

extension $SceneGeneratePost$RequestBodyExtension
    on SceneGeneratePost$RequestBody {
  SceneGeneratePost$RequestBody copyWith({
    String? description,
    String? tone,
    String? targetLanguage,
  }) {
    return SceneGeneratePost$RequestBody(
      description: description ?? this.description,
      tone: tone ?? this.tone,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }

  SceneGeneratePost$RequestBody copyWithWrapped({
    Wrapped<String>? description,
    Wrapped<String?>? tone,
    Wrapped<String?>? targetLanguage,
  }) {
    return SceneGeneratePost$RequestBody(
      description: (description != null ? description.value : this.description),
      tone: (tone != null ? tone.value : this.tone),
      targetLanguage: (targetLanguage != null
          ? targetLanguage.value
          : this.targetLanguage),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ScenePolishPost$RequestBody {
  const ScenePolishPost$RequestBody({required this.description});

  factory ScenePolishPost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$ScenePolishPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$ScenePolishPost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$ScenePolishPost$RequestBodyToJson(this);

  @JsonKey(name: 'description')
  final String description;
  static const fromJsonFactory = _$ScenePolishPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ScenePolishPost$RequestBody &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(description) ^ runtimeType.hashCode;
}

extension $ScenePolishPost$RequestBodyExtension on ScenePolishPost$RequestBody {
  ScenePolishPost$RequestBody copyWith({String? description}) {
    return ScenePolishPost$RequestBody(
      description: description ?? this.description,
    );
  }

  ScenePolishPost$RequestBody copyWithWrapped({Wrapped<String>? description}) {
    return ScenePolishPost$RequestBody(
      description: (description != null ? description.value : this.description),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CommonTranslatePost$RequestBody {
  const CommonTranslatePost$RequestBody({
    required this.text,
    required this.targetLanguage,
  });

  factory CommonTranslatePost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$CommonTranslatePost$RequestBodyFromJson(json);

  static const toJsonFactory = _$CommonTranslatePost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$CommonTranslatePost$RequestBodyToJson(this);

  @JsonKey(name: 'text')
  final String text;
  @JsonKey(name: 'target_language')
  final String targetLanguage;
  static const fromJsonFactory = _$CommonTranslatePost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CommonTranslatePost$RequestBody &&
            (identical(other.text, text) ||
                const DeepCollectionEquality().equals(other.text, text)) &&
            (identical(other.targetLanguage, targetLanguage) ||
                const DeepCollectionEquality().equals(
                  other.targetLanguage,
                  targetLanguage,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(text) ^
      const DeepCollectionEquality().hash(targetLanguage) ^
      runtimeType.hashCode;
}

extension $CommonTranslatePost$RequestBodyExtension
    on CommonTranslatePost$RequestBody {
  CommonTranslatePost$RequestBody copyWith({
    String? text,
    String? targetLanguage,
  }) {
    return CommonTranslatePost$RequestBody(
      text: text ?? this.text,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }

  CommonTranslatePost$RequestBody copyWithWrapped({
    Wrapped<String>? text,
    Wrapped<String>? targetLanguage,
  }) {
    return CommonTranslatePost$RequestBody(
      text: (text != null ? text.value : this.text),
      targetLanguage: (targetLanguage != null
          ? targetLanguage.value
          : this.targetLanguage),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChatShadowPost$RequestBody {
  const ChatShadowPost$RequestBody({
    required this.targetText,
    required this.userAudioText,
  });

  factory ChatShadowPost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$ChatShadowPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$ChatShadowPost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$ChatShadowPost$RequestBodyToJson(this);

  @JsonKey(name: 'target_text')
  final String targetText;
  @JsonKey(name: 'user_audio_text')
  final String userAudioText;
  static const fromJsonFactory = _$ChatShadowPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatShadowPost$RequestBody &&
            (identical(other.targetText, targetText) ||
                const DeepCollectionEquality().equals(
                  other.targetText,
                  targetText,
                )) &&
            (identical(other.userAudioText, userAudioText) ||
                const DeepCollectionEquality().equals(
                  other.userAudioText,
                  userAudioText,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(targetText) ^
      const DeepCollectionEquality().hash(userAudioText) ^
      runtimeType.hashCode;
}

extension $ChatShadowPost$RequestBodyExtension on ChatShadowPost$RequestBody {
  ChatShadowPost$RequestBody copyWith({
    String? targetText,
    String? userAudioText,
  }) {
    return ChatShadowPost$RequestBody(
      targetText: targetText ?? this.targetText,
      userAudioText: userAudioText ?? this.userAudioText,
    );
  }

  ChatShadowPost$RequestBody copyWithWrapped({
    Wrapped<String>? targetText,
    Wrapped<String>? userAudioText,
  }) {
    return ChatShadowPost$RequestBody(
      targetText: (targetText != null ? targetText.value : this.targetText),
      userAudioText: (userAudioText != null
          ? userAudioText.value
          : this.userAudioText),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChatOptimizePost$RequestBody {
  const ChatOptimizePost$RequestBody({
    required this.message,
    required this.sceneContext,
    this.history,
    this.targetLanguage,
  });

  factory ChatOptimizePost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$ChatOptimizePost$RequestBodyFromJson(json);

  static const toJsonFactory = _$ChatOptimizePost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$ChatOptimizePost$RequestBodyToJson(this);

  @JsonKey(name: 'message')
  final String message;
  @JsonKey(name: 'scene_context')
  final String sceneContext;
  @JsonKey(name: 'history')
  final List<ChatOptimizePost$RequestBody$History$Item>? history;
  @JsonKey(name: 'target_language')
  final String? targetLanguage;
  static const fromJsonFactory = _$ChatOptimizePost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatOptimizePost$RequestBody &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(
                  other.message,
                  message,
                )) &&
            (identical(other.sceneContext, sceneContext) ||
                const DeepCollectionEquality().equals(
                  other.sceneContext,
                  sceneContext,
                )) &&
            (identical(other.history, history) ||
                const DeepCollectionEquality().equals(
                  other.history,
                  history,
                )) &&
            (identical(other.targetLanguage, targetLanguage) ||
                const DeepCollectionEquality().equals(
                  other.targetLanguage,
                  targetLanguage,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(sceneContext) ^
      const DeepCollectionEquality().hash(history) ^
      const DeepCollectionEquality().hash(targetLanguage) ^
      runtimeType.hashCode;
}

extension $ChatOptimizePost$RequestBodyExtension
    on ChatOptimizePost$RequestBody {
  ChatOptimizePost$RequestBody copyWith({
    String? message,
    String? sceneContext,
    List<ChatOptimizePost$RequestBody$History$Item>? history,
    String? targetLanguage,
  }) {
    return ChatOptimizePost$RequestBody(
      message: message ?? this.message,
      sceneContext: sceneContext ?? this.sceneContext,
      history: history ?? this.history,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }

  ChatOptimizePost$RequestBody copyWithWrapped({
    Wrapped<String>? message,
    Wrapped<String>? sceneContext,
    Wrapped<List<ChatOptimizePost$RequestBody$History$Item>?>? history,
    Wrapped<String?>? targetLanguage,
  }) {
    return ChatOptimizePost$RequestBody(
      message: (message != null ? message.value : this.message),
      sceneContext: (sceneContext != null
          ? sceneContext.value
          : this.sceneContext),
      history: (history != null ? history.value : this.history),
      targetLanguage: (targetLanguage != null
          ? targetLanguage.value
          : this.targetLanguage),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChatMessagesDelete$RequestBody {
  const ChatMessagesDelete$RequestBody({
    required this.sceneKey,
    required this.messageIds,
  });

  factory ChatMessagesDelete$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$ChatMessagesDelete$RequestBodyFromJson(json);

  static const toJsonFactory = _$ChatMessagesDelete$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$ChatMessagesDelete$RequestBodyToJson(this);

  @JsonKey(name: 'scene_key')
  final String sceneKey;
  @JsonKey(name: 'message_ids', defaultValue: <String>[])
  final List<String> messageIds;
  static const fromJsonFactory = _$ChatMessagesDelete$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatMessagesDelete$RequestBody &&
            (identical(other.sceneKey, sceneKey) ||
                const DeepCollectionEquality().equals(
                  other.sceneKey,
                  sceneKey,
                )) &&
            (identical(other.messageIds, messageIds) ||
                const DeepCollectionEquality().equals(
                  other.messageIds,
                  messageIds,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(sceneKey) ^
      const DeepCollectionEquality().hash(messageIds) ^
      runtimeType.hashCode;
}

extension $ChatMessagesDelete$RequestBodyExtension
    on ChatMessagesDelete$RequestBody {
  ChatMessagesDelete$RequestBody copyWith({
    String? sceneKey,
    List<String>? messageIds,
  }) {
    return ChatMessagesDelete$RequestBody(
      sceneKey: sceneKey ?? this.sceneKey,
      messageIds: messageIds ?? this.messageIds,
    );
  }

  ChatMessagesDelete$RequestBody copyWithWrapped({
    Wrapped<String>? sceneKey,
    Wrapped<List<String>>? messageIds,
  }) {
    return ChatMessagesDelete$RequestBody(
      sceneKey: (sceneKey != null ? sceneKey.value : this.sceneKey),
      messageIds: (messageIds != null ? messageIds.value : this.messageIds),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UserSyncPost$RequestBody {
  const UserSyncPost$RequestBody({required this.id, this.email});

  factory UserSyncPost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$UserSyncPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$UserSyncPost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$UserSyncPost$RequestBodyToJson(this);

  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'email')
  final String? email;
  static const fromJsonFactory = _$UserSyncPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UserSyncPost$RequestBody &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.email, email) ||
                const DeepCollectionEquality().equals(other.email, email)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(email) ^
      runtimeType.hashCode;
}

extension $UserSyncPost$RequestBodyExtension on UserSyncPost$RequestBody {
  UserSyncPost$RequestBody copyWith({String? id, String? email}) {
    return UserSyncPost$RequestBody(
      id: id ?? this.id,
      email: email ?? this.email,
    );
  }

  UserSyncPost$RequestBody copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String?>? email,
  }) {
    return UserSyncPost$RequestBody(
      id: (id != null ? id.value : this.id),
      email: (email != null ? email.value : this.email),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ShadowingUpsertPut$RequestBody {
  const ShadowingUpsertPut$RequestBody({
    required this.targetText,
    required this.sourceType,
    required this.sourceId,
    this.sceneKey,
    required this.pronunciationScore,
    this.accuracyScore,
    this.fluencyScore,
    this.completenessScore,
    this.prosodyScore,
    this.wordFeedback,
    this.feedbackText,
    this.segments,
  });

  factory ShadowingUpsertPut$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$ShadowingUpsertPut$RequestBodyFromJson(json);

  static const toJsonFactory = _$ShadowingUpsertPut$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$ShadowingUpsertPut$RequestBodyToJson(this);

  @JsonKey(name: 'target_text')
  final String targetText;
  @JsonKey(
    name: 'source_type',
    toJson: shadowingUpsertPut$RequestBodySourceTypeToJson,
    fromJson: shadowingUpsertPut$RequestBodySourceTypeFromJson,
  )
  final enums.ShadowingUpsertPut$RequestBodySourceType sourceType;
  @JsonKey(name: 'source_id')
  final String sourceId;
  @JsonKey(name: 'scene_key')
  final String? sceneKey;
  @JsonKey(name: 'pronunciation_score')
  final double pronunciationScore;
  @JsonKey(name: 'accuracy_score')
  final double? accuracyScore;
  @JsonKey(name: 'fluency_score')
  final double? fluencyScore;
  @JsonKey(name: 'completeness_score')
  final double? completenessScore;
  @JsonKey(name: 'prosody_score')
  final double? prosodyScore;
  @JsonKey(name: 'word_feedback')
  final List<ShadowingUpsertPut$RequestBody$WordFeedback$Item>? wordFeedback;
  @JsonKey(name: 'feedback_text')
  final String? feedbackText;
  @JsonKey(name: 'segments')
  final List<ShadowingUpsertPut$RequestBody$Segments$Item>? segments;
  static const fromJsonFactory = _$ShadowingUpsertPut$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShadowingUpsertPut$RequestBody &&
            (identical(other.targetText, targetText) ||
                const DeepCollectionEquality().equals(
                  other.targetText,
                  targetText,
                )) &&
            (identical(other.sourceType, sourceType) ||
                const DeepCollectionEquality().equals(
                  other.sourceType,
                  sourceType,
                )) &&
            (identical(other.sourceId, sourceId) ||
                const DeepCollectionEquality().equals(
                  other.sourceId,
                  sourceId,
                )) &&
            (identical(other.sceneKey, sceneKey) ||
                const DeepCollectionEquality().equals(
                  other.sceneKey,
                  sceneKey,
                )) &&
            (identical(other.pronunciationScore, pronunciationScore) ||
                const DeepCollectionEquality().equals(
                  other.pronunciationScore,
                  pronunciationScore,
                )) &&
            (identical(other.accuracyScore, accuracyScore) ||
                const DeepCollectionEquality().equals(
                  other.accuracyScore,
                  accuracyScore,
                )) &&
            (identical(other.fluencyScore, fluencyScore) ||
                const DeepCollectionEquality().equals(
                  other.fluencyScore,
                  fluencyScore,
                )) &&
            (identical(other.completenessScore, completenessScore) ||
                const DeepCollectionEquality().equals(
                  other.completenessScore,
                  completenessScore,
                )) &&
            (identical(other.prosodyScore, prosodyScore) ||
                const DeepCollectionEquality().equals(
                  other.prosodyScore,
                  prosodyScore,
                )) &&
            (identical(other.wordFeedback, wordFeedback) ||
                const DeepCollectionEquality().equals(
                  other.wordFeedback,
                  wordFeedback,
                )) &&
            (identical(other.feedbackText, feedbackText) ||
                const DeepCollectionEquality().equals(
                  other.feedbackText,
                  feedbackText,
                )) &&
            (identical(other.segments, segments) ||
                const DeepCollectionEquality().equals(
                  other.segments,
                  segments,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(targetText) ^
      const DeepCollectionEquality().hash(sourceType) ^
      const DeepCollectionEquality().hash(sourceId) ^
      const DeepCollectionEquality().hash(sceneKey) ^
      const DeepCollectionEquality().hash(pronunciationScore) ^
      const DeepCollectionEquality().hash(accuracyScore) ^
      const DeepCollectionEquality().hash(fluencyScore) ^
      const DeepCollectionEquality().hash(completenessScore) ^
      const DeepCollectionEquality().hash(prosodyScore) ^
      const DeepCollectionEquality().hash(wordFeedback) ^
      const DeepCollectionEquality().hash(feedbackText) ^
      const DeepCollectionEquality().hash(segments) ^
      runtimeType.hashCode;
}

extension $ShadowingUpsertPut$RequestBodyExtension
    on ShadowingUpsertPut$RequestBody {
  ShadowingUpsertPut$RequestBody copyWith({
    String? targetText,
    enums.ShadowingUpsertPut$RequestBodySourceType? sourceType,
    String? sourceId,
    String? sceneKey,
    double? pronunciationScore,
    double? accuracyScore,
    double? fluencyScore,
    double? completenessScore,
    double? prosodyScore,
    List<ShadowingUpsertPut$RequestBody$WordFeedback$Item>? wordFeedback,
    String? feedbackText,
    List<ShadowingUpsertPut$RequestBody$Segments$Item>? segments,
  }) {
    return ShadowingUpsertPut$RequestBody(
      targetText: targetText ?? this.targetText,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      sceneKey: sceneKey ?? this.sceneKey,
      pronunciationScore: pronunciationScore ?? this.pronunciationScore,
      accuracyScore: accuracyScore ?? this.accuracyScore,
      fluencyScore: fluencyScore ?? this.fluencyScore,
      completenessScore: completenessScore ?? this.completenessScore,
      prosodyScore: prosodyScore ?? this.prosodyScore,
      wordFeedback: wordFeedback ?? this.wordFeedback,
      feedbackText: feedbackText ?? this.feedbackText,
      segments: segments ?? this.segments,
    );
  }

  ShadowingUpsertPut$RequestBody copyWithWrapped({
    Wrapped<String>? targetText,
    Wrapped<enums.ShadowingUpsertPut$RequestBodySourceType>? sourceType,
    Wrapped<String>? sourceId,
    Wrapped<String?>? sceneKey,
    Wrapped<double>? pronunciationScore,
    Wrapped<double?>? accuracyScore,
    Wrapped<double?>? fluencyScore,
    Wrapped<double?>? completenessScore,
    Wrapped<double?>? prosodyScore,
    Wrapped<List<ShadowingUpsertPut$RequestBody$WordFeedback$Item>?>?
    wordFeedback,
    Wrapped<String?>? feedbackText,
    Wrapped<List<ShadowingUpsertPut$RequestBody$Segments$Item>?>? segments,
  }) {
    return ShadowingUpsertPut$RequestBody(
      targetText: (targetText != null ? targetText.value : this.targetText),
      sourceType: (sourceType != null ? sourceType.value : this.sourceType),
      sourceId: (sourceId != null ? sourceId.value : this.sourceId),
      sceneKey: (sceneKey != null ? sceneKey.value : this.sceneKey),
      pronunciationScore: (pronunciationScore != null
          ? pronunciationScore.value
          : this.pronunciationScore),
      accuracyScore: (accuracyScore != null
          ? accuracyScore.value
          : this.accuracyScore),
      fluencyScore: (fluencyScore != null
          ? fluencyScore.value
          : this.fluencyScore),
      completenessScore: (completenessScore != null
          ? completenessScore.value
          : this.completenessScore),
      prosodyScore: (prosodyScore != null
          ? prosodyScore.value
          : this.prosodyScore),
      wordFeedback: (wordFeedback != null
          ? wordFeedback.value
          : this.wordFeedback),
      feedbackText: (feedbackText != null
          ? feedbackText.value
          : this.feedbackText),
      segments: (segments != null ? segments.value : this.segments),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AdminStandardScenesPost$RequestBody {
  const AdminStandardScenesPost$RequestBody({required this.scenes});

  factory AdminStandardScenesPost$RequestBody.fromJson(
    Map<String, dynamic> json,
  ) => _$AdminStandardScenesPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$AdminStandardScenesPost$RequestBodyToJson;
  Map<String, dynamic> toJson() =>
      _$AdminStandardScenesPost$RequestBodyToJson(this);

  @JsonKey(name: 'scenes')
  final List<AdminStandardScenesPost$RequestBody$Scenes$Item> scenes;
  static const fromJsonFactory = _$AdminStandardScenesPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdminStandardScenesPost$RequestBody &&
            (identical(other.scenes, scenes) ||
                const DeepCollectionEquality().equals(other.scenes, scenes)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(scenes) ^ runtimeType.hashCode;
}

extension $AdminStandardScenesPost$RequestBodyExtension
    on AdminStandardScenesPost$RequestBody {
  AdminStandardScenesPost$RequestBody copyWith({
    List<AdminStandardScenesPost$RequestBody$Scenes$Item>? scenes,
  }) {
    return AdminStandardScenesPost$RequestBody(scenes: scenes ?? this.scenes);
  }

  AdminStandardScenesPost$RequestBody copyWithWrapped({
    Wrapped<List<AdminStandardScenesPost$RequestBody$Scenes$Item>>? scenes,
  }) {
    return AdminStandardScenesPost$RequestBody(
      scenes: (scenes != null ? scenes.value : this.scenes),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AdminPushTestPost$RequestBody {
  const AdminPushTestPost$RequestBody({
    required this.userId,
    this.title,
    this.body,
    this.data,
  });

  factory AdminPushTestPost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$AdminPushTestPost$RequestBodyFromJson(json);

  static const toJsonFactory = _$AdminPushTestPost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$AdminPushTestPost$RequestBodyToJson(this);

  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'body')
  final String? body;
  @JsonKey(name: 'data')
  final Map<String, dynamic>? data;
  static const fromJsonFactory = _$AdminPushTestPost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdminPushTestPost$RequestBody &&
            (identical(other.userId, userId) ||
                const DeepCollectionEquality().equals(other.userId, userId)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.body, body) ||
                const DeepCollectionEquality().equals(other.body, body)) &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(userId) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(body) ^
      const DeepCollectionEquality().hash(data) ^
      runtimeType.hashCode;
}

extension $AdminPushTestPost$RequestBodyExtension
    on AdminPushTestPost$RequestBody {
  AdminPushTestPost$RequestBody copyWith({
    String? userId,
    String? title,
    String? body,
    Map<String, dynamic>? data,
  }) {
    return AdminPushTestPost$RequestBody(
      userId: userId ?? this.userId,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
    );
  }

  AdminPushTestPost$RequestBody copyWithWrapped({
    Wrapped<String>? userId,
    Wrapped<String?>? title,
    Wrapped<String?>? body,
    Wrapped<Map<String, dynamic>?>? data,
  }) {
    return AdminPushTestPost$RequestBody(
      userId: (userId != null ? userId.value : this.userId),
      title: (title != null ? title.value : this.title),
      body: (body != null ? body.value : this.body),
      data: (data != null ? data.value : this.data),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class HealthGet$Response {
  const HealthGet$Response({required this.status});

  factory HealthGet$Response.fromJson(Map<String, dynamic> json) =>
      _$HealthGet$ResponseFromJson(json);

  static const toJsonFactory = _$HealthGet$ResponseToJson;
  Map<String, dynamic> toJson() => _$HealthGet$ResponseToJson(this);

  @JsonKey(name: 'status')
  final String status;
  static const fromJsonFactory = _$HealthGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is HealthGet$Response &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(status) ^ runtimeType.hashCode;
}

extension $HealthGet$ResponseExtension on HealthGet$Response {
  HealthGet$Response copyWith({String? status}) {
    return HealthGet$Response(status: status ?? this.status);
  }

  HealthGet$Response copyWithWrapped({Wrapped<String>? status}) {
    return HealthGet$Response(
      status: (status != null ? status.value : this.status),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChatSendPost$Response {
  const ChatSendPost$Response({
    required this.message,
    this.translation,
    this.reviewFeedback,
  });

  factory ChatSendPost$Response.fromJson(Map<String, dynamic> json) =>
      _$ChatSendPost$ResponseFromJson(json);

  static const toJsonFactory = _$ChatSendPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$ChatSendPost$ResponseToJson(this);

  @JsonKey(name: 'message')
  final String message;
  @JsonKey(name: 'translation')
  final String? translation;
  @JsonKey(name: 'review_feedback')
  final ChatSendPost$Response$ReviewFeedback? reviewFeedback;
  static const fromJsonFactory = _$ChatSendPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatSendPost$Response &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(
                  other.message,
                  message,
                )) &&
            (identical(other.translation, translation) ||
                const DeepCollectionEquality().equals(
                  other.translation,
                  translation,
                )) &&
            (identical(other.reviewFeedback, reviewFeedback) ||
                const DeepCollectionEquality().equals(
                  other.reviewFeedback,
                  reviewFeedback,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(message) ^
      const DeepCollectionEquality().hash(translation) ^
      const DeepCollectionEquality().hash(reviewFeedback) ^
      runtimeType.hashCode;
}

extension $ChatSendPost$ResponseExtension on ChatSendPost$Response {
  ChatSendPost$Response copyWith({
    String? message,
    String? translation,
    ChatSendPost$Response$ReviewFeedback? reviewFeedback,
  }) {
    return ChatSendPost$Response(
      message: message ?? this.message,
      translation: translation ?? this.translation,
      reviewFeedback: reviewFeedback ?? this.reviewFeedback,
    );
  }

  ChatSendPost$Response copyWithWrapped({
    Wrapped<String>? message,
    Wrapped<String?>? translation,
    Wrapped<ChatSendPost$Response$ReviewFeedback?>? reviewFeedback,
  }) {
    return ChatSendPost$Response(
      message: (message != null ? message.value : this.message),
      translation: (translation != null ? translation.value : this.translation),
      reviewFeedback: (reviewFeedback != null
          ? reviewFeedback.value
          : this.reviewFeedback),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChatTranscribePost$Response {
  const ChatTranscribePost$Response({required this.text, this.rawText});

  factory ChatTranscribePost$Response.fromJson(Map<String, dynamic> json) =>
      _$ChatTranscribePost$ResponseFromJson(json);

  static const toJsonFactory = _$ChatTranscribePost$ResponseToJson;
  Map<String, dynamic> toJson() => _$ChatTranscribePost$ResponseToJson(this);

  @JsonKey(name: 'text')
  final String text;
  @JsonKey(name: 'raw_text')
  final String? rawText;
  static const fromJsonFactory = _$ChatTranscribePost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatTranscribePost$Response &&
            (identical(other.text, text) ||
                const DeepCollectionEquality().equals(other.text, text)) &&
            (identical(other.rawText, rawText) ||
                const DeepCollectionEquality().equals(other.rawText, rawText)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(text) ^
      const DeepCollectionEquality().hash(rawText) ^
      runtimeType.hashCode;
}

extension $ChatTranscribePost$ResponseExtension on ChatTranscribePost$Response {
  ChatTranscribePost$Response copyWith({String? text, String? rawText}) {
    return ChatTranscribePost$Response(
      text: text ?? this.text,
      rawText: rawText ?? this.rawText,
    );
  }

  ChatTranscribePost$Response copyWithWrapped({
    Wrapped<String>? text,
    Wrapped<String?>? rawText,
  }) {
    return ChatTranscribePost$Response(
      text: (text != null ? text.value : this.text),
      rawText: (rawText != null ? rawText.value : this.rawText),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChatHintPost$Response {
  const ChatHintPost$Response({required this.hints});

  factory ChatHintPost$Response.fromJson(Map<String, dynamic> json) =>
      _$ChatHintPost$ResponseFromJson(json);

  static const toJsonFactory = _$ChatHintPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$ChatHintPost$ResponseToJson(this);

  @JsonKey(name: 'hints', defaultValue: <String>[])
  final List<String> hints;
  static const fromJsonFactory = _$ChatHintPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatHintPost$Response &&
            (identical(other.hints, hints) ||
                const DeepCollectionEquality().equals(other.hints, hints)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(hints) ^ runtimeType.hashCode;
}

extension $ChatHintPost$ResponseExtension on ChatHintPost$Response {
  ChatHintPost$Response copyWith({List<String>? hints}) {
    return ChatHintPost$Response(hints: hints ?? this.hints);
  }

  ChatHintPost$Response copyWithWrapped({Wrapped<List<String>>? hints}) {
    return ChatHintPost$Response(
      hints: (hints != null ? hints.value : this.hints),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class SceneGeneratePost$Response {
  const SceneGeneratePost$Response({
    required this.title,
    required this.aiRole,
    required this.userRole,
    required this.goal,
    required this.description,
    required this.initialMessage,
    required this.emoji,
  });

  factory SceneGeneratePost$Response.fromJson(Map<String, dynamic> json) =>
      _$SceneGeneratePost$ResponseFromJson(json);

  static const toJsonFactory = _$SceneGeneratePost$ResponseToJson;
  Map<String, dynamic> toJson() => _$SceneGeneratePost$ResponseToJson(this);

  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'ai_role')
  final String aiRole;
  @JsonKey(name: 'user_role')
  final String userRole;
  @JsonKey(name: 'goal')
  final String goal;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'initial_message')
  final String initialMessage;
  @JsonKey(name: 'emoji')
  final String emoji;
  static const fromJsonFactory = _$SceneGeneratePost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is SceneGeneratePost$Response &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.aiRole, aiRole) ||
                const DeepCollectionEquality().equals(other.aiRole, aiRole)) &&
            (identical(other.userRole, userRole) ||
                const DeepCollectionEquality().equals(
                  other.userRole,
                  userRole,
                )) &&
            (identical(other.goal, goal) ||
                const DeepCollectionEquality().equals(other.goal, goal)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.initialMessage, initialMessage) ||
                const DeepCollectionEquality().equals(
                  other.initialMessage,
                  initialMessage,
                )) &&
            (identical(other.emoji, emoji) ||
                const DeepCollectionEquality().equals(other.emoji, emoji)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(aiRole) ^
      const DeepCollectionEquality().hash(userRole) ^
      const DeepCollectionEquality().hash(goal) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(initialMessage) ^
      const DeepCollectionEquality().hash(emoji) ^
      runtimeType.hashCode;
}

extension $SceneGeneratePost$ResponseExtension on SceneGeneratePost$Response {
  SceneGeneratePost$Response copyWith({
    String? title,
    String? aiRole,
    String? userRole,
    String? goal,
    String? description,
    String? initialMessage,
    String? emoji,
  }) {
    return SceneGeneratePost$Response(
      title: title ?? this.title,
      aiRole: aiRole ?? this.aiRole,
      userRole: userRole ?? this.userRole,
      goal: goal ?? this.goal,
      description: description ?? this.description,
      initialMessage: initialMessage ?? this.initialMessage,
      emoji: emoji ?? this.emoji,
    );
  }

  SceneGeneratePost$Response copyWithWrapped({
    Wrapped<String>? title,
    Wrapped<String>? aiRole,
    Wrapped<String>? userRole,
    Wrapped<String>? goal,
    Wrapped<String>? description,
    Wrapped<String>? initialMessage,
    Wrapped<String>? emoji,
  }) {
    return SceneGeneratePost$Response(
      title: (title != null ? title.value : this.title),
      aiRole: (aiRole != null ? aiRole.value : this.aiRole),
      userRole: (userRole != null ? userRole.value : this.userRole),
      goal: (goal != null ? goal.value : this.goal),
      description: (description != null ? description.value : this.description),
      initialMessage: (initialMessage != null
          ? initialMessage.value
          : this.initialMessage),
      emoji: (emoji != null ? emoji.value : this.emoji),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ScenePolishPost$Response {
  const ScenePolishPost$Response({required this.polishedText});

  factory ScenePolishPost$Response.fromJson(Map<String, dynamic> json) =>
      _$ScenePolishPost$ResponseFromJson(json);

  static const toJsonFactory = _$ScenePolishPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$ScenePolishPost$ResponseToJson(this);

  @JsonKey(name: 'polished_text')
  final String polishedText;
  static const fromJsonFactory = _$ScenePolishPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ScenePolishPost$Response &&
            (identical(other.polishedText, polishedText) ||
                const DeepCollectionEquality().equals(
                  other.polishedText,
                  polishedText,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(polishedText) ^ runtimeType.hashCode;
}

extension $ScenePolishPost$ResponseExtension on ScenePolishPost$Response {
  ScenePolishPost$Response copyWith({String? polishedText}) {
    return ScenePolishPost$Response(
      polishedText: polishedText ?? this.polishedText,
    );
  }

  ScenePolishPost$Response copyWithWrapped({Wrapped<String>? polishedText}) {
    return ScenePolishPost$Response(
      polishedText: (polishedText != null
          ? polishedText.value
          : this.polishedText),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class CommonTranslatePost$Response {
  const CommonTranslatePost$Response({required this.translation});

  factory CommonTranslatePost$Response.fromJson(Map<String, dynamic> json) =>
      _$CommonTranslatePost$ResponseFromJson(json);

  static const toJsonFactory = _$CommonTranslatePost$ResponseToJson;
  Map<String, dynamic> toJson() => _$CommonTranslatePost$ResponseToJson(this);

  @JsonKey(name: 'translation')
  final String translation;
  static const fromJsonFactory = _$CommonTranslatePost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CommonTranslatePost$Response &&
            (identical(other.translation, translation) ||
                const DeepCollectionEquality().equals(
                  other.translation,
                  translation,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(translation) ^ runtimeType.hashCode;
}

extension $CommonTranslatePost$ResponseExtension
    on CommonTranslatePost$Response {
  CommonTranslatePost$Response copyWith({String? translation}) {
    return CommonTranslatePost$Response(
      translation: translation ?? this.translation,
    );
  }

  CommonTranslatePost$Response copyWithWrapped({Wrapped<String>? translation}) {
    return CommonTranslatePost$Response(
      translation: (translation != null ? translation.value : this.translation),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChatShadowPost$Response {
  const ChatShadowPost$Response({required this.score, required this.details});

  factory ChatShadowPost$Response.fromJson(Map<String, dynamic> json) =>
      _$ChatShadowPost$ResponseFromJson(json);

  static const toJsonFactory = _$ChatShadowPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$ChatShadowPost$ResponseToJson(this);

  @JsonKey(name: 'score')
  final double score;
  @JsonKey(name: 'details')
  final ChatShadowPost$Response$Details details;
  static const fromJsonFactory = _$ChatShadowPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatShadowPost$Response &&
            (identical(other.score, score) ||
                const DeepCollectionEquality().equals(other.score, score)) &&
            (identical(other.details, details) ||
                const DeepCollectionEquality().equals(other.details, details)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(score) ^
      const DeepCollectionEquality().hash(details) ^
      runtimeType.hashCode;
}

extension $ChatShadowPost$ResponseExtension on ChatShadowPost$Response {
  ChatShadowPost$Response copyWith({
    double? score,
    ChatShadowPost$Response$Details? details,
  }) {
    return ChatShadowPost$Response(
      score: score ?? this.score,
      details: details ?? this.details,
    );
  }

  ChatShadowPost$Response copyWithWrapped({
    Wrapped<double>? score,
    Wrapped<ChatShadowPost$Response$Details>? details,
  }) {
    return ChatShadowPost$Response(
      score: (score != null ? score.value : this.score),
      details: (details != null ? details.value : this.details),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChatOptimizePost$Response {
  const ChatOptimizePost$Response({required this.optimizedText});

  factory ChatOptimizePost$Response.fromJson(Map<String, dynamic> json) =>
      _$ChatOptimizePost$ResponseFromJson(json);

  static const toJsonFactory = _$ChatOptimizePost$ResponseToJson;
  Map<String, dynamic> toJson() => _$ChatOptimizePost$ResponseToJson(this);

  @JsonKey(name: 'optimized_text')
  final String optimizedText;
  static const fromJsonFactory = _$ChatOptimizePost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatOptimizePost$Response &&
            (identical(other.optimizedText, optimizedText) ||
                const DeepCollectionEquality().equals(
                  other.optimizedText,
                  optimizedText,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(optimizedText) ^ runtimeType.hashCode;
}

extension $ChatOptimizePost$ResponseExtension on ChatOptimizePost$Response {
  ChatOptimizePost$Response copyWith({String? optimizedText}) {
    return ChatOptimizePost$Response(
      optimizedText: optimizedText ?? this.optimizedText,
    );
  }

  ChatOptimizePost$Response copyWithWrapped({Wrapped<String>? optimizedText}) {
    return ChatOptimizePost$Response(
      optimizedText: (optimizedText != null
          ? optimizedText.value
          : this.optimizedText),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChatMessagesDelete$Response {
  const ChatMessagesDelete$Response({
    required this.success,
    required this.deletedCount,
  });

  factory ChatMessagesDelete$Response.fromJson(Map<String, dynamic> json) =>
      _$ChatMessagesDelete$ResponseFromJson(json);

  static const toJsonFactory = _$ChatMessagesDelete$ResponseToJson;
  Map<String, dynamic> toJson() => _$ChatMessagesDelete$ResponseToJson(this);

  @JsonKey(name: 'success')
  final bool success;
  @JsonKey(name: 'deleted_count')
  final double deletedCount;
  static const fromJsonFactory = _$ChatMessagesDelete$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatMessagesDelete$Response &&
            (identical(other.success, success) ||
                const DeepCollectionEquality().equals(
                  other.success,
                  success,
                )) &&
            (identical(other.deletedCount, deletedCount) ||
                const DeepCollectionEquality().equals(
                  other.deletedCount,
                  deletedCount,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(success) ^
      const DeepCollectionEquality().hash(deletedCount) ^
      runtimeType.hashCode;
}

extension $ChatMessagesDelete$ResponseExtension on ChatMessagesDelete$Response {
  ChatMessagesDelete$Response copyWith({bool? success, double? deletedCount}) {
    return ChatMessagesDelete$Response(
      success: success ?? this.success,
      deletedCount: deletedCount ?? this.deletedCount,
    );
  }

  ChatMessagesDelete$Response copyWithWrapped({
    Wrapped<bool>? success,
    Wrapped<double>? deletedCount,
  }) {
    return ChatMessagesDelete$Response(
      success: (success != null ? success.value : this.success),
      deletedCount: (deletedCount != null
          ? deletedCount.value
          : this.deletedCount),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UserSyncPost$Response {
  const UserSyncPost$Response({required this.status, required this.syncedAt});

  factory UserSyncPost$Response.fromJson(Map<String, dynamic> json) =>
      _$UserSyncPost$ResponseFromJson(json);

  static const toJsonFactory = _$UserSyncPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$UserSyncPost$ResponseToJson(this);

  @JsonKey(name: 'status')
  final String status;
  @JsonKey(name: 'synced_at')
  final String syncedAt;
  static const fromJsonFactory = _$UserSyncPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UserSyncPost$Response &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)) &&
            (identical(other.syncedAt, syncedAt) ||
                const DeepCollectionEquality().equals(
                  other.syncedAt,
                  syncedAt,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(status) ^
      const DeepCollectionEquality().hash(syncedAt) ^
      runtimeType.hashCode;
}

extension $UserSyncPost$ResponseExtension on UserSyncPost$Response {
  UserSyncPost$Response copyWith({String? status, String? syncedAt}) {
    return UserSyncPost$Response(
      status: status ?? this.status,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  UserSyncPost$Response copyWithWrapped({
    Wrapped<String>? status,
    Wrapped<String>? syncedAt,
  }) {
    return UserSyncPost$Response(
      status: (status != null ? status.value : this.status),
      syncedAt: (syncedAt != null ? syncedAt.value : this.syncedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ShadowingUpsertPut$Response {
  const ShadowingUpsertPut$Response({
    required this.success,
    required this.data,
  });

  factory ShadowingUpsertPut$Response.fromJson(Map<String, dynamic> json) =>
      _$ShadowingUpsertPut$ResponseFromJson(json);

  static const toJsonFactory = _$ShadowingUpsertPut$ResponseToJson;
  Map<String, dynamic> toJson() => _$ShadowingUpsertPut$ResponseToJson(this);

  @JsonKey(name: 'success')
  final bool success;
  @JsonKey(name: 'data')
  final ShadowingUpsertPut$Response$Data data;
  static const fromJsonFactory = _$ShadowingUpsertPut$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShadowingUpsertPut$Response &&
            (identical(other.success, success) ||
                const DeepCollectionEquality().equals(
                  other.success,
                  success,
                )) &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(success) ^
      const DeepCollectionEquality().hash(data) ^
      runtimeType.hashCode;
}

extension $ShadowingUpsertPut$ResponseExtension on ShadowingUpsertPut$Response {
  ShadowingUpsertPut$Response copyWith({
    bool? success,
    ShadowingUpsertPut$Response$Data? data,
  }) {
    return ShadowingUpsertPut$Response(
      success: success ?? this.success,
      data: data ?? this.data,
    );
  }

  ShadowingUpsertPut$Response copyWithWrapped({
    Wrapped<bool>? success,
    Wrapped<ShadowingUpsertPut$Response$Data>? data,
  }) {
    return ShadowingUpsertPut$Response(
      success: (success != null ? success.value : this.success),
      data: (data != null ? data.value : this.data),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ShadowingGetGet$Response {
  const ShadowingGetGet$Response({required this.success, this.data});

  factory ShadowingGetGet$Response.fromJson(Map<String, dynamic> json) =>
      _$ShadowingGetGet$ResponseFromJson(json);

  static const toJsonFactory = _$ShadowingGetGet$ResponseToJson;
  Map<String, dynamic> toJson() => _$ShadowingGetGet$ResponseToJson(this);

  @JsonKey(name: 'success')
  final bool success;
  @JsonKey(name: 'data')
  final ShadowingGetGet$Response$Data? data;
  static const fromJsonFactory = _$ShadowingGetGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShadowingGetGet$Response &&
            (identical(other.success, success) ||
                const DeepCollectionEquality().equals(
                  other.success,
                  success,
                )) &&
            (identical(other.data, data) ||
                const DeepCollectionEquality().equals(other.data, data)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(success) ^
      const DeepCollectionEquality().hash(data) ^
      runtimeType.hashCode;
}

extension $ShadowingGetGet$ResponseExtension on ShadowingGetGet$Response {
  ShadowingGetGet$Response copyWith({
    bool? success,
    ShadowingGetGet$Response$Data? data,
  }) {
    return ShadowingGetGet$Response(
      success: success ?? this.success,
      data: data ?? this.data,
    );
  }

  ShadowingGetGet$Response copyWithWrapped({
    Wrapped<bool>? success,
    Wrapped<ShadowingGetGet$Response$Data?>? data,
  }) {
    return ShadowingGetGet$Response(
      success: (success != null ? success.value : this.success),
      data: (data != null ? data.value : this.data),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class UserAccountDelete$Response {
  const UserAccountDelete$Response({
    required this.success,
    required this.message,
  });

  factory UserAccountDelete$Response.fromJson(Map<String, dynamic> json) =>
      _$UserAccountDelete$ResponseFromJson(json);

  static const toJsonFactory = _$UserAccountDelete$ResponseToJson;
  Map<String, dynamic> toJson() => _$UserAccountDelete$ResponseToJson(this);

  @JsonKey(name: 'success')
  final bool success;
  @JsonKey(name: 'message')
  final String message;
  static const fromJsonFactory = _$UserAccountDelete$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is UserAccountDelete$Response &&
            (identical(other.success, success) ||
                const DeepCollectionEquality().equals(
                  other.success,
                  success,
                )) &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(other.message, message)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(success) ^
      const DeepCollectionEquality().hash(message) ^
      runtimeType.hashCode;
}

extension $UserAccountDelete$ResponseExtension on UserAccountDelete$Response {
  UserAccountDelete$Response copyWith({bool? success, String? message}) {
    return UserAccountDelete$Response(
      success: success ?? this.success,
      message: message ?? this.message,
    );
  }

  UserAccountDelete$Response copyWithWrapped({
    Wrapped<bool>? success,
    Wrapped<String>? message,
  }) {
    return UserAccountDelete$Response(
      success: (success != null ? success.value : this.success),
      message: (message != null ? message.value : this.message),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AdminStandardScenesGet$Response {
  const AdminStandardScenesGet$Response({
    required this.success,
    required this.count,
    required this.scenes,
  });

  factory AdminStandardScenesGet$Response.fromJson(Map<String, dynamic> json) =>
      _$AdminStandardScenesGet$ResponseFromJson(json);

  static const toJsonFactory = _$AdminStandardScenesGet$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$AdminStandardScenesGet$ResponseToJson(this);

  @JsonKey(name: 'success')
  final bool success;
  @JsonKey(name: 'count')
  final double count;
  @JsonKey(name: 'scenes')
  final List<AdminStandardScenesGet$Response$Scenes$Item> scenes;
  static const fromJsonFactory = _$AdminStandardScenesGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdminStandardScenesGet$Response &&
            (identical(other.success, success) ||
                const DeepCollectionEquality().equals(
                  other.success,
                  success,
                )) &&
            (identical(other.count, count) ||
                const DeepCollectionEquality().equals(other.count, count)) &&
            (identical(other.scenes, scenes) ||
                const DeepCollectionEquality().equals(other.scenes, scenes)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(success) ^
      const DeepCollectionEquality().hash(count) ^
      const DeepCollectionEquality().hash(scenes) ^
      runtimeType.hashCode;
}

extension $AdminStandardScenesGet$ResponseExtension
    on AdminStandardScenesGet$Response {
  AdminStandardScenesGet$Response copyWith({
    bool? success,
    double? count,
    List<AdminStandardScenesGet$Response$Scenes$Item>? scenes,
  }) {
    return AdminStandardScenesGet$Response(
      success: success ?? this.success,
      count: count ?? this.count,
      scenes: scenes ?? this.scenes,
    );
  }

  AdminStandardScenesGet$Response copyWithWrapped({
    Wrapped<bool>? success,
    Wrapped<double>? count,
    Wrapped<List<AdminStandardScenesGet$Response$Scenes$Item>>? scenes,
  }) {
    return AdminStandardScenesGet$Response(
      success: (success != null ? success.value : this.success),
      count: (count != null ? count.value : this.count),
      scenes: (scenes != null ? scenes.value : this.scenes),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AdminStandardScenesPost$Response {
  const AdminStandardScenesPost$Response({
    required this.success,
    required this.createdCount,
    required this.scenes,
  });

  factory AdminStandardScenesPost$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$AdminStandardScenesPost$ResponseFromJson(json);

  static const toJsonFactory = _$AdminStandardScenesPost$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$AdminStandardScenesPost$ResponseToJson(this);

  @JsonKey(name: 'success')
  final bool success;
  @JsonKey(name: 'created_count')
  final double createdCount;
  @JsonKey(name: 'scenes')
  final List<AdminStandardScenesPost$Response$Scenes$Item> scenes;
  static const fromJsonFactory = _$AdminStandardScenesPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdminStandardScenesPost$Response &&
            (identical(other.success, success) ||
                const DeepCollectionEquality().equals(
                  other.success,
                  success,
                )) &&
            (identical(other.createdCount, createdCount) ||
                const DeepCollectionEquality().equals(
                  other.createdCount,
                  createdCount,
                )) &&
            (identical(other.scenes, scenes) ||
                const DeepCollectionEquality().equals(other.scenes, scenes)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(success) ^
      const DeepCollectionEquality().hash(createdCount) ^
      const DeepCollectionEquality().hash(scenes) ^
      runtimeType.hashCode;
}

extension $AdminStandardScenesPost$ResponseExtension
    on AdminStandardScenesPost$Response {
  AdminStandardScenesPost$Response copyWith({
    bool? success,
    double? createdCount,
    List<AdminStandardScenesPost$Response$Scenes$Item>? scenes,
  }) {
    return AdminStandardScenesPost$Response(
      success: success ?? this.success,
      createdCount: createdCount ?? this.createdCount,
      scenes: scenes ?? this.scenes,
    );
  }

  AdminStandardScenesPost$Response copyWithWrapped({
    Wrapped<bool>? success,
    Wrapped<double>? createdCount,
    Wrapped<List<AdminStandardScenesPost$Response$Scenes$Item>>? scenes,
  }) {
    return AdminStandardScenesPost$Response(
      success: (success != null ? success.value : this.success),
      createdCount: (createdCount != null
          ? createdCount.value
          : this.createdCount),
      scenes: (scenes != null ? scenes.value : this.scenes),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AdminStandardScenesIdDelete$Response {
  const AdminStandardScenesIdDelete$Response({
    required this.success,
    required this.deletedCount,
  });

  factory AdminStandardScenesIdDelete$Response.fromJson(
    Map<String, dynamic> json,
  ) => _$AdminStandardScenesIdDelete$ResponseFromJson(json);

  static const toJsonFactory = _$AdminStandardScenesIdDelete$ResponseToJson;
  Map<String, dynamic> toJson() =>
      _$AdminStandardScenesIdDelete$ResponseToJson(this);

  @JsonKey(name: 'success')
  final bool success;
  @JsonKey(name: 'deleted_count')
  final double deletedCount;
  static const fromJsonFactory = _$AdminStandardScenesIdDelete$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdminStandardScenesIdDelete$Response &&
            (identical(other.success, success) ||
                const DeepCollectionEquality().equals(
                  other.success,
                  success,
                )) &&
            (identical(other.deletedCount, deletedCount) ||
                const DeepCollectionEquality().equals(
                  other.deletedCount,
                  deletedCount,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(success) ^
      const DeepCollectionEquality().hash(deletedCount) ^
      runtimeType.hashCode;
}

extension $AdminStandardScenesIdDelete$ResponseExtension
    on AdminStandardScenesIdDelete$Response {
  AdminStandardScenesIdDelete$Response copyWith({
    bool? success,
    double? deletedCount,
  }) {
    return AdminStandardScenesIdDelete$Response(
      success: success ?? this.success,
      deletedCount: deletedCount ?? this.deletedCount,
    );
  }

  AdminStandardScenesIdDelete$Response copyWithWrapped({
    Wrapped<bool>? success,
    Wrapped<double>? deletedCount,
  }) {
    return AdminStandardScenesIdDelete$Response(
      success: (success != null ? success.value : this.success),
      deletedCount: (deletedCount != null
          ? deletedCount.value
          : this.deletedCount),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AdminPushTestPost$Response {
  const AdminPushTestPost$Response({
    required this.success,
    required this.sent,
    required this.failed,
    required this.message,
  });

  factory AdminPushTestPost$Response.fromJson(Map<String, dynamic> json) =>
      _$AdminPushTestPost$ResponseFromJson(json);

  static const toJsonFactory = _$AdminPushTestPost$ResponseToJson;
  Map<String, dynamic> toJson() => _$AdminPushTestPost$ResponseToJson(this);

  @JsonKey(name: 'success')
  final bool success;
  @JsonKey(name: 'sent')
  final double sent;
  @JsonKey(name: 'failed')
  final double failed;
  @JsonKey(name: 'message')
  final String message;
  static const fromJsonFactory = _$AdminPushTestPost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdminPushTestPost$Response &&
            (identical(other.success, success) ||
                const DeepCollectionEquality().equals(
                  other.success,
                  success,
                )) &&
            (identical(other.sent, sent) ||
                const DeepCollectionEquality().equals(other.sent, sent)) &&
            (identical(other.failed, failed) ||
                const DeepCollectionEquality().equals(other.failed, failed)) &&
            (identical(other.message, message) ||
                const DeepCollectionEquality().equals(other.message, message)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(success) ^
      const DeepCollectionEquality().hash(sent) ^
      const DeepCollectionEquality().hash(failed) ^
      const DeepCollectionEquality().hash(message) ^
      runtimeType.hashCode;
}

extension $AdminPushTestPost$ResponseExtension on AdminPushTestPost$Response {
  AdminPushTestPost$Response copyWith({
    bool? success,
    double? sent,
    double? failed,
    String? message,
  }) {
    return AdminPushTestPost$Response(
      success: success ?? this.success,
      sent: sent ?? this.sent,
      failed: failed ?? this.failed,
      message: message ?? this.message,
    );
  }

  AdminPushTestPost$Response copyWithWrapped({
    Wrapped<bool>? success,
    Wrapped<double>? sent,
    Wrapped<double>? failed,
    Wrapped<String>? message,
  }) {
    return AdminPushTestPost$Response(
      success: (success != null ? success.value : this.success),
      sent: (sent != null ? sent.value : this.sent),
      failed: (failed != null ? failed.value : this.failed),
      message: (message != null ? message.value : this.message),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AdminPushStatusGet$Response {
  const AdminPushStatusGet$Response({
    required this.configured,
    this.projectId,
    this.clientEmail,
  });

  factory AdminPushStatusGet$Response.fromJson(Map<String, dynamic> json) =>
      _$AdminPushStatusGet$ResponseFromJson(json);

  static const toJsonFactory = _$AdminPushStatusGet$ResponseToJson;
  Map<String, dynamic> toJson() => _$AdminPushStatusGet$ResponseToJson(this);

  @JsonKey(name: 'configured')
  final bool configured;
  @JsonKey(name: 'project_id')
  final String? projectId;
  @JsonKey(name: 'client_email')
  final String? clientEmail;
  static const fromJsonFactory = _$AdminPushStatusGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdminPushStatusGet$Response &&
            (identical(other.configured, configured) ||
                const DeepCollectionEquality().equals(
                  other.configured,
                  configured,
                )) &&
            (identical(other.projectId, projectId) ||
                const DeepCollectionEquality().equals(
                  other.projectId,
                  projectId,
                )) &&
            (identical(other.clientEmail, clientEmail) ||
                const DeepCollectionEquality().equals(
                  other.clientEmail,
                  clientEmail,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(configured) ^
      const DeepCollectionEquality().hash(projectId) ^
      const DeepCollectionEquality().hash(clientEmail) ^
      runtimeType.hashCode;
}

extension $AdminPushStatusGet$ResponseExtension on AdminPushStatusGet$Response {
  AdminPushStatusGet$Response copyWith({
    bool? configured,
    String? projectId,
    String? clientEmail,
  }) {
    return AdminPushStatusGet$Response(
      configured: configured ?? this.configured,
      projectId: projectId ?? this.projectId,
      clientEmail: clientEmail ?? this.clientEmail,
    );
  }

  AdminPushStatusGet$Response copyWithWrapped({
    Wrapped<bool>? configured,
    Wrapped<String?>? projectId,
    Wrapped<String?>? clientEmail,
  }) {
    return AdminPushStatusGet$Response(
      configured: (configured != null ? configured.value : this.configured),
      projectId: (projectId != null ? projectId.value : this.projectId),
      clientEmail: (clientEmail != null ? clientEmail.value : this.clientEmail),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChatSendPost$RequestBody$History$Item {
  const ChatSendPost$RequestBody$History$Item({
    required this.role,
    required this.content,
  });

  factory ChatSendPost$RequestBody$History$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ChatSendPost$RequestBody$History$ItemFromJson(json);

  static const toJsonFactory = _$ChatSendPost$RequestBody$History$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ChatSendPost$RequestBody$History$ItemToJson(this);

  @JsonKey(name: 'role')
  final String role;
  @JsonKey(name: 'content')
  final String content;
  static const fromJsonFactory =
      _$ChatSendPost$RequestBody$History$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatSendPost$RequestBody$History$Item &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.content, content) ||
                const DeepCollectionEquality().equals(other.content, content)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(content) ^
      runtimeType.hashCode;
}

extension $ChatSendPost$RequestBody$History$ItemExtension
    on ChatSendPost$RequestBody$History$Item {
  ChatSendPost$RequestBody$History$Item copyWith({
    String? role,
    String? content,
  }) {
    return ChatSendPost$RequestBody$History$Item(
      role: role ?? this.role,
      content: content ?? this.content,
    );
  }

  ChatSendPost$RequestBody$History$Item copyWithWrapped({
    Wrapped<String>? role,
    Wrapped<String>? content,
  }) {
    return ChatSendPost$RequestBody$History$Item(
      role: (role != null ? role.value : this.role),
      content: (content != null ? content.value : this.content),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChatHintPost$RequestBody$History$Item {
  const ChatHintPost$RequestBody$History$Item({
    required this.role,
    required this.content,
  });

  factory ChatHintPost$RequestBody$History$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ChatHintPost$RequestBody$History$ItemFromJson(json);

  static const toJsonFactory = _$ChatHintPost$RequestBody$History$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ChatHintPost$RequestBody$History$ItemToJson(this);

  @JsonKey(name: 'role')
  final String role;
  @JsonKey(name: 'content')
  final String content;
  static const fromJsonFactory =
      _$ChatHintPost$RequestBody$History$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatHintPost$RequestBody$History$Item &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.content, content) ||
                const DeepCollectionEquality().equals(other.content, content)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(content) ^
      runtimeType.hashCode;
}

extension $ChatHintPost$RequestBody$History$ItemExtension
    on ChatHintPost$RequestBody$History$Item {
  ChatHintPost$RequestBody$History$Item copyWith({
    String? role,
    String? content,
  }) {
    return ChatHintPost$RequestBody$History$Item(
      role: role ?? this.role,
      content: content ?? this.content,
    );
  }

  ChatHintPost$RequestBody$History$Item copyWithWrapped({
    Wrapped<String>? role,
    Wrapped<String>? content,
  }) {
    return ChatHintPost$RequestBody$History$Item(
      role: (role != null ? role.value : this.role),
      content: (content != null ? content.value : this.content),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChatOptimizePost$RequestBody$History$Item {
  const ChatOptimizePost$RequestBody$History$Item({
    required this.role,
    required this.content,
  });

  factory ChatOptimizePost$RequestBody$History$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ChatOptimizePost$RequestBody$History$ItemFromJson(json);

  static const toJsonFactory =
      _$ChatOptimizePost$RequestBody$History$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ChatOptimizePost$RequestBody$History$ItemToJson(this);

  @JsonKey(name: 'role')
  final String role;
  @JsonKey(name: 'content')
  final String content;
  static const fromJsonFactory =
      _$ChatOptimizePost$RequestBody$History$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatOptimizePost$RequestBody$History$Item &&
            (identical(other.role, role) ||
                const DeepCollectionEquality().equals(other.role, role)) &&
            (identical(other.content, content) ||
                const DeepCollectionEquality().equals(other.content, content)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(role) ^
      const DeepCollectionEquality().hash(content) ^
      runtimeType.hashCode;
}

extension $ChatOptimizePost$RequestBody$History$ItemExtension
    on ChatOptimizePost$RequestBody$History$Item {
  ChatOptimizePost$RequestBody$History$Item copyWith({
    String? role,
    String? content,
  }) {
    return ChatOptimizePost$RequestBody$History$Item(
      role: role ?? this.role,
      content: content ?? this.content,
    );
  }

  ChatOptimizePost$RequestBody$History$Item copyWithWrapped({
    Wrapped<String>? role,
    Wrapped<String>? content,
  }) {
    return ChatOptimizePost$RequestBody$History$Item(
      role: (role != null ? role.value : this.role),
      content: (content != null ? content.value : this.content),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ShadowingUpsertPut$RequestBody$WordFeedback$Item {
  const ShadowingUpsertPut$RequestBody$WordFeedback$Item({
    required this.text,
    required this.score,
    required this.level,
    required this.errorType,
    required this.phonemes,
  });

  factory ShadowingUpsertPut$RequestBody$WordFeedback$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ShadowingUpsertPut$RequestBody$WordFeedback$ItemFromJson(json);

  static const toJsonFactory =
      _$ShadowingUpsertPut$RequestBody$WordFeedback$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ShadowingUpsertPut$RequestBody$WordFeedback$ItemToJson(this);

  @JsonKey(name: 'text')
  final String text;
  @JsonKey(name: 'score')
  final double score;
  @JsonKey(
    name: 'level',
    toJson: shadowingUpsertPut$RequestBody$WordFeedback$ItemLevelToJson,
    fromJson: shadowingUpsertPut$RequestBody$WordFeedback$ItemLevelFromJson,
  )
  final enums.ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel level;
  @JsonKey(name: 'error_type')
  final String errorType;
  @JsonKey(name: 'phonemes')
  final List<ShadowingUpsertPut$RequestBody$WordFeedback$Item$Phonemes$Item>
  phonemes;
  static const fromJsonFactory =
      _$ShadowingUpsertPut$RequestBody$WordFeedback$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShadowingUpsertPut$RequestBody$WordFeedback$Item &&
            (identical(other.text, text) ||
                const DeepCollectionEquality().equals(other.text, text)) &&
            (identical(other.score, score) ||
                const DeepCollectionEquality().equals(other.score, score)) &&
            (identical(other.level, level) ||
                const DeepCollectionEquality().equals(other.level, level)) &&
            (identical(other.errorType, errorType) ||
                const DeepCollectionEquality().equals(
                  other.errorType,
                  errorType,
                )) &&
            (identical(other.phonemes, phonemes) ||
                const DeepCollectionEquality().equals(
                  other.phonemes,
                  phonemes,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(text) ^
      const DeepCollectionEquality().hash(score) ^
      const DeepCollectionEquality().hash(level) ^
      const DeepCollectionEquality().hash(errorType) ^
      const DeepCollectionEquality().hash(phonemes) ^
      runtimeType.hashCode;
}

extension $ShadowingUpsertPut$RequestBody$WordFeedback$ItemExtension
    on ShadowingUpsertPut$RequestBody$WordFeedback$Item {
  ShadowingUpsertPut$RequestBody$WordFeedback$Item copyWith({
    String? text,
    double? score,
    enums.ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel? level,
    String? errorType,
    List<ShadowingUpsertPut$RequestBody$WordFeedback$Item$Phonemes$Item>?
    phonemes,
  }) {
    return ShadowingUpsertPut$RequestBody$WordFeedback$Item(
      text: text ?? this.text,
      score: score ?? this.score,
      level: level ?? this.level,
      errorType: errorType ?? this.errorType,
      phonemes: phonemes ?? this.phonemes,
    );
  }

  ShadowingUpsertPut$RequestBody$WordFeedback$Item copyWithWrapped({
    Wrapped<String>? text,
    Wrapped<double>? score,
    Wrapped<enums.ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel>? level,
    Wrapped<String>? errorType,
    Wrapped<
      List<ShadowingUpsertPut$RequestBody$WordFeedback$Item$Phonemes$Item>
    >?
    phonemes,
  }) {
    return ShadowingUpsertPut$RequestBody$WordFeedback$Item(
      text: (text != null ? text.value : this.text),
      score: (score != null ? score.value : this.score),
      level: (level != null ? level.value : this.level),
      errorType: (errorType != null ? errorType.value : this.errorType),
      phonemes: (phonemes != null ? phonemes.value : this.phonemes),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ShadowingUpsertPut$RequestBody$Segments$Item {
  const ShadowingUpsertPut$RequestBody$Segments$Item({
    required this.text,
    required this.startIndex,
    required this.endIndex,
    required this.score,
    required this.hasError,
    required this.wordCount,
  });

  factory ShadowingUpsertPut$RequestBody$Segments$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ShadowingUpsertPut$RequestBody$Segments$ItemFromJson(json);

  static const toJsonFactory =
      _$ShadowingUpsertPut$RequestBody$Segments$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ShadowingUpsertPut$RequestBody$Segments$ItemToJson(this);

  @JsonKey(name: 'text')
  final String text;
  @JsonKey(name: 'start_index')
  final double startIndex;
  @JsonKey(name: 'end_index')
  final double endIndex;
  @JsonKey(name: 'score')
  final double score;
  @JsonKey(name: 'has_error')
  final bool hasError;
  @JsonKey(name: 'word_count')
  final double wordCount;
  static const fromJsonFactory =
      _$ShadowingUpsertPut$RequestBody$Segments$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShadowingUpsertPut$RequestBody$Segments$Item &&
            (identical(other.text, text) ||
                const DeepCollectionEquality().equals(other.text, text)) &&
            (identical(other.startIndex, startIndex) ||
                const DeepCollectionEquality().equals(
                  other.startIndex,
                  startIndex,
                )) &&
            (identical(other.endIndex, endIndex) ||
                const DeepCollectionEquality().equals(
                  other.endIndex,
                  endIndex,
                )) &&
            (identical(other.score, score) ||
                const DeepCollectionEquality().equals(other.score, score)) &&
            (identical(other.hasError, hasError) ||
                const DeepCollectionEquality().equals(
                  other.hasError,
                  hasError,
                )) &&
            (identical(other.wordCount, wordCount) ||
                const DeepCollectionEquality().equals(
                  other.wordCount,
                  wordCount,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(text) ^
      const DeepCollectionEquality().hash(startIndex) ^
      const DeepCollectionEquality().hash(endIndex) ^
      const DeepCollectionEquality().hash(score) ^
      const DeepCollectionEquality().hash(hasError) ^
      const DeepCollectionEquality().hash(wordCount) ^
      runtimeType.hashCode;
}

extension $ShadowingUpsertPut$RequestBody$Segments$ItemExtension
    on ShadowingUpsertPut$RequestBody$Segments$Item {
  ShadowingUpsertPut$RequestBody$Segments$Item copyWith({
    String? text,
    double? startIndex,
    double? endIndex,
    double? score,
    bool? hasError,
    double? wordCount,
  }) {
    return ShadowingUpsertPut$RequestBody$Segments$Item(
      text: text ?? this.text,
      startIndex: startIndex ?? this.startIndex,
      endIndex: endIndex ?? this.endIndex,
      score: score ?? this.score,
      hasError: hasError ?? this.hasError,
      wordCount: wordCount ?? this.wordCount,
    );
  }

  ShadowingUpsertPut$RequestBody$Segments$Item copyWithWrapped({
    Wrapped<String>? text,
    Wrapped<double>? startIndex,
    Wrapped<double>? endIndex,
    Wrapped<double>? score,
    Wrapped<bool>? hasError,
    Wrapped<double>? wordCount,
  }) {
    return ShadowingUpsertPut$RequestBody$Segments$Item(
      text: (text != null ? text.value : this.text),
      startIndex: (startIndex != null ? startIndex.value : this.startIndex),
      endIndex: (endIndex != null ? endIndex.value : this.endIndex),
      score: (score != null ? score.value : this.score),
      hasError: (hasError != null ? hasError.value : this.hasError),
      wordCount: (wordCount != null ? wordCount.value : this.wordCount),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AdminStandardScenesPost$RequestBody$Scenes$Item {
  const AdminStandardScenesPost$RequestBody$Scenes$Item({
    this.id,
    required this.title,
    required this.description,
    required this.aiRole,
    required this.userRole,
    required this.initialMessage,
    required this.goal,
    this.emoji,
    required this.category,
    required this.difficulty,
    this.iconPath,
    required this.color,
    this.targetLanguage,
  });

  factory AdminStandardScenesPost$RequestBody$Scenes$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$AdminStandardScenesPost$RequestBody$Scenes$ItemFromJson(json);

  static const toJsonFactory =
      _$AdminStandardScenesPost$RequestBody$Scenes$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$AdminStandardScenesPost$RequestBody$Scenes$ItemToJson(this);

  @JsonKey(name: 'id')
  final String? id;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'ai_role')
  final String aiRole;
  @JsonKey(name: 'user_role')
  final String userRole;
  @JsonKey(name: 'initial_message')
  final String initialMessage;
  @JsonKey(name: 'goal')
  final String goal;
  @JsonKey(name: 'emoji')
  final String? emoji;
  @JsonKey(name: 'category')
  final String category;
  @JsonKey(
    name: 'difficulty',
    toJson: adminStandardScenesPost$RequestBody$Scenes$ItemDifficultyToJson,
    fromJson: adminStandardScenesPost$RequestBody$Scenes$ItemDifficultyFromJson,
  )
  final enums.AdminStandardScenesPost$RequestBody$Scenes$ItemDifficulty
  difficulty;
  @JsonKey(name: 'icon_path')
  final String? iconPath;
  @JsonKey(name: 'color')
  final double color;
  @JsonKey(name: 'target_language')
  final String? targetLanguage;
  static const fromJsonFactory =
      _$AdminStandardScenesPost$RequestBody$Scenes$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdminStandardScenesPost$RequestBody$Scenes$Item &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.aiRole, aiRole) ||
                const DeepCollectionEquality().equals(other.aiRole, aiRole)) &&
            (identical(other.userRole, userRole) ||
                const DeepCollectionEquality().equals(
                  other.userRole,
                  userRole,
                )) &&
            (identical(other.initialMessage, initialMessage) ||
                const DeepCollectionEquality().equals(
                  other.initialMessage,
                  initialMessage,
                )) &&
            (identical(other.goal, goal) ||
                const DeepCollectionEquality().equals(other.goal, goal)) &&
            (identical(other.emoji, emoji) ||
                const DeepCollectionEquality().equals(other.emoji, emoji)) &&
            (identical(other.category, category) ||
                const DeepCollectionEquality().equals(
                  other.category,
                  category,
                )) &&
            (identical(other.difficulty, difficulty) ||
                const DeepCollectionEquality().equals(
                  other.difficulty,
                  difficulty,
                )) &&
            (identical(other.iconPath, iconPath) ||
                const DeepCollectionEquality().equals(
                  other.iconPath,
                  iconPath,
                )) &&
            (identical(other.color, color) ||
                const DeepCollectionEquality().equals(other.color, color)) &&
            (identical(other.targetLanguage, targetLanguage) ||
                const DeepCollectionEquality().equals(
                  other.targetLanguage,
                  targetLanguage,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(aiRole) ^
      const DeepCollectionEquality().hash(userRole) ^
      const DeepCollectionEquality().hash(initialMessage) ^
      const DeepCollectionEquality().hash(goal) ^
      const DeepCollectionEquality().hash(emoji) ^
      const DeepCollectionEquality().hash(category) ^
      const DeepCollectionEquality().hash(difficulty) ^
      const DeepCollectionEquality().hash(iconPath) ^
      const DeepCollectionEquality().hash(color) ^
      const DeepCollectionEquality().hash(targetLanguage) ^
      runtimeType.hashCode;
}

extension $AdminStandardScenesPost$RequestBody$Scenes$ItemExtension
    on AdminStandardScenesPost$RequestBody$Scenes$Item {
  AdminStandardScenesPost$RequestBody$Scenes$Item copyWith({
    String? id,
    String? title,
    String? description,
    String? aiRole,
    String? userRole,
    String? initialMessage,
    String? goal,
    String? emoji,
    String? category,
    enums.AdminStandardScenesPost$RequestBody$Scenes$ItemDifficulty? difficulty,
    String? iconPath,
    double? color,
    String? targetLanguage,
  }) {
    return AdminStandardScenesPost$RequestBody$Scenes$Item(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      aiRole: aiRole ?? this.aiRole,
      userRole: userRole ?? this.userRole,
      initialMessage: initialMessage ?? this.initialMessage,
      goal: goal ?? this.goal,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      iconPath: iconPath ?? this.iconPath,
      color: color ?? this.color,
      targetLanguage: targetLanguage ?? this.targetLanguage,
    );
  }

  AdminStandardScenesPost$RequestBody$Scenes$Item copyWithWrapped({
    Wrapped<String?>? id,
    Wrapped<String>? title,
    Wrapped<String>? description,
    Wrapped<String>? aiRole,
    Wrapped<String>? userRole,
    Wrapped<String>? initialMessage,
    Wrapped<String>? goal,
    Wrapped<String?>? emoji,
    Wrapped<String>? category,
    Wrapped<enums.AdminStandardScenesPost$RequestBody$Scenes$ItemDifficulty>?
    difficulty,
    Wrapped<String?>? iconPath,
    Wrapped<double>? color,
    Wrapped<String?>? targetLanguage,
  }) {
    return AdminStandardScenesPost$RequestBody$Scenes$Item(
      id: (id != null ? id.value : this.id),
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      aiRole: (aiRole != null ? aiRole.value : this.aiRole),
      userRole: (userRole != null ? userRole.value : this.userRole),
      initialMessage: (initialMessage != null
          ? initialMessage.value
          : this.initialMessage),
      goal: (goal != null ? goal.value : this.goal),
      emoji: (emoji != null ? emoji.value : this.emoji),
      category: (category != null ? category.value : this.category),
      difficulty: (difficulty != null ? difficulty.value : this.difficulty),
      iconPath: (iconPath != null ? iconPath.value : this.iconPath),
      color: (color != null ? color.value : this.color),
      targetLanguage: (targetLanguage != null
          ? targetLanguage.value
          : this.targetLanguage),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChatSendPost$Response$ReviewFeedback {
  const ChatSendPost$Response$ReviewFeedback({
    required this.isPerfect,
    required this.correctedText,
    required this.nativeExpression,
    required this.explanation,
    required this.exampleAnswer,
  });

  factory ChatSendPost$Response$ReviewFeedback.fromJson(
    Map<String, dynamic> json,
  ) => _$ChatSendPost$Response$ReviewFeedbackFromJson(json);

  static const toJsonFactory = _$ChatSendPost$Response$ReviewFeedbackToJson;
  Map<String, dynamic> toJson() =>
      _$ChatSendPost$Response$ReviewFeedbackToJson(this);

  @JsonKey(name: 'is_perfect')
  final bool isPerfect;
  @JsonKey(name: 'corrected_text')
  final String correctedText;
  @JsonKey(name: 'native_expression')
  final String nativeExpression;
  @JsonKey(name: 'explanation')
  final String explanation;
  @JsonKey(name: 'example_answer')
  final String exampleAnswer;
  static const fromJsonFactory = _$ChatSendPost$Response$ReviewFeedbackFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatSendPost$Response$ReviewFeedback &&
            (identical(other.isPerfect, isPerfect) ||
                const DeepCollectionEquality().equals(
                  other.isPerfect,
                  isPerfect,
                )) &&
            (identical(other.correctedText, correctedText) ||
                const DeepCollectionEquality().equals(
                  other.correctedText,
                  correctedText,
                )) &&
            (identical(other.nativeExpression, nativeExpression) ||
                const DeepCollectionEquality().equals(
                  other.nativeExpression,
                  nativeExpression,
                )) &&
            (identical(other.explanation, explanation) ||
                const DeepCollectionEquality().equals(
                  other.explanation,
                  explanation,
                )) &&
            (identical(other.exampleAnswer, exampleAnswer) ||
                const DeepCollectionEquality().equals(
                  other.exampleAnswer,
                  exampleAnswer,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(isPerfect) ^
      const DeepCollectionEquality().hash(correctedText) ^
      const DeepCollectionEquality().hash(nativeExpression) ^
      const DeepCollectionEquality().hash(explanation) ^
      const DeepCollectionEquality().hash(exampleAnswer) ^
      runtimeType.hashCode;
}

extension $ChatSendPost$Response$ReviewFeedbackExtension
    on ChatSendPost$Response$ReviewFeedback {
  ChatSendPost$Response$ReviewFeedback copyWith({
    bool? isPerfect,
    String? correctedText,
    String? nativeExpression,
    String? explanation,
    String? exampleAnswer,
  }) {
    return ChatSendPost$Response$ReviewFeedback(
      isPerfect: isPerfect ?? this.isPerfect,
      correctedText: correctedText ?? this.correctedText,
      nativeExpression: nativeExpression ?? this.nativeExpression,
      explanation: explanation ?? this.explanation,
      exampleAnswer: exampleAnswer ?? this.exampleAnswer,
    );
  }

  ChatSendPost$Response$ReviewFeedback copyWithWrapped({
    Wrapped<bool>? isPerfect,
    Wrapped<String>? correctedText,
    Wrapped<String>? nativeExpression,
    Wrapped<String>? explanation,
    Wrapped<String>? exampleAnswer,
  }) {
    return ChatSendPost$Response$ReviewFeedback(
      isPerfect: (isPerfect != null ? isPerfect.value : this.isPerfect),
      correctedText: (correctedText != null
          ? correctedText.value
          : this.correctedText),
      nativeExpression: (nativeExpression != null
          ? nativeExpression.value
          : this.nativeExpression),
      explanation: (explanation != null ? explanation.value : this.explanation),
      exampleAnswer: (exampleAnswer != null
          ? exampleAnswer.value
          : this.exampleAnswer),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ChatShadowPost$Response$Details {
  const ChatShadowPost$Response$Details({
    required this.intonationScore,
    required this.pronunciationScore,
    required this.feedback,
  });

  factory ChatShadowPost$Response$Details.fromJson(Map<String, dynamic> json) =>
      _$ChatShadowPost$Response$DetailsFromJson(json);

  static const toJsonFactory = _$ChatShadowPost$Response$DetailsToJson;
  Map<String, dynamic> toJson() =>
      _$ChatShadowPost$Response$DetailsToJson(this);

  @JsonKey(name: 'intonation_score')
  final double intonationScore;
  @JsonKey(name: 'pronunciation_score')
  final double pronunciationScore;
  @JsonKey(name: 'feedback')
  final String feedback;
  static const fromJsonFactory = _$ChatShadowPost$Response$DetailsFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ChatShadowPost$Response$Details &&
            (identical(other.intonationScore, intonationScore) ||
                const DeepCollectionEquality().equals(
                  other.intonationScore,
                  intonationScore,
                )) &&
            (identical(other.pronunciationScore, pronunciationScore) ||
                const DeepCollectionEquality().equals(
                  other.pronunciationScore,
                  pronunciationScore,
                )) &&
            (identical(other.feedback, feedback) ||
                const DeepCollectionEquality().equals(
                  other.feedback,
                  feedback,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(intonationScore) ^
      const DeepCollectionEquality().hash(pronunciationScore) ^
      const DeepCollectionEquality().hash(feedback) ^
      runtimeType.hashCode;
}

extension $ChatShadowPost$Response$DetailsExtension
    on ChatShadowPost$Response$Details {
  ChatShadowPost$Response$Details copyWith({
    double? intonationScore,
    double? pronunciationScore,
    String? feedback,
  }) {
    return ChatShadowPost$Response$Details(
      intonationScore: intonationScore ?? this.intonationScore,
      pronunciationScore: pronunciationScore ?? this.pronunciationScore,
      feedback: feedback ?? this.feedback,
    );
  }

  ChatShadowPost$Response$Details copyWithWrapped({
    Wrapped<double>? intonationScore,
    Wrapped<double>? pronunciationScore,
    Wrapped<String>? feedback,
  }) {
    return ChatShadowPost$Response$Details(
      intonationScore: (intonationScore != null
          ? intonationScore.value
          : this.intonationScore),
      pronunciationScore: (pronunciationScore != null
          ? pronunciationScore.value
          : this.pronunciationScore),
      feedback: (feedback != null ? feedback.value : this.feedback),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ShadowingUpsertPut$Response$Data {
  const ShadowingUpsertPut$Response$Data({
    required this.id,
    required this.practicedAt,
  });

  factory ShadowingUpsertPut$Response$Data.fromJson(
    Map<String, dynamic> json,
  ) => _$ShadowingUpsertPut$Response$DataFromJson(json);

  static const toJsonFactory = _$ShadowingUpsertPut$Response$DataToJson;
  Map<String, dynamic> toJson() =>
      _$ShadowingUpsertPut$Response$DataToJson(this);

  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'practiced_at')
  final String practicedAt;
  static const fromJsonFactory = _$ShadowingUpsertPut$Response$DataFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShadowingUpsertPut$Response$Data &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.practicedAt, practicedAt) ||
                const DeepCollectionEquality().equals(
                  other.practicedAt,
                  practicedAt,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(practicedAt) ^
      runtimeType.hashCode;
}

extension $ShadowingUpsertPut$Response$DataExtension
    on ShadowingUpsertPut$Response$Data {
  ShadowingUpsertPut$Response$Data copyWith({String? id, String? practicedAt}) {
    return ShadowingUpsertPut$Response$Data(
      id: id ?? this.id,
      practicedAt: practicedAt ?? this.practicedAt,
    );
  }

  ShadowingUpsertPut$Response$Data copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? practicedAt,
  }) {
    return ShadowingUpsertPut$Response$Data(
      id: (id != null ? id.value : this.id),
      practicedAt: (practicedAt != null ? practicedAt.value : this.practicedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ShadowingGetGet$Response$Data {
  const ShadowingGetGet$Response$Data({
    required this.id,
    required this.sourceType,
    required this.sourceId,
    required this.targetText,
    this.sceneKey,
    required this.pronunciationScore,
    this.accuracyScore,
    this.fluencyScore,
    this.completenessScore,
    this.prosodyScore,
    required this.wordFeedback,
    this.feedbackText,
    required this.segments,
    required this.practicedAt,
  });

  factory ShadowingGetGet$Response$Data.fromJson(Map<String, dynamic> json) =>
      _$ShadowingGetGet$Response$DataFromJson(json);

  static const toJsonFactory = _$ShadowingGetGet$Response$DataToJson;
  Map<String, dynamic> toJson() => _$ShadowingGetGet$Response$DataToJson(this);

  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'source_type')
  final String sourceType;
  @JsonKey(name: 'source_id')
  final String sourceId;
  @JsonKey(name: 'target_text')
  final String targetText;
  @JsonKey(name: 'scene_key')
  final String? sceneKey;
  @JsonKey(name: 'pronunciation_score')
  final double pronunciationScore;
  @JsonKey(name: 'accuracy_score')
  final double? accuracyScore;
  @JsonKey(name: 'fluency_score')
  final double? fluencyScore;
  @JsonKey(name: 'completeness_score')
  final double? completenessScore;
  @JsonKey(name: 'prosody_score')
  final double? prosodyScore;
  @JsonKey(name: 'word_feedback')
  final List<ShadowingGetGet$Response$Data$WordFeedback$Item> wordFeedback;
  @JsonKey(name: 'feedback_text')
  final String? feedbackText;
  @JsonKey(name: 'segments')
  final List<ShadowingGetGet$Response$Data$Segments$Item> segments;
  @JsonKey(name: 'practiced_at')
  final String practicedAt;
  static const fromJsonFactory = _$ShadowingGetGet$Response$DataFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShadowingGetGet$Response$Data &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.sourceType, sourceType) ||
                const DeepCollectionEquality().equals(
                  other.sourceType,
                  sourceType,
                )) &&
            (identical(other.sourceId, sourceId) ||
                const DeepCollectionEquality().equals(
                  other.sourceId,
                  sourceId,
                )) &&
            (identical(other.targetText, targetText) ||
                const DeepCollectionEquality().equals(
                  other.targetText,
                  targetText,
                )) &&
            (identical(other.sceneKey, sceneKey) ||
                const DeepCollectionEquality().equals(
                  other.sceneKey,
                  sceneKey,
                )) &&
            (identical(other.pronunciationScore, pronunciationScore) ||
                const DeepCollectionEquality().equals(
                  other.pronunciationScore,
                  pronunciationScore,
                )) &&
            (identical(other.accuracyScore, accuracyScore) ||
                const DeepCollectionEquality().equals(
                  other.accuracyScore,
                  accuracyScore,
                )) &&
            (identical(other.fluencyScore, fluencyScore) ||
                const DeepCollectionEquality().equals(
                  other.fluencyScore,
                  fluencyScore,
                )) &&
            (identical(other.completenessScore, completenessScore) ||
                const DeepCollectionEquality().equals(
                  other.completenessScore,
                  completenessScore,
                )) &&
            (identical(other.prosodyScore, prosodyScore) ||
                const DeepCollectionEquality().equals(
                  other.prosodyScore,
                  prosodyScore,
                )) &&
            (identical(other.wordFeedback, wordFeedback) ||
                const DeepCollectionEquality().equals(
                  other.wordFeedback,
                  wordFeedback,
                )) &&
            (identical(other.feedbackText, feedbackText) ||
                const DeepCollectionEquality().equals(
                  other.feedbackText,
                  feedbackText,
                )) &&
            (identical(other.segments, segments) ||
                const DeepCollectionEquality().equals(
                  other.segments,
                  segments,
                )) &&
            (identical(other.practicedAt, practicedAt) ||
                const DeepCollectionEquality().equals(
                  other.practicedAt,
                  practicedAt,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(sourceType) ^
      const DeepCollectionEquality().hash(sourceId) ^
      const DeepCollectionEquality().hash(targetText) ^
      const DeepCollectionEquality().hash(sceneKey) ^
      const DeepCollectionEquality().hash(pronunciationScore) ^
      const DeepCollectionEquality().hash(accuracyScore) ^
      const DeepCollectionEquality().hash(fluencyScore) ^
      const DeepCollectionEquality().hash(completenessScore) ^
      const DeepCollectionEquality().hash(prosodyScore) ^
      const DeepCollectionEquality().hash(wordFeedback) ^
      const DeepCollectionEquality().hash(feedbackText) ^
      const DeepCollectionEquality().hash(segments) ^
      const DeepCollectionEquality().hash(practicedAt) ^
      runtimeType.hashCode;
}

extension $ShadowingGetGet$Response$DataExtension
    on ShadowingGetGet$Response$Data {
  ShadowingGetGet$Response$Data copyWith({
    String? id,
    String? sourceType,
    String? sourceId,
    String? targetText,
    String? sceneKey,
    double? pronunciationScore,
    double? accuracyScore,
    double? fluencyScore,
    double? completenessScore,
    double? prosodyScore,
    List<ShadowingGetGet$Response$Data$WordFeedback$Item>? wordFeedback,
    String? feedbackText,
    List<ShadowingGetGet$Response$Data$Segments$Item>? segments,
    String? practicedAt,
  }) {
    return ShadowingGetGet$Response$Data(
      id: id ?? this.id,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      targetText: targetText ?? this.targetText,
      sceneKey: sceneKey ?? this.sceneKey,
      pronunciationScore: pronunciationScore ?? this.pronunciationScore,
      accuracyScore: accuracyScore ?? this.accuracyScore,
      fluencyScore: fluencyScore ?? this.fluencyScore,
      completenessScore: completenessScore ?? this.completenessScore,
      prosodyScore: prosodyScore ?? this.prosodyScore,
      wordFeedback: wordFeedback ?? this.wordFeedback,
      feedbackText: feedbackText ?? this.feedbackText,
      segments: segments ?? this.segments,
      practicedAt: practicedAt ?? this.practicedAt,
    );
  }

  ShadowingGetGet$Response$Data copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? sourceType,
    Wrapped<String>? sourceId,
    Wrapped<String>? targetText,
    Wrapped<String?>? sceneKey,
    Wrapped<double>? pronunciationScore,
    Wrapped<double?>? accuracyScore,
    Wrapped<double?>? fluencyScore,
    Wrapped<double?>? completenessScore,
    Wrapped<double?>? prosodyScore,
    Wrapped<List<ShadowingGetGet$Response$Data$WordFeedback$Item>>?
    wordFeedback,
    Wrapped<String?>? feedbackText,
    Wrapped<List<ShadowingGetGet$Response$Data$Segments$Item>>? segments,
    Wrapped<String>? practicedAt,
  }) {
    return ShadowingGetGet$Response$Data(
      id: (id != null ? id.value : this.id),
      sourceType: (sourceType != null ? sourceType.value : this.sourceType),
      sourceId: (sourceId != null ? sourceId.value : this.sourceId),
      targetText: (targetText != null ? targetText.value : this.targetText),
      sceneKey: (sceneKey != null ? sceneKey.value : this.sceneKey),
      pronunciationScore: (pronunciationScore != null
          ? pronunciationScore.value
          : this.pronunciationScore),
      accuracyScore: (accuracyScore != null
          ? accuracyScore.value
          : this.accuracyScore),
      fluencyScore: (fluencyScore != null
          ? fluencyScore.value
          : this.fluencyScore),
      completenessScore: (completenessScore != null
          ? completenessScore.value
          : this.completenessScore),
      prosodyScore: (prosodyScore != null
          ? prosodyScore.value
          : this.prosodyScore),
      wordFeedback: (wordFeedback != null
          ? wordFeedback.value
          : this.wordFeedback),
      feedbackText: (feedbackText != null
          ? feedbackText.value
          : this.feedbackText),
      segments: (segments != null ? segments.value : this.segments),
      practicedAt: (practicedAt != null ? practicedAt.value : this.practicedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AdminStandardScenesGet$Response$Scenes$Item {
  const AdminStandardScenesGet$Response$Scenes$Item({
    required this.id,
    required this.title,
    required this.description,
    required this.aiRole,
    required this.userRole,
    required this.initialMessage,
    required this.goal,
    this.emoji,
    required this.category,
    required this.difficulty,
    this.iconPath,
    required this.color,
    this.targetLanguage,
    this.createdAt,
  });

  factory AdminStandardScenesGet$Response$Scenes$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$AdminStandardScenesGet$Response$Scenes$ItemFromJson(json);

  static const toJsonFactory =
      _$AdminStandardScenesGet$Response$Scenes$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$AdminStandardScenesGet$Response$Scenes$ItemToJson(this);

  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'title')
  final String title;
  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'ai_role')
  final String aiRole;
  @JsonKey(name: 'user_role')
  final String userRole;
  @JsonKey(name: 'initial_message')
  final String initialMessage;
  @JsonKey(name: 'goal')
  final String goal;
  @JsonKey(name: 'emoji')
  final String? emoji;
  @JsonKey(name: 'category')
  final String category;
  @JsonKey(
    name: 'difficulty',
    toJson: adminStandardScenesGet$Response$Scenes$ItemDifficultyToJson,
    fromJson: adminStandardScenesGet$Response$Scenes$ItemDifficultyFromJson,
  )
  final enums.AdminStandardScenesGet$Response$Scenes$ItemDifficulty difficulty;
  @JsonKey(name: 'icon_path')
  final String? iconPath;
  @JsonKey(name: 'color')
  final double color;
  @JsonKey(name: 'target_language')
  final String? targetLanguage;
  @JsonKey(name: 'created_at')
  final String? createdAt;
  static const fromJsonFactory =
      _$AdminStandardScenesGet$Response$Scenes$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdminStandardScenesGet$Response$Scenes$Item &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)) &&
            (identical(other.description, description) ||
                const DeepCollectionEquality().equals(
                  other.description,
                  description,
                )) &&
            (identical(other.aiRole, aiRole) ||
                const DeepCollectionEquality().equals(other.aiRole, aiRole)) &&
            (identical(other.userRole, userRole) ||
                const DeepCollectionEquality().equals(
                  other.userRole,
                  userRole,
                )) &&
            (identical(other.initialMessage, initialMessage) ||
                const DeepCollectionEquality().equals(
                  other.initialMessage,
                  initialMessage,
                )) &&
            (identical(other.goal, goal) ||
                const DeepCollectionEquality().equals(other.goal, goal)) &&
            (identical(other.emoji, emoji) ||
                const DeepCollectionEquality().equals(other.emoji, emoji)) &&
            (identical(other.category, category) ||
                const DeepCollectionEquality().equals(
                  other.category,
                  category,
                )) &&
            (identical(other.difficulty, difficulty) ||
                const DeepCollectionEquality().equals(
                  other.difficulty,
                  difficulty,
                )) &&
            (identical(other.iconPath, iconPath) ||
                const DeepCollectionEquality().equals(
                  other.iconPath,
                  iconPath,
                )) &&
            (identical(other.color, color) ||
                const DeepCollectionEquality().equals(other.color, color)) &&
            (identical(other.targetLanguage, targetLanguage) ||
                const DeepCollectionEquality().equals(
                  other.targetLanguage,
                  targetLanguage,
                )) &&
            (identical(other.createdAt, createdAt) ||
                const DeepCollectionEquality().equals(
                  other.createdAt,
                  createdAt,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(title) ^
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(aiRole) ^
      const DeepCollectionEquality().hash(userRole) ^
      const DeepCollectionEquality().hash(initialMessage) ^
      const DeepCollectionEquality().hash(goal) ^
      const DeepCollectionEquality().hash(emoji) ^
      const DeepCollectionEquality().hash(category) ^
      const DeepCollectionEquality().hash(difficulty) ^
      const DeepCollectionEquality().hash(iconPath) ^
      const DeepCollectionEquality().hash(color) ^
      const DeepCollectionEquality().hash(targetLanguage) ^
      const DeepCollectionEquality().hash(createdAt) ^
      runtimeType.hashCode;
}

extension $AdminStandardScenesGet$Response$Scenes$ItemExtension
    on AdminStandardScenesGet$Response$Scenes$Item {
  AdminStandardScenesGet$Response$Scenes$Item copyWith({
    String? id,
    String? title,
    String? description,
    String? aiRole,
    String? userRole,
    String? initialMessage,
    String? goal,
    String? emoji,
    String? category,
    enums.AdminStandardScenesGet$Response$Scenes$ItemDifficulty? difficulty,
    String? iconPath,
    double? color,
    String? targetLanguage,
    String? createdAt,
  }) {
    return AdminStandardScenesGet$Response$Scenes$Item(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      aiRole: aiRole ?? this.aiRole,
      userRole: userRole ?? this.userRole,
      initialMessage: initialMessage ?? this.initialMessage,
      goal: goal ?? this.goal,
      emoji: emoji ?? this.emoji,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      iconPath: iconPath ?? this.iconPath,
      color: color ?? this.color,
      targetLanguage: targetLanguage ?? this.targetLanguage,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  AdminStandardScenesGet$Response$Scenes$Item copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? title,
    Wrapped<String>? description,
    Wrapped<String>? aiRole,
    Wrapped<String>? userRole,
    Wrapped<String>? initialMessage,
    Wrapped<String>? goal,
    Wrapped<String?>? emoji,
    Wrapped<String>? category,
    Wrapped<enums.AdminStandardScenesGet$Response$Scenes$ItemDifficulty>?
    difficulty,
    Wrapped<String?>? iconPath,
    Wrapped<double>? color,
    Wrapped<String?>? targetLanguage,
    Wrapped<String?>? createdAt,
  }) {
    return AdminStandardScenesGet$Response$Scenes$Item(
      id: (id != null ? id.value : this.id),
      title: (title != null ? title.value : this.title),
      description: (description != null ? description.value : this.description),
      aiRole: (aiRole != null ? aiRole.value : this.aiRole),
      userRole: (userRole != null ? userRole.value : this.userRole),
      initialMessage: (initialMessage != null
          ? initialMessage.value
          : this.initialMessage),
      goal: (goal != null ? goal.value : this.goal),
      emoji: (emoji != null ? emoji.value : this.emoji),
      category: (category != null ? category.value : this.category),
      difficulty: (difficulty != null ? difficulty.value : this.difficulty),
      iconPath: (iconPath != null ? iconPath.value : this.iconPath),
      color: (color != null ? color.value : this.color),
      targetLanguage: (targetLanguage != null
          ? targetLanguage.value
          : this.targetLanguage),
      createdAt: (createdAt != null ? createdAt.value : this.createdAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class AdminStandardScenesPost$Response$Scenes$Item {
  const AdminStandardScenesPost$Response$Scenes$Item({
    required this.id,
    required this.title,
  });

  factory AdminStandardScenesPost$Response$Scenes$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$AdminStandardScenesPost$Response$Scenes$ItemFromJson(json);

  static const toJsonFactory =
      _$AdminStandardScenesPost$Response$Scenes$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$AdminStandardScenesPost$Response$Scenes$ItemToJson(this);

  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'title')
  final String title;
  static const fromJsonFactory =
      _$AdminStandardScenesPost$Response$Scenes$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is AdminStandardScenesPost$Response$Scenes$Item &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
            (identical(other.title, title) ||
                const DeepCollectionEquality().equals(other.title, title)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(id) ^
      const DeepCollectionEquality().hash(title) ^
      runtimeType.hashCode;
}

extension $AdminStandardScenesPost$Response$Scenes$ItemExtension
    on AdminStandardScenesPost$Response$Scenes$Item {
  AdminStandardScenesPost$Response$Scenes$Item copyWith({
    String? id,
    String? title,
  }) {
    return AdminStandardScenesPost$Response$Scenes$Item(
      id: id ?? this.id,
      title: title ?? this.title,
    );
  }

  AdminStandardScenesPost$Response$Scenes$Item copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? title,
  }) {
    return AdminStandardScenesPost$Response$Scenes$Item(
      id: (id != null ? id.value : this.id),
      title: (title != null ? title.value : this.title),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ShadowingUpsertPut$RequestBody$WordFeedback$Item$Phonemes$Item {
  const ShadowingUpsertPut$RequestBody$WordFeedback$Item$Phonemes$Item({
    required this.phoneme,
    required this.accuracyScore,
    this.offset,
    this.duration,
  });

  factory ShadowingUpsertPut$RequestBody$WordFeedback$Item$Phonemes$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ShadowingUpsertPut$RequestBody$WordFeedback$Item$Phonemes$ItemFromJson(
    json,
  );

  static const toJsonFactory =
      _$ShadowingUpsertPut$RequestBody$WordFeedback$Item$Phonemes$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ShadowingUpsertPut$RequestBody$WordFeedback$Item$Phonemes$ItemToJson(
        this,
      );

  @JsonKey(name: 'phoneme')
  final String phoneme;
  @JsonKey(name: 'accuracy_score')
  final double accuracyScore;
  @JsonKey(name: 'offset')
  final double? offset;
  @JsonKey(name: 'duration')
  final double? duration;
  static const fromJsonFactory =
      _$ShadowingUpsertPut$RequestBody$WordFeedback$Item$Phonemes$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other
                is ShadowingUpsertPut$RequestBody$WordFeedback$Item$Phonemes$Item &&
            (identical(other.phoneme, phoneme) ||
                const DeepCollectionEquality().equals(
                  other.phoneme,
                  phoneme,
                )) &&
            (identical(other.accuracyScore, accuracyScore) ||
                const DeepCollectionEquality().equals(
                  other.accuracyScore,
                  accuracyScore,
                )) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.duration, duration) ||
                const DeepCollectionEquality().equals(
                  other.duration,
                  duration,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(phoneme) ^
      const DeepCollectionEquality().hash(accuracyScore) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(duration) ^
      runtimeType.hashCode;
}

extension $ShadowingUpsertPut$RequestBody$WordFeedback$Item$Phonemes$ItemExtension
    on ShadowingUpsertPut$RequestBody$WordFeedback$Item$Phonemes$Item {
  ShadowingUpsertPut$RequestBody$WordFeedback$Item$Phonemes$Item copyWith({
    String? phoneme,
    double? accuracyScore,
    double? offset,
    double? duration,
  }) {
    return ShadowingUpsertPut$RequestBody$WordFeedback$Item$Phonemes$Item(
      phoneme: phoneme ?? this.phoneme,
      accuracyScore: accuracyScore ?? this.accuracyScore,
      offset: offset ?? this.offset,
      duration: duration ?? this.duration,
    );
  }

  ShadowingUpsertPut$RequestBody$WordFeedback$Item$Phonemes$Item
  copyWithWrapped({
    Wrapped<String>? phoneme,
    Wrapped<double>? accuracyScore,
    Wrapped<double?>? offset,
    Wrapped<double?>? duration,
  }) {
    return ShadowingUpsertPut$RequestBody$WordFeedback$Item$Phonemes$Item(
      phoneme: (phoneme != null ? phoneme.value : this.phoneme),
      accuracyScore: (accuracyScore != null
          ? accuracyScore.value
          : this.accuracyScore),
      offset: (offset != null ? offset.value : this.offset),
      duration: (duration != null ? duration.value : this.duration),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ShadowingGetGet$Response$Data$WordFeedback$Item {
  const ShadowingGetGet$Response$Data$WordFeedback$Item({
    required this.text,
    required this.score,
    required this.level,
    required this.errorType,
    required this.phonemes,
  });

  factory ShadowingGetGet$Response$Data$WordFeedback$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ShadowingGetGet$Response$Data$WordFeedback$ItemFromJson(json);

  static const toJsonFactory =
      _$ShadowingGetGet$Response$Data$WordFeedback$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ShadowingGetGet$Response$Data$WordFeedback$ItemToJson(this);

  @JsonKey(name: 'text')
  final String text;
  @JsonKey(name: 'score')
  final double score;
  @JsonKey(
    name: 'level',
    toJson: shadowingGetGet$Response$Data$WordFeedback$ItemLevelToJson,
    fromJson: shadowingGetGet$Response$Data$WordFeedback$ItemLevelFromJson,
  )
  final enums.ShadowingGetGet$Response$Data$WordFeedback$ItemLevel level;
  @JsonKey(name: 'error_type')
  final String errorType;
  @JsonKey(name: 'phonemes')
  final List<ShadowingGetGet$Response$Data$WordFeedback$Item$Phonemes$Item>
  phonemes;
  static const fromJsonFactory =
      _$ShadowingGetGet$Response$Data$WordFeedback$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShadowingGetGet$Response$Data$WordFeedback$Item &&
            (identical(other.text, text) ||
                const DeepCollectionEquality().equals(other.text, text)) &&
            (identical(other.score, score) ||
                const DeepCollectionEquality().equals(other.score, score)) &&
            (identical(other.level, level) ||
                const DeepCollectionEquality().equals(other.level, level)) &&
            (identical(other.errorType, errorType) ||
                const DeepCollectionEquality().equals(
                  other.errorType,
                  errorType,
                )) &&
            (identical(other.phonemes, phonemes) ||
                const DeepCollectionEquality().equals(
                  other.phonemes,
                  phonemes,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(text) ^
      const DeepCollectionEquality().hash(score) ^
      const DeepCollectionEquality().hash(level) ^
      const DeepCollectionEquality().hash(errorType) ^
      const DeepCollectionEquality().hash(phonemes) ^
      runtimeType.hashCode;
}

extension $ShadowingGetGet$Response$Data$WordFeedback$ItemExtension
    on ShadowingGetGet$Response$Data$WordFeedback$Item {
  ShadowingGetGet$Response$Data$WordFeedback$Item copyWith({
    String? text,
    double? score,
    enums.ShadowingGetGet$Response$Data$WordFeedback$ItemLevel? level,
    String? errorType,
    List<ShadowingGetGet$Response$Data$WordFeedback$Item$Phonemes$Item>?
    phonemes,
  }) {
    return ShadowingGetGet$Response$Data$WordFeedback$Item(
      text: text ?? this.text,
      score: score ?? this.score,
      level: level ?? this.level,
      errorType: errorType ?? this.errorType,
      phonemes: phonemes ?? this.phonemes,
    );
  }

  ShadowingGetGet$Response$Data$WordFeedback$Item copyWithWrapped({
    Wrapped<String>? text,
    Wrapped<double>? score,
    Wrapped<enums.ShadowingGetGet$Response$Data$WordFeedback$ItemLevel>? level,
    Wrapped<String>? errorType,
    Wrapped<
      List<ShadowingGetGet$Response$Data$WordFeedback$Item$Phonemes$Item>
    >?
    phonemes,
  }) {
    return ShadowingGetGet$Response$Data$WordFeedback$Item(
      text: (text != null ? text.value : this.text),
      score: (score != null ? score.value : this.score),
      level: (level != null ? level.value : this.level),
      errorType: (errorType != null ? errorType.value : this.errorType),
      phonemes: (phonemes != null ? phonemes.value : this.phonemes),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ShadowingGetGet$Response$Data$Segments$Item {
  const ShadowingGetGet$Response$Data$Segments$Item({
    required this.text,
    required this.startIndex,
    required this.endIndex,
    required this.score,
    required this.hasError,
    required this.wordCount,
  });

  factory ShadowingGetGet$Response$Data$Segments$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ShadowingGetGet$Response$Data$Segments$ItemFromJson(json);

  static const toJsonFactory =
      _$ShadowingGetGet$Response$Data$Segments$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ShadowingGetGet$Response$Data$Segments$ItemToJson(this);

  @JsonKey(name: 'text')
  final String text;
  @JsonKey(name: 'start_index')
  final double startIndex;
  @JsonKey(name: 'end_index')
  final double endIndex;
  @JsonKey(name: 'score')
  final double score;
  @JsonKey(name: 'has_error')
  final bool hasError;
  @JsonKey(name: 'word_count')
  final double wordCount;
  static const fromJsonFactory =
      _$ShadowingGetGet$Response$Data$Segments$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShadowingGetGet$Response$Data$Segments$Item &&
            (identical(other.text, text) ||
                const DeepCollectionEquality().equals(other.text, text)) &&
            (identical(other.startIndex, startIndex) ||
                const DeepCollectionEquality().equals(
                  other.startIndex,
                  startIndex,
                )) &&
            (identical(other.endIndex, endIndex) ||
                const DeepCollectionEquality().equals(
                  other.endIndex,
                  endIndex,
                )) &&
            (identical(other.score, score) ||
                const DeepCollectionEquality().equals(other.score, score)) &&
            (identical(other.hasError, hasError) ||
                const DeepCollectionEquality().equals(
                  other.hasError,
                  hasError,
                )) &&
            (identical(other.wordCount, wordCount) ||
                const DeepCollectionEquality().equals(
                  other.wordCount,
                  wordCount,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(text) ^
      const DeepCollectionEquality().hash(startIndex) ^
      const DeepCollectionEquality().hash(endIndex) ^
      const DeepCollectionEquality().hash(score) ^
      const DeepCollectionEquality().hash(hasError) ^
      const DeepCollectionEquality().hash(wordCount) ^
      runtimeType.hashCode;
}

extension $ShadowingGetGet$Response$Data$Segments$ItemExtension
    on ShadowingGetGet$Response$Data$Segments$Item {
  ShadowingGetGet$Response$Data$Segments$Item copyWith({
    String? text,
    double? startIndex,
    double? endIndex,
    double? score,
    bool? hasError,
    double? wordCount,
  }) {
    return ShadowingGetGet$Response$Data$Segments$Item(
      text: text ?? this.text,
      startIndex: startIndex ?? this.startIndex,
      endIndex: endIndex ?? this.endIndex,
      score: score ?? this.score,
      hasError: hasError ?? this.hasError,
      wordCount: wordCount ?? this.wordCount,
    );
  }

  ShadowingGetGet$Response$Data$Segments$Item copyWithWrapped({
    Wrapped<String>? text,
    Wrapped<double>? startIndex,
    Wrapped<double>? endIndex,
    Wrapped<double>? score,
    Wrapped<bool>? hasError,
    Wrapped<double>? wordCount,
  }) {
    return ShadowingGetGet$Response$Data$Segments$Item(
      text: (text != null ? text.value : this.text),
      startIndex: (startIndex != null ? startIndex.value : this.startIndex),
      endIndex: (endIndex != null ? endIndex.value : this.endIndex),
      score: (score != null ? score.value : this.score),
      hasError: (hasError != null ? hasError.value : this.hasError),
      wordCount: (wordCount != null ? wordCount.value : this.wordCount),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ShadowingGetGet$Response$Data$WordFeedback$Item$Phonemes$Item {
  const ShadowingGetGet$Response$Data$WordFeedback$Item$Phonemes$Item({
    required this.phoneme,
    required this.accuracyScore,
    this.offset,
    this.duration,
  });

  factory ShadowingGetGet$Response$Data$WordFeedback$Item$Phonemes$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ShadowingGetGet$Response$Data$WordFeedback$Item$Phonemes$ItemFromJson(
    json,
  );

  static const toJsonFactory =
      _$ShadowingGetGet$Response$Data$WordFeedback$Item$Phonemes$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ShadowingGetGet$Response$Data$WordFeedback$Item$Phonemes$ItemToJson(
        this,
      );

  @JsonKey(name: 'phoneme')
  final String phoneme;
  @JsonKey(name: 'accuracy_score')
  final double accuracyScore;
  @JsonKey(name: 'offset')
  final double? offset;
  @JsonKey(name: 'duration')
  final double? duration;
  static const fromJsonFactory =
      _$ShadowingGetGet$Response$Data$WordFeedback$Item$Phonemes$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other
                is ShadowingGetGet$Response$Data$WordFeedback$Item$Phonemes$Item &&
            (identical(other.phoneme, phoneme) ||
                const DeepCollectionEquality().equals(
                  other.phoneme,
                  phoneme,
                )) &&
            (identical(other.accuracyScore, accuracyScore) ||
                const DeepCollectionEquality().equals(
                  other.accuracyScore,
                  accuracyScore,
                )) &&
            (identical(other.offset, offset) ||
                const DeepCollectionEquality().equals(other.offset, offset)) &&
            (identical(other.duration, duration) ||
                const DeepCollectionEquality().equals(
                  other.duration,
                  duration,
                )));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(phoneme) ^
      const DeepCollectionEquality().hash(accuracyScore) ^
      const DeepCollectionEquality().hash(offset) ^
      const DeepCollectionEquality().hash(duration) ^
      runtimeType.hashCode;
}

extension $ShadowingGetGet$Response$Data$WordFeedback$Item$Phonemes$ItemExtension
    on ShadowingGetGet$Response$Data$WordFeedback$Item$Phonemes$Item {
  ShadowingGetGet$Response$Data$WordFeedback$Item$Phonemes$Item copyWith({
    String? phoneme,
    double? accuracyScore,
    double? offset,
    double? duration,
  }) {
    return ShadowingGetGet$Response$Data$WordFeedback$Item$Phonemes$Item(
      phoneme: phoneme ?? this.phoneme,
      accuracyScore: accuracyScore ?? this.accuracyScore,
      offset: offset ?? this.offset,
      duration: duration ?? this.duration,
    );
  }

  ShadowingGetGet$Response$Data$WordFeedback$Item$Phonemes$Item
  copyWithWrapped({
    Wrapped<String>? phoneme,
    Wrapped<double>? accuracyScore,
    Wrapped<double?>? offset,
    Wrapped<double?>? duration,
  }) {
    return ShadowingGetGet$Response$Data$WordFeedback$Item$Phonemes$Item(
      phoneme: (phoneme != null ? phoneme.value : this.phoneme),
      accuracyScore: (accuracyScore != null
          ? accuracyScore.value
          : this.accuracyScore),
      offset: (offset != null ? offset.value : this.offset),
      duration: (duration != null ? duration.value : this.duration),
    );
  }
}

String? shadowingGetGet$Response$Data$WordFeedback$ItemLevelNullableToJson(
  enums.ShadowingGetGet$Response$Data$WordFeedback$ItemLevel?
  shadowingGetGet$Response$Data$WordFeedback$ItemLevel,
) {
  return shadowingGetGet$Response$Data$WordFeedback$ItemLevel?.value;
}

String? shadowingGetGet$Response$Data$WordFeedback$ItemLevelToJson(
  enums.ShadowingGetGet$Response$Data$WordFeedback$ItemLevel
  shadowingGetGet$Response$Data$WordFeedback$ItemLevel,
) {
  return shadowingGetGet$Response$Data$WordFeedback$ItemLevel.value;
}

enums.ShadowingGetGet$Response$Data$WordFeedback$ItemLevel
shadowingGetGet$Response$Data$WordFeedback$ItemLevelFromJson(
  Object? shadowingGetGet$Response$Data$WordFeedback$ItemLevel, [
  enums.ShadowingGetGet$Response$Data$WordFeedback$ItemLevel? defaultValue,
]) {
  return enums.ShadowingGetGet$Response$Data$WordFeedback$ItemLevel.values
          .firstWhereOrNull(
            (e) =>
                e.value == shadowingGetGet$Response$Data$WordFeedback$ItemLevel,
          ) ??
      defaultValue ??
      enums
          .ShadowingGetGet$Response$Data$WordFeedback$ItemLevel
          .swaggerGeneratedUnknown;
}

enums.ShadowingGetGet$Response$Data$WordFeedback$ItemLevel?
shadowingGetGet$Response$Data$WordFeedback$ItemLevelNullableFromJson(
  Object? shadowingGetGet$Response$Data$WordFeedback$ItemLevel, [
  enums.ShadowingGetGet$Response$Data$WordFeedback$ItemLevel? defaultValue,
]) {
  if (shadowingGetGet$Response$Data$WordFeedback$ItemLevel == null) {
    return null;
  }
  return enums.ShadowingGetGet$Response$Data$WordFeedback$ItemLevel.values
          .firstWhereOrNull(
            (e) =>
                e.value == shadowingGetGet$Response$Data$WordFeedback$ItemLevel,
          ) ??
      defaultValue;
}

String shadowingGetGet$Response$Data$WordFeedback$ItemLevelExplodedListToJson(
  List<enums.ShadowingGetGet$Response$Data$WordFeedback$ItemLevel>?
  shadowingGetGet$Response$Data$WordFeedback$ItemLevel,
) {
  return shadowingGetGet$Response$Data$WordFeedback$ItemLevel
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> shadowingGetGet$Response$Data$WordFeedback$ItemLevelListToJson(
  List<enums.ShadowingGetGet$Response$Data$WordFeedback$ItemLevel>?
  shadowingGetGet$Response$Data$WordFeedback$ItemLevel,
) {
  if (shadowingGetGet$Response$Data$WordFeedback$ItemLevel == null) {
    return [];
  }

  return shadowingGetGet$Response$Data$WordFeedback$ItemLevel
      .map((e) => e.value!)
      .toList();
}

List<enums.ShadowingGetGet$Response$Data$WordFeedback$ItemLevel>
shadowingGetGet$Response$Data$WordFeedback$ItemLevelListFromJson(
  List? shadowingGetGet$Response$Data$WordFeedback$ItemLevel, [
  List<enums.ShadowingGetGet$Response$Data$WordFeedback$ItemLevel>?
  defaultValue,
]) {
  if (shadowingGetGet$Response$Data$WordFeedback$ItemLevel == null) {
    return defaultValue ?? [];
  }

  return shadowingGetGet$Response$Data$WordFeedback$ItemLevel
      .map(
        (e) => shadowingGetGet$Response$Data$WordFeedback$ItemLevelFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ShadowingGetGet$Response$Data$WordFeedback$ItemLevel>?
shadowingGetGet$Response$Data$WordFeedback$ItemLevelNullableListFromJson(
  List? shadowingGetGet$Response$Data$WordFeedback$ItemLevel, [
  List<enums.ShadowingGetGet$Response$Data$WordFeedback$ItemLevel>?
  defaultValue,
]) {
  if (shadowingGetGet$Response$Data$WordFeedback$ItemLevel == null) {
    return defaultValue;
  }

  return shadowingGetGet$Response$Data$WordFeedback$ItemLevel
      .map(
        (e) => shadowingGetGet$Response$Data$WordFeedback$ItemLevelFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? shadowingGetGetSourceTypeNullableToJson(
  enums.ShadowingGetGetSourceType? shadowingGetGetSourceType,
) {
  return shadowingGetGetSourceType?.value;
}

String? shadowingGetGetSourceTypeToJson(
  enums.ShadowingGetGetSourceType shadowingGetGetSourceType,
) {
  return shadowingGetGetSourceType.value;
}

enums.ShadowingGetGetSourceType shadowingGetGetSourceTypeFromJson(
  Object? shadowingGetGetSourceType, [
  enums.ShadowingGetGetSourceType? defaultValue,
]) {
  return enums.ShadowingGetGetSourceType.values.firstWhereOrNull(
        (e) => e.value == shadowingGetGetSourceType,
      ) ??
      defaultValue ??
      enums.ShadowingGetGetSourceType.swaggerGeneratedUnknown;
}

enums.ShadowingGetGetSourceType? shadowingGetGetSourceTypeNullableFromJson(
  Object? shadowingGetGetSourceType, [
  enums.ShadowingGetGetSourceType? defaultValue,
]) {
  if (shadowingGetGetSourceType == null) {
    return null;
  }
  return enums.ShadowingGetGetSourceType.values.firstWhereOrNull(
        (e) => e.value == shadowingGetGetSourceType,
      ) ??
      defaultValue;
}

String shadowingGetGetSourceTypeExplodedListToJson(
  List<enums.ShadowingGetGetSourceType>? shadowingGetGetSourceType,
) {
  return shadowingGetGetSourceType?.map((e) => e.value!).join(',') ?? '';
}

List<String> shadowingGetGetSourceTypeListToJson(
  List<enums.ShadowingGetGetSourceType>? shadowingGetGetSourceType,
) {
  if (shadowingGetGetSourceType == null) {
    return [];
  }

  return shadowingGetGetSourceType.map((e) => e.value!).toList();
}

List<enums.ShadowingGetGetSourceType> shadowingGetGetSourceTypeListFromJson(
  List? shadowingGetGetSourceType, [
  List<enums.ShadowingGetGetSourceType>? defaultValue,
]) {
  if (shadowingGetGetSourceType == null) {
    return defaultValue ?? [];
  }

  return shadowingGetGetSourceType
      .map((e) => shadowingGetGetSourceTypeFromJson(e.toString()))
      .toList();
}

List<enums.ShadowingGetGetSourceType>?
shadowingGetGetSourceTypeNullableListFromJson(
  List? shadowingGetGetSourceType, [
  List<enums.ShadowingGetGetSourceType>? defaultValue,
]) {
  if (shadowingGetGetSourceType == null) {
    return defaultValue;
  }

  return shadowingGetGetSourceType
      .map((e) => shadowingGetGetSourceTypeFromJson(e.toString()))
      .toList();
}

String? adminStandardScenesGet$Response$Scenes$ItemDifficultyNullableToJson(
  enums.AdminStandardScenesGet$Response$Scenes$ItemDifficulty?
  adminStandardScenesGet$Response$Scenes$ItemDifficulty,
) {
  return adminStandardScenesGet$Response$Scenes$ItemDifficulty?.value;
}

String? adminStandardScenesGet$Response$Scenes$ItemDifficultyToJson(
  enums.AdminStandardScenesGet$Response$Scenes$ItemDifficulty
  adminStandardScenesGet$Response$Scenes$ItemDifficulty,
) {
  return adminStandardScenesGet$Response$Scenes$ItemDifficulty.value;
}

enums.AdminStandardScenesGet$Response$Scenes$ItemDifficulty
adminStandardScenesGet$Response$Scenes$ItemDifficultyFromJson(
  Object? adminStandardScenesGet$Response$Scenes$ItemDifficulty, [
  enums.AdminStandardScenesGet$Response$Scenes$ItemDifficulty? defaultValue,
]) {
  return enums.AdminStandardScenesGet$Response$Scenes$ItemDifficulty.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                adminStandardScenesGet$Response$Scenes$ItemDifficulty,
          ) ??
      defaultValue ??
      enums
          .AdminStandardScenesGet$Response$Scenes$ItemDifficulty
          .swaggerGeneratedUnknown;
}

enums.AdminStandardScenesGet$Response$Scenes$ItemDifficulty?
adminStandardScenesGet$Response$Scenes$ItemDifficultyNullableFromJson(
  Object? adminStandardScenesGet$Response$Scenes$ItemDifficulty, [
  enums.AdminStandardScenesGet$Response$Scenes$ItemDifficulty? defaultValue,
]) {
  if (adminStandardScenesGet$Response$Scenes$ItemDifficulty == null) {
    return null;
  }
  return enums.AdminStandardScenesGet$Response$Scenes$ItemDifficulty.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                adminStandardScenesGet$Response$Scenes$ItemDifficulty,
          ) ??
      defaultValue;
}

String adminStandardScenesGet$Response$Scenes$ItemDifficultyExplodedListToJson(
  List<enums.AdminStandardScenesGet$Response$Scenes$ItemDifficulty>?
  adminStandardScenesGet$Response$Scenes$ItemDifficulty,
) {
  return adminStandardScenesGet$Response$Scenes$ItemDifficulty
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> adminStandardScenesGet$Response$Scenes$ItemDifficultyListToJson(
  List<enums.AdminStandardScenesGet$Response$Scenes$ItemDifficulty>?
  adminStandardScenesGet$Response$Scenes$ItemDifficulty,
) {
  if (adminStandardScenesGet$Response$Scenes$ItemDifficulty == null) {
    return [];
  }

  return adminStandardScenesGet$Response$Scenes$ItemDifficulty
      .map((e) => e.value!)
      .toList();
}

List<enums.AdminStandardScenesGet$Response$Scenes$ItemDifficulty>
adminStandardScenesGet$Response$Scenes$ItemDifficultyListFromJson(
  List? adminStandardScenesGet$Response$Scenes$ItemDifficulty, [
  List<enums.AdminStandardScenesGet$Response$Scenes$ItemDifficulty>?
  defaultValue,
]) {
  if (adminStandardScenesGet$Response$Scenes$ItemDifficulty == null) {
    return defaultValue ?? [];
  }

  return adminStandardScenesGet$Response$Scenes$ItemDifficulty
      .map(
        (e) => adminStandardScenesGet$Response$Scenes$ItemDifficultyFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.AdminStandardScenesGet$Response$Scenes$ItemDifficulty>?
adminStandardScenesGet$Response$Scenes$ItemDifficultyNullableListFromJson(
  List? adminStandardScenesGet$Response$Scenes$ItemDifficulty, [
  List<enums.AdminStandardScenesGet$Response$Scenes$ItemDifficulty>?
  defaultValue,
]) {
  if (adminStandardScenesGet$Response$Scenes$ItemDifficulty == null) {
    return defaultValue;
  }

  return adminStandardScenesGet$Response$Scenes$ItemDifficulty
      .map(
        (e) => adminStandardScenesGet$Response$Scenes$ItemDifficultyFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? shadowingUpsertPut$RequestBodySourceTypeNullableToJson(
  enums.ShadowingUpsertPut$RequestBodySourceType?
  shadowingUpsertPut$RequestBodySourceType,
) {
  return shadowingUpsertPut$RequestBodySourceType?.value;
}

String? shadowingUpsertPut$RequestBodySourceTypeToJson(
  enums.ShadowingUpsertPut$RequestBodySourceType
  shadowingUpsertPut$RequestBodySourceType,
) {
  return shadowingUpsertPut$RequestBodySourceType.value;
}

enums.ShadowingUpsertPut$RequestBodySourceType
shadowingUpsertPut$RequestBodySourceTypeFromJson(
  Object? shadowingUpsertPut$RequestBodySourceType, [
  enums.ShadowingUpsertPut$RequestBodySourceType? defaultValue,
]) {
  return enums.ShadowingUpsertPut$RequestBodySourceType.values.firstWhereOrNull(
        (e) => e.value == shadowingUpsertPut$RequestBodySourceType,
      ) ??
      defaultValue ??
      enums.ShadowingUpsertPut$RequestBodySourceType.swaggerGeneratedUnknown;
}

enums.ShadowingUpsertPut$RequestBodySourceType?
shadowingUpsertPut$RequestBodySourceTypeNullableFromJson(
  Object? shadowingUpsertPut$RequestBodySourceType, [
  enums.ShadowingUpsertPut$RequestBodySourceType? defaultValue,
]) {
  if (shadowingUpsertPut$RequestBodySourceType == null) {
    return null;
  }
  return enums.ShadowingUpsertPut$RequestBodySourceType.values.firstWhereOrNull(
        (e) => e.value == shadowingUpsertPut$RequestBodySourceType,
      ) ??
      defaultValue;
}

String shadowingUpsertPut$RequestBodySourceTypeExplodedListToJson(
  List<enums.ShadowingUpsertPut$RequestBodySourceType>?
  shadowingUpsertPut$RequestBodySourceType,
) {
  return shadowingUpsertPut$RequestBodySourceType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> shadowingUpsertPut$RequestBodySourceTypeListToJson(
  List<enums.ShadowingUpsertPut$RequestBodySourceType>?
  shadowingUpsertPut$RequestBodySourceType,
) {
  if (shadowingUpsertPut$RequestBodySourceType == null) {
    return [];
  }

  return shadowingUpsertPut$RequestBodySourceType.map((e) => e.value!).toList();
}

List<enums.ShadowingUpsertPut$RequestBodySourceType>
shadowingUpsertPut$RequestBodySourceTypeListFromJson(
  List? shadowingUpsertPut$RequestBodySourceType, [
  List<enums.ShadowingUpsertPut$RequestBodySourceType>? defaultValue,
]) {
  if (shadowingUpsertPut$RequestBodySourceType == null) {
    return defaultValue ?? [];
  }

  return shadowingUpsertPut$RequestBodySourceType
      .map(
        (e) => shadowingUpsertPut$RequestBodySourceTypeFromJson(e.toString()),
      )
      .toList();
}

List<enums.ShadowingUpsertPut$RequestBodySourceType>?
shadowingUpsertPut$RequestBodySourceTypeNullableListFromJson(
  List? shadowingUpsertPut$RequestBodySourceType, [
  List<enums.ShadowingUpsertPut$RequestBodySourceType>? defaultValue,
]) {
  if (shadowingUpsertPut$RequestBodySourceType == null) {
    return defaultValue;
  }

  return shadowingUpsertPut$RequestBodySourceType
      .map(
        (e) => shadowingUpsertPut$RequestBodySourceTypeFromJson(e.toString()),
      )
      .toList();
}

String? shadowingUpsertPut$RequestBody$WordFeedback$ItemLevelNullableToJson(
  enums.ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel?
  shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel,
) {
  return shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel?.value;
}

String? shadowingUpsertPut$RequestBody$WordFeedback$ItemLevelToJson(
  enums.ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel
  shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel,
) {
  return shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel.value;
}

enums.ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel
shadowingUpsertPut$RequestBody$WordFeedback$ItemLevelFromJson(
  Object? shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel, [
  enums.ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel? defaultValue,
]) {
  return enums.ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel,
          ) ??
      defaultValue ??
      enums
          .ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel
          .swaggerGeneratedUnknown;
}

enums.ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel?
shadowingUpsertPut$RequestBody$WordFeedback$ItemLevelNullableFromJson(
  Object? shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel, [
  enums.ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel? defaultValue,
]) {
  if (shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel == null) {
    return null;
  }
  return enums.ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel,
          ) ??
      defaultValue;
}

String shadowingUpsertPut$RequestBody$WordFeedback$ItemLevelExplodedListToJson(
  List<enums.ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel>?
  shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel,
) {
  return shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> shadowingUpsertPut$RequestBody$WordFeedback$ItemLevelListToJson(
  List<enums.ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel>?
  shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel,
) {
  if (shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel == null) {
    return [];
  }

  return shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel
      .map((e) => e.value!)
      .toList();
}

List<enums.ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel>
shadowingUpsertPut$RequestBody$WordFeedback$ItemLevelListFromJson(
  List? shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel, [
  List<enums.ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel>?
  defaultValue,
]) {
  if (shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel == null) {
    return defaultValue ?? [];
  }

  return shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel
      .map(
        (e) => shadowingUpsertPut$RequestBody$WordFeedback$ItemLevelFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel>?
shadowingUpsertPut$RequestBody$WordFeedback$ItemLevelNullableListFromJson(
  List? shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel, [
  List<enums.ShadowingUpsertPut$RequestBody$WordFeedback$ItemLevel>?
  defaultValue,
]) {
  if (shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel == null) {
    return defaultValue;
  }

  return shadowingUpsertPut$RequestBody$WordFeedback$ItemLevel
      .map(
        (e) => shadowingUpsertPut$RequestBody$WordFeedback$ItemLevelFromJson(
          e.toString(),
        ),
      )
      .toList();
}

String? adminStandardScenesPost$RequestBody$Scenes$ItemDifficultyNullableToJson(
  enums.AdminStandardScenesPost$RequestBody$Scenes$ItemDifficulty?
  adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty,
) {
  return adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty?.value;
}

String? adminStandardScenesPost$RequestBody$Scenes$ItemDifficultyToJson(
  enums.AdminStandardScenesPost$RequestBody$Scenes$ItemDifficulty
  adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty,
) {
  return adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty.value;
}

enums.AdminStandardScenesPost$RequestBody$Scenes$ItemDifficulty
adminStandardScenesPost$RequestBody$Scenes$ItemDifficultyFromJson(
  Object? adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty, [
  enums.AdminStandardScenesPost$RequestBody$Scenes$ItemDifficulty? defaultValue,
]) {
  return enums.AdminStandardScenesPost$RequestBody$Scenes$ItemDifficulty.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty,
          ) ??
      defaultValue ??
      enums
          .AdminStandardScenesPost$RequestBody$Scenes$ItemDifficulty
          .swaggerGeneratedUnknown;
}

enums.AdminStandardScenesPost$RequestBody$Scenes$ItemDifficulty?
adminStandardScenesPost$RequestBody$Scenes$ItemDifficultyNullableFromJson(
  Object? adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty, [
  enums.AdminStandardScenesPost$RequestBody$Scenes$ItemDifficulty? defaultValue,
]) {
  if (adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty == null) {
    return null;
  }
  return enums.AdminStandardScenesPost$RequestBody$Scenes$ItemDifficulty.values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty,
          ) ??
      defaultValue;
}

String
adminStandardScenesPost$RequestBody$Scenes$ItemDifficultyExplodedListToJson(
  List<enums.AdminStandardScenesPost$RequestBody$Scenes$ItemDifficulty>?
  adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty,
) {
  return adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
adminStandardScenesPost$RequestBody$Scenes$ItemDifficultyListToJson(
  List<enums.AdminStandardScenesPost$RequestBody$Scenes$ItemDifficulty>?
  adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty,
) {
  if (adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty == null) {
    return [];
  }

  return adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty
      .map((e) => e.value!)
      .toList();
}

List<enums.AdminStandardScenesPost$RequestBody$Scenes$ItemDifficulty>
adminStandardScenesPost$RequestBody$Scenes$ItemDifficultyListFromJson(
  List? adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty, [
  List<enums.AdminStandardScenesPost$RequestBody$Scenes$ItemDifficulty>?
  defaultValue,
]) {
  if (adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty == null) {
    return defaultValue ?? [];
  }

  return adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty
      .map(
        (e) =>
            adminStandardScenesPost$RequestBody$Scenes$ItemDifficultyFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<enums.AdminStandardScenesPost$RequestBody$Scenes$ItemDifficulty>?
adminStandardScenesPost$RequestBody$Scenes$ItemDifficultyNullableListFromJson(
  List? adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty, [
  List<enums.AdminStandardScenesPost$RequestBody$Scenes$ItemDifficulty>?
  defaultValue,
]) {
  if (adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty == null) {
    return defaultValue;
  }

  return adminStandardScenesPost$RequestBody$Scenes$ItemDifficulty
      .map(
        (e) =>
            adminStandardScenesPost$RequestBody$Scenes$ItemDifficultyFromJson(
              e.toString(),
            ),
      )
      .toList();
}

// ignore: unused_element
String? _dateToJson(DateTime? date) {
  if (date == null) {
    return null;
  }

  final year = date.year.toString();
  final month = date.month < 10 ? '0${date.month}' : date.month.toString();
  final day = date.day < 10 ? '0${date.day}' : date.day.toString();

  return '$year-$month-$day';
}

class Wrapped<T> {
  final T value;
  const Wrapped.value(this.value);
}
