---
name: testing-guide
description: Guidelines for writing Flutter widget tests and backend unit tests. Use when creating or reviewing tests. | Flutter Widget 测试和后端单元测试的编写指南。在创建或审查测试时使用。
---

# Testing Guide Skill

Testing conventions for TriTalk's Flutter frontend and Node.js backend.

## When to use

- Writing new tests
- Reviewing test coverage
- Debugging failing tests

## Flutter Widget Tests

### Basic Structure
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tritalk/features/chat/presentation/widgets/chat_bubble.dart';

void main() {
  group('ChatBubble', () {
    testWidgets('displays message text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChatBubble(message: 'Hello'),
        ),
      );
      
      expect(find.text('Hello'), findsOneWidget);
    });
    
    testWidgets('handles tap interaction', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: ChatBubble(
            message: 'Tap me',
            onTap: () => tapped = true,
          ),
        ),
      );
      
      await tester.tap(find.byType(ChatBubble));
      expect(tapped, isTrue);
    });
  });
}
```

### Testing with Riverpod
```dart
testWidgets('provider test', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        myProvider.overrideWithValue(mockValue),
      ],
      child: MaterialApp(home: MyWidget()),
    ),
  );
});
```

## Backend Unit Tests

### Jest Test Structure
```typescript
describe('UserService', () => {
  beforeEach(() => {
    // Setup mocks
  });
  
  afterEach(() => {
    jest.clearAllMocks();
  });
  
  it('should create user with valid data', async () => {
    const result = await userService.create({ name: 'Test' });
    expect(result.name).toBe('Test');
  });
  
  it('should throw error with invalid data', async () => {
    await expect(userService.create({}))
      .rejects.toThrow('Name is required');
  });
});
```

## Test Naming Convention

```
should [expected behavior] when [condition]
```

Examples:
- `should display loading spinner when data is fetching`
- `should return error when userId is missing`

## Coverage Goals

| Type | Target |
|------|--------|
| Widget Tests | Key UI interactions |
| Unit Tests | Business logic, services |
| Integration | Critical user flows |
