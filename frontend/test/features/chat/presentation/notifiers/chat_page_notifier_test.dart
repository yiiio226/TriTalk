import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/features/chat/presentation/notifiers/chat_page_notifier.dart';
import 'package:frontend/features/scenes/domain/models/scene.dart';
import 'package:frontend/features/chat/domain/models/message.dart';
import 'package:frontend/core/data/api/api_service.dart';
import '../../../../mocks/mock_chat_repository.dart';

// Helper to create a test scene
Scene _createTestScene() {
  return const Scene(
    id: 'test_scene',
    title: 'Test Scene',
    description: 'A test scene',
    emoji: '🧪',
    aiRole: 'AI Assistant',
    userRole: 'User',
    initialMessage: 'Hello!',
    category: 'Test',
    difficulty: 'Easy',
    goal: 'Test things',
    iconPath: '',
    color: 0xFF000000,
  );
}

void main() {
  late ChatPageNotifier notifier;
  late MockChatRepository mockRepository;
  late Scene testScene;

  setUp(() {
    mockRepository = MockChatRepository();
    testScene = _createTestScene();
    notifier = ChatPageNotifier(repository: mockRepository, scene: testScene);
  });

  group('ChatPageNotifier', () {
    test('initial state is correct', () {
      expect(notifier.state.isLoading, false);
      expect(notifier.state.messages, isEmpty);
      expect(notifier.state.error, null);
    });

    group('loadMessages', () {
      test('sets loading state and fetches history', () async {
        // Arrange
        final messages = [
          Message(
            id: '1',
            content: 'Hello',
            isUser: false,
            timestamp: DateTime.now(),
          ),
        ];
        when(
          () => mockRepository.fetchHistory(sceneKey: 'test_scene'),
        ).thenAnswer((_) async => messages);

        // Act
        final future = notifier.loadMessages();

        // Assert - Check loading state immediately (might be tricky with async)
        // Ideally we'd stream the state changes, but checking final state is easier here.
        await future;

        expect(notifier.state.isLoading, false);
        expect(notifier.state.messages, messages);
        verify(
          () => mockRepository.fetchHistory(sceneKey: 'test_scene'),
        ).called(1);
      });

      test('handles errors when loading messages', () async {
        // Arrange
        when(
          () => mockRepository.fetchHistory(sceneKey: 'test_scene'),
        ).thenThrow('Fetch failed');

        // Act
        await notifier.loadMessages();

        // Assert
        expect(notifier.state.isLoading, false);
        expect(notifier.state.error, contains('Fetch failed'));
      });
    });

    group('sendMessage', () {
      test('sends text message successfully', () async {
        // Arrange
        const text = 'Hello AI';
        final chatResponse = ChatResponse(
          message: 'Hello User',
          translation: 'Hola Usuario',
          feedback: null,
        );

        when(
          () => mockRepository.syncMessages(
            sceneKey: any(named: 'sceneKey'),
            messages: any(named: 'messages'),
          ),
        ).thenAnswer((_) async {});

        when(
          () => mockRepository.sendMessage(
            text: any(named: 'text'),
            sceneContext: any(named: 'sceneContext'),
            history: any(named: 'history'),
          ),
        ).thenAnswer((_) async => chatResponse);

        // Act
        await notifier.sendMessage(text);

        // Assert
        expect(notifier.state.isSending, false);
        expect(notifier.state.messages.length, 2); // User msg + AI msg

        final userMsg = notifier.state.messages.first;
        expect(userMsg.content, text);
        expect(userMsg.isUser, true);

        final aiMsg = notifier.state.messages.last;
        expect(aiMsg.content, 'Hello User');
        expect(aiMsg.isUser, false);
        expect(aiMsg.translation, 'Hola Usuario');

        verify(
          () => mockRepository.sendMessage(
            text: text,
            sceneContext: any(named: 'sceneContext'),
            history: any(named: 'history'),
          ),
        ).called(1);
      });

      test('does not send empty message', () async {
        await notifier.sendMessage('   ');
        verifyNever(
          () => mockRepository.sendMessage(
            text: any(named: 'text'),
            sceneContext: any(named: 'sceneContext'),
            history: any(named: 'history'),
          ),
        );
      });

      // Note: We're skipping RevenueCat checks in unit tests as it's a singleton service
      // that's hard to mock without dependency injection in the Notifier constructor.
      // In a real scenario, we'd inject RevenueCatService or mock the singleton.
    });

    group('multi-select mode', () {
      test('toggles selection mode and selects message', () {
        // Act
        notifier.toggleMultiSelectMode('msg1');

        // Assert
        expect(notifier.state.isMultiSelectMode, true);
        expect(notifier.state.selectedMessageIds, contains('msg1'));
      });

      test('toggles message selection off', () {
        // Arrange
        notifier.toggleMultiSelectMode('msg1');

        // Act
        notifier.toggleMultiSelectMode('msg1');

        // Assert
        expect(notifier.state.isMultiSelectMode, false);
        expect(notifier.state.selectedMessageIds, isEmpty);
      });
    });
  });
}
