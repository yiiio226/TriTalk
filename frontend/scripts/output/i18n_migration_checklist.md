# i18n 迁移清单

> 生成时间: 2026-01-19  
> 状态: 待审核

## 扫描概览

| 指标               | 数量 |
| ------------------ | ---- |
| 扫描到的字符串总数 | 48   |
| 去重后的唯一字符串 | 32   |
| 优化后的 ARB 条目  | 22   |
| 涉及的文件数       | 15   |

## 优化说明

以下字符串已从 ARB 草稿中排除：

### ❌ 代码示例 (不需要国际化)

- `core/design/app_design_system.dart:217` - `Hello` - 这是文档注释中的示例

### ❌ Mock 数据 (实际数据来自后端)

- `features/scenes/data/datasources/mock_scenes.dart` - 所有 title 字段

### ✅ 已合并的重复字符串

- `Cancel` - 出现 5 次，合并为 `commonCancel`
- `Retry` - 出现 2 次，合并为 `commonRetry`
- `SUMMARY` - 出现 2 次，合并为 `studySummary`
- `SENTENCE STRUCTURE` - 出现 3 次，合并为 `studySentenceStructure`
- `GRAMMAR POINTS` - 出现 3 次，合并为 `studyGrammarPoints`
- `VOCABULARY` - 出现 3 次，合并为 `studyVocabulary`
- `IDIOMS & SLANG` - 出现 3 次，合并为 `studyIdiomsSlang`
- `Favorites` - 出现 2 次（场景抽屉和个人资料），保留为独立 key

## 待替换清单

### 通用组件 (Common)

| 文件                             | 行号 | 原字符串          | ARB Key            |
| -------------------------------- | ---- | ----------------- | ------------------ |
| `core/widgets/error_screen.dart` | 13   | `TriTalk - Error` | `errorScreenTitle` |

### 首页 (Home)

| 文件               | 行号 | 原字符串 | ARB Key        |
| ------------------ | ---- | -------- | -------------- |
| `home_screen.dart` | 541  | `Cancel` | `commonCancel` |
| `home_screen.dart` | 598  | `Cancel` | `commonCancel` |

### 场景 (Scenes)

| 文件                        | 行号 | 原字符串                | ARB Key                            |
| --------------------------- | ---- | ----------------------- | ---------------------------------- |
| `scene_options_drawer.dart` | 28   | `Favorites`             | `scenesDrawerFavorites`            |
| `scene_options_drawer.dart` | 37   | `Clear Conversation`    | `scenesDrawerClearConversation`    |
| `scene_options_drawer.dart` | 46   | `Bookmark Conversation` | `scenesDrawerBookmarkConversation` |

### 学习 (Study)

| 文件                   | 行号          | 原字符串                 | ARB Key                     |
| ---------------------- | ------------- | ------------------------ | --------------------------- |
| `save_note_sheet.dart` | 62            | `Saved to Notebook!`     | `studySavedToNotebook`      |
| `analysis_sheet.dart`  | 335, 396      | `SUMMARY`                | `studySummary`              |
| `analysis_sheet.dart`  | 358, 417, 483 | `SENTENCE STRUCTURE`     | `studySentenceStructure`    |
| `analysis_sheet.dart`  | 367, 495, 510 | `GRAMMAR POINTS`         | `studyGrammarPoints`        |
| `analysis_sheet.dart`  | 376, 522, 537 | `VOCABULARY`             | `studyVocabulary`           |
| `analysis_sheet.dart`  | 385, 549, 564 | `IDIOMS & SLANG`         | `studyIdiomsSlang`          |
| `analysis_sheet.dart`  | 576           | `Analysis not available` | `studyAnalysisNotAvailable` |

### 聊天 (Chat)

| 文件                            | 行号                 | 原字符串                     | ARB Key                      |
| ------------------------------- | -------------------- | ---------------------------- | ---------------------------- |
| `chat_screen.dart`              | 441, 833, 1201, 1258 | `Cancel`                     | `commonCancel`               |
| `chat_screen.dart`              | 807                  | `Delete`                     | `commonDelete`               |
| `chat_screen.dart`              | 977                  | `Type a message...`          | `chatTypeAMessage`           |
| `chat_screen.dart`              | 1012                 | `Optimize with AI`           | `chatOptimizeWithAi`         |
| `chat_history_list_widget.dart` | 96                   | `Conversation deleted`       | `chatConversationDeleted`    |
| `voice_feedback_sheet.dart`     | 241                  | `Analyzing pronunciation...` | `chatAnalyzingPronunciation` |
| `voice_feedback_sheet.dart`     | 477                  | `Retry`                      | `commonRetry`                |
| `hints_sheet.dart`              | 137                  | `Retry`                      | `commonRetry`                |

### 订阅 (Subscription)

| 文件                  | 行号 | 原字符串             | ARB Key                         |
| --------------------- | ---- | -------------------- | ------------------------------- |
| `paywall_screen.dart` | 87   | `Welcome to Pro!`    | `subscriptionWelcomeToPro`      |
| `paywall_screen.dart` | 115  | `Purchases Restored` | `subscriptionPurchasesRestored` |

### 个人资料 (Profile)

| 文件                  | 行号 | 原字符串                              | ARB Key                       |
| --------------------- | ---- | ------------------------------------- | ----------------------------- |
| `profile_screen.dart` | 301  | `Native Language`                     | `profileNativeLanguage`       |
| `profile_screen.dart` | 316  | `Learning Language`                   | `profileLearningLanguage`     |
| `profile_screen.dart` | 339  | `Favorites`                           | `profileFavorites`            |
| `profile_screen.dart` | 340  | `Vocabulary, Sentences, Grammar, Chat History` | `profileFavoritesSubtitle`    |
| `profile_screen.dart` | 356  | `Upgrade to Pro`                      | `profileUpgradeToPro`         |
| `profile_screen.dart` | 357  | `Get unlimited chats...`              | `profileUpgradeToProSubtitle` |
| `profile_screen.dart` | 373  | `Log Out`                             | `profileLogOut`               |

### 引导流程 (Onboarding)

| 文件                     | 行号 | 原字符串             | ARB Key                    |
| ------------------------ | ---- | -------------------- | -------------------------- |
| `onboarding_screen.dart` | 57   | `Session expired...` | `onboardingSessionExpired` |

### 主入口 (Main)

| 文件        | 行号 | 原字符串  | ARB Key    |
| ----------- | ---- | --------- | ---------- |
| `main.dart` | 78   | `TriTalk` | `appTitle` |

## 迁移步骤

### Step 1: 审核 ARB 草稿

```bash
# 查看优化后的 ARB 草稿
cat scripts/output/intl_en_draft.arb
```

### Step 2: 复制到正式 ARB 文件

将 `scripts/output/intl_en_draft.arb` 的内容合并到 `lib/l10n/intl_en.arb`

### Step 3: 生成 Dart 代码

```bash
flutter gen-l10n
```

### Step 4: 翻译中文

将英文内容翻译到 `lib/l10n/intl_zh.arb`

### Step 5: 替换硬编码字符串

将代码中的硬编码字符串替换为 `context.l10n.xxx`

**替换示例:**

```dart
// Before
Text('Cancel')

// After
import 'package:frontend/core/utils/l10n_ext.dart';
Text(context.l10n.commonCancel)
```

## 后续检查

迁移完成后，运行扫描脚本验证：

```bash
dart run scripts/i18n_scanner.dart
```

预期结果：应该只剩下排除项（代码示例、mock 数据等）。
