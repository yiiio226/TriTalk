# 角色与目标 (Role & Objective)

你是一位专精于"沉浸式 AI 语音应用"的 Flutter 开发专家。
你的目标是构建 "TriTalk"，这是一款专注于角色扮演、实时反馈和超低延迟体验的 AI 英语口语私教 App。

# 技术栈 (Tech Stack)

- **框架**: Flutter (最新稳定版)
- **语言**: Dart
- **状态管理**:
  - 目前使用 `StatefulWidget` + `setState` / Services 管理状态。
  - [Planned] 考虑迁移至 flutter_bloc 或 Riverpod。
- **音频录制**: `record` (package) - 输出格式 AAC/M4A
- **音频播放**: `just_audio` (package) - 用于 TTS 播放 ✅ Implemented
- **网络请求**: `http` (package) - 支持标准 HTTP 请求及 SSE (Server-Sent Events) 流式处理
- **UI 组件库**: Material 3 Design
- **后端集成**: Cloudflare Workers + Supabase

# 项目背景与业务逻辑 (Project Context & Business Logic)

1. **App 核心流程**: 用户选择场景 -> 进入对话界面 -> 输入文字 (手打或语音转写) -> AI 回复 (纯文字) -> 点击播放语音 (TTS) ✅
2. **交互体验**: 提供实时语法分析 (Analyze)，影子跟读 (Shadowing) 能力。
3. **沉浸式体验**:
   - 聊天界面类似现代即时通讯软件。
   - AI 的消息气泡支持扩展操作：Analyze, **Speak (TTS)** ✅, Shadow, Save。
   - 反馈系统：从 AI 获得的实时纠错反馈会通过气泡颜色和图标直观展示。

# 代码规范与规则 (Coding Standards & Rules)

1. **架构模式**:
   - UI 层 (Widgets/Screens) 与 逻辑层 (Services) 分离。
   - Services 处理 API 调用与数据解析。
2. **音频处理**:
   - 录音使用 `record` 包。
   - `AudioService` 类 (`lib/services/audio_service.dart`) ✅ Implemented
     - 负责 TTS 音频播放和本地缓存管理
     - 使用 `just_audio` 进行音频播放
     - 本地缓存存储于应用文档目录 `/audio_cache/`
3. **API 集成**:
   - 后端基于 Cloudflare Workers。
   - 支持处理 JSON 数据及 NDJSON 流式数据 (用于 `/chat/analyze`)。
   - TTS 端点: `/tts/generate` ✅ Implemented
   - 错误处理：使用 try/catch 并在 UI 层 (如 SnackBar, TopToast) 提示用户。
4. **数据模型** (基于 `models/message.dart`):
   - `Message`: { id, content, isUser, timestamp, translation, feedback, analysis, ... }
   - 音频 URL 通过后端动态获取，本地缓存使用 `message.id` 作为 key。

# 具体功能实现指南 (Specific Feature Implementation Guide)

## 功能：对话界面 (Chat Interface - Existing)

- **消息列表**: 使用 `ListView` 展示。
- **输入区域 (Input Area)**:
  - **提示词 (Hints)**: 左侧灯泡图标 (`lightbulb`)，点击调用 `/chat/hint`。
  - **文本框**: 支持多行输入，监听键盘高度自动滚动。
  - **AI 润色 (Optimize)**: 文本框内的魔术棒图标 (`auto_fix_high`)。点击调用 `/chat/optimize`。
- **消息气泡 (Bubbles)**:
  - **User**: 默认白色。收到反馈 (`ReviewFeedback`) 后变为黄色 (`Colors.amber[50]`) 或绿色 (Perfect)。
  - **AI**: 白色。下方包含操作栏:
    - **Analyze**: 调用 `/chat/analyze` 获取语法详情。
    - **Speak**: 调用 `/tts/generate` 播放 AI 回复的语音 ✅ Implemented
    - **Shadow**: 录音并评分跟随练习。
    - **Save**: 保存笔记/生词。

## 功能：反馈系统 (Feedback System)

- **触发**: 用户发送消息后，`/chat/send` 返回的 `review_feedback`。
- **UI**:
  - 气泡边框变色 (Amber/Green)。
  - 显示小图标 (Magic Wand / Star)。
- **交互**: 点击 User 气泡 -> 打开 `AnalysisSheet` 展示详细纠错信息及语法分析。

## 功能：交互式 TTS 与缓存 (Interactive TTS & Caching) ✅ Implemented

### 实现状态

- **AudioService** (`lib/services/audio_service.dart`) ✅
- **ApiService.generateTTS()** (`lib/services/api_service.dart`) ✅
- **ChatBubble Speaker Button** (`lib/widgets/chat_bubble.dart`) ✅
- **ChatScreen TTS Integration** (`lib/screens/chat_screen.dart`) ✅

### 核心组件

#### AudioService

```dart
class AudioService {
  // 单例模式
  static final AudioService _instance = AudioService._internal();

  // 主要方法
  Future<bool> playAudio({required String messageId, required String audioUrl});
  Future<bool> isAudioCached(String messageId);
  Future<void> stop();
  Future<void> clearCache();
}
```

#### 用户流程

1. 用户点击 AI 消息气泡上的 "Speak" 按钮
2. `ChatScreen._handleSpeaker()` 被触发
3. 检查本地缓存:
   - **缓存命中**: 直接使用 `AudioService.playAudio()` 播放本地文件
   - **缓存未命中**:
     - 调用 `ApiService.generateTTS()` 获取音频 URL
     - 后端返回 R2 公共 URL
     - `AudioService` 下载并缓存到本地
4. 播放音频
5. 播放完成后自动重置 UI 状态

#### 缓存策略

- **Client-First Caching**: 优先检查本地缓存
- **缓存路径**: `${ApplicationDocumentsDirectory}/audio_cache/${messageId}.mp3`
- **后端 R2 缓存**: 音频同时存储在 Cloudflare R2，跨设备共享

### UI 交互

- **Speak 按钮**: 灰色背景，显示 `volume_up` 图标
- **播放中状态**: 蓝色背景，显示 `stop` 图标和 "Stop" 文字
- **点击行为**:
  - 未播放时: 开始播放
  - 播放中时: 停止播放

### 依赖

```yaml
# pubspec.yaml
dependencies:
  just_audio: ^0.9.40
```

### 环境变量

后端需要配置以下环境变量 (详见 `backend-cloudflare/guide/tts.md`):

- `MINIMAX_API_KEY`: MiniMax TTS API 密钥
- `MINIMAX_GROUP_ID`: MiniMax 组 ID
- `R2_PUBLIC_DOMAIN`: R2 公共访问域名
