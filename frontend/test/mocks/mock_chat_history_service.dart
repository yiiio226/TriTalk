import 'package:flutter/foundation.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/services/chat_history_service.dart';
import 'package:frontend/models/message.dart';

/// Mock implementation of [ChatHistoryService] for unit testing.
///
/// Uses mocktail for easy stubbing without code generation.
class MockChatHistoryService extends Mock implements ChatHistoryService {
  final ValueNotifier<SyncStatus> _syncStatus = ValueNotifier(
    SyncStatus.synced,
  );

  @override
  ValueNotifier<SyncStatus> get syncStatus => _syncStatus;
}

/// Fake class for Message to use with registerFallbackValue
class FakeMessage extends Fake implements Message {}
