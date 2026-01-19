# GCP Vertex AI TTS 实现指南

## 目标

在 Cloudflare Workers 上使用 **Hono 框架** 实现 Text-to-Speech (TTS) 功能，**仅支持**通过 **Vertex AI** 调用 `gemini-2.5-flash-tts` 模型生成语音。

## 技术约束

1. **运行时**: Cloudflare Workers (Edge Runtime)，**不支持 Node.js 内置模块**（无 `fs`、无 `crypto` 模块、无 `google-auth-library`）
2. **框架**: Hono
3. **认证**: 使用 GCP Service Account，需手动实现 **RS256 JWT 签名**（使用 Web Crypto API `crypto.subtle`）
4. **网络请求**: 仅支持原生 `fetch`
5. **目标 API**: Google Vertex AI REST API (`aiplatform.googleapis.com`)
6. **模型**: `gemini-2.5-flash-preview-tts`

## 音频格式说明

| 属性       | GCP Gemini TTS              |
| ---------- | --------------------------- |
| **格式**   | 原始 16-bit PCM (无 header) |
| **采样率** | 24kHz                       |
| **MIME**   | `audio/L16;rate=24000`      |
| **处理**   | 需添加 WAV 头才能播放       |

## 项目结构（符合现有架构）

```
backend/
├── src/
│   ├── server.ts              # Hono 主服务（已有）
│   ├── types.ts               # TypeScript 类型定义（已有）
│   ├── auth/
│   │   └── gcp-auth.ts        # GCP Service Account 认证
│   ├── services/
│   │   ├── index.ts           # 服务导出
│   │   ├── gcp-tts.ts         # GCP Vertex AI TTS (Gemini) 客户端
│   │   └── ...                # 其他服务
│   └── utils/
│       └── ...                # 工具函数
├── .dev.vars.example          # 环境变量示例
└── wrangler.toml              # Cloudflare 配置（不存储敏感信息）
```

## 环境变量配置

**所有敏感信息通过 Cloudflare Dashboard 设置**，不写入 `wrangler.toml`。

需要在 Cloudflare Dashboard -> Settings -> Variables and Secrets 中添加：

| 变量名                       | 说明                            | 示例值                                   |
| ---------------------------- | ------------------------------- | ---------------------------------------- |
| `GCP_PROJECT_ID`             | GCP 项目 ID                     | `my-project-123`                         |
| `GCP_CLIENT_EMAIL`           | Service Account 邮箱            | `tts-sa@project.iam.gserviceaccount.com` |
| `GCP_PRIVATE_KEY`            | Service Account 私钥 (PEM 格式) | `-----BEGIN PRIVATE KEY-----\n...`       |
| `GCP_REGION`                 | Vertex AI 区域                  | `us-central1`                            |
| `GCP_TTS_DEFAULT_VOICE_NAME` | 默认语音名称（可选）            | `Kore`                                   |

## API 端点

### `POST /tts/gcp/generate` - 流式 TTS

生成语音，流式返回 PCM 音频块。

**请求体：**

```json
{
  "text": "Hello, this is a test.",
  "voice_name": "Kore", // 可选，默认 Kore
  "language_code": "en-US" // 可选，用于自动选择 voice
}
```

**响应格式（NDJSON 流）：**

```json
{"type":"audio_chunk","chunk_index":0,"audio_base64":"...","audio_format":{"mime_type":"audio/L16;rate=24000","sample_rate":24000,"bits_per_sample":16,"num_channels":1}}
{"type":"audio_chunk","chunk_index":1,"audio_base64":"...","audio_format":{...}}
{"type":"info","total_chunks":5,"audio_format":"pcm_24khz_16bit_mono","note":"Use WAV header for playback"}
{"type":"done"}
```

**可用语音：**

| 语音名称 | 特点                         |
| -------- | ---------------------------- |
| Aoede    | Warm, expressive female      |
| Charon   | Deep, authoritative male     |
| Fenrir   | Energetic, dynamic male      |
| Kore     | Clear, natural female (默认) |
| Puck     | Friendly, conversational     |
| Orbit    | Neutral, professional        |

## 实现细节

### 1. 认证模块 (`src/auth/gcp-auth.ts`)

导出函数 `getGCPAccessToken(clientEmail, privateKey, scopes)`：

- 使用 `crypto.subtle.importKey` 导入 PEM 私钥 (PKCS#8 格式)
- 使用 `crypto.subtle.sign` 进行 RS256 签名
- 向 `https://oauth2.googleapis.com/token` 交换 Access Token
- **Scope**: `https://www.googleapis.com/auth/cloud-platform`
- **注意**: 私钥中的 `\n` 可能被转义为 `\\n`，需要还原

### 2. TTS 服务 (`src/services/gcp-tts.ts`)

**导出函数：**

| 函数                     | 说明                         |
| ------------------------ | ---------------------------- |
| `callGCPTTSStreaming`    | 流式 TTS，返回 Response 对象 |
| `callGCPTTS`             | 非流式 TTS，返回 WAV base64  |
| `parseGCPTTSStreamChunk` | 解析流式响应块               |
| `createWavHeader`        | 为 PCM 数据创建 WAV 头       |
| `isGCPTTSConfigured`     | 检查环境变量是否配置         |
| `getGCPTTSConfig`        | 获取配置对象                 |

**流式 Endpoint：**

```
POST https://{REGION}-aiplatform.googleapis.com/v1beta1/projects/{PROJECT_ID}/locations/{REGION}/publishers/google/models/gemini-2.5-flash-preview-tts:streamGenerateContent?alt=sse
```

**非流式 Endpoint：**

```
POST https://{REGION}-aiplatform.googleapis.com/v1beta1/projects/{PROJECT_ID}/locations/{REGION}/publishers/google/models/gemini-2.5-flash-preview-tts:generateContent
```

**Request Body：**

```json
{
  "contents": [
    {
      "role": "user",
      "parts": [
        { "text": "Please speak the following text naturally: Hello World" }
      ]
    }
  ],
  "generationConfig": {
    "responseModalities": ["AUDIO"],
    "speechConfig": {
      "voiceConfig": {
        "prebuiltVoiceConfig": {
          "voiceName": "Kore"
        }
      }
    }
  }
}
```

### 3. 音频处理

由于 Gemini TTS 返回原始 PCM 数据，客户端需要：

1. 收集所有 `audio_base64` 块
2. 解码 Base64 为二进制
3. 拼接所有 PCM 数据
4. 添加 WAV 头（使用 `createWavHeader` 函数）

```typescript
// 示例：将 PCM 转换为 WAV
const wavHeader = createWavHeader(pcmDataLength);
const wavData = new Uint8Array(wavHeader.length + pcmData.length);
wavData.set(wavHeader, 0);
wavData.set(pcmData, wavHeader.length);
```

## 部署提示

### 私钥格式问题

通过 `wrangler secret put GCP_PRIVATE_KEY` 设置私钥时，代码已处理转义：

```typescript
const privateKey = env.GCP_PRIVATE_KEY.replace(/\\n/g, "\n");
```

### IAM 权限

确保 Service Account 拥有以下角色：

- **Vertex AI User** (`roles/aiplatform.user`)

## 💰 成本估算

### ✅ Gemini 2.5 Flash Preview TTS 成本

| 项目   | Free Tier      | Paid Tier          |
| ------ | -------------- | ------------------ |
| Input  | Free of charge | $0.50 / 1M tokens  |
| Output | Free of charge | $10.00 / 1M tokens |

#### Free Tier（当前使用）

| 场景                   | 说明                  | 成本      |
| ---------------------- | --------------------- | --------- |
| Preview 模型           | 免费使用              | **$0**    |
| 1000 DAU / 月          | Free Tier 内          | **$0/月** |
| 备用: $25,000 GCP 额度 | 超出 Free Tier 时使用 | -         |

#### Paid Tier（超出 Free Tier 后预估）

> 💡 **Token 计费规则 (官方)**：
>
> - **Input**: $0.50 / 1M text tokens
> - **Output**: $10.00 / 1M **audio tokens**
> - **换算**: **1 秒音频 = 25 tokens** `(Audio tokens correspond to 25 tokens per second of audio)`
> - **单价**: 约 **$0.015 / 分钟** ($10 / 1M _ 25 _ 60)

以下按**对话/跟读场景**估算：

| 场景                       | 假设参数                          | 计算过程                        | 成本                     |
| -------------------------- | --------------------------------- | ------------------------------- | ------------------------ |
| 单次句子 TTS (约 10 词)    | 语速 ~150 wpm → 约 **4 秒**       | 4s × 25 tokens = **100 tokens** | **$0.001**               |
| 用户每天 50 句 (深度练习)  | 50 句 × 4 秒 = 200 秒 (~3.3 分钟) | 50 × $0.001                     | **$0.05 / 天**           |
| **1000 DAU / 月 (无缓存)** | 1000 人 × 30 天                   | 1000 × 30 × $0.05               | **$1,500/月 (≈¥10,800)** |
| 1000 DAU / 月 (50% 缓存)   | 缓存命中率 50%                    | $1,500 × 50%                    | **$750/月 (≈¥5,400)**    |

> 📉 **结论**：得益于 **25 tokens/sec** 的低消耗率，Gemini TTS 的实际成本非常低（约 $0.90/小时），远低于 Azure/OpenAI 的字符计费模式。
>
> 配合 **$25,000 GCP 赠金**，即使在 10k DAU 规模下也基本能覆盖全额成本。

## 日志标签

调试时可通过以下日志标签过滤：

- `[GCP Auth]` - 认证相关
- `[GCP TTS]` - 非流式 TTS
- `[GCP TTS Streaming]` - 流式 TTS 服务层
- `[GCP TTS Route]` - 路由层
