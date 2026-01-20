# 语言处理架构规范 (Language Handling Architecture)

本文档定义了 TriTalk 在前端应用中处理用户语言设置（目标语言、母语等）的架构规范。核心原则是**单一数据源 (Single Source of Truth)** 和 **BCP-47 标准化**。

## 1. 核心原则

### 1.1 BCP-47 标准化

所有涉及语言代码（Locale/Language Code）的地方，**必须**严格遵循 [BCP-47 IETF 语言标签](https://tools.ietf.org/html/bcp47) 标准。

- **格式**: `language-REGION` (例如: `en-US`, `zh-CN`, `ja-JP`)
- **禁止**:
  - ❌ 仅使用语言代码 (如 `en`, `ja`) —— 除非特指泛指，但在 API交互中通常需要具体区域。
  - ❌ 使用下划线 (如 `en_US`) —— 除非特定底层库（如某些 Android API）强制要求，必须在各层边界处进行转换。
- **工具**: 使用 `LanguageConstants.getIsoCode()` 确保格式统一。

### 1.2 单一数据源 (SSOT)

不要在各个服务（Service）中重复查询数据库或本地存储来获取用户的语言设置。

- **唯一源**: `authProvider` 中的 `User` 对象。
- **访问方式**: 通过 Riverpod 的 `currentUserTargetLanguageProvider`。

### 1.3 服务层无状态性

服务类（如 `WordTtsService`, `SpeechAssessmentService`）**不应**负责获取当前用户的状态。

- **设计模式**: 服务方法应通过**参数**接收语言代码，而不是自己在方法内部去获取。
- **优势**: 服务变得纯粹、易于测试，且解耦了用户状态管理。

---

## 2. 架构模式

### 2.1 Provider 层 (数据源)

我们在 `auth_provider.dart` 中定义了一个专门的 Provider 来获取当前用户的目标语言。这是应用中获取目标语言的**唯一推荐方式**。

```dart
// lib/core/auth/auth_provider.dart

/// Provider for accessing current user's target language
///
/// This is the single source of truth.
/// Returns BCP-47 format string (e.g., 'en-US', 'ja-JP').
final currentUserTargetLanguageProvider = Provider<String>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) {
    return LanguageConstants.defaultTargetLanguageCode; // e.g., 'en-US'
  }
  // Normalize to ensure BCP-47 format
  return LanguageConstants.getIsoCode(user.targetLanguage);
});
```

### 2.2 服务层 (Service Layer)

服务层方法必须显式要求传递语言参数。

**❌ 错误做法 (Anti-Pattern):**

```dart
class WordTtsService {
  // 错误：服务自己去查库/查状态
  Future<void> speak(String text) async {
    final lang = await _getUserLangFromDB(); // ❌ 违反单一职责，重复代码
    // ...
  }
}
```

**✅ 正确做法 (Best Practice):**

```dart
class WordTtsService {
  // 正确：语言作为必需参数传入
  Future<void> speak(String text, {required String language}) async {
    // ... use language directly
  }
}
```

### 2.3 UI/调用层 (Consumer)

在 UI 层（Widget）或 ViewModel（Notifier）中，从 Provider 读取语言，然后传递给服务。

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. 从 Provider 获取 BCP-47 语言代码
    final targetLang = ref.watch(currentUserTargetLanguageProvider);

    return ElevatedButton(
      onPressed: () async {
        // 2. 将语言代码传递给服务
        await WordTtsService().speak(
          'Hello',
          language: targetLang // 传递 'en-US'
        );
      },
      child: Text('Speak'),
    );
  }
}
```

---

## 3. 实现细节与迁移

### BCP-47转换工具

使用 `LanguageConstants` (位于 `lib/core/data/language_constants.dart`) 处理格式标准化。

```dart
// 确保输入是标准化格式
static String getIsoCode(String? language) {
  // 处理 null, 转换下划线, 处理简写等逻辑
  // 返回如 'en-US'
}
```

### API 交互

所有后端 API 端点（TTS, 评估等）均已更新为期望接收 BCP-47 格式的 `language` 字段。

- 前端：发送 `en-US`
- 后端：接收 `en-US` (必要时后端会转换为具体云服务商所需的格式，如 Google TTS 的 `en-US-Neural2-F`)

## 4. 总结

遵循此规范可带来以下好处：

1.  **一致性**: 避免有的地方用 `en` 有的地方用 `en-US` 导致的 Bug。
2.  **可维护性**: 用户切换语言时，所有依赖 `ref.watch(currentUserTargetLanguageProvider)` 的组件会自动更新，无需重启或手动刷新。
3.  **性能**: 利用了 Riverpod 的缓存机制，减少了不必要的数据库查询。
