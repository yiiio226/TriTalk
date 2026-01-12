import 'package:mocktail/mocktail.dart';
import 'package:frontend/features/chat/domain/repositories/chat_repository.dart';

/// Mock implementation of [ChatRepository] for unit testing.
///
/// Uses mocktail for easy stubbing without code generation.
class MockChatRepository extends Mock implements ChatRepository {}
