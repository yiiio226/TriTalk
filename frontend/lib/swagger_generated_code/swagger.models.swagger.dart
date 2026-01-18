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
  const SceneGeneratePost$RequestBody({required this.description, this.tone});

  factory SceneGeneratePost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$SceneGeneratePost$RequestBodyFromJson(json);

  static const toJsonFactory = _$SceneGeneratePost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$SceneGeneratePost$RequestBodyToJson(this);

  @JsonKey(name: 'description')
  final String description;
  @JsonKey(name: 'tone')
  final String? tone;
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
                const DeepCollectionEquality().equals(other.tone, tone)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(description) ^
      const DeepCollectionEquality().hash(tone) ^
      runtimeType.hashCode;
}

extension $SceneGeneratePost$RequestBodyExtension
    on SceneGeneratePost$RequestBody {
  SceneGeneratePost$RequestBody copyWith({String? description, String? tone}) {
    return SceneGeneratePost$RequestBody(
      description: description ?? this.description,
      tone: tone ?? this.tone,
    );
  }

  SceneGeneratePost$RequestBody copyWithWrapped({
    Wrapped<String>? description,
    Wrapped<String?>? tone,
  }) {
    return SceneGeneratePost$RequestBody(
      description: (description != null ? description.value : this.description),
      tone: (tone != null ? tone.value : this.tone),
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
class ShadowingSavePost$RequestBody {
  const ShadowingSavePost$RequestBody({
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
  });

  factory ShadowingSavePost$RequestBody.fromJson(Map<String, dynamic> json) =>
      _$ShadowingSavePost$RequestBodyFromJson(json);

  static const toJsonFactory = _$ShadowingSavePost$RequestBodyToJson;
  Map<String, dynamic> toJson() => _$ShadowingSavePost$RequestBodyToJson(this);

  @JsonKey(name: 'target_text')
  final String targetText;
  @JsonKey(
    name: 'source_type',
    toJson: shadowingSavePost$RequestBodySourceTypeToJson,
    fromJson: shadowingSavePost$RequestBodySourceTypeFromJson,
  )
  final enums.ShadowingSavePost$RequestBodySourceType sourceType;
  @JsonKey(name: 'source_id')
  final String? sourceId;
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
  final List<ShadowingSavePost$RequestBody$WordFeedback$Item>? wordFeedback;
  @JsonKey(name: 'feedback_text')
  final String? feedbackText;
  @JsonKey(name: 'audio_path')
  final String? audioPath;
  static const fromJsonFactory = _$ShadowingSavePost$RequestBodyFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShadowingSavePost$RequestBody &&
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
            (identical(other.audioPath, audioPath) ||
                const DeepCollectionEquality().equals(
                  other.audioPath,
                  audioPath,
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
      const DeepCollectionEquality().hash(audioPath) ^
      runtimeType.hashCode;
}

extension $ShadowingSavePost$RequestBodyExtension
    on ShadowingSavePost$RequestBody {
  ShadowingSavePost$RequestBody copyWith({
    String? targetText,
    enums.ShadowingSavePost$RequestBodySourceType? sourceType,
    String? sourceId,
    String? sceneKey,
    double? pronunciationScore,
    double? accuracyScore,
    double? fluencyScore,
    double? completenessScore,
    double? prosodyScore,
    List<ShadowingSavePost$RequestBody$WordFeedback$Item>? wordFeedback,
    String? feedbackText,
    String? audioPath,
  }) {
    return ShadowingSavePost$RequestBody(
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
      audioPath: audioPath ?? this.audioPath,
    );
  }

  ShadowingSavePost$RequestBody copyWithWrapped({
    Wrapped<String>? targetText,
    Wrapped<enums.ShadowingSavePost$RequestBodySourceType>? sourceType,
    Wrapped<String?>? sourceId,
    Wrapped<String?>? sceneKey,
    Wrapped<double>? pronunciationScore,
    Wrapped<double?>? accuracyScore,
    Wrapped<double?>? fluencyScore,
    Wrapped<double?>? completenessScore,
    Wrapped<double?>? prosodyScore,
    Wrapped<List<ShadowingSavePost$RequestBody$WordFeedback$Item>?>?
    wordFeedback,
    Wrapped<String?>? feedbackText,
    Wrapped<String?>? audioPath,
  }) {
    return ShadowingSavePost$RequestBody(
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
      audioPath: (audioPath != null ? audioPath.value : this.audioPath),
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
class ShadowingSavePost$Response {
  const ShadowingSavePost$Response({required this.success, required this.data});

  factory ShadowingSavePost$Response.fromJson(Map<String, dynamic> json) =>
      _$ShadowingSavePost$ResponseFromJson(json);

  static const toJsonFactory = _$ShadowingSavePost$ResponseToJson;
  Map<String, dynamic> toJson() => _$ShadowingSavePost$ResponseToJson(this);

  @JsonKey(name: 'success')
  final bool success;
  @JsonKey(name: 'data')
  final ShadowingSavePost$Response$Data data;
  static const fromJsonFactory = _$ShadowingSavePost$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShadowingSavePost$Response &&
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

extension $ShadowingSavePost$ResponseExtension on ShadowingSavePost$Response {
  ShadowingSavePost$Response copyWith({
    bool? success,
    ShadowingSavePost$Response$Data? data,
  }) {
    return ShadowingSavePost$Response(
      success: success ?? this.success,
      data: data ?? this.data,
    );
  }

  ShadowingSavePost$Response copyWithWrapped({
    Wrapped<bool>? success,
    Wrapped<ShadowingSavePost$Response$Data>? data,
  }) {
    return ShadowingSavePost$Response(
      success: (success != null ? success.value : this.success),
      data: (data != null ? data.value : this.data),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ShadowingHistoryGet$Response {
  const ShadowingHistoryGet$Response({
    required this.success,
    required this.data,
  });

  factory ShadowingHistoryGet$Response.fromJson(Map<String, dynamic> json) =>
      _$ShadowingHistoryGet$ResponseFromJson(json);

  static const toJsonFactory = _$ShadowingHistoryGet$ResponseToJson;
  Map<String, dynamic> toJson() => _$ShadowingHistoryGet$ResponseToJson(this);

  @JsonKey(name: 'success')
  final bool success;
  @JsonKey(name: 'data')
  final ShadowingHistoryGet$Response$Data data;
  static const fromJsonFactory = _$ShadowingHistoryGet$ResponseFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShadowingHistoryGet$Response &&
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

extension $ShadowingHistoryGet$ResponseExtension
    on ShadowingHistoryGet$Response {
  ShadowingHistoryGet$Response copyWith({
    bool? success,
    ShadowingHistoryGet$Response$Data? data,
  }) {
    return ShadowingHistoryGet$Response(
      success: success ?? this.success,
      data: data ?? this.data,
    );
  }

  ShadowingHistoryGet$Response copyWithWrapped({
    Wrapped<bool>? success,
    Wrapped<ShadowingHistoryGet$Response$Data>? data,
  }) {
    return ShadowingHistoryGet$Response(
      success: (success != null ? success.value : this.success),
      data: (data != null ? data.value : this.data),
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
class ShadowingSavePost$RequestBody$WordFeedback$Item {
  const ShadowingSavePost$RequestBody$WordFeedback$Item({
    required this.text,
    required this.score,
    required this.level,
    required this.errorType,
    required this.phonemes,
  });

  factory ShadowingSavePost$RequestBody$WordFeedback$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ShadowingSavePost$RequestBody$WordFeedback$ItemFromJson(json);

  static const toJsonFactory =
      _$ShadowingSavePost$RequestBody$WordFeedback$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ShadowingSavePost$RequestBody$WordFeedback$ItemToJson(this);

  @JsonKey(name: 'text')
  final String text;
  @JsonKey(name: 'score')
  final double score;
  @JsonKey(
    name: 'level',
    toJson: shadowingSavePost$RequestBody$WordFeedback$ItemLevelToJson,
    fromJson: shadowingSavePost$RequestBody$WordFeedback$ItemLevelFromJson,
  )
  final enums.ShadowingSavePost$RequestBody$WordFeedback$ItemLevel level;
  @JsonKey(name: 'error_type')
  final String errorType;
  @JsonKey(name: 'phonemes')
  final List<ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$Item>
  phonemes;
  static const fromJsonFactory =
      _$ShadowingSavePost$RequestBody$WordFeedback$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShadowingSavePost$RequestBody$WordFeedback$Item &&
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

extension $ShadowingSavePost$RequestBody$WordFeedback$ItemExtension
    on ShadowingSavePost$RequestBody$WordFeedback$Item {
  ShadowingSavePost$RequestBody$WordFeedback$Item copyWith({
    String? text,
    double? score,
    enums.ShadowingSavePost$RequestBody$WordFeedback$ItemLevel? level,
    String? errorType,
    List<ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$Item>?
    phonemes,
  }) {
    return ShadowingSavePost$RequestBody$WordFeedback$Item(
      text: text ?? this.text,
      score: score ?? this.score,
      level: level ?? this.level,
      errorType: errorType ?? this.errorType,
      phonemes: phonemes ?? this.phonemes,
    );
  }

  ShadowingSavePost$RequestBody$WordFeedback$Item copyWithWrapped({
    Wrapped<String>? text,
    Wrapped<double>? score,
    Wrapped<enums.ShadowingSavePost$RequestBody$WordFeedback$ItemLevel>? level,
    Wrapped<String>? errorType,
    Wrapped<
      List<ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$Item>
    >?
    phonemes,
  }) {
    return ShadowingSavePost$RequestBody$WordFeedback$Item(
      text: (text != null ? text.value : this.text),
      score: (score != null ? score.value : this.score),
      level: (level != null ? level.value : this.level),
      errorType: (errorType != null ? errorType.value : this.errorType),
      phonemes: (phonemes != null ? phonemes.value : this.phonemes),
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
class ShadowingSavePost$Response$Data {
  const ShadowingSavePost$Response$Data({
    required this.id,
    required this.practicedAt,
  });

  factory ShadowingSavePost$Response$Data.fromJson(Map<String, dynamic> json) =>
      _$ShadowingSavePost$Response$DataFromJson(json);

  static const toJsonFactory = _$ShadowingSavePost$Response$DataToJson;
  Map<String, dynamic> toJson() =>
      _$ShadowingSavePost$Response$DataToJson(this);

  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'practiced_at')
  final String practicedAt;
  static const fromJsonFactory = _$ShadowingSavePost$Response$DataFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShadowingSavePost$Response$Data &&
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

extension $ShadowingSavePost$Response$DataExtension
    on ShadowingSavePost$Response$Data {
  ShadowingSavePost$Response$Data copyWith({String? id, String? practicedAt}) {
    return ShadowingSavePost$Response$Data(
      id: id ?? this.id,
      practicedAt: practicedAt ?? this.practicedAt,
    );
  }

  ShadowingSavePost$Response$Data copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? practicedAt,
  }) {
    return ShadowingSavePost$Response$Data(
      id: (id != null ? id.value : this.id),
      practicedAt: (practicedAt != null ? practicedAt.value : this.practicedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ShadowingHistoryGet$Response$Data {
  const ShadowingHistoryGet$Response$Data({
    required this.practices,
    required this.total,
  });

  factory ShadowingHistoryGet$Response$Data.fromJson(
    Map<String, dynamic> json,
  ) => _$ShadowingHistoryGet$Response$DataFromJson(json);

  static const toJsonFactory = _$ShadowingHistoryGet$Response$DataToJson;
  Map<String, dynamic> toJson() =>
      _$ShadowingHistoryGet$Response$DataToJson(this);

  @JsonKey(name: 'practices')
  final List<ShadowingHistoryGet$Response$Data$Practices$Item> practices;
  @JsonKey(name: 'total')
  final double total;
  static const fromJsonFactory = _$ShadowingHistoryGet$Response$DataFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShadowingHistoryGet$Response$Data &&
            (identical(other.practices, practices) ||
                const DeepCollectionEquality().equals(
                  other.practices,
                  practices,
                )) &&
            (identical(other.total, total) ||
                const DeepCollectionEquality().equals(other.total, total)));
  }

  @override
  int get hashCode =>
      const DeepCollectionEquality().hash(practices) ^
      const DeepCollectionEquality().hash(total) ^
      runtimeType.hashCode;
}

extension $ShadowingHistoryGet$Response$DataExtension
    on ShadowingHistoryGet$Response$Data {
  ShadowingHistoryGet$Response$Data copyWith({
    List<ShadowingHistoryGet$Response$Data$Practices$Item>? practices,
    double? total,
  }) {
    return ShadowingHistoryGet$Response$Data(
      practices: practices ?? this.practices,
      total: total ?? this.total,
    );
  }

  ShadowingHistoryGet$Response$Data copyWithWrapped({
    Wrapped<List<ShadowingHistoryGet$Response$Data$Practices$Item>>? practices,
    Wrapped<double>? total,
  }) {
    return ShadowingHistoryGet$Response$Data(
      practices: (practices != null ? practices.value : this.practices),
      total: (total != null ? total.value : this.total),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$Item {
  const ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$Item({
    required this.phoneme,
    required this.accuracyScore,
    this.offset,
    this.duration,
  });

  factory ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$ItemFromJson(
    json,
  );

  static const toJsonFactory =
      _$ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$ItemToJson(
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
      _$ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other
                is ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$Item &&
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

extension $ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$ItemExtension
    on ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$Item {
  ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$Item copyWith({
    String? phoneme,
    double? accuracyScore,
    double? offset,
    double? duration,
  }) {
    return ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$Item(
      phoneme: phoneme ?? this.phoneme,
      accuracyScore: accuracyScore ?? this.accuracyScore,
      offset: offset ?? this.offset,
      duration: duration ?? this.duration,
    );
  }

  ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$Item
  copyWithWrapped({
    Wrapped<String>? phoneme,
    Wrapped<double>? accuracyScore,
    Wrapped<double?>? offset,
    Wrapped<double?>? duration,
  }) {
    return ShadowingSavePost$RequestBody$WordFeedback$Item$Phonemes$Item(
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
class ShadowingHistoryGet$Response$Data$Practices$Item {
  const ShadowingHistoryGet$Response$Data$Practices$Item({
    required this.id,
    required this.targetText,
    required this.sourceType,
    this.sourceId,
    required this.pronunciationScore,
    this.accuracyScore,
    this.fluencyScore,
    this.completenessScore,
    this.prosodyScore,
    required this.wordFeedback,
    this.feedbackText,
    this.audioPath,
    required this.practicedAt,
  });

  factory ShadowingHistoryGet$Response$Data$Practices$Item.fromJson(
    Map<String, dynamic> json,
  ) => _$ShadowingHistoryGet$Response$Data$Practices$ItemFromJson(json);

  static const toJsonFactory =
      _$ShadowingHistoryGet$Response$Data$Practices$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ShadowingHistoryGet$Response$Data$Practices$ItemToJson(this);

  @JsonKey(name: 'id')
  final String id;
  @JsonKey(name: 'target_text')
  final String targetText;
  @JsonKey(name: 'source_type')
  final String sourceType;
  @JsonKey(name: 'source_id')
  final String? sourceId;
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
  final List<ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item>
  wordFeedback;
  @JsonKey(name: 'feedback_text')
  final String? feedbackText;
  @JsonKey(name: 'audio_path')
  final String? audioPath;
  @JsonKey(name: 'practiced_at')
  final String practicedAt;
  static const fromJsonFactory =
      _$ShadowingHistoryGet$Response$Data$Practices$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is ShadowingHistoryGet$Response$Data$Practices$Item &&
            (identical(other.id, id) ||
                const DeepCollectionEquality().equals(other.id, id)) &&
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
            (identical(other.audioPath, audioPath) ||
                const DeepCollectionEquality().equals(
                  other.audioPath,
                  audioPath,
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
      const DeepCollectionEquality().hash(targetText) ^
      const DeepCollectionEquality().hash(sourceType) ^
      const DeepCollectionEquality().hash(sourceId) ^
      const DeepCollectionEquality().hash(pronunciationScore) ^
      const DeepCollectionEquality().hash(accuracyScore) ^
      const DeepCollectionEquality().hash(fluencyScore) ^
      const DeepCollectionEquality().hash(completenessScore) ^
      const DeepCollectionEquality().hash(prosodyScore) ^
      const DeepCollectionEquality().hash(wordFeedback) ^
      const DeepCollectionEquality().hash(feedbackText) ^
      const DeepCollectionEquality().hash(audioPath) ^
      const DeepCollectionEquality().hash(practicedAt) ^
      runtimeType.hashCode;
}

extension $ShadowingHistoryGet$Response$Data$Practices$ItemExtension
    on ShadowingHistoryGet$Response$Data$Practices$Item {
  ShadowingHistoryGet$Response$Data$Practices$Item copyWith({
    String? id,
    String? targetText,
    String? sourceType,
    String? sourceId,
    double? pronunciationScore,
    double? accuracyScore,
    double? fluencyScore,
    double? completenessScore,
    double? prosodyScore,
    List<ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item>?
    wordFeedback,
    String? feedbackText,
    String? audioPath,
    String? practicedAt,
  }) {
    return ShadowingHistoryGet$Response$Data$Practices$Item(
      id: id ?? this.id,
      targetText: targetText ?? this.targetText,
      sourceType: sourceType ?? this.sourceType,
      sourceId: sourceId ?? this.sourceId,
      pronunciationScore: pronunciationScore ?? this.pronunciationScore,
      accuracyScore: accuracyScore ?? this.accuracyScore,
      fluencyScore: fluencyScore ?? this.fluencyScore,
      completenessScore: completenessScore ?? this.completenessScore,
      prosodyScore: prosodyScore ?? this.prosodyScore,
      wordFeedback: wordFeedback ?? this.wordFeedback,
      feedbackText: feedbackText ?? this.feedbackText,
      audioPath: audioPath ?? this.audioPath,
      practicedAt: practicedAt ?? this.practicedAt,
    );
  }

  ShadowingHistoryGet$Response$Data$Practices$Item copyWithWrapped({
    Wrapped<String>? id,
    Wrapped<String>? targetText,
    Wrapped<String>? sourceType,
    Wrapped<String?>? sourceId,
    Wrapped<double>? pronunciationScore,
    Wrapped<double?>? accuracyScore,
    Wrapped<double?>? fluencyScore,
    Wrapped<double?>? completenessScore,
    Wrapped<double?>? prosodyScore,
    Wrapped<
      List<ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item>
    >?
    wordFeedback,
    Wrapped<String?>? feedbackText,
    Wrapped<String?>? audioPath,
    Wrapped<String>? practicedAt,
  }) {
    return ShadowingHistoryGet$Response$Data$Practices$Item(
      id: (id != null ? id.value : this.id),
      targetText: (targetText != null ? targetText.value : this.targetText),
      sourceType: (sourceType != null ? sourceType.value : this.sourceType),
      sourceId: (sourceId != null ? sourceId.value : this.sourceId),
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
      audioPath: (audioPath != null ? audioPath.value : this.audioPath),
      practicedAt: (practicedAt != null ? practicedAt.value : this.practicedAt),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item {
  const ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item({
    required this.text,
    required this.score,
    required this.level,
    required this.errorType,
    required this.phonemes,
  });

  factory ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemFromJson(
        json,
      );

  static const toJsonFactory =
      _$ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemToJson(
        this,
      );

  @JsonKey(name: 'text')
  final String text;
  @JsonKey(name: 'score')
  final double score;
  @JsonKey(
    name: 'level',
    toJson:
        shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevelToJson,
    fromJson:
        shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevelFromJson,
  )
  final enums.ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
  level;
  @JsonKey(name: 'error_type')
  final String errorType;
  @JsonKey(name: 'phonemes')
  final List<
    ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$Item
  >
  phonemes;
  static const fromJsonFactory =
      _$ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other
                is ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item &&
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

extension $ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemExtension
    on ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item {
  ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item copyWith({
    String? text,
    double? score,
    enums.ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel?
    level,
    String? errorType,
    List<
      ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$Item
    >?
    phonemes,
  }) {
    return ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item(
      text: text ?? this.text,
      score: score ?? this.score,
      level: level ?? this.level,
      errorType: errorType ?? this.errorType,
      phonemes: phonemes ?? this.phonemes,
    );
  }

  ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item
  copyWithWrapped({
    Wrapped<String>? text,
    Wrapped<double>? score,
    Wrapped<
      enums.ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
    >?
    level,
    Wrapped<String>? errorType,
    Wrapped<
      List<
        ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$Item
      >
    >?
    phonemes,
  }) {
    return ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item(
      text: (text != null ? text.value : this.text),
      score: (score != null ? score.value : this.score),
      level: (level != null ? level.value : this.level),
      errorType: (errorType != null ? errorType.value : this.errorType),
      phonemes: (phonemes != null ? phonemes.value : this.phonemes),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$Item {
  const ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$Item({
    required this.phoneme,
    required this.accuracyScore,
    this.offset,
    this.duration,
  });

  factory ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$Item.fromJson(
    Map<String, dynamic> json,
  ) =>
      _$ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$ItemFromJson(
        json,
      );

  static const toJsonFactory =
      _$ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$ItemToJson;
  Map<String, dynamic> toJson() =>
      _$ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$ItemToJson(
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
      _$ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$ItemFromJson;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other
                is ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$Item &&
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

extension $ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$ItemExtension
    on
        ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$Item {
  ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$Item
  copyWith({
    String? phoneme,
    double? accuracyScore,
    double? offset,
    double? duration,
  }) {
    return ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$Item(
      phoneme: phoneme ?? this.phoneme,
      accuracyScore: accuracyScore ?? this.accuracyScore,
      offset: offset ?? this.offset,
      duration: duration ?? this.duration,
    );
  }

  ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$Item
  copyWithWrapped({
    Wrapped<String>? phoneme,
    Wrapped<double>? accuracyScore,
    Wrapped<double?>? offset,
    Wrapped<double?>? duration,
  }) {
    return ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$Item$Phonemes$Item(
      phoneme: (phoneme != null ? phoneme.value : this.phoneme),
      accuracyScore: (accuracyScore != null
          ? accuracyScore.value
          : this.accuracyScore),
      offset: (offset != null ? offset.value : this.offset),
      duration: (duration != null ? duration.value : this.duration),
    );
  }
}

String?
shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevelNullableToJson(
  enums.ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel?
  shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel,
) {
  return shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
      ?.value;
}

String?
shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevelToJson(
  enums.ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
  shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel,
) {
  return shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
      .value;
}

enums.ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevelFromJson(
  Object?
  shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel, [
  enums.ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel?
  defaultValue,
]) {
  return enums
          .ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel,
          ) ??
      defaultValue ??
      enums
          .ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
          .swaggerGeneratedUnknown;
}

enums.ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel?
shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevelNullableFromJson(
  Object?
  shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel, [
  enums.ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel?
  defaultValue,
]) {
  if (shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel ==
      null) {
    return null;
  }
  return enums
          .ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
          .values
          .firstWhereOrNull(
            (e) =>
                e.value ==
                shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel,
          ) ??
      defaultValue;
}

String
shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevelExplodedListToJson(
  List<
    enums.ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
  >?
  shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel,
) {
  return shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String>
shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevelListToJson(
  List<
    enums.ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
  >?
  shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel,
) {
  if (shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel ==
      null) {
    return [];
  }

  return shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
      .map((e) => e.value!)
      .toList();
}

List<
  enums.ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
>
shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevelListFromJson(
  List?
  shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel, [
  List<
    enums.ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
  >?
  defaultValue,
]) {
  if (shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel ==
      null) {
    return defaultValue ?? [];
  }

  return shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
      .map(
        (e) =>
            shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevelFromJson(
              e.toString(),
            ),
      )
      .toList();
}

List<
  enums.ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
>?
shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevelNullableListFromJson(
  List?
  shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel, [
  List<
    enums.ShadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
  >?
  defaultValue,
]) {
  if (shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel ==
      null) {
    return defaultValue;
  }

  return shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevel
      .map(
        (e) =>
            shadowingHistoryGet$Response$Data$Practices$Item$WordFeedback$ItemLevelFromJson(
              e.toString(),
            ),
      )
      .toList();
}

String? shadowingSavePost$RequestBodySourceTypeNullableToJson(
  enums.ShadowingSavePost$RequestBodySourceType?
  shadowingSavePost$RequestBodySourceType,
) {
  return shadowingSavePost$RequestBodySourceType?.value;
}

String? shadowingSavePost$RequestBodySourceTypeToJson(
  enums.ShadowingSavePost$RequestBodySourceType
  shadowingSavePost$RequestBodySourceType,
) {
  return shadowingSavePost$RequestBodySourceType.value;
}

enums.ShadowingSavePost$RequestBodySourceType
shadowingSavePost$RequestBodySourceTypeFromJson(
  Object? shadowingSavePost$RequestBodySourceType, [
  enums.ShadowingSavePost$RequestBodySourceType? defaultValue,
]) {
  return enums.ShadowingSavePost$RequestBodySourceType.values.firstWhereOrNull(
        (e) => e.value == shadowingSavePost$RequestBodySourceType,
      ) ??
      defaultValue ??
      enums.ShadowingSavePost$RequestBodySourceType.swaggerGeneratedUnknown;
}

enums.ShadowingSavePost$RequestBodySourceType?
shadowingSavePost$RequestBodySourceTypeNullableFromJson(
  Object? shadowingSavePost$RequestBodySourceType, [
  enums.ShadowingSavePost$RequestBodySourceType? defaultValue,
]) {
  if (shadowingSavePost$RequestBodySourceType == null) {
    return null;
  }
  return enums.ShadowingSavePost$RequestBodySourceType.values.firstWhereOrNull(
        (e) => e.value == shadowingSavePost$RequestBodySourceType,
      ) ??
      defaultValue;
}

String shadowingSavePost$RequestBodySourceTypeExplodedListToJson(
  List<enums.ShadowingSavePost$RequestBodySourceType>?
  shadowingSavePost$RequestBodySourceType,
) {
  return shadowingSavePost$RequestBodySourceType
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> shadowingSavePost$RequestBodySourceTypeListToJson(
  List<enums.ShadowingSavePost$RequestBodySourceType>?
  shadowingSavePost$RequestBodySourceType,
) {
  if (shadowingSavePost$RequestBodySourceType == null) {
    return [];
  }

  return shadowingSavePost$RequestBodySourceType.map((e) => e.value!).toList();
}

List<enums.ShadowingSavePost$RequestBodySourceType>
shadowingSavePost$RequestBodySourceTypeListFromJson(
  List? shadowingSavePost$RequestBodySourceType, [
  List<enums.ShadowingSavePost$RequestBodySourceType>? defaultValue,
]) {
  if (shadowingSavePost$RequestBodySourceType == null) {
    return defaultValue ?? [];
  }

  return shadowingSavePost$RequestBodySourceType
      .map((e) => shadowingSavePost$RequestBodySourceTypeFromJson(e.toString()))
      .toList();
}

List<enums.ShadowingSavePost$RequestBodySourceType>?
shadowingSavePost$RequestBodySourceTypeNullableListFromJson(
  List? shadowingSavePost$RequestBodySourceType, [
  List<enums.ShadowingSavePost$RequestBodySourceType>? defaultValue,
]) {
  if (shadowingSavePost$RequestBodySourceType == null) {
    return defaultValue;
  }

  return shadowingSavePost$RequestBodySourceType
      .map((e) => shadowingSavePost$RequestBodySourceTypeFromJson(e.toString()))
      .toList();
}

String? shadowingSavePost$RequestBody$WordFeedback$ItemLevelNullableToJson(
  enums.ShadowingSavePost$RequestBody$WordFeedback$ItemLevel?
  shadowingSavePost$RequestBody$WordFeedback$ItemLevel,
) {
  return shadowingSavePost$RequestBody$WordFeedback$ItemLevel?.value;
}

String? shadowingSavePost$RequestBody$WordFeedback$ItemLevelToJson(
  enums.ShadowingSavePost$RequestBody$WordFeedback$ItemLevel
  shadowingSavePost$RequestBody$WordFeedback$ItemLevel,
) {
  return shadowingSavePost$RequestBody$WordFeedback$ItemLevel.value;
}

enums.ShadowingSavePost$RequestBody$WordFeedback$ItemLevel
shadowingSavePost$RequestBody$WordFeedback$ItemLevelFromJson(
  Object? shadowingSavePost$RequestBody$WordFeedback$ItemLevel, [
  enums.ShadowingSavePost$RequestBody$WordFeedback$ItemLevel? defaultValue,
]) {
  return enums.ShadowingSavePost$RequestBody$WordFeedback$ItemLevel.values
          .firstWhereOrNull(
            (e) =>
                e.value == shadowingSavePost$RequestBody$WordFeedback$ItemLevel,
          ) ??
      defaultValue ??
      enums
          .ShadowingSavePost$RequestBody$WordFeedback$ItemLevel
          .swaggerGeneratedUnknown;
}

enums.ShadowingSavePost$RequestBody$WordFeedback$ItemLevel?
shadowingSavePost$RequestBody$WordFeedback$ItemLevelNullableFromJson(
  Object? shadowingSavePost$RequestBody$WordFeedback$ItemLevel, [
  enums.ShadowingSavePost$RequestBody$WordFeedback$ItemLevel? defaultValue,
]) {
  if (shadowingSavePost$RequestBody$WordFeedback$ItemLevel == null) {
    return null;
  }
  return enums.ShadowingSavePost$RequestBody$WordFeedback$ItemLevel.values
          .firstWhereOrNull(
            (e) =>
                e.value == shadowingSavePost$RequestBody$WordFeedback$ItemLevel,
          ) ??
      defaultValue;
}

String shadowingSavePost$RequestBody$WordFeedback$ItemLevelExplodedListToJson(
  List<enums.ShadowingSavePost$RequestBody$WordFeedback$ItemLevel>?
  shadowingSavePost$RequestBody$WordFeedback$ItemLevel,
) {
  return shadowingSavePost$RequestBody$WordFeedback$ItemLevel
          ?.map((e) => e.value!)
          .join(',') ??
      '';
}

List<String> shadowingSavePost$RequestBody$WordFeedback$ItemLevelListToJson(
  List<enums.ShadowingSavePost$RequestBody$WordFeedback$ItemLevel>?
  shadowingSavePost$RequestBody$WordFeedback$ItemLevel,
) {
  if (shadowingSavePost$RequestBody$WordFeedback$ItemLevel == null) {
    return [];
  }

  return shadowingSavePost$RequestBody$WordFeedback$ItemLevel
      .map((e) => e.value!)
      .toList();
}

List<enums.ShadowingSavePost$RequestBody$WordFeedback$ItemLevel>
shadowingSavePost$RequestBody$WordFeedback$ItemLevelListFromJson(
  List? shadowingSavePost$RequestBody$WordFeedback$ItemLevel, [
  List<enums.ShadowingSavePost$RequestBody$WordFeedback$ItemLevel>?
  defaultValue,
]) {
  if (shadowingSavePost$RequestBody$WordFeedback$ItemLevel == null) {
    return defaultValue ?? [];
  }

  return shadowingSavePost$RequestBody$WordFeedback$ItemLevel
      .map(
        (e) => shadowingSavePost$RequestBody$WordFeedback$ItemLevelFromJson(
          e.toString(),
        ),
      )
      .toList();
}

List<enums.ShadowingSavePost$RequestBody$WordFeedback$ItemLevel>?
shadowingSavePost$RequestBody$WordFeedback$ItemLevelNullableListFromJson(
  List? shadowingSavePost$RequestBody$WordFeedback$ItemLevel, [
  List<enums.ShadowingSavePost$RequestBody$WordFeedback$ItemLevel>?
  defaultValue,
]) {
  if (shadowingSavePost$RequestBody$WordFeedback$ItemLevel == null) {
    return defaultValue;
  }

  return shadowingSavePost$RequestBody$WordFeedback$ItemLevel
      .map(
        (e) => shadowingSavePost$RequestBody$WordFeedback$ItemLevelFromJson(
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
