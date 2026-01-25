# FeatureGate 集成点总结

本文档记录了所有已集成 FeatureGate 的位置，以确保付费功能的配额限制得到正确执行。

## 集成模式

我们使用两种集成风格：

### Style 1: Callback（用于导航操作）

```dart
FeatureGate().performWithFeatureCheck(
  context,
  feature: PaidFeature.xxx,
  onGranted: () {
    // 用户有权限时执行的逻辑
  },
);
```

### Style 2: Await（用于异步 API 调用）

```dart
final granted = await FeatureGate().performWithFeatureCheck(
  context,
  feature: PaidFeature.xxx,
);
if (!granted) return;
// 用户有权限时继续执行
```

---

## 已集成的文件

### 1. `home_screen.dart`

| 功能           | PaidFeature       | 方法            | 样式    |
| -------------- | ----------------- | --------------- | ------- |
| 创建自定义场景 | `customScenarios` | FAB `onPressed` | Style 1 |

### 2. `chat_screen.dart`

| 功能                 | PaidFeature         | 方法                           | 样式    |
| -------------------- | ------------------- | ------------------------------ | ------- |
| 发送消息/AI 对话     | `dailyConversation` | `_sendMessage()`               | Style 2 |
| 语音输入             | `voiceInput`        | `_startVoiceRecording()`       | Style 2 |
| 用户消息分析（语音） | `speechAssessment`  | `_handleUserMessageAnalysis()` | Style 2 |
| 用户消息分析（文本） | `grammarAnalysis`   | `_handleUserMessageAnalysis()` | Style 2 |
| AI 消息分析          | `grammarAnalysis`   | `_handleAnalyze()`             | Style 2 |
| AI 消息优化/重写     | `grammarAnalysis`   | `_optimizeMessage()`           | Style 2 |

### 3. `chat_bubble.dart`

| 功能     | PaidFeature | 方法                  | 样式    |
| -------- | ----------- | --------------------- | ------- |
| TTS 播放 | `ttsSpeak`  | `_playTextToSpeech()` | Style 2 |

### 4. `shadowing_sheet.dart`

| 功能     | PaidFeature         | 方法                                      | 样式    |
| -------- | ------------------- | ----------------------------------------- | ------- |
| TTS 播放 | `ttsSpeak`          | `_playTextToSpeech()`                     | Style 2 |
| 单词发音 | `wordPronunciation` | `_playWordPronunciation()`                | Style 2 |
| 发音评估 | `speechAssessment`  | `_stopRecording()` (调用 `_analyzeAudio`) | Style 2 |

### 5. `vocab_list_widget.dart`

| 功能     | PaidFeature         | 方法                       | 样式    |
| -------- | ------------------- | -------------------------- | ------- |
| 单词发音 | `wordPronunciation` | `_playWordPronunciation()` | Style 2 |

### 6. `analysis_sheet.dart`

| 功能     | PaidFeature         | 方法                       | 样式    |
| -------- | ------------------- | -------------------------- | ------- |
| 单词发音 | `wordPronunciation` | `_playWordPronunciation()` | Style 2 |

### 7. `voice_feedback_sheet.dart`

| 功能     | PaidFeature         | 方法                       | 样式    |
| -------- | ------------------- | -------------------------- | ------- |
| 单词发音 | `wordPronunciation` | `_playWordPronunciation()` | Style 2 |

### 8. `favorites_sheet.dart`

| 功能     | PaidFeature         | 方法                       | 样式    |
| -------- | ------------------- | -------------------------- | ------- |
| 单词发音 | `wordPronunciation` | `_playWordPronunciation()` | Style 2 |

---

## PaidFeature 枚举

```dart
enum PaidFeature {
  // --- 次数限制类 (Quota Limited) ---
  dailyConversation, // AI 对话 (每日会话/消息数)
  voiceInput, // 语音输入
  speechAssessment, // 句子发音评估
  wordPronunciation, // 单词发音 (Free: 10/day, Plus/Pro: Unlimited)
  grammarAnalysis, // 语法深度分析
  ttsSpeak, // AI 消息朗读
  // --- 访问权限类 (Gatekeepers) ---
  pitchAnalysis, // 音高对比分析 (仅 Plus/Pro)
  customScenarios, // 自定义场景 (Free: 不可创建, Plus: 10个, Pro: 50个)
}
```

---

## 注意事项

1. **缓存内容不计次**: 如果内容已缓存（如 TTS 音频、翻译结果），不会扣减配额
2. **免费用户**: 超出配额时显示 Paywall 弹窗
3. **Plus/Pro 用户**: 大部分功能无限制，少数功能有更高配额
