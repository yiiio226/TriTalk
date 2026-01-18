---
name: code-review
description: Reviews Flutter and TypeScript code for bugs, style issues, and best practices. Use when reviewing PRs or checking code quality. | 审查 Flutter 和 TypeScript 代码的 bug、风格问题和最佳实践。在审查 PR 或检查代码质量时使用。
---

# Code Review Skill | 代码审查技能

Provides structured code review for TriTalk's Flutter frontend and Node.js backend.
为 TriTalk 的 Flutter 前端和 Node.js 后端提供结构化的代码审查。

## When to use | 何时使用

- Reviewing pull requests | 审查拉取请求
- Checking code quality before commits | 提交前检查代码质量
- Debugging issues in existing code | 调试现有代码中的问题

## Review Checklist | 审查清单

### 1. Correctness | 正确性
- [ ] Does the code do what it's supposed to? | 代码是否实现了预期功能？
- [ ] Are edge cases and error conditions handled? | 是否处理了边界情况和错误条件？
- [ ] Is async/await used correctly? | async/await 是否正确使用？

### 2. Flutter Specific | Flutter 专项
- [ ] Uses `AppColors` from design system (no hardcoded colors) | 使用设计系统中的 `AppColors`（无硬编码颜色）
- [ ] Proper state management (Riverpod providers) | 正确的状态管理（Riverpod providers）
- [ ] Widgets are properly disposed | Widgets 正确销毁
- [ ] No memory leaks (listeners, subscriptions cleaned up) | 无内存泄漏（监听器、订阅已清理）

### 3. TypeScript Backend | TypeScript 后端
- [ ] Proper error handling with try/catch | 使用 try/catch 正确处理错误
- [ ] Input validation present | 存在输入验证
- [ ] No exposed sensitive data in responses | 响应中未暴露敏感数据

### 4. Performance | 性能
- [ ] No unnecessary rebuilds in Flutter widgets | Flutter widgets 无不必要的重建
- [ ] Expensive operations not in build methods | 耗时操作不在 build 方法中
- [ ] Proper use of `const` constructors | 正确使用 `const` 构造函数

### 5. Localization | 本地化
- [ ] User-facing strings are localized | 用户可见字符串已本地化
- [ ] No hardcoded text in UI | UI 中无硬编码文本

## How to Provide Feedback | 如何提供反馈

- Be specific about what needs to change | 明确指出需要修改的内容
- Explain **why**, not just what | 解释**为什么**，而不仅仅是什么
- Suggest alternatives when possible | 尽可能提供替代方案
- Use severity levels | 使用严重性级别: 🔴 Critical 严重 | 🟡 Suggestion 建议 | 🟢 Nitpick 细节
