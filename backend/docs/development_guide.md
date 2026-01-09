# TriTalk Backend Development Guide

This guide covers setting up the local development environment, running the server, testing, and deploying to Cloudflare.

## 🛠 本地开发 (Local Development)

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

---

## ☁️ 部署到 Cloudflare

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

### 5. 更新前端配置

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

---

## 📜 查看日志

```bash
npm run tail
```

---

## 🔧 故障排查 (Troubleshooting)

### 本地开发时连接失败

确保 `.dev.vars` 文件存在且包含正确的 API key。

### 部署后 API 返回错误

检查是否正确设置了生产环境密钥：

```bash
npx wrangler secret list
```

### CORS 错误

代码已包含 CORS 头，如果仍有问题，检查前端请求是否正确。
