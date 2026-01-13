# 技术实施文档：AI 语音教练模块 (Speech Coach Module)

## 1. 概述

本模块通过集成 **Azure AI Speech Pronunciation Assessment API**，实现对用户口语发音的实时评估。核心功能包括：音素级准确度分析、语调/韵律评估、流利度检测及可视化反馈。

## 2. 技术栈

- **前端**: Flutter (基于项目背景)
- **后端**: Hono / Cloudflare Workers (作为 API 网关与密钥管理)
- **核心引擎**: Azure AI Speech SDK (`microsoft-cognitiveservices-speech-sdk`)
- **音频格式**: PCM 16bit, 16kHz, Mono (Azure 推荐格式)

---

## 3. Azure 发音评估核心配置 (Backend/Client Side)

在调用 Azure SDK 时，必须正确配置 `PronunciationAssessmentConfig` 以获取 PRD 中要求的深度诊断数据。

### 核心配置项 (JSON 逻辑)

```typescript
{
  "referenceText": "The text user is supposed to say",
  "gradingSystem": "HundredMark",      // 百分制：0-100
  "granularity": "Phoneme",           // 颗粒度：音素级 (最高级别)
  "phonemeAlphabet": "IPA",           // 音标系统：国际音标
  "enableProsodyAssessment": true     // 开启语调/重音评估 (关键)
}

```

---

## 4. 数据处理逻辑与 UI 映射

Azure 返回的响应需要被解构成前端可用的模型。

### A. 单词级评分 (Traffic Light)

| 字段            | 逻辑判断      | UI 表现        |
| --------------- | ------------- | -------------- |
| `AccuracyScore` | > 80          | 绿色 (Perfect) |
| `AccuracyScore` | 60 - 80       | 黄色 (Warning) |
| `AccuracyScore` | < 60          | 红色 (Error)   |
| `ErrorType`     | == "Omission" | 灰色 (Missing) |

### B. 音素级对比 (Deep Dive)

当用户点击特定单词（如 "live"）时，提取该单词下的 `Phonemes` 数组：

- **目标音标**: `phoneme.phoneme` (API 返回的预期音标)
- **得分**: `phoneme.pronunciationAssessment.accuracyScore`
- **错误逻辑**: 若 `accuracyScore` 低于阈值，则触发“音素纠错卡片”。

---

## 5. 核心代码实现 (以 TypeScript/SDK 为例)

### 步骤 1: 初始化语音配置

```typescript
import * as SpeechSDK from "microsoft-cognitiveservices-speech-sdk";

const speechConfig = SpeechSDK.SpeechConfig.fromSubscription(
  AZURE_KEY,
  AZURE_REGION
);
speechConfig.speechRecognitionLanguage = "en-US"; // 或动态传入
```

### 步骤 2: 配置发音评估服务

```typescript
// 定义发音评估配置
const pronConfig = new SpeechSDK.PronunciationAssessmentConfig(
  referenceText,
  SpeechSDK.PronunciationAssessmentGradingSystem.HundredMark,
  SpeechSDK.PronunciationAssessmentGranularity.Phoneme,
  true // 开启音信级反馈
);

// 开启韵律（语调）评估
pronConfig.enableProsodyAssessment = true;

const audioConfig = SpeechSDK.AudioConfig.fromDefaultMicrophoneInput();
const recognizer = new SpeechSDK.SpeechRecognizer(speechConfig, audioConfig);

pronConfig.applyTo(recognizer);
```

### 步骤 3: 处理返回结果

```typescript
recognizer.recognizeOnceAsync((result) => {
  const pronResult = SpeechSDK.PronunciationAssessmentResult.fromResult(result);

  // 1. 整体评分
  console.log("Overall Score:", pronResult.pronunciationScore);

  // 2. 逐词分析 (映射到 UI)
  const wordResults = result.privJson.NBest[0].Words.map((w) => ({
    text: w.Word,
    score: w.PronunciationAssessment.AccuracyScore,
    errorType: w.PronunciationAssessment.ErrorType,
    phonemes: w.Phonemes, // 用于深度诊断卡片
  }));

  // 3. 韵律/语调分析
  const prosodyScore = pronResult.prosodyScore;
});
```

---

## 6. UI 组件结构说明 (Cursor 辅助实现)

### 组件 1: `SpeechBubble` (语音气泡)

- **Input**: `List<WordResult>`
- **Logic**: 遍历单词，根据 `accuracyScore` 动态改变文本 `TextStyle.color`。

### 组件 2: `CorrectionCard` (诊断卡片)

- **触发条件**: 点击 `WordResult` 且 `score < 80`。
- **内容**:
- 显示错误单词的音标对比。
- _(提示：此处需根据音素 ID 加载本地 SVG 资源)_。

### 组件 3: `PitchChart` (音高对比图)

- **数据来源**: 需要从音频文件中提取 F0 频率。
- **实现方案**: 使用第三方库（如 Flutter 的 `fl_chart`）绘制 Azure 返回的 `Prosody` 数据时间轴。

---

## 7. 异常处理与性能优化

1. **VAD (Voice Activity Detection)**: 在前端开启静音检测，用户停止说话 1.5s 后自动提交，避免无意义的 API 调用。
2. **音频压缩**: 即使是 16kHz PCM，长句子也可能导致传输慢。建议在 Cloudflare Worker 层做流式转发。
3. **多语言支持**: 确保 `ReferenceText` 的语言编码与 `speechRecognitionLanguage` 一致。

---

**下一步建议：**
你可以直接将此文档贴给 Cursor，并输入提示词：

> _"根据这个技术文档，帮我用 Flutter 实现一个 `PronunciationAnalyzer` 类，并写出对接 Azure SDK 的识别逻辑。"_
