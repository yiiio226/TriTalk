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

## 🔐 Security Note

- **Database**: The frontend talks **directly** to Supabase. Security is handled via **RLS Policies** defined in `database/V0000002_core_data_schema.sql`.
- **AI Keys**: LLM API keys are stored in Cloudflare `secrets` and are never exposed to the frontend application.
