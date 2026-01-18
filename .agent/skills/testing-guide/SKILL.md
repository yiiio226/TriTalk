---
name: testing-guide
description: Guidelines for writing Flutter widget tests and backend unit tests. Use when creating or reviewing tests. | Flutter Widget 测试和后端单元测试的编写指南。在创建或审查测试时使用。
---

# Testing Guide Skill | 测试指南技能

Testing conventions for TriTalk's Flutter frontend and Node.js backend.
TriTalk Flutter 前端和 Node.js 后端的测试规范。

## When to use | 何时使用

- Writing new tests | 编写新测试
- Reviewing test coverage | 审查测试覆盖率
- Debugging failing tests | 调试失败的测试

## Flutter Widget Tests | Flutter Widget 测试

### Basic Structure | 基本结构
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:tritalk/features/chat/presentation/widgets/chat_bubble.dart';

void main() {
  group('ChatBubble', () {
    testWidgets('displays message text', (tester) async {
      // 显示消息文本
      await tester.pumpWidget(
        MaterialApp(
          home: ChatBubble(message: 'Hello'),
        ),
      );
      
      expect(find.text('Hello'), findsOneWidget);
    });
    
    testWidgets('handles tap interaction', (tester) async {
      // 处理点击交互
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

### Testing with Riverpod | 使用 Riverpod 测试
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

## Backend Unit Tests | 后端单元测试

### Jest Test Structure | Jest 测试结构
```typescript
describe('UserService', () => {
  beforeEach(() => {
    // Setup mocks | 设置模拟
  });
  
  afterEach(() => {
    jest.clearAllMocks();
  });
  
  it('should create user with valid data', async () => {
    // 应该用有效数据创建用户
    const result = await userService.create({ name: 'Test' });
    expect(result.name).toBe('Test');
  });
  
  it('should throw error with invalid data', async () => {
    // 应该用无效数据抛出错误
    await expect(userService.create({}))
      .rejects.toThrow('Name is required');
  });
});
```

## Test Naming Convention | 测试命名规范

```
should [expected behavior] when [condition]
应该 [预期行为] 当 [条件]
```

Examples | 示例:
- `should display loading spinner when data is fetching` | 当数据获取时应该显示加载指示器
- `should return error when userId is missing` | 当缺少 userId 时应该返回错误

## Coverage Goals | 覆盖率目标

| Type 类型 | Target 目标 |
|-----------|-------------|
| Widget Tests Widget 测试 | Key UI interactions 关键 UI 交互 |
| Unit Tests 单元测试 | Business logic, services 业务逻辑、服务 |
| Integration 集成测试 | Critical user flows 关键用户流程 |
