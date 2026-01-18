---
name: code-review
description: Reviews Flutter and TypeScript code for bugs, style issues, and best practices. Use when reviewing PRs or checking code quality. | 审查 Flutter 和 TypeScript 代码的 bug、风格问题和最佳实践。在审查 PR 或检查代码质量时使用。
---

# Code Review Skill

Provides structured code review for TriTalk's Flutter frontend and Node.js backend.

## When to use

- Reviewing pull requests
- Checking code quality before commits
- Debugging issues in existing code

## Review Checklist

### 1. Correctness
- [ ] Does the code do what it's supposed to?
- [ ] Are edge cases and error conditions handled?
- [ ] Is async/await used correctly?

### 2. Flutter Specific
- [ ] Uses `AppColors` from design system (no hardcoded colors)
- [ ] Proper state management (Riverpod providers)
- [ ] Widgets are properly disposed
- [ ] No memory leaks (listeners, subscriptions cleaned up)

### 3. TypeScript Backend
- [ ] Proper error handling with try/catch
- [ ] Input validation present
- [ ] No exposed sensitive data in responses

### 4. Performance
- [ ] No unnecessary rebuilds in Flutter widgets
- [ ] Expensive operations not in build methods
- [ ] Proper use of `const` constructors

### 5. Localization
- [ ] User-facing strings are localized
- [ ] No hardcoded text in UI

## How to Provide Feedback

- Be specific about what needs to change
- Explain **why**, not just what
- Suggest alternatives when possible
- Use severity levels: 🔴 Critical | 🟡 Suggestion | 🟢 Nitpick
