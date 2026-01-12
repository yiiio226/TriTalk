import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../../models/message.dart';

part 'chat_page_state.freezed.dart';

@freezed
abstract class ChatPageState with _$ChatPageState {
  const factory ChatPageState({
    /// List of messages in the current conversation
    @Default([]) List<Message> messages,

    /// Whether the initial load is in progress
    @Default(false) bool isLoading,

    /// Whether a message is currently being sent
    @Default(false) bool isSending,

    /// Whether voice recording is active
    @Default(false) bool isRecording,

    /// Current recording duration in seconds (for UI display)
    @Default(0) int recordingDuration,

    /// Whether voice transcription is in progress
    @Default(false) bool isTranscribing,

    /// Whether the app is currently playing audio
    @Default(false) bool isPlayingAudio,

    /// ID of the message currently playing audio
    String? playingMessageId,

    /// Whether multi-select mode is active
    @Default(false) bool isMultiSelectMode,

    /// Set of selected message IDs in multi-select mode
    @Default({}) Set<String> selectedMessageIds,

    /// Error message to display (transient)
    String? error,

    /// Whether to show the error banner
    @Default(false) bool showErrorBanner,

    /// Whether the last error was a timeout
    @Default(false) bool isTimeoutError,

    /// Cached hints for the current conversation state
    List<String>? cachedHints,

    /// Optimization loading state
    @Default(false) bool isOptimizing,
  }) = _ChatPageState;
}
