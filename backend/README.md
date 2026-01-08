# TriTalk Backend - Cloudflare Workers

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

### 系统端点

| 端点      | 方法 | 描述              |
| --------- | ---- | ----------------- |
| `/`       | GET  | 健康检查          |
| `/health` | GET  | 健康检查          |
| `/doc`    | GET  | OpenAPI JSON 规范 |
| `/ui`     | GET  | Swagger UI        |

## 本地开发

### 1. 安装依赖

```bash
cd backend
npm install
```

### 2. 配置环境变量

```bash
cp .dev.vars.example .dev.vars
```

编辑 `.dev.vars` 文件，填入你的 OpenRouter API Key：

```
OPENROUTER_API_KEY=your_actual_api_key_here
OPENROUTER_MODEL=google/gemini-2.0-flash-exp:free
```

### 3. 本地运行

```bash
npm run dev
```

服务将在 `http://localhost:8787` 启动。

### 4. 测试 API

```bash
# 测试健康检查
curl http://localhost:8787/health

# 测试聊天
curl -X POST http://localhost:8787/chat/send \
  -H "Content-Type: application/json" \
  -d '{
    "message": "I want coffee",
    "scene_context": "You are a barista at a coffee shop"
  }'
```

## 部署到 Cloudflare

### 1. 登录 Cloudflare

```bash
npx wrangler login
```

### 2. 配置生产环境密钥

```bash
# 设置 OpenRouter API Key
npx wrangler secret put OPENROUTER_API_KEY
# 输入你的 API key

# 设置模型（可选，默认使用 wrangler.toml 中的配置）
npx wrangler secret put OPENROUTER_MODEL
# 输入: google/gemini-2.0-flash-exp:free
```

### 3. 部署

```bash
npm run deploy
```

部署成功后，你会得到一个 Workers URL，类似：

```
https://tritalk-backend.your-subdomain.workers.dev
```

### 4. 验证部署

```bash
# 测试生产环境
curl https://tritalk-backend.your-subdomain.workers.dev/health
```

## 更新前端配置

部署成功后，需要更新 Flutter 前端的 API 地址：

编辑 `frontend/lib/services/api_service.dart`：

```dart
class ApiService {
  // 开发环境使用本地地址
  // 生产环境使用 Cloudflare Workers URL
  static const String baseUrl = 'https://tritalk-backend.your-subdomain.workers.dev';

  // ...
}
```

## 查看日志

```bash
npm run tail
```

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
│   │   └── cors.ts        # CORS 工具 (流式响应头)
│   ├── services/
│   │   ├── index.ts       # 服务导出
│   │   ├── openrouter.ts  # OpenRouter API 客户端
│   │   ├── minimax.ts     # MiniMax TTS API 客户端
│   │   ├── supabase.ts    # Supabase 客户端工具
│   │   └── auth.ts        # 认证服务和中间件
│   └── prompts/
│       ├── index.ts       # Prompt 模板导出
│       ├── chat.ts        # 对话相关 prompts
│       ├── analyze.ts     # 分析相关 prompts
│       ├── scene.ts       # 场景生成 prompts
│       ├── transcribe.ts  # 转录相关 prompts
│       └── translate.ts   # 翻译相关 prompts
├── scripts/
│   └── generate-openapi.ts # OpenAPI 规范生成脚本
├── wrangler.toml          # Cloudflare 配置
├── package.json           # 依赖配置
├── tsconfig.json          # TypeScript 配置
├── openapi_backend.md     # OpenAPI 后端指南
├── .dev.vars.example      # 环境变量示例
└── README.md              # 本文档
```

## 费用说明

Cloudflare Workers 免费计划：

- 每天 100,000 次请求
- 10ms CPU 时间/请求
- 完全够用于个人项目和小型应用

如需更多配额，可升级到付费计划（$5/月起）。

## 故障排查

### 本地开发时连接失败

确保 `.dev.vars` 文件存在且包含正确的 API key。

### 部署后 API 返回错误

检查是否正确设置了生产环境密钥：

```bash
npx wrangler secret list
```

### CORS 错误

代码已包含 CORS 头，如果仍有问题，检查前端请求是否正确。

## 相关链接

- [Cloudflare Workers 文档](https://developers.cloudflare.com/workers/)
- [Wrangler CLI 文档](https://developers.cloudflare.com/workers/wrangler/)
- [OpenRouter API 文档](https://openrouter.ai/docs)
