# TriTalk - AI Language Practice Companion

TriTalk is a modern, AI-powered language learning application designed to help users practice conversation through realistic roleplay scenarios.

## 🏗 System Architecture

The project follows a **Modern Serverless Architecture**, leveraging Flutter for a rich client experience, Cloudflare Workers for global low-latency AI processing, and Supabase as a Backend-as-a-Service (BaaS) solution.

```mermaid
graph TD
    User([User Device<br/>Flutter App])

    subgraph "Frontend Layer"
        Auth[Auth Service<br/>(Google/Apple Sign-in)]
        Chat[Chat Logic<br/>(Offline-first Sync)]
    end

    subgraph "Edge Logic"
        CF[Cloudflare Workers<br/>(AI Gateway / Proxy)]
    end

    subgraph "Data & Infra"
        DB[(Supabase DB<br/>PostgreSQL)]
        AI[OpenRouter API<br/>(Gemini/Claude/GPT)]
    end

    User --> Auth
    User --> Chat

    %% Database Interaction
    Auth -->|Direct Connect (RLS)| DB
    Chat -->|Read/Write History| DB

    %% AI Processing Flow
    User -->|HTTPS Request| CF
    CF -->|Prompt Engineering| AI
    AI -->|Generated Response| CF
    CF -->|JSON Response| User
```

## 📂 Project Structure

This monorepo is organized into four distinct components:

```text
TriTalk/
├── frontend/             # 📱 FLUTTER APPLICATION
│   ├── lib/              # Client-side code, UI, State Management
│   └── pubspec.yaml      # Dependencies
│
├── backend/   # ⚡️ EDGE FUNCTIONS (AI PROXY)
│   ├── src/              # TypeScript worker logic
│   └── wrangler.toml     # Cloudflare deployment config
│
├── database/             # 🗄️ DATABASE MIGRATIONS
│   ├── V0000001_...sql   # Initial schema setup
│   └── V000000X_...sql   # Ordered migration scripts
│
└── scripts/              # 🛠 UTILITY SCRIPTS
    └── remove_bg.py      # Image processing tools
```

## 🛠 Tech Stack

### Frontend (User Experience)

- **Framework**: Flutter (Dart)
- **State Management**: Offline-First architecture with local caching (`SharedPreferences`).
- **Auth**: Native Google & Apple Sign-In via Supabase Auth.
- **Key Features**:
  - Real-time Chat UI
  - Local caching for offline support
  - Conflict resolution for multi-device sync

### Backend (AI Logic)

- **Platform**: Cloudflare Workers
- **Language**: TypeScript
- **Duties**:
  - Hides API Keys (OpenRouter/LLM keys never hit the client).
  - Prompt Engineering (System prompts for roleplay, grammar analysis).
  - Response formatting (JSON parsing, strict schema enforcement).

### Database (Storage)

- **Platform**: Supabase (PostgreSQL)
- **Security**: Row Level Security (RLS) policies ensuring users can only access their own data.
- **Management**: SQL migration files managed in the `database/` directory.

## 🚀 Getting Started

### 1. Database Setup

The database schema is managed via SQL files. To set up a new environment:

1. Go to your Supabase SQL Editor.
2. Execute the scripts in `database/` in sequential order (V1 -> V2 -> ...).

### 2. Backend Setup

```bash
cd backend
npm install
# Local development
npm run dev
# Deploy to global edge
npm run deploy
```

### 3. Frontend Setup

```bash
cd frontend
flutter pub get
# Run with local backend (dev) or production URL
flutter run
```

---

## 🔄 OpenAPI 工作流程

TriTalk 使用 OpenAPI 规范实现前后端类型安全的 API 契约。

### 完整流程图

```
┌─────────────────────────────────────────────────────────────────┐
│                        开发者修改后端 API                          │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  1. 更新 backend/package.json 的 version 字段（如有必要）          │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  2. 推送到 main 分支                                              │
│     GitHub Actions 自动执行:                                      │
│     - npm run gen:spec → 生成 swagger.json                       │
│     - 上传到 R2: tritalk/latest/swagger.json                     │
│     - 上传版本: tritalk/v{version}/swagger.json                  │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  3. 前端开发者同步规范                                             │
│     cd frontend && ./sync-spec.sh                                │
│     (自动下载 + 生成客户端代码)                                     │
└─────────────────────────────────────────────────────────────────┘
                                │
                                ▼
┌─────────────────────────────────────────────────────────────────┐
│  4. 使用生成的类型安全客户端进行开发                                 │
│     ClientProvider.client.chatHintPost(...)                      │
└─────────────────────────────────────────────────────────────────┘
```

### 后端：触发规范生成

```bash
# 本地测试生成
cd backend
npm run gen:spec

# 自动 CI/CD（推送到 main 自动触发）
git push origin main
```

### 前端：同步并生成客户端

```bash
cd frontend

# 拉取最新规范 + 生成代码
./sync-spec.sh

# 拉取指定版本（如锁定 v1.0.0）
./sync-spec.sh 1.0.0
```

> 📖 详细文档：
>
> - 后端：[backend/openapi_backend.md](backend/openapi_backend.md)
> - 前端：[frontend/openapi_frontend.md](frontend/openapi_frontend.md)

---

## 🔐 Security Note

- **Database**: The frontend talks **directly** to Supabase. Security is handled via **RLS Policies** defined in `database/V0000002_core_data_schema.sql`.
- **AI Keys**: LLM API keys are stored in Cloudflare `secrets` and are never exposed to the frontend application.
