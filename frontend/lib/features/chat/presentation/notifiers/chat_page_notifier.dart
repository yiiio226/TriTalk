import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:frontend/features/chat/domain/models/message.dart';
import 'package:frontend/features/scenes/domain/models/scene.dart';
import '../../../../core/data/api/api_service.dart';
import 'package:frontend/features/subscription/data/services/revenue_cat_service.dart';
import '../../domain/repositories/chat_repository.dart';
import '../state/chat_page_state.dart';

class ChatPageNotifier extends StateNotifier<ChatPageState> {
  final ChatRepository _repository;
  final String _sceneId;
  final Scene _scene; // We might need scene details for context
  final Uuid _uuid = const Uuid();

  ChatPageNotifier({required ChatRepository repository, required Scene scene})
    : _repository = repository,
      _scene = scene,
      _sceneId = scene.id,
      super(const ChatPageState());

  /// Load initial messages for the scene
  Future<void> loadMessages() async {
    state = state.copyWith(isLoading: true);
    try {
      final messages = await _repository.fetchHistory(sceneKey: _sceneId);

      // If new conversation, we might want to handle initial message logic here
      // or rely on the UI/Repository to have already set it up.
      // For now, let's just load what we have.

      state = state.copyWith(isLoading: false, messages: messages);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Send a text message
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.isSending) return;

    if (!RevenueCatService().canSendMessage()) {
      state = state.copyWith(error: 'daily_limit_reached');
      return;
    }

    final userMsgId = _uuid.v4();
    final userMessage = Message(
      id: userMsgId,
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Optimistic update
    final currentMessages = List<Message>.from(state.messages)
      ..add(userMessage);
    state = state.copyWith(
      messages: currentMessages,
      isSending: true,
      cachedHints: null, // Clear hints on new message
      error: null,
      showErrorBanner: false,
    );

    // Sync immediately
    _repository.syncMessages(sceneKey: _sceneId, messages: currentMessages);

    RevenueCatService().incrementMessageCount();

    // Add loading placeholder for AI
    final loadingId = 'loading_${DateTime.now().millisecondsSinceEpoch}';
    final loadingMsg = Message(
      id: loadingId,
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
    );

    final messagesWithLoading = List<Message>.from(currentMessages)
      ..add(loadingMsg);
    state = state.copyWith(messages: messagesWithLoading);

    try {
      final history = _buildHistory(currentMessages);
      final sceneContext = _buildSceneContext();

      final response = await _repository.sendMessage(
        text: text,
        sceneContext: sceneContext,
        history: history,
      );

      // Remove loading, add actual response
      final finalMessages = List<Message>.from(state.messages)
        ..removeWhere((m) => m.id == loadingId);

      final aiMessage = Message(
        id: _uuid.v4(),
        content: response.message,
        isUser: false,
        timestamp: DateTime.now(),
        translation: response.translation,
        feedback: response.feedback,
        isAnimated: true,
      );

      finalMessages.add(aiMessage);

      state = state.copyWith(isSending: false, messages: finalMessages);

      _repository.syncMessages(sceneKey: _sceneId, messages: finalMessages);
    } catch (e) {
      // Handle error (mark message as failed)
      final failedMessages = List<Message>.from(state.messages)
        ..removeWhere((m) => m.id == loadingId);

      final index = failedMessages.indexWhere((m) => m.id == userMsgId);
      if (index != -1) {
        failedMessages[index] = failedMessages[index].copyWith(
          hasPendingError: true,
        );
      }

      state = state.copyWith(
        isSending: false,
        messages: failedMessages,
        error: e.toString(),
        showErrorBanner: true,
      );

      _repository.syncMessages(sceneKey: _sceneId, messages: failedMessages);
    }
  }

  /// Delete selected messages
  Future<void> deleteSelectedMessages() async {
    if (state.selectedMessageIds.isEmpty) return;

    final idsToDelete = state.selectedMessageIds.toList();
    final newMessages = state.messages
        .where((m) => !idsToDelete.contains(m.id))
        .toList();

    state = state.copyWith(
      messages: newMessages,
      selectedMessageIds: {},
      isMultiSelectMode: false,
    );

    try {
      await _repository.deleteMessages(
        sceneKey: _sceneId,
        messageIds: idsToDelete,
      );
    } catch (e) {
      // Revert or show error? For now show error
      state = state.copyWith(error: "Failed to delete: $e");
      // Ideally we would revert the state change here
    }
  }

  /// Toggle selection mode
  void toggleMultiSelectMode(String messageId) {
    if (state.isMultiSelectMode) {
      final newSelected = Set<String>.from(state.selectedMessageIds);
      if (newSelected.contains(messageId)) {
        newSelected.remove(messageId);
      } else {
        newSelected.add(messageId);
      }

      if (newSelected.isEmpty) {
        state = state.copyWith(
          isMultiSelectMode: false,
          selectedMessageIds: {},
        );
      } else {
        state = state.copyWith(selectedMessageIds: newSelected);
      }
    } else {
      state = state.copyWith(
        isMultiSelectMode: true,
        selectedMessageIds: {messageId},
      );
    }
  }

  void exitMultiSelectMode() {
    state = state.copyWith(isMultiSelectMode: false, selectedMessageIds: {});
  }

  // Helper methods
  List<Map<String, String>> _buildHistory(List<Message> messages) {
    return messages
        .where((m) => !m.isLoading && m.content.isNotEmpty)
        .map(
          (m) => <String, String>{
            'role': m.isUser ? 'user' : 'assistant',
            'content': m.content,
          },
        )
        .toList();
  }

  String _buildSceneContext() {
    return 'AI Role: ${_scene.aiRole}, User Role: ${_scene.userRole}. ${_scene.description}';
  }

  /// Analyze a user message
  /// For voice messages: Assessment is handled by VoiceFeedbackSheet when opened
  /// For text messages: Calls the API to generate feedback
  Future<void> analyzeMessage(Message message) async {
    if (!message.isUser) return;

    final index = state.messages.indexWhere((m) => m.id == message.id);
    if (index == -1) return;

    // For voice messages, the VoiceFeedbackSheet handles Azure assessment
    // when the sheet is opened. Just return here.
    if (message.isVoiceMessage) {
      return;
    }

    // Text message analysis flow
    // Update state to analyzing
    final analyzingMsg = message.copyWith(isAnalyzing: true);
    final updatedMessages = List<Message>.from(state.messages);
    updatedMessages[index] = analyzingMsg;

    state = state.copyWith(messages: updatedMessages);

    try {
      final history = _buildHistory(updatedMessages);
      final sceneContext = _buildSceneContext();

      // Call sendMessage API to get feedback for text messages
      final response = await _repository.sendMessage(
        text: message.content,
        sceneContext: sceneContext,
        history: history
            .where((m) => m['content'] != message.content)
            .toList(), // Exclude self
      );

      final doneMsg = analyzingMsg.copyWith(
        feedback: response.feedback,
        isAnalyzing: false,
      );

      final doneMessages = List<Message>.from(state.messages);
      doneMessages[index] = doneMsg;

      state = state.copyWith(messages: doneMessages);

      _repository.syncMessages(sceneKey: _sceneId, messages: doneMessages);
    } catch (e) {
      final errorMsg = analyzingMsg.copyWith(isAnalyzing: false);
      final errorMessages = List<Message>.from(state.messages);
      errorMessages[index] = errorMsg;

      state = state.copyWith(
        messages: errorMessages,
        error: "Analysis failed: $e",
      );
    }
  }

  /// Retry a failed message
  Future<void> retryMessage(Message failedMsg) async {
    // Remove failed message and try sending content again
    final index = state.messages.indexWhere((m) => m.id == failedMsg.id);
    if (index != -1) {
      final newMessages = List<Message>.from(state.messages)..removeAt(index);
      state = state.copyWith(messages: newMessages);
      // Now send as new
      await sendMessage(failedMsg.content);
    }
  }

  /// Optimize a draft message
  Future<String> optimizeMessage(String draft) async {
    state = state.copyWith(isOptimizing: true);
    try {
      final history = _buildHistory(state.messages);
      final sceneContext = _buildSceneContext();

      final result = await _repository.optimizeMessage(
        draft: draft,
        sceneContext: sceneContext,
        history: history,
      );

      state = state.copyWith(isOptimizing: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isOptimizing: false,
        error: "Optimization failed: $e",
      );
      rethrow;
    }
  }

  /// Get hints
  Future<List<String>> getHints() async {
    // If we have cached hints and state hasn't changed meaningfully?
    // The UI logic checked message count.

    // Simplification: Always fetch for now or implement logic.
    // Logic: fetch based on current history.

    try {
      final history = _buildHistory(state.messages);
      final sceneContext = _buildSceneContext();

      final response = await _repository.getHints(
        sceneContext: sceneContext,
        history: history,
      );

      // Cache hints in the last message?
      // Original logic: "restore hints from last message if available".
      // We can update the last message to store hints.

      if (state.messages.isNotEmpty) {
        final lastIndex = state.messages.length - 1;
        final lastMsg = state.messages.last;
        final updatedMsg = lastMsg.copyWith(hints: response.hints);

        final newMessages = List<Message>.from(state.messages);
        newMessages[lastIndex] = updatedMsg;
        state = state.copyWith(
          messages: newMessages,
          cachedHints: response.hints,
        );

        _repository.syncMessages(sceneKey: _sceneId, messages: newMessages);
      }

      return response.hints;
    } catch (e) {
      // Don't error state for hints, just return empty
      return [];
    }
  }

  /// Send voice message with Azure pronunciation assessment integration
  Future<void> sendVoiceMessage(String audioPath, int duration) async {
    // Optimistic: Add user voice message immediately
    final userMsgId = _uuid.v4();
    final userMessage = Message(
      id: userMsgId,
      content: '', // Transcript will come later
      isUser: true,
      timestamp: DateTime.now(),
      audioPath: audioPath,
      audioDuration: duration,
    );

    // Placeholder AI message
    final aiMessageId = _uuid.v4();
    final aiMessage = Message(
      id: aiMessageId,
      content: '',
      isUser: false,
      timestamp: DateTime.now(),
      isLoading: true,
      isAnimated: true,
    );

    final currentMessages = List<Message>.from(state.messages)
      ..add(userMessage)
      ..add(aiMessage);

    state = state.copyWith(messages: currentMessages, isRecording: false);

    _repository.syncMessages(sceneKey: _sceneId, messages: currentMessages);

    try {
      final history = _buildHistory(currentMessages);
      final sceneContext = _buildSceneContext();

      final stream = _repository.sendVoiceMessage(
        audioPath: audioPath,
        sceneContext: sceneContext,
        history: history,
      );

      await for (final event in stream) {
        if (event.type == VoiceStreamEventType.token && event.content != null) {
          // Update partial content
          _updateAiMessageContent(aiMessageId, event.content!);
        } else if (event.type == VoiceStreamEventType.metadata &&
            event.metadata != null) {
          // Log the response for debugging
          if (kDebugMode) {
            final meta = event.metadata!;
            debugPrint('📝 Voice Response Metadata:');
            debugPrint('   transcript: "${meta.transcript}"');
            debugPrint('   translation: "${meta.translation}"');
            debugPrint(
              '   reviewFeedback.correctedText: "${meta.reviewFeedback?.correctedText}"',
            );
            debugPrint(
              '   voiceFeedback.pronunciationScore: ${meta.voiceFeedback.pronunciationScore}',
            );
          }
          _updateVoiceMetadata(userMsgId, aiMessageId, event.metadata!);
        }
      }

      // Note: Azure pronunciation assessment is now called on-demand
      // when user taps Analyze, not automatically after voice message
    } catch (e) {
      // Handle error
      state = state.copyWith(error: "Voice message failed: $e");
    }
  }

  void _updateAiMessageContent(String msgId, String content) {
    final index = state.messages.indexWhere((m) => m.id == msgId);
    if (index != -1) {
      final currentContent = state.messages[index].content;
      final newContent = currentContent + content;

      final updatedMsg = state.messages[index].copyWith(
        content: newContent,
        isLoading: false,
      );

      final newMessages = List<Message>.from(state.messages);
      newMessages[index] = updatedMsg;
      state = state.copyWith(messages: newMessages);
    }
  }

  void _updateVoiceMetadata(
    String userMsgId,
    String aiMsgId,
    VoiceMessageResponse metadata,
  ) {
    final messages = List<Message>.from(state.messages);

    // Update user message with transcript and cached feedback
    final userIndex = messages.indexWhere((m) => m.id == userMsgId);
    if (userIndex != -1) {
      final userMsg = messages[userIndex];
      messages[userIndex] = userMsg.copyWith(
        content: metadata.transcript ?? '',
        // Cache feedback from voice response - available when user clicks "Analyze"
        feedback: metadata.reviewFeedback,
        voiceFeedback: metadata.voiceFeedback,
      );
    }

    // Update AI message translation
    final aiIndex = messages.indexWhere((m) => m.id == aiMsgId);
    if (aiIndex != -1) {
      messages[aiIndex] = messages[aiIndex].copyWith(
        translation: metadata.translation,
        isLoading: false,
      );
    }

    state = state.copyWith(messages: messages);
    _repository.syncMessages(sceneKey: _sceneId, messages: messages);
  }

  void setRecording(bool isRecording) {
    state = state.copyWith(isRecording: isRecording);
  }

  void updateMessage(Message updatedMessage) {
    final index = state.messages.indexWhere((m) => m.id == updatedMessage.id);
    if (index != -1) {
      final newMessages = List<Message>.from(state.messages);
      newMessages[index] = updatedMessage;
      state = state.copyWith(messages: newMessages);
      _repository.syncMessages(sceneKey: _sceneId, messages: newMessages);
    }
  }

  void cacheHints(List<String> hints, int messageCount) {
    state = state.copyWith(cachedHints: hints);

    if (state.messages.isNotEmpty) {
      final lastMsg = state.messages.last;
      final updated = lastMsg.copyWith(hints: hints);

      final index = state.messages.length - 1;
      final newMessages = List<Message>.from(state.messages);
      newMessages[index] = updated;

      state = state.copyWith(messages: newMessages);
      _repository.syncMessages(sceneKey: _sceneId, messages: newMessages);
    }
  }

  void setOptimizing(bool isOptimizing) {
    state = state.copyWith(isOptimizing: isOptimizing);
  }

  void setTranscribing(bool isTranscribing) {
    state = state.copyWith(isTranscribing: isTranscribing);
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null, showErrorBanner: false);
  }

  /// Update recording duration (for UI display)
  void updateRecordingDuration(int duration) {
    state = state.copyWith(recordingDuration: duration);
  }
}
