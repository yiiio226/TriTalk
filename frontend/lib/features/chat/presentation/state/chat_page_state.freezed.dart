// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_page_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatPageState {

/// List of messages in the current conversation
 List<Message> get messages;/// Whether the initial load is in progress
 bool get isLoading;/// Whether a message is currently being sent
 bool get isSending;/// Whether voice recording is active
 bool get isRecording;/// Whether voice transcription is in progress
 bool get isTranscribing;/// Whether the app is currently playing audio
 bool get isPlayingAudio;/// ID of the message currently playing audio
 String? get playingMessageId;/// Whether multi-select mode is active
 bool get isMultiSelectMode;/// Set of selected message IDs in multi-select mode
 Set<String> get selectedMessageIds;/// Error message to display (transient)
 String? get error;/// Whether to show the error banner
 bool get showErrorBanner;/// Whether the last error was a timeout
 bool get isTimeoutError;/// Cached hints for the current conversation state
 List<String>? get cachedHints;/// Optimization loading state
 bool get isOptimizing;
/// Create a copy of ChatPageState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatPageStateCopyWith<ChatPageState> get copyWith => _$ChatPageStateCopyWithImpl<ChatPageState>(this as ChatPageState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatPageState&&const DeepCollectionEquality().equals(other.messages, messages)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&(identical(other.isRecording, isRecording) || other.isRecording == isRecording)&&(identical(other.isTranscribing, isTranscribing) || other.isTranscribing == isTranscribing)&&(identical(other.isPlayingAudio, isPlayingAudio) || other.isPlayingAudio == isPlayingAudio)&&(identical(other.playingMessageId, playingMessageId) || other.playingMessageId == playingMessageId)&&(identical(other.isMultiSelectMode, isMultiSelectMode) || other.isMultiSelectMode == isMultiSelectMode)&&const DeepCollectionEquality().equals(other.selectedMessageIds, selectedMessageIds)&&(identical(other.error, error) || other.error == error)&&(identical(other.showErrorBanner, showErrorBanner) || other.showErrorBanner == showErrorBanner)&&(identical(other.isTimeoutError, isTimeoutError) || other.isTimeoutError == isTimeoutError)&&const DeepCollectionEquality().equals(other.cachedHints, cachedHints)&&(identical(other.isOptimizing, isOptimizing) || other.isOptimizing == isOptimizing));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(messages),isLoading,isSending,isRecording,isTranscribing,isPlayingAudio,playingMessageId,isMultiSelectMode,const DeepCollectionEquality().hash(selectedMessageIds),error,showErrorBanner,isTimeoutError,const DeepCollectionEquality().hash(cachedHints),isOptimizing);

@override
String toString() {
  return 'ChatPageState(messages: $messages, isLoading: $isLoading, isSending: $isSending, isRecording: $isRecording, isTranscribing: $isTranscribing, isPlayingAudio: $isPlayingAudio, playingMessageId: $playingMessageId, isMultiSelectMode: $isMultiSelectMode, selectedMessageIds: $selectedMessageIds, error: $error, showErrorBanner: $showErrorBanner, isTimeoutError: $isTimeoutError, cachedHints: $cachedHints, isOptimizing: $isOptimizing)';
}


}

/// @nodoc
abstract mixin class $ChatPageStateCopyWith<$Res>  {
  factory $ChatPageStateCopyWith(ChatPageState value, $Res Function(ChatPageState) _then) = _$ChatPageStateCopyWithImpl;
@useResult
$Res call({
 List<Message> messages, bool isLoading, bool isSending, bool isRecording, bool isTranscribing, bool isPlayingAudio, String? playingMessageId, bool isMultiSelectMode, Set<String> selectedMessageIds, String? error, bool showErrorBanner, bool isTimeoutError, List<String>? cachedHints, bool isOptimizing
});




}
/// @nodoc
class _$ChatPageStateCopyWithImpl<$Res>
    implements $ChatPageStateCopyWith<$Res> {
  _$ChatPageStateCopyWithImpl(this._self, this._then);

  final ChatPageState _self;
  final $Res Function(ChatPageState) _then;

/// Create a copy of ChatPageState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? messages = null,Object? isLoading = null,Object? isSending = null,Object? isRecording = null,Object? isTranscribing = null,Object? isPlayingAudio = null,Object? playingMessageId = freezed,Object? isMultiSelectMode = null,Object? selectedMessageIds = null,Object? error = freezed,Object? showErrorBanner = null,Object? isTimeoutError = null,Object? cachedHints = freezed,Object? isOptimizing = null,}) {
  return _then(_self.copyWith(
messages: null == messages ? _self.messages : messages // ignore: cast_nullable_to_non_nullable
as List<Message>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,isRecording: null == isRecording ? _self.isRecording : isRecording // ignore: cast_nullable_to_non_nullable
as bool,isTranscribing: null == isTranscribing ? _self.isTranscribing : isTranscribing // ignore: cast_nullable_to_non_nullable
as bool,isPlayingAudio: null == isPlayingAudio ? _self.isPlayingAudio : isPlayingAudio // ignore: cast_nullable_to_non_nullable
as bool,playingMessageId: freezed == playingMessageId ? _self.playingMessageId : playingMessageId // ignore: cast_nullable_to_non_nullable
as String?,isMultiSelectMode: null == isMultiSelectMode ? _self.isMultiSelectMode : isMultiSelectMode // ignore: cast_nullable_to_non_nullable
as bool,selectedMessageIds: null == selectedMessageIds ? _self.selectedMessageIds : selectedMessageIds // ignore: cast_nullable_to_non_nullable
as Set<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,showErrorBanner: null == showErrorBanner ? _self.showErrorBanner : showErrorBanner // ignore: cast_nullable_to_non_nullable
as bool,isTimeoutError: null == isTimeoutError ? _self.isTimeoutError : isTimeoutError // ignore: cast_nullable_to_non_nullable
as bool,cachedHints: freezed == cachedHints ? _self.cachedHints : cachedHints // ignore: cast_nullable_to_non_nullable
as List<String>?,isOptimizing: null == isOptimizing ? _self.isOptimizing : isOptimizing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatPageState].
extension ChatPageStatePatterns on ChatPageState {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatPageState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatPageState() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatPageState value)  $default,){
final _that = this;
switch (_that) {
case _ChatPageState():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatPageState value)?  $default,){
final _that = this;
switch (_that) {
case _ChatPageState() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Message> messages,  bool isLoading,  bool isSending,  bool isRecording,  bool isTranscribing,  bool isPlayingAudio,  String? playingMessageId,  bool isMultiSelectMode,  Set<String> selectedMessageIds,  String? error,  bool showErrorBanner,  bool isTimeoutError,  List<String>? cachedHints,  bool isOptimizing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatPageState() when $default != null:
return $default(_that.messages,_that.isLoading,_that.isSending,_that.isRecording,_that.isTranscribing,_that.isPlayingAudio,_that.playingMessageId,_that.isMultiSelectMode,_that.selectedMessageIds,_that.error,_that.showErrorBanner,_that.isTimeoutError,_that.cachedHints,_that.isOptimizing);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Message> messages,  bool isLoading,  bool isSending,  bool isRecording,  bool isTranscribing,  bool isPlayingAudio,  String? playingMessageId,  bool isMultiSelectMode,  Set<String> selectedMessageIds,  String? error,  bool showErrorBanner,  bool isTimeoutError,  List<String>? cachedHints,  bool isOptimizing)  $default,) {final _that = this;
switch (_that) {
case _ChatPageState():
return $default(_that.messages,_that.isLoading,_that.isSending,_that.isRecording,_that.isTranscribing,_that.isPlayingAudio,_that.playingMessageId,_that.isMultiSelectMode,_that.selectedMessageIds,_that.error,_that.showErrorBanner,_that.isTimeoutError,_that.cachedHints,_that.isOptimizing);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Message> messages,  bool isLoading,  bool isSending,  bool isRecording,  bool isTranscribing,  bool isPlayingAudio,  String? playingMessageId,  bool isMultiSelectMode,  Set<String> selectedMessageIds,  String? error,  bool showErrorBanner,  bool isTimeoutError,  List<String>? cachedHints,  bool isOptimizing)?  $default,) {final _that = this;
switch (_that) {
case _ChatPageState() when $default != null:
return $default(_that.messages,_that.isLoading,_that.isSending,_that.isRecording,_that.isTranscribing,_that.isPlayingAudio,_that.playingMessageId,_that.isMultiSelectMode,_that.selectedMessageIds,_that.error,_that.showErrorBanner,_that.isTimeoutError,_that.cachedHints,_that.isOptimizing);case _:
  return null;

}
}

}

/// @nodoc


class _ChatPageState implements ChatPageState {
  const _ChatPageState({final  List<Message> messages = const [], this.isLoading = false, this.isSending = false, this.isRecording = false, this.isTranscribing = false, this.isPlayingAudio = false, this.playingMessageId, this.isMultiSelectMode = false, final  Set<String> selectedMessageIds = const {}, this.error, this.showErrorBanner = false, this.isTimeoutError = false, final  List<String>? cachedHints, this.isOptimizing = false}): _messages = messages,_selectedMessageIds = selectedMessageIds,_cachedHints = cachedHints;
  

/// List of messages in the current conversation
 final  List<Message> _messages;
/// List of messages in the current conversation
@override@JsonKey() List<Message> get messages {
  if (_messages is EqualUnmodifiableListView) return _messages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_messages);
}

/// Whether the initial load is in progress
@override@JsonKey() final  bool isLoading;
/// Whether a message is currently being sent
@override@JsonKey() final  bool isSending;
/// Whether voice recording is active
@override@JsonKey() final  bool isRecording;
/// Whether voice transcription is in progress
@override@JsonKey() final  bool isTranscribing;
/// Whether the app is currently playing audio
@override@JsonKey() final  bool isPlayingAudio;
/// ID of the message currently playing audio
@override final  String? playingMessageId;
/// Whether multi-select mode is active
@override@JsonKey() final  bool isMultiSelectMode;
/// Set of selected message IDs in multi-select mode
 final  Set<String> _selectedMessageIds;
/// Set of selected message IDs in multi-select mode
@override@JsonKey() Set<String> get selectedMessageIds {
  if (_selectedMessageIds is EqualUnmodifiableSetView) return _selectedMessageIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedMessageIds);
}

/// Error message to display (transient)
@override final  String? error;
/// Whether to show the error banner
@override@JsonKey() final  bool showErrorBanner;
/// Whether the last error was a timeout
@override@JsonKey() final  bool isTimeoutError;
/// Cached hints for the current conversation state
 final  List<String>? _cachedHints;
/// Cached hints for the current conversation state
@override List<String>? get cachedHints {
  final value = _cachedHints;
  if (value == null) return null;
  if (_cachedHints is EqualUnmodifiableListView) return _cachedHints;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

/// Optimization loading state
@override@JsonKey() final  bool isOptimizing;

/// Create a copy of ChatPageState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatPageStateCopyWith<_ChatPageState> get copyWith => __$ChatPageStateCopyWithImpl<_ChatPageState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatPageState&&const DeepCollectionEquality().equals(other._messages, _messages)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isSending, isSending) || other.isSending == isSending)&&(identical(other.isRecording, isRecording) || other.isRecording == isRecording)&&(identical(other.isTranscribing, isTranscribing) || other.isTranscribing == isTranscribing)&&(identical(other.isPlayingAudio, isPlayingAudio) || other.isPlayingAudio == isPlayingAudio)&&(identical(other.playingMessageId, playingMessageId) || other.playingMessageId == playingMessageId)&&(identical(other.isMultiSelectMode, isMultiSelectMode) || other.isMultiSelectMode == isMultiSelectMode)&&const DeepCollectionEquality().equals(other._selectedMessageIds, _selectedMessageIds)&&(identical(other.error, error) || other.error == error)&&(identical(other.showErrorBanner, showErrorBanner) || other.showErrorBanner == showErrorBanner)&&(identical(other.isTimeoutError, isTimeoutError) || other.isTimeoutError == isTimeoutError)&&const DeepCollectionEquality().equals(other._cachedHints, _cachedHints)&&(identical(other.isOptimizing, isOptimizing) || other.isOptimizing == isOptimizing));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_messages),isLoading,isSending,isRecording,isTranscribing,isPlayingAudio,playingMessageId,isMultiSelectMode,const DeepCollectionEquality().hash(_selectedMessageIds),error,showErrorBanner,isTimeoutError,const DeepCollectionEquality().hash(_cachedHints),isOptimizing);

@override
String toString() {
  return 'ChatPageState(messages: $messages, isLoading: $isLoading, isSending: $isSending, isRecording: $isRecording, isTranscribing: $isTranscribing, isPlayingAudio: $isPlayingAudio, playingMessageId: $playingMessageId, isMultiSelectMode: $isMultiSelectMode, selectedMessageIds: $selectedMessageIds, error: $error, showErrorBanner: $showErrorBanner, isTimeoutError: $isTimeoutError, cachedHints: $cachedHints, isOptimizing: $isOptimizing)';
}


}

/// @nodoc
abstract mixin class _$ChatPageStateCopyWith<$Res> implements $ChatPageStateCopyWith<$Res> {
  factory _$ChatPageStateCopyWith(_ChatPageState value, $Res Function(_ChatPageState) _then) = __$ChatPageStateCopyWithImpl;
@override @useResult
$Res call({
 List<Message> messages, bool isLoading, bool isSending, bool isRecording, bool isTranscribing, bool isPlayingAudio, String? playingMessageId, bool isMultiSelectMode, Set<String> selectedMessageIds, String? error, bool showErrorBanner, bool isTimeoutError, List<String>? cachedHints, bool isOptimizing
});




}
/// @nodoc
class __$ChatPageStateCopyWithImpl<$Res>
    implements _$ChatPageStateCopyWith<$Res> {
  __$ChatPageStateCopyWithImpl(this._self, this._then);

  final _ChatPageState _self;
  final $Res Function(_ChatPageState) _then;

/// Create a copy of ChatPageState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? messages = null,Object? isLoading = null,Object? isSending = null,Object? isRecording = null,Object? isTranscribing = null,Object? isPlayingAudio = null,Object? playingMessageId = freezed,Object? isMultiSelectMode = null,Object? selectedMessageIds = null,Object? error = freezed,Object? showErrorBanner = null,Object? isTimeoutError = null,Object? cachedHints = freezed,Object? isOptimizing = null,}) {
  return _then(_ChatPageState(
messages: null == messages ? _self._messages : messages // ignore: cast_nullable_to_non_nullable
as List<Message>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isSending: null == isSending ? _self.isSending : isSending // ignore: cast_nullable_to_non_nullable
as bool,isRecording: null == isRecording ? _self.isRecording : isRecording // ignore: cast_nullable_to_non_nullable
as bool,isTranscribing: null == isTranscribing ? _self.isTranscribing : isTranscribing // ignore: cast_nullable_to_non_nullable
as bool,isPlayingAudio: null == isPlayingAudio ? _self.isPlayingAudio : isPlayingAudio // ignore: cast_nullable_to_non_nullable
as bool,playingMessageId: freezed == playingMessageId ? _self.playingMessageId : playingMessageId // ignore: cast_nullable_to_non_nullable
as String?,isMultiSelectMode: null == isMultiSelectMode ? _self.isMultiSelectMode : isMultiSelectMode // ignore: cast_nullable_to_non_nullable
as bool,selectedMessageIds: null == selectedMessageIds ? _self._selectedMessageIds : selectedMessageIds // ignore: cast_nullable_to_non_nullable
as Set<String>,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,showErrorBanner: null == showErrorBanner ? _self.showErrorBanner : showErrorBanner // ignore: cast_nullable_to_non_nullable
as bool,isTimeoutError: null == isTimeoutError ? _self.isTimeoutError : isTimeoutError // ignore: cast_nullable_to_non_nullable
as bool,cachedHints: freezed == cachedHints ? _self._cachedHints : cachedHints // ignore: cast_nullable_to_non_nullable
as List<String>?,isOptimizing: null == isOptimizing ? _self.isOptimizing : isOptimizing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
