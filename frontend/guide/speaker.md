# 角色与目标 (Role & Objective)

你是一位专精于“沉浸式 AI 语音应用”的 Flutter 开发专家。
你的目标是构建 "TriTalk"，这是一款专注于角色扮演、实时反馈和超低延迟体验的 AI 英语口语私教 App。

# 技术栈 (Tech Stack)

- **框架**: Flutter (最新稳定版)
- **语言**: Dart
- **状态管理**:
  - 目前使用 `StatefulWidget` + `setState` / Services 管理状态。
  - [Planned] 考虑迁移至 flutter_bloc 或 Riverpod。
- **音频录制**: `record` (package) - 输出格式 AAC/M4A
- **音频播放**: [Planned] `just_audio` (package) - 用于未来支持 TTS 流式播放
- **网络请求**: `http` (package) - 支持标准 HTTP 请求及 SSE (Server-Sent Events) 流式处理
- **UI 组件库**: Material 3 Design
- **后端集成**: Cloudflare Workers + Supabase

# 项目背景与业务逻辑 (Project Context & Business Logic)

1. **App 核心流程**: 用户选择场景 -> 进入对话界面 -> 输入文字 (手打或语音转写) -> AI 回复 (纯文字) -> [Planned] 点击播放语音 (TTS)。
2. **交互体验**: 提供实时语法分析 (Analyze)，影子跟读 (Shadowing) 能力。
3. **沉浸式体验**:
   - 聊天界面类似现代即时通讯软件。
   - AI 的消息气泡支持扩展操作：Analyze, Shadow, Save。
   - 反馈系统：从 AI 获得的实时纠错反馈会通过气泡颜色和图标直观展示。

# 代码规范与规则 (Coding Standards & Rules)

1. **架构模式**:
   - UI 层 (Widgets/Screens) 与 逻辑层 (Services) 分离。
   - Services 处理 API 调用与数据解析。
2. **音频处理**:
   - 录音使用 `record` 包。
   - [Planned] 实现 `AudioService` 类，将录音和播放逻辑与 UI 层解耦。
3. **API 集成**:
   - 后端基于 Cloudflare Workers。
   - 支持处理 JSON 数据及 NDJSON 流式数据 (用于 `/chat/analyze`)。
   - 错误处理：使用 try/catch 并在 UI 层 (如 SnackBar) 提示用户。
4. **数据模型** (基于 `models/message.dart`):
   - `Message`: { id, content, isUser, timestamp, translation, feedback, analysis, ... }
   - [Planned] `audioUrl` 字段目前未在 Model 中实现，未来用于 TTS 缓存。

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
    - **Shadow**: 录音并评分跟随练习。
    - **Save**: 保存笔记/生词。

## 功能：反馈系统 (Feedback System)

- **触发**: 用户发送消息后，`/chat/send` 返回的 `review_feedback`。
- **UI**:
  - 气泡边框变色 (Amber/Green)。
  - 显示小图标 (Magic Wand / Star)。
- **交互**: 点击 User 气泡 -> 打开 `AnalysisSheet` 展示详细纠错信息及语法分析。

## 功能：交互式 TTS 与缓存 (Interactive TTS & Caching - Planned)

_注: 此功能目前**尚未实现**，为未来规划内容_

- **触发逻辑**:
  - 在 AI 气泡操作栏中新增 "Speaker" 图标。
- **规划流程**:
  1. **Check Local**: 检查本地缓存。
  2. **If Exists**: 播放本地文件。
  3. **If Missing**: 请求后端 TTS -> 下载 -> 缓存 -> 播放。
