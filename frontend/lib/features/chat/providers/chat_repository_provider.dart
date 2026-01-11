import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/repositories/chat_repository_impl.dart';
import '../domain/repositories/chat_repository.dart';
import '../../../services/api_service.dart';
import '../../../services/chat_history_service.dart';

/// Provider for the Chat Repository.
///
/// This is the main entry point for chat-related data operations.
/// UI components should use this provider to access repository methods,
/// never directly importing ApiService or ChatHistoryService.
///
/// Usage in a ConsumerWidget:
/// ```dart
/// final chatRepository = ref.watch(chatRepositoryProvider);
/// final messages = await chatRepository.fetchHistory(sceneKey: 'my_scene');
/// ```
///
/// The repository is created as a singleton and disposed when the app closes.
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final repository = ChatRepositoryImpl(
    apiService: ApiService(),
    chatHistoryService: ChatHistoryService(),
  );

  // Dispose when provider is destroyed (app close)
  ref.onDispose(() {
    repository.dispose();
  });

  return repository;
});

/// Provider for sync status stream.
///
/// Watch this provider to get real-time updates on sync status.
///
/// Usage:
/// ```dart
/// final syncStatus = ref.watch(chatSyncStatusProvider);
/// return syncStatus.when(
///   data: (status) => SyncStatusIndicator(status: status),
///   loading: () => CircularProgressIndicator(),
///   error: (e, s) => Text('Error: $e'),
/// );
/// ```
final chatSyncStatusProvider = StreamProvider<SyncStatus>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.syncStatusStream;
});

/// Provider for current sync status (non-streaming).
///
/// Use when you just need the current value, not real-time updates.
final currentSyncStatusProvider = Provider<SyncStatus>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return repository.currentSyncStatus;
});
