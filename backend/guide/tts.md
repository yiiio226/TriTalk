# 角色与目标 (Role & Objective)

你是一位专精于 Serverless 架构 (Cloudflare Workers) 的后端开发专家。
你的目标是构建 "TriTalk" 的后端，通过 LLM API 提供沉浸式语言学习体验。
未来的目标（[Planned]）是支持**语音转优化文本**输入，以及**交互式点击触发 TTS**，利用 R2 与本地缓存策略实现高效音频管理。

# 技术栈 (Tech Stack)

- **运行时**: Cloudflare Workers (Node.js/TypeScript 环境)
- **框架**: Serverless Functions (标准 `Request` / `Response` 对象)
- **核心集成**:
  - **LLM (大模型)**: OpenRouter API (调用 Google Gemini 2.0 Flash 等模型) - **当前核心**
  - **STT (语音转文字)**: [Planned] OpenAI Whisper API
  - **TTS (语音合成)**: MiniMax API (模型: `speech-01-turbo`) - **已实现**
  - **存储**: [Planned] Cloudflare R2 (用于存储 TTS 音频)
  - **数据库**: Supabase (PostgreSQL)

# 架构与流程 (Architecture & Pipeline)

目前核心功能为基于 LLM 的文本对话、语法分析、场景生成。

## 1. 智能语音输入 (Smart Voice Input - Helper) [Planned]

_功能：仅作为输入辅助，将用户语音转写并优化为高质量文本，填入输入框供用户发送。_

1. **输入**: 用户录音文件。
2. **转录 (Whisper)**: 调用 OpenAI Whisper API 获取原始文本。
3. **优化 (LLM)**:
   - Prompt 目标: "修正语法错误、去除语气词(如'呃', '嗯')、润色表达，但保持原意"。
   - 输入: 原始 ASR 文本。
4. **输出**: 返回优化后的 JSON 文本 `{ "optimized_text": "..." }`。

## 2. 交互式 TTS (On-demand TTS) [已实现]

_功能：用户点击聊天记录中的 AI 消息气泡的"Listen"按钮时，触发语音播放。_

### 实现架构

**后端 (Cloudflare Workers)**:

- **端点**: `POST /tts/generate`
- **输入**: `{ text: string, message_id?: string, voice_id?: string }`
- **模型**: MiniMax T2A V2 (`speech-01-turbo`)
- **输出**: `{ audio_base64: string, duration_ms?: number }`

**前端 (Flutter)**:

- **服务**: `ApiService.generateTTS()` - 调用后端 TTS API
- **UI**: `ChatBubble._playTextToSpeech()` - 处理播放逻辑
- **缓存**: 音频文件缓存在 `Documents/tts_cache/${message_id}.mp3`

### 流程

1. **触发**: 用户点击 AI 消息气泡上的 "Listen" 按钮
2. **客户端缓存检查**:
   - 检查本地 `tts_cache` 目录是否存在该消息的音频文件
   - **HIT**: 直接播放本地文件
   - **MISS**: 调用后端 API
3. **后端处理**:
   - 调用 MiniMax T2A V2 API 生成音频
   - 返回 Base64 编码的 MP3 音频数据
4. **客户端后处理**:
   - 解码 Base64 音频数据
   - 保存到本地缓存 (`tts_cache/${message_id}.mp3`)
   - 播放音频

### 配置

需要在 Cloudflare Workers 中设置以下环境变量:

```bash
wrangler secret put MINIMAX_API_KEY
wrangler secret put MINIMAX_GROUP_ID
```

## 3. 标准对话流程 (Standard Chat Flow) [Current Implemented]

_纯文本对话，提供实时语法分析与反馈。_

1. **输入**: 用户文本/场景上下文。
2. **LLM**:
   - `/chat/send`: 生成回复并对用户输入进行简要分析。
   - `/chat/analyze`: (Stream) 深度分析用户句子的语法、词汇、句式结构 (NDJSON 格式流式返回)。
   - `/scene/generate`: 根据描述生成角色扮演场景配置。
3. **存储**: 对话历史存储在 Supabase 的 `chat_history` 表中，以 JSONB 格式保存整个会话。
4. **输出**: 返回文本回复、分析数据或场景配置。

# 代码规范 (Coding Standards)

1. **类型安全**: 为所有请求/响应体使用 TypeScript 接口 (Interfaces) 定义 (见 `types.ts`)。
2. **错误处理**: 将所有 API 调用包裹在 try/catch 中。返回标准化的错误 JSON `{ error: string }`。
3. **环境变量**: 必须通过 `Env` 接口访问密钥，严禁硬编码。
   - `OPENROUTER_API_KEY`
   - `OPENROUTER_MODEL`
   - `MINIMAX_API_KEY` - **已实现**
   - `MINIMAX_GROUP_ID` - **已实现**
   - [Planned] `R2_ACCESS_KEY_ID`
4. **API 设计**:
   - 使用 RESTful 风格路由 /chat/send, /chat/analyze 等。
   - 支持 SSE (Server-Sent Events) 流式传输用于长文本生成 (如 analyze)。

# 数据库模式参考 (Database Schema) [Current Implemented]

目前主要使用 `chat_history` 表存储完整会话（以 JSONB 形式），而非单条消息存储。

- **表 `chat_history`**:

  - `id` (uuid)
  - `user_id` (uuid)
  - `scene_key` (text) - 场景标识符
  - `messages` (jsonb) - 存储完整的 `Message[]` 数组，包含 role, content 等
  - `created_at` / `updated_at`

- **表 `custom_scenarios`**:

  - 用户自定义场景配置 (title, ai_role, user_role, goal, etc)

- **表 `vocabulary`**:
  - 用户收藏的生词本
