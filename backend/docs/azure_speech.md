# Azure Speech Pronunciation Assessment API 集成指南

本文档描述 TriTalk 后端如何集成 Azure AI Speech Pronunciation Assessment API，实现用户发音的实时评估。

## 功能概述

- **音素级准确度分析**: 每个音素的发音评分 (0-100)
- **单词级评估**: 单词准确度、遗漏/插入/发音错误检测
- **语调/韵律评估**: Prosody (语调) 评分
- **流利度检测**: 整体流利度评分
- **Traffic Light UI 反馈**: 根据分数自动分类为 perfect/warning/error/missing

## API 端点

### POST `/speech/assess`

发音评估端点，支持 multipart/form-data 格式。

#### 请求参数

| 参数             | 类型    | 必填 | 描述                                        |
| ---------------- | ------- | ---- | ------------------------------------------- |
| `audio`          | File    | ✅   | 音频文件 (推荐: PCM 16bit, 16kHz, Mono WAV) |
| `reference_text` | string  | ✅   | 用户应该朗读的参考文本                      |
| `language`       | string  | ❌   | 语言代码 (默认: "en-US")                    |
| `enable_prosody` | boolean | ❌   | 是否启用语调评估 (默认: true)               |

#### 响应格式

```json
{
  "recognition_status": "Success",
  "display_text": "The quick brown fox",
  "pronunciation_score": 87.5,
  "accuracy_score": 89.2,
  "fluency_score": 85.0,
  "completeness_score": 100.0,
  "prosody_score": 82.5,
  "words": [
    {
      "word": "the",
      "accuracy_score": 92.3,
      "error_type": "None",
      "phonemes": [
        {
          "phoneme": "ð",
          "accuracy_score": 88.5,
          "offset": 0,
          "duration": 50
        },
        {
          "phoneme": "ə",
          "accuracy_score": 96.0,
          "offset": 50,
          "duration": 30
        }
      ]
    }
  ],
  "word_feedback": [
    {
      "text": "the",
      "score": 92.3,
      "level": "perfect",
      "error_type": "None",
      "phonemes": [...]
    }
  ]
}
```

#### Traffic Light 评分逻辑

| 分数范围 | 错误类型 | UI 等级   | 颜色 |
| -------- | -------- | --------- | ---- |
| > 80     | -        | `perfect` | 绿色 |
| 60 - 80  | -        | `warning` | 黄色 |
| < 60     | -        | `error`   | 红色 |
| -        | Omission | `missing` | 灰色 |

## 配置

### 环境变量

在 Cloudflare Dashboard 或 `.dev.vars` 中配置：

```bash
AZURE_SPEECH_KEY=your_azure_speech_subscription_key
AZURE_SPEECH_REGION=westus2
```

### 获取 Azure Speech API Key

1. 登录 [Azure Portal](https://portal.azure.com)
2. 创建 "Cognitive Services" -> "Speech" 资源
3. 在资源页面找到 Keys and Endpoint
4. 复制 Key 1 或 Key 2 作为 `AZURE_SPEECH_KEY`
5. 复制 Location/Region 作为 `AZURE_SPEECH_REGION`

## 音频格式要求

Azure Speech API 推荐的音频格式：

- **编码**: PCM (未压缩)
- **采样率**: 16kHz
- **位深**: 16-bit
- **声道**: Mono (单声道)
- **格式**: WAV

> 💡 提示: 其他格式 (如 mp3, m4a) 也可能被接受，但 PCM 16kHz Mono WAV 提供最佳准确度。

## 前端集成示例

### Flutter 服务类完整示例

基于 TriChat `chat_service.dart` 的代码模式，以下是发音评估服务的完整实现：

```dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../services/auth_service.dart';

/// 发音评估结果模型
class PronunciationResult {
  final String recognitionStatus;
  final String displayText;
  final double pronunciationScore;
  final double accuracyScore;
  final double fluencyScore;
  final double completenessScore;
  final double? prosodyScore;
  final List<WordFeedback> wordFeedback;

  PronunciationResult({
    required this.recognitionStatus,
    required this.displayText,
    required this.pronunciationScore,
    required this.accuracyScore,
    required this.fluencyScore,
    required this.completenessScore,
    this.prosodyScore,
    required this.wordFeedback,
  });

  factory PronunciationResult.fromJson(Map<String, dynamic> json) {
    return PronunciationResult(
      recognitionStatus: json['recognition_status'] as String,
      displayText: json['display_text'] as String,
      pronunciationScore: (json['pronunciation_score'] as num).toDouble(),
      accuracyScore: (json['accuracy_score'] as num).toDouble(),
      fluencyScore: (json['fluency_score'] as num).toDouble(),
      completenessScore: (json['completeness_score'] as num).toDouble(),
      prosodyScore: json['prosody_score'] != null
          ? (json['prosody_score'] as num).toDouble()
          : null,
      wordFeedback: (json['word_feedback'] as List<dynamic>)
          .map((w) => WordFeedback.fromJson(w as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// 单词反馈模型 (Traffic Light 系统)
class WordFeedback {
  final String text;
  final double score;
  final String level; // perfect, warning, error, missing
  final String errorType;
  final List<PhonemeFeedback> phonemes;

  WordFeedback({
    required this.text,
    required this.score,
    required this.level,
    required this.errorType,
    required this.phonemes,
  });

  factory WordFeedback.fromJson(Map<String, dynamic> json) {
    return WordFeedback(
      text: json['text'] as String,
      score: (json['score'] as num).toDouble(),
      level: json['level'] as String,
      errorType: json['error_type'] as String,
      phonemes: (json['phonemes'] as List<dynamic>)
          .map((p) => PhonemeFeedback.fromJson(p as Map<String, dynamic>))
          .toList(),
    );
  }

  /// 获取单词颜色 (Traffic Light)
  Color get color {
    switch (level) {
      case 'perfect':
        return Colors.green;
      case 'warning':
        return Colors.orange;
      case 'error':
        return Colors.red;
      case 'missing':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}

/// 音素反馈模型
class PhonemeFeedback {
  final String phoneme; // IPA 音标
  final double accuracyScore;
  final int? offset;
  final int? duration;

  PhonemeFeedback({
    required this.phoneme,
    required this.accuracyScore,
    this.offset,
    this.duration,
  });

  factory PhonemeFeedback.fromJson(Map<String, dynamic> json) {
    return PhonemeFeedback(
      phoneme: json['phoneme'] as String,
      accuracyScore: (json['accuracy_score'] as num).toDouble(),
      offset: json['offset'] as int?,
      duration: json['duration'] as int?,
    );
  }
}

/// 发音评估服务
class SpeechAssessmentService {
  final AuthService _authService;

  SpeechAssessmentService({AuthService? authService})
      : _authService = authService ?? AuthService();

  /// 构建请求头
  Map<String, String> _headers() {
    final headers = {'Content-Type': 'application/json'};
    final token = _authService.accessToken;
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  /// 评估用户发音
  ///
  /// [audioFile] - 录音文件 (推荐 WAV 格式, 16kHz, Mono)
  /// [referenceText] - 用户应该朗读的参考文本
  /// [language] - 语言代码 (默认: en-US)
  /// [enableProsody] - 是否启用语调评估
  Future<PronunciationResult> assessPronunciation({
    required File audioFile,
    required String referenceText,
    String language = 'en-US',
    bool enableProsody = true,
  }) async {
    try {
      final baseUrl = Env.apiBaseUrl;
      final uri = Uri.parse('$baseUrl/speech/assess');

      // 构建 multipart 请求
      final request = http.MultipartRequest('POST', uri);

      // 添加认证头
      final token = _authService.accessToken;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // 添加表单字段
      request.fields['reference_text'] = referenceText;
      request.fields['language'] = language;
      request.fields['enable_prosody'] = enableProsody.toString();

      // 添加音频文件
      request.files.add(await http.MultipartFile.fromPath(
        'audio',
        audioFile.path,
        filename: 'audio.wav',
      ));

      // 发送请求
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return PronunciationResult.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(
          errorData['error'] ?? 'Failed to assess pronunciation: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SpeechAssessmentService error: $e');
      }
      rethrow;
    }
  }

  /// 从字节数据评估发音 (用于录音后直接评估)
  Future<PronunciationResult> assessPronunciationFromBytes({
    required List<int> audioBytes,
    required String referenceText,
    String language = 'en-US',
    bool enableProsody = true,
  }) async {
    try {
      final baseUrl = Env.apiBaseUrl;
      final uri = Uri.parse('$baseUrl/speech/assess');

      final request = http.MultipartRequest('POST', uri);

      // 添加认证头
      final token = _authService.accessToken;
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // 添加表单字段
      request.fields['reference_text'] = referenceText;
      request.fields['language'] = language;
      request.fields['enable_prosody'] = enableProsody.toString();

      // 从字节创建文件
      request.files.add(http.MultipartFile.fromBytes(
        'audio',
        audioBytes,
        filename: 'audio.wav',
      ));

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return PronunciationResult.fromJson(data);
      } else {
        final errorData = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(
          errorData['error'] ?? 'Failed to assess pronunciation: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('SpeechAssessmentService error: $e');
      }
      rethrow;
    }
  }
}
```

### 使用示例

```dart
// 初始化服务
final speechService = SpeechAssessmentService();

// 从文件评估发音
final result = await speechService.assessPronunciation(
  audioFile: File('/path/to/recording.wav'),
  referenceText: 'The quick brown fox jumps over the lazy dog',
  language: 'en-US',
  enableProsody: true,
);

// 打印结果
print('发音评分: ${result.pronunciationScore}');
print('准确度: ${result.accuracyScore}');
print('流利度: ${result.fluencyScore}');

// 遍历每个单词的反馈
for (final word in result.wordFeedback) {
  print('${word.text}: ${word.score} (${word.level})');

  // 如果是问题单词，显示音素详情
  if (word.level == 'error' || word.level == 'warning') {
    for (final phoneme in word.phonemes) {
      print('  音素: ${phoneme.phoneme}, 评分: ${phoneme.accuracyScore}');
    }
  }
}
```

### UI 组件建议

1. **SpeechBubble 组件**: 根据 `word_feedback.level` 为每个单词着色
2. **CorrectionCard 组件**: 点击单词时显示音素详情
3. **ScoreGauge 组件**: 显示整体 `pronunciation_score`
4. **ProsodyChart 组件**: 如果需要音高曲线，使用 `fl_chart` 绑定 prosody 数据

### cURL 测试示例

```bash
# 测试发音评估 API
curl -X POST http://localhost:8787/speech/assess \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -F "audio=@/path/to/audio.wav" \
  -F "reference_text=Hello world" \
  -F "language=en-US" \
  -F "enable_prosody=true"
```

## 错误处理

| 错误信息                          | 原因                  | 解决方案                      |
| --------------------------------- | --------------------- | ----------------------------- |
| "Azure Speech is not configured"  | 未配置 API Key/Region | 检查环境变量配置              |
| "Azure Speech recognition failed" | 无法识别语音          | 检查音频质量/格式             |
| "No audio file uploaded"          | 未上传音频文件        | 确保 multipart 请求包含 audio |
| "Reference text is required"      | 未提供参考文本        | 添加 reference_text 字段      |

## 相关链接

- [Azure Speech Pronunciation Assessment 官方文档](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/how-to-pronunciation-assessment)
- [Azure Speech REST API 参考](https://learn.microsoft.com/en-us/azure/ai-services/speech-service/rest-speech-to-text-short)
