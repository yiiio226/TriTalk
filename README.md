# TriTalk - AI Language Practice Companion

TriTalk is a modern, AI-powered language learning application designed to help users practice conversation through realistic roleplay scenarios.

## 🏗 System Architecture

The project follows a **Modern Serverless Architecture**, leveraging Flutter for a rich client experience, Cloudflare Workers for global low-latency AI processing, and Supabase as a Backend-as-a-Service (BaaS) solution.

```mermaid
graph TD
    User(["User Device<br/>Flutter App"])

    subgraph "Frontend Layer"
        Auth["Auth Service<br/>(Google/Apple Sign-in)"]
        Chat["Chat Logic<br/>(Offline-first Sync)"]
    end

    subgraph "Edge Logic"
        CF["Cloudflare Workers<br/>(AI Gateway / Proxy)"]
    end

    subgraph "Data & Infra"
        DB[("Supabase DB<br/>PostgreSQL")]
        AI["OpenRouter API<br/>(Gemini/Claude/GPT)"]
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

This monorepo is organized into three distinct components:

```text
TriTalk/
├── frontend/             # 📱 FLUTTER APPLICATION
│   ├── lib/              # Client-side code, UI, State Management
│   └── pubspec.yaml      # Dependencies
│
├── backend/              # ⚡️ EDGE FUNCTIONS (AI PROXY)
│   ├── src/              # TypeScript worker logic
│   ├── supabase/         # 🗄️ DATABASE MIGRATIONS
│   │   └── migrations/   # Ordered SQL migration files
│   └── wrangler.toml     # Cloudflare deployment config
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
- **Management**: SQL migration files managed via Supabase CLI in `backend/supabase/migrations/`.

## 🚀 Getting Started

### 1. Database Setup

The database schema is managed via **Supabase Migration**. See [backend/README.md](backend/README.md#-数据库-migration) for detailed instructions.

### 2. Backend Setup

See [backend/README.md](backend/README.md#本地开发) for setup and deployment instructions.

### 3. Frontend Setup

See [frontend/README.md](frontend/README.md) for setup instructions.

---

## 🔄 OpenAPI 工作流程

TriTalk 使用 OpenAPI 规范实现前后端类型安全的 API 契约。

- **后端 (生成规范)**: 见 [backend/README.md](backend/README.md#🔄-openapi-工作流程)
- **前端 (同步客户端)**: 见 [frontend/README.md](frontend/README.md#🔄-openapi-integration)

---

## 🗄️ 数据库 Migration

详细文档请见：[backend/README.md](backend/README.md#-数据库-migration)

---

## 🔐 Security Note

- **Database**: The frontend talks **directly** to Supabase. Security is handled via **RLS Policies** defined in migration files.
- **AI Keys**: LLM API keys are stored in Cloudflare `secrets` and are never exposed to the frontend application.
