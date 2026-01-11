import '../../../../models/message.dart';
import '../../../../services/api_service.dart';
import '../../../../services/chat_history_service.dart';

/// Abstract repository interface for Chat operations.
///
/// This interface defines the contract for all chat-related data operations,
/// decoupling the UI layer from data sources (API, local storage, etc.).
///
/// Key Design Decisions:
/// - Uses domain models (Message, MessageAnalysis) instead of raw API types
/// - Returns Streams for real-time updates (e.g., SSE-based AI responses)
/// - Abstracts both remote (ApiService) and local (ChatHistoryService) data sources
abstract class ChatRepository {
  // ============================================
  // Message Sending & AI Interaction
  // ============================================

  /// Sends a text message and receives an AI response.
  ///
  /// [text] - The user's message content
  /// [sceneContext] - The current scene/scenario description
  /// [history] - Previous messages in the conversation (for context)
  ///
  /// Returns [ChatResponse] containing the AI's reply and optional feedback.
  Future<ChatResponse> sendMessage({
    required String text,
    required String sceneContext,
    required List<Map<String, String>> history,
  });

  /// Sends a voice message (audio file) and streams the AI's response.
  ///
  /// Uses streaming protocol for low-latency conversational experience.
  /// Yields [VoiceStreamEvent] tokens as they arrive from the API.
  Stream<VoiceStreamEvent> sendVoiceMessage({
    required String audioPath,
    required String sceneContext,
    required List<Map<String, String>> history,
  });

  // ============================================
  // Message Analysis
  // ============================================

  /// Analyzes a message for grammar, vocabulary, and structure.
  ///
  /// Returns a stream of [MessageAnalysis] updates as sections are processed.
  /// Uses streaming to provide incremental UI updates.
  Stream<MessageAnalysis> analyzeMessage(String message);

  // ============================================
  // Chat History (Local + Cloud Sync)
  // ============================================

  /// Fetches message history for a specific scene.
  ///
  /// [sceneKey] - Unique identifier for the scene/conversation
  /// [forceSync] - If true, forces cloud sync before returning
  ///
  /// Uses local-first strategy: returns cached data immediately,
  /// then syncs with cloud in background.
  Future<List<Message>> fetchHistory({
    required String sceneKey,
    bool forceSync = false,
  });

  /// Persists the current message list for a scene.
  ///
  /// Saves to local storage immediately and syncs to cloud in background.
  Future<void> syncMessages({
    required String sceneKey,
    required List<Message> messages,
  });

  /// Deletes specific messages from a scene's history.
  ///
  /// Removes from local storage and syncs deletion to cloud.
  Future<void> deleteMessages({
    required String sceneKey,
    required List<String> messageIds,
  });

  /// Clears all messages for a scene.
  ///
  /// Removes from both local storage and cloud.
  Future<void> clearHistory(String sceneKey);

  // ============================================
  // Hints & Suggestions
  // ============================================

  /// Gets AI-generated response hints based on conversation context.
  ///
  /// Returns suggested replies the user might want to use.
  Future<HintResponse> getHints({
    required String sceneContext,
    required List<Map<String, String>> history,
  });

  // ============================================
  // Message Optimization
  // ============================================

  /// Optimizes a draft message for the current context.
  ///
  /// The AI improves grammar, tone, and expression while
  /// maintaining the user's intended meaning.
  Future<String> optimizeMessage({
    required String draft,
    required String sceneContext,
    required List<Map<String, String>> history,
  });

  // ============================================
  // Sync Status
  // ============================================

  /// Stream of sync status updates for UI indicators.
  ///
  /// Values: synced, syncing, offline
  Stream<SyncStatus> get syncStatusStream;

  /// Current sync status.
  SyncStatus get currentSyncStatus;
}
