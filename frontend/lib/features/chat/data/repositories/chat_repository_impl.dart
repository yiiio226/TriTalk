import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:frontend/features/chat/domain/models/message.dart';
import '../../../../core/data/api/api_service.dart';
import '../chat_history_service.dart';
import '../../domain/repositories/chat_repository.dart';

/// Implementation of [ChatRepository] that coordinates between:
/// - Remote data source: [ApiService] (Cloudflare Workers API)
/// - Local data source: [ChatHistoryService] (SharedPreferences + Supabase sync)
///
/// Design Principles:
/// - Delegates API calls to existing [ApiService] (no duplication)
/// - Delegates persistence to existing [ChatHistoryService] (local-first sync)
/// - Acts as a coordination layer, not a replacement
class ChatRepositoryImpl implements ChatRepository {
  final ApiService _apiService;
  final ChatHistoryService _chatHistoryService;

  // Track ownership of services for proper disposal
  final bool _ownsApiService;

  // Stream controller for sync status
  late final StreamController<SyncStatus> _syncStatusController;

  ChatRepositoryImpl({
    ApiService? apiService,
    ChatHistoryService? chatHistoryService,
  }) : _apiService = apiService ?? ApiService(),
       _chatHistoryService = chatHistoryService ?? ChatHistoryService(),
       _ownsApiService = apiService == null {
    // Bridge the existing ValueNotifier to a Stream
    _syncStatusController = StreamController<SyncStatus>.broadcast();

    // Listen to existing sync status and forward to stream
    _chatHistoryService.syncStatus.addListener(_onSyncStatusChanged);
  }

  void _onSyncStatusChanged() {
    _syncStatusController.add(_chatHistoryService.syncStatus.value);
  }

  /// Dispose resources when no longer needed.
  ///
  /// If [ApiService] or [ChatHistoryService] were created internally
  /// (not injected via constructor), they will be disposed here.
  /// Callers who inject their own services are responsible for disposing them.
  @override
  void dispose() {
    _chatHistoryService.syncStatus.removeListener(_onSyncStatusChanged);
    _syncStatusController.close();

    // Dispose internally-created services to prevent resource leaks
    // Note: ChatHistoryService is a singleton so we don't dispose it
    if (_ownsApiService) {
      _apiService.dispose();
    }
  }

  // ============================================
  // Message Sending & AI Interaction
  // ============================================

  @override
  Future<ChatResponse> sendMessage({
    required String text,
    required String sceneContext,
    required List<Map<String, String>> history,
  }) async {
    try {
      final response = await _apiService.sendMessage(
        text,
        sceneContext,
        history,
      );
      return response;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatRepository: sendMessage error - $e');
      }
      rethrow;
    }
  }

  @override
  Stream<VoiceStreamEvent> sendVoiceMessage({
    required String audioPath,
    required String sceneContext,
    required List<Map<String, String>> history,
  }) {
    return _apiService.sendVoiceMessage(audioPath, sceneContext, history);
  }

  // ============================================
  // Message Analysis
  // ============================================

  @override
  Stream<MessageAnalysis> analyzeMessage(String message) {
    return _apiService.analyzeMessage(message);
  }

  // ============================================
  // Chat History (Local + Cloud Sync)
  // ============================================

  @override
  Future<List<Message>> fetchHistory({
    required String sceneKey,
    bool forceSync = false,
  }) async {
    try {
      if (forceSync) {
        // Force refresh from cloud with timeout fallback
        return await _chatHistoryService.getMessagesWithSync(sceneKey);
      } else {
        // Local-first approach
        return await _chatHistoryService.getMessages(sceneKey);
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatRepository: fetchHistory error - $e');
      }
      // Return empty list on error to avoid UI crashes
      return [];
    }
  }

  @override
  Future<void> syncMessages({
    required String sceneKey,
    required List<Message> messages,
  }) async {
    try {
      await _chatHistoryService.syncMessages(sceneKey, messages);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatRepository: syncMessages error - $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteMessages({
    required String sceneKey,
    required List<String> messageIds,
  }) async {
    try {
      await _chatHistoryService.deleteMessages(sceneKey, messageIds);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatRepository: deleteMessages error - $e');
      }
      rethrow;
    }
  }

  @override
  Future<void> clearHistory(String sceneKey) async {
    try {
      await _chatHistoryService.clearHistory(sceneKey);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatRepository: clearHistory error - $e');
      }
      rethrow;
    }
  }

  // ============================================
  // Hints & Suggestions
  // ============================================

  @override
  Future<HintResponse> getHints({
    required String sceneContext,
    required List<Map<String, String>> history,
  }) async {
    try {
      return await _apiService.getHints(sceneContext, history);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatRepository: getHints error - $e');
      }
      rethrow;
    }
  }

  // ============================================
  // Message Optimization
  // ============================================

  @override
  Future<String> optimizeMessage({
    required String draft,
    required String sceneContext,
    required List<Map<String, String>> history,
  }) async {
    try {
      return await _apiService.optimizeMessage(draft, sceneContext, history);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('ChatRepository: optimizeMessage error - $e');
      }
      rethrow;
    }
  }

  // ============================================
  // Sync Status
  // ============================================

  @override
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  @override
  SyncStatus get currentSyncStatus => _chatHistoryService.syncStatus.value;
}
