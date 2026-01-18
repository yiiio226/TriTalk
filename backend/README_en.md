**English** | [中文](README.md)

# TriTalk Backend - Cloudflare Workers

> ⚠️ **IMPORTANT TODO: Production Setup**
>
> The Production environment is not yet configured! Before deploying to Production, you must configure the following variables in GitHub Secrets:
>
> - `SUPABASE_PROD_PROJECT_REF` (Prod Project ID)
> - `SUPABASE_PROD_DB_PASSWORD` (Prod Database Password)
>
> See the automated deployment section in [database_migration.md](docs/database_migration.md#cicd-automated-deployment) for details.

TriTalk backend service, deployed on Cloudflare Workers, providing global edge computing capabilities.

## Features

- ✅ Global edge deployment, low latency
- ✅ Management-free serverless architecture
- ✅ Auto-scaling
- ✅ Free tier: 100,000 requests per day

## API Endpoints

### OpenAPI Defined Endpoints

| Endpoint            | Method | Description                     |
| ------------------- | ------ | ------------------------------- |
| `/chat/send`        | POST   | Send text message, get AI reply |
| `/chat/hint`        | POST   | Get conversation hints          |
| `/chat/transcribe`  | POST   | Audio transcription             |
| `/chat/shadow`      | POST   | Shadowing score/evaluation      |
| `/chat/optimize`    | POST   | Optimize user message           |
| `/chat/messages`    | DELETE | Delete messages                 |
| `/scene/generate`   | POST   | Generate new scene              |
| `/scene/polish`     | POST   | Polish scene description        |
| `/common/translate` | POST   | Text translation                |

### Streaming Endpoints (Manually Defined)

| Endpoint            | Method | Description                                    |
| ------------------- | ------ | ---------------------------------------------- |
| `/chat/send-voice`  | POST   | Voice message + Streaming AI reply             |
| `/chat/analyze`     | POST   | Streaming grammar analysis                     |
| `/tts/gcp/generate` | POST   | Streaming TTS (GCP Gemini TTS) ✅              |
| `/tts/word`         | POST   | Word pronunciation (GCP Gemini, non-stream) ✅ |

### Speech Assessment Endpoints (Azure Speech)

| Endpoint         | Method | Description                                    |
| ---------------- | ------ | ---------------------------------------------- |
| `/speech/assess` | POST   | Pronunciation assessment (phoneme-level + prosody) |

> 📝 **Note**: `/speech/assess` endpoint requires Azure Speech API credentials (`AZURE_SPEECH_KEY`, `AZURE_SPEECH_REGION`)

### Shadowing Practice History Endpoints

| Endpoint             | Method | Description                          |
| -------------------- | ------ | ------------------------------------ |
| `/shadowing/save`    | POST   | Save shadowing practice record       |
| `/shadowing/history` | GET    | Query practice history (with filters)|

> 📝 **Shadowing System Keys Explained**:
> 
> The shadowing practice system uses multiple keys and IDs to track and organize practice records:
> 
> - **`target_text`** (required): The target text for shadowing practice. Used to query all practice history for the same sentence.
> - **`source_type`** (required): Practice source type, supports:
>   - `'ai_message'`: AI response message
>   - `'native_expression'`: Native expression (from grammar feedback)
>   - `'reference_answer'`: Reference answer (from grammar feedback)
>   - `'custom'`: Custom text
> - **`source_id`** (optional): Unique identifier of the source object
>   - For AI messages: uses `message.id`
>   - For native expressions/reference answers: uses original `message.id`
>   - Links practice records to specific messages or content
> - **`scene_key`** (optional): Scene identifier (e.g., `'coffee_shop'`), used to filter practice records by scene
> - **`message_id`** (frontend): Used to generate audio filenames, ensuring file uniqueness
> 
> **How it works**:
> 1. Each practice attempt creates a new record (no overwriting)
> 2. Query by `target_text` to get all practice history for the same sentence
> 3. Use `source_id` + `source_type` to trace practice origin
> 4. Use `scene_key` to track learning progress by scene
> 5. Audio files are stored locally only; cloud stores scores and feedback data

### System Endpoints

| Endpoint  | Method | Description       |
| --------- | ------ | ----------------- |
| `/`       | GET    | Health check      |
| `/health` | GET    | Health check      |
| `/doc`    | GET    | OpenAPI JSON Spec |
| `/ui`     | GET    | Swagger UI        |

## 💻 Development & Deployment Guide

For detailed steps on **local development**, **environment configuration**, **API testing**, and **deploying to Cloudflare**, please visit:

👉 **[development_guide.md](docs/development_guide.md)**

---

## 🔄 OpenAPI Workflow

TriTalk uses OpenAPI specification to implement type-safe API contracts between frontend and backend.

> 📖 Detailed docs: [openapi_backend.md](docs/openapi_backend.md)

---

## 🗄️ Database Migration

TriTalk uses **Supabase Migration** to manage database schema changes.

For info on **Creating Migrations**, **Applying them**, **CI/CD Automation**, and **Troubleshooting**, please visit:

👉 **[database_migration.md](docs/database_migration.md)**

---

---

## 🔐 Security

For detailed instructions on API security mechanisms and authentication flows (Supabase Auth), please see:

👉 **[security.md](docs/security.md)**

---

## Project Structure

```
backend/
├── src/
│   ├── server.ts          # Hono OpenAPI Main Server (Route definitions)
│   ├── schemas.ts         # Zod Request/Response validation schemas
│   ├── types.ts           # TypeScript type definitions
│   ├── utils/
│   │   ├── index.ts       # Utility exports
│   │   ├── json.ts        # JSON parsing utils (parseJSON)
│   │   ├── text.ts        # Text processing utils (sanitizeText)
│   │   ├── encoding.ts    # Encoding utils (hexToBase64, arrayBufferToBase64)
│   │   ├── audio.ts       # Audio processing utils (detectAudioFormat)
│   │   ├── streaming.ts   # Streaming response utils
│   │   └── cors.ts        # CORS utils (streaming response headers)
│   ├── services/
│   │   ├── index.ts       # Service exports
│   │   ├── openrouter.ts  # OpenRouter API client
│   │   ├── gcp-tts.ts     # GCP Gemini TTS API client ✅
│   │   ├── azure-speech.ts # Azure Speech pronunciation assessment
│   │   ├── supabase.ts    # Supabase client utils
│   │   ├── auth.ts        # Auth service and middleware
│   │   └── auth/
│   │       └── gcp-auth.ts # GCP Service Account auth
│   └── prompts/
│       ├── index.ts       # Prompt template exports
│       ├── chat.ts        # Chat relevant prompts
│       ├── analyze.ts     # Analysis relevant prompts
│       ├── scene.ts       # Scene generation prompts
│       ├── transcribe.ts  # Transcription relevant prompts
│       └── translate.ts   # Translation relevant prompts
├── supabase/
│   ├── config.toml        # Supabase CLI config
│   └── migrations/        # Database Migration files
├── scripts/
│   └── generate-openapi.ts # OpenAPI spec generation script
├── wrangler.toml          # Cloudflare config
├── package.json           # Dependencies config
├── tsconfig.json          # TypeScript config
├── docs/                  # [New] Documentation folder
│   ├── openapi_backend.md     # OpenAPI Backend Guide
│   ├── development_guide.md   # Development & Deployment Guide
│   ├── database_migration.md  # Database Migration Guide
│   ├── security.md            # Security documentation
│   ├── azure_speech.md        # Azure Speech Assessment Guide
│   └── gcp_tts.md             # GCP Gemini TTS Integration Guide ✅
├── .dev.vars.example      # Environment variables example
└── README.md              # This document
```

## Cost Info

Cloudflare Workers Free Plan:

- 100,000 requests/day
- 10ms CPU time/request
- Sufficient for personal projects and small apps

For more quota, you can upgrade to a paid plan (starting at $5/month).

## Related Links

- [Cloudflare Workers Docs](https://developers.cloudflare.com/workers/)
- [Wrangler CLI Docs](https://developers.cloudflare.com/workers/wrangler/)
- [OpenRouter API Docs](https://openrouter.ai/docs)
- [Supabase Migration Docs](https://supabase.com/docs/guides/cli/local-development#database-migrations)
