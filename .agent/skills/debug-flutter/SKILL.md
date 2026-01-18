---
name: debug-flutter
description: Systematic approach to debugging Flutter issues including UI, state, and async problems. Use when troubleshooting bugs or unexpected behavior. | 系统化调试 Flutter 问题的方法，包括 UI、状态和异步问题。在排查 bug 或异常行为时使用。
---

# Flutter Debugging Skill

Systematic debugging approach for TriTalk Flutter issues.

## When to use

- UI not rendering correctly
- State not updating as expected
- Async operations failing
- Widget errors or exceptions

## Debugging Decision Tree

```
Issue Type?
├── UI/Layout Error
│   └── Check: RenderFlex overflow, constraints, sizing
├── State Not Updating
│   └── Check: Provider/Riverpod usage, notifyListeners
├── Async Failure
│   └── Check: await usage, error handling, timeouts
└── Widget Error
    └── Check: build() method, dispose(), mounted state
```

## Common Issues & Solutions

### RenderFlex Overflow
```dart
// Problem: Text overflows
Text(longText)

// Solution: Wrap with Flexible/Expanded or use overflow
Flexible(child: Text(longText, overflow: TextOverflow.ellipsis))
```

### State Not Rebuilding
```dart
// Check mounted before setState
if (mounted) {
  setState(() { ... });
}
```

### Scroll Issues
```dart
// Ensure scroll controller attached and jump after layout
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (_controller.hasClients) {
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }
});
```

## Debug Steps

1. **Reproduce** - Get consistent reproduction steps
2. **Isolate** - Narrow down to specific widget/function
3. **Log** - Add print/debugPrint statements
4. **Fix** - Make minimal change to fix
5. **Verify** - Test fix + edge cases
