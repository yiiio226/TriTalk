**中文** | [English](README_en.md)

# TriTalk Backend - Cloudflare Workers

> ⚠️ **IMPORTANT TODO: Production Setup**
>
> 目前 Production 环境尚未配置！在部署 Production 之前，必须在 GitHub Secrets 中配置以下变量：
>
> - `SUPABASE_PROD_PROJECT_REF` (Prod 项目 ID)
> - `SUPABASE_PROD_DB_PASSWORD` (Prod 数据库密码)
>
> 详见 [database_migration.md](docs/database_migration.md#自动化部署-cicd) 的自动化部署章节。

TriTalk 后端服务，部署在 Cloudflare Workers 上，提供全球边缘计算能力。

## 功能特性

- ✅ 全球边缘部署，低延迟
- ✅ 无需服务器管理
- ✅ 自动扩展
- ✅ 免费额度：每天 100,000 次请求

## API 端点

### OpenAPI 规范定义的端点

| 端点                | 方法   | 描述                       |
| ------------------- | ------ | -------------------------- |
| `/chat/send`        | POST   | 发送文本消息，获取 AI 回复 |
| `/chat/hint`        | POST   | 获取对话提示建议           |
| `/chat/transcribe`  | POST   | 音频转文字                 |
| `/chat/shadow`      | POST   | 跟读评分                   |
| `/chat/optimize`    | POST   | 优化用户消息               |
| `/chat/messages`    | DELETE | 删除消息                   |
| `/scene/generate`   | POST   | 生成新场景                 |
| `/scene/polish`     | POST   | 润色场景描述               |
| `/common/translate` | POST   | 文本翻译                   |

### 流式端点（手动定义）

| 端点               | 方法 | 描述                    |
| ------------------ | ---- | ----------------------- |
| `/chat/send-voice` | POST | 语音消息 + 流式 AI 回复 |
| `/chat/analyze`    | POST | 流式语法分析            |
| `/tts/generate`    | POST | 流式语音合成            |

### 语音评估端点 (Azure Speech)

| 端点             | 方法 | 描述                             |
| ---------------- | ---- | -------------------------------- |
| `/speech/assess` | POST | 发音评估 (音素级分析 + 语调评估) |

> 📝 **注意**: `/speech/assess` 端点需要配置 Azure Speech API 凭证 (`AZURE_SPEECH_KEY`, `AZURE_SPEECH_REGION`)

### 系统端点

| 端点      | 方法 | 描述              |
| --------- | ---- | ----------------- |
| `/`       | GET  | 健康检查          |
| `/health` | GET  | 健康检查          |
| `/doc`    | GET  | OpenAPI JSON 规范 |
| `/ui`     | GET  | Swagger UI        |

## 💻 开发与部署指南

关于 **本地开发**、**环境变量配置**、**API 测试** 以及 **Deploy 到 Cloudflare** 的详细步骤，请移步至：

👉 **[development_guide.md](docs/development_guide.md)**

---

## 🔄 OpenAPI 工作流程

TriTalk 使用 OpenAPI 规范实现前后端类型安全的 API 契约。

> 📖 详细文档：[openapi_backend.md](docs/openapi_backend.md)

---

## 🗄️ 数据库 Migration

TriTalk 使用 **Supabase Migration** 管理数据库 schema 变更。

关于 **Migration 创建**、**应用**、**CI/CD 自动化** 以及 **故障排查**，请移步至：

👉 **[database_migration.md](docs/database_migration.md)**

---

---

## 🔐 安全 (Security)

关于 API 安全机制、认证流程 (Supabase Auth) 的详细说明，请见：

👉 **[security.md](docs/security.md)**

---

## 项目结构

```
backend/
├── src/
│   ├── server.ts          # Hono OpenAPI 主服务（路由定义）
│   ├── schemas.ts         # Zod 请求/响应验证模式
│   ├── types.ts           # TypeScript 类型定义
│   ├── utils/
│   │   ├── index.ts       # 工具函数导出
│   │   ├── json.ts        # JSON 解析工具 (parseJSON)
│   │   ├── text.ts        # 文本处理工具 (sanitizeText)
│   │   ├── encoding.ts    # 编码工具 (hexToBase64, arrayBufferToBase64)
│   │   ├── audio.ts       # 音频处理工具 (detectAudioFormat)
│   │   ├── streaming.ts   # 流式响应工具
│   │   ├── cors.ts        # CORS 工具 (流式响应头)
│   ├── services/
│   │   ├── index.ts       # 服务导出
│   │   ├── openrouter.ts  # OpenRouter API 客户端
│   │   ├── minimax.ts     # MiniMax TTS API 客户端
│   │   ├── gcp-tts.ts     # GCP Text-to-Speech API 客户端
│   │   ├── azure-speech.ts # Azure Speech 发音评估 API 客户端
│   │   ├── supabase.ts    # Supabase 客户端工具
│   │   └── auth.ts        # 认证服务和中间件
│   └── prompts/
│       ├── index.ts       # Prompt 模板导出
│       ├── chat.ts        # 对话相关 prompts
│       ├── analyze.ts     # 分析相关 prompts
│       ├── scene.ts       # 场景生成 prompts
│       ├── transcribe.ts  # 转录相关 prompts
│       └── translate.ts   # 翻译相关 prompts
├── supabase/
│   ├── config.toml        # Supabase CLI 配置
│   └── migrations/        # 数据库 Migration 文件
├── scripts/
│   └── generate-openapi.ts # OpenAPI 规范生成脚本
├── wrangler.toml          # Cloudflare 配置
├── package.json           # 依赖配置
├── tsconfig.json          # TypeScript 配置
├── docs/                  # [新] 文档文件夹
│   ├── openapi_backend.md     # OpenAPI 后端指南
│   ├── development_guide.md   # 开发与部署指南
│   ├── database_migration.md  # 数据库迁移指南
│   └── security.md            # 安全文档
├── .dev.vars.example      # 环境变量示例
└── README.md              # 本文档
```

## 费用说明

Cloudflare Workers 免费计划：

- 每天 100,000 次请求
- 10ms CPU 时间/请求
- 完全够用于个人项目和小型应用

如需更多配额，可升级到付费计划（$5/月起）。

## 相关链接

- [Cloudflare Workers 文档](https://developers.cloudflare.com/workers/)
- [Wrangler CLI 文档](https://developers.cloudflare.com/workers/wrangler/)
- [OpenRouter API 文档](https://openrouter.ai/docs)
- [Supabase Migration 文档](https://supabase.com/docs/guides/cli/local-development#database-migrations)
