import 'package:mocktail/mocktail.dart';
import 'package:frontend/services/api_service.dart';

/// Mock implementation of [ApiService] for unit testing.
///
/// Uses mocktail for easy stubbing without code generation.
class MockApiService extends Mock implements ApiService {}

/// Fake class for ChatResponse to use with registerFallbackValue
class FakeChatResponse extends Fake implements ChatResponse {}

/// Fake class for HintResponse to use with registerFallbackValue
class FakeHintResponse extends Fake implements HintResponse {}
