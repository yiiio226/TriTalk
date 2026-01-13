# 技术实施文档：AI 语音教练模块 (Speech Coach Module)

## 1. 概述

本模块通过集成 **Azure AI Speech Pronunciation Assessment API**，实现对用户口语发音的实时评估。核心功能包括：音素级准确度分析、语调/韵律评估、流利度检测及可视化反馈。

## 2. 技术栈

- **前端**: Flutter (基于项目背景)
- **后端**: Hono / Cloudflare Workers (作为 API 网关与密钥管理)
- **核心引擎**: Azure AI Speech SDK (`microsoft-cognitiveservices-speech-sdk`)
- **音频格式**: PCM 16bit, 16kHz, Mono (Azure 推荐格式)

---

## 3. 前端实现状态

✅ **已完成实现** (2026-01-13)

### 文件结构

```
lib/features/speech/
├── speech.dart                           # 模块入口 (barrel export)
├── data/
│   ├── data.dart                         # 数据层导出
│   └── services/
│       └── speech_assessment_service.dart # API 服务类
├── domain/
│   ├── domain.dart                       # 领域层导出
│   └── models/
│       └── pronunciation_result.dart     # 数据模型
└── providers/
    └── speech_providers.dart             # Riverpod 状态管理
```

---

## 4. 数据模型

### PronunciationResult (发音评估结果)

```dart
class PronunciationResult {
  final String recognitionStatus;     // 识别状态
  final String displayText;           // 识别文本
  final double pronunciationScore;    // 综合发音评分 (0-100)
  final double accuracyScore;         // 准确度评分
  final double fluencyScore;          // 流利度评分
  final double completenessScore;     // 完整度评分
  final double? prosodyScore;         // 语调评分 (可选)
  final List<WordFeedback> wordFeedback; // 单词级反馈
}
```

### WordFeedback (单词反馈 - Traffic Light)

| 字段            | 逻辑判断      | UI 表现        |
| --------------- | ------------- | -------------- |
| `AccuracyScore` | > 80          | 绿色 (Perfect) |
| `AccuracyScore` | 60 - 80       | 黄色 (Warning) |
| `AccuracyScore` | < 60          | 红色 (Error)   |
| `ErrorType`     | == "Omission" | 灰色 (Missing) |

### PhonemeFeedback (音素反馈)

```dart
class PhonemeFeedback {
  final String phoneme;         // IPA 音标
  final double accuracyScore;   // 准确度评分
  final int? offset;            // 偏移量 (ms)
  final int? duration;          // 持续时间 (ms)
}
```

---

## 5. 使用方法

### 方法 1: 使用 SpeechAssessmentService 直接调用

```dart
import 'package:frontend/features/speech/speech.dart';

// 初始化服务 (单例模式)
final speechService = SpeechAssessmentService();

// 从文件评估发音
final result = await speechService.assessPronunciationFromPath(
  audioPath: '/path/to/recording.wav',
  referenceText: 'The quick brown fox jumps over the lazy dog',
  language: 'en-US',
  enableProsody: true,
);

// 处理结果
if (result.isSuccess) {
  print('发音评分: ${result.pronunciationScore}');
  print('准确度: ${result.accuracyScore}');
  print('流利度: ${result.fluencyScore}');

  // 遍历每个单词的反馈
  for (final word in result.wordFeedback) {
    print('${word.text}: ${word.score} (${word.level})');

    // 如果是问题单词，显示音素详情
    if (word.hasIssue) {
      for (final phoneme in word.problemPhonemes) {
        print('  音素: ${phoneme.phoneme}, 评分: ${phoneme.accuracyScore}');
      }
    }
  }
}
```

### 方法 2: 使用 Riverpod Provider

```dart
import 'package:frontend/features/speech/speech.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PronunciationWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pronunciationAssessmentProvider);

    if (state.isLoading) {
      return CircularProgressIndicator();
    }

    if (state.error != null) {
      return Text('Error: ${state.error}');
    }

    if (state.result != null) {
      return PronunciationResultView(result: state.result!);
    }

    return ElevatedButton(
      onPressed: () async {
        await ref.read(pronunciationAssessmentProvider.notifier).assessFromPath(
          audioPath: audioPath,
          referenceText: 'Hello world',
        );
      },
      child: Text('Assess Pronunciation'),
    );
  }
}
```

### 方法 3: 从字节数据评估 (录音后直接评估)

```dart
// 录音完成后获取字节数据
final audioBytes = await recorder.stopRecording();

final result = await speechService.assessPronunciationFromBytes(
  audioBytes: audioBytes,
  referenceText: referenceText,
);
```

---

## 6. UI 组件建议

### 组件 1: `SpeechBubble` (语音气泡)

- **Input**: `List<WordResult>`
- **Logic**: 遍历单词，根据 `word.color` 动态改变文本颜色

```dart
Row(
  children: result.wordFeedback.map((word) =>
    Text(
      word.text,
      style: TextStyle(color: word.color),
    ),
  ).toList(),
)
```

### 组件 2: `CorrectionCard` (诊断卡片)

- **触发条件**: 点击 `WordResult` 且 `score < 80`
- **内容**:
  - 显示错误单词和正确发音
  - 列出问题音素及其评分
  - 提供音标对比

### 组件 3: `ScoreGauge` (评分仪表盘)

- 使用圆形进度条显示 `pronunciationScore`
- 颜色根据 `overallLevel` 变化

### 组件 4: `ProsodyChart` (语调图表)

- 使用 `fl_chart` 绑定 prosody 数据
- 显示音高变化曲线

---

## 7. 错误处理

### 常见错误

| 错误信息                          | 原因               | 解决方案                      |
| --------------------------------- | ------------------ | ----------------------------- |
| `Azure Speech is not configured`  | 后端未配置 API Key | 检查 Worker 环境变量          |
| `Azure Speech recognition failed` | 无法识别语音       | 检查音频质量/格式             |
| `No audio file uploaded`          | 未上传音频文件     | 确保 multipart 请求包含 audio |
| `Reference text is required`      | 未提供参考文本     | 添加 reference_text 字段      |

### 异常处理示例

```dart
try {
  final result = await speechService.assessPronunciationFromPath(
    audioPath: audioPath,
    referenceText: referenceText,
  );
  // 处理成功结果
} on SpeechAssessmentException catch (e) {
  // 处理 API 错误
  showSnackBar('评估失败: ${e.message}');
} catch (e) {
  // 处理其他错误
  showSnackBar('发生未知错误');
}
```

---

## 8. 性能优化建议

1. **VAD (Voice Activity Detection)**: 在前端开启静音检测，用户停止说话 1.5s 后自动提交
2. **音频压缩**: 使用 16kHz PCM 格式减少传输大小
3. **缓存结果**: 对于相同音频可缓存评估结果
4. **多语言支持**: 确保 `language` 参数与音频内容匹配

---

## 9. 相关链接

- [Azure Speech Pronunciation Assessment 官方文档](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/how-to-pronunciation-assessment)
- [后端 API 文档](../backend/docs/azure_speech.md)
