---
name: debug-flutter
description: Systematic approach to debugging Flutter issues including UI, state, and async problems. Use when troubleshooting bugs or unexpected behavior. | 系统化调试 Flutter 问题的方法，包括 UI、状态和异步问题。在排查 bug 或异常行为时使用。
---

# Flutter Debugging Skill | Flutter 调试技能

Systematic debugging approach for TriTalk Flutter issues.
TriTalk Flutter 问题的系统化调试方法。

## When to use | 何时使用

- UI not rendering correctly | UI 渲染不正确
- State not updating as expected | 状态未按预期更新
- Async operations failing | 异步操作失败
- Widget errors or exceptions | Widget 错误或异常

## Debugging Decision Tree | 调试决策树

```
Issue Type? | 问题类型？
├── UI/Layout Error | UI/布局错误
│   └── Check: RenderFlex overflow, constraints, sizing | 检查：RenderFlex 溢出、约束、尺寸
├── State Not Updating | 状态未更新
│   └── Check: Provider/Riverpod usage, notifyListeners | 检查：Provider/Riverpod 用法、notifyListeners
├── Async Failure | 异步失败
│   └── Check: await usage, error handling, timeouts | 检查：await 用法、错误处理、超时
└── Widget Error | Widget 错误
    └── Check: build() method, dispose(), mounted state | 检查：build() 方法、dispose()、mounted 状态
```

## Common Issues & Solutions | 常见问题与解决方案

### RenderFlex Overflow | RenderFlex 溢出
```dart
// Problem: Text overflows | 问题：文本溢出
Text(longText)

// Solution: Wrap with Flexible/Expanded or use overflow | 解决：用 Flexible/Expanded 包裹或使用 overflow
Flexible(child: Text(longText, overflow: TextOverflow.ellipsis))
```

### State Not Rebuilding | 状态未重建
```dart
// Check mounted before setState | setState 前检查 mounted
if (mounted) {
  setState(() { ... });
}
```

### Scroll Issues | 滚动问题
```dart
// Ensure scroll controller attached and jump after layout
// 确保滚动控制器已附加并在布局后跳转
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (_controller.hasClients) {
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }
});
```

## Debug Steps | 调试步骤

1. **Reproduce 复现** - Get consistent reproduction steps | 获取一致的复现步骤
2. **Isolate 隔离** - Narrow down to specific widget/function | 缩小到具体的 widget/函数
3. **Log 日志** - Add print/debugPrint statements | 添加 print/debugPrint 语句
4. **Fix 修复** - Make minimal change to fix | 进行最小改动修复
5. **Verify 验证** - Test fix + edge cases | 测试修复 + 边界情况
