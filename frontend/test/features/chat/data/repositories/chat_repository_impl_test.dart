import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:frontend/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:frontend/core/data/api/api_service.dart';
import 'package:frontend/features/chat/data/chat_history_service.dart';
import 'package:frontend/models/message.dart';

import '../../../../mocks/mock_api_service.dart';
import '../../../../mocks/mock_chat_history_service.dart';

void main() {
  late ChatRepositoryImpl repository;
  late MockApiService mockApiService;
  late MockChatHistoryService mockChatHistoryService;

  setUpAll(() {
    registerFallbackValue(FakeChatResponse());
    registerFallbackValue(FakeHintResponse());
  });

  setUp(() {
    mockApiService = MockApiService();
    mockChatHistoryService = MockChatHistoryService();
    repository = ChatRepositoryImpl(
      apiService: mockApiService,
      chatHistoryService: mockChatHistoryService,
    );
  });

  group('ChatRepositoryImpl', () {
    group('fetchHistory', () {
      test('fetches from local history by default', () async {
        // Arrange
        final messages = [
          Message(
            id: '1',
            content: 'Hello',
            isUser: true,
            timestamp: DateTime.now(),
          ),
        ];
        when(
          () => mockChatHistoryService.getMessages('scene_1'),
        ).thenAnswer((_) async => messages);

        // Act
        final result = await repository.fetchHistory(sceneKey: 'scene_1');

        // Assert
        expect(result, messages);
        verify(() => mockChatHistoryService.getMessages('scene_1')).called(1);
        verifyNever(() => mockChatHistoryService.getMessagesWithSync(any()));
      });

      test('forces sync when requested', () async {
        // Arrange
        final messages = <Message>[];
        when(
          () => mockChatHistoryService.getMessagesWithSync('scene_1'),
        ).thenAnswer((_) async => messages);

        // Act
        final result = await repository.fetchHistory(
          sceneKey: 'scene_1',
          forceSync: true,
        );

        // Assert
        expect(result, messages);
        verify(
          () => mockChatHistoryService.getMessagesWithSync('scene_1'),
        ).called(1);
      });
    });

    group('sendMessage', () {
      test('delegates to ApiService', () async {
        // Arrange
        const text = 'Hi';
        const sceneContext = 'Context';
        final history = <Map<String, String>>[];
        final response = ChatResponse(
          message: 'Reply',
          translation: null,
          feedback: null,
        );

        when(
          () => mockApiService.sendMessage(text, sceneContext, history),
        ).thenAnswer((_) async => response);

        // Act
        final result = await repository.sendMessage(
          text: text,
          sceneContext: sceneContext,
          history: history,
        );

        // Assert
        expect(result, response);
        verify(
          () => mockApiService.sendMessage(text, sceneContext, history),
        ).called(1);
      });
    });

    group('syncMessages', () {
      test('delegates to ChatHistoryService', () async {
        // Arrange
        final messages = <Message>[];
        when(
          () => mockChatHistoryService.syncMessages('scene_1', messages),
        ).thenAnswer((_) async {});

        // Act
        await repository.syncMessages(sceneKey: 'scene_1', messages: messages);

        // Assert
        verify(
          () => mockChatHistoryService.syncMessages('scene_1', messages),
        ).called(1);
      });
    });
  });
}
