# TriTalk - AI 语言练习伴侣

**中文** | [English](README_en.md)

TriTalk 是一个现代化的、由 AI 驱动的语言学习应用程序，旨在帮助用户通过逼真的角色扮演场景练习对话。

## 🏗 系统架构

本项目遵循 **现代无服务器架构 (Modern Serverless Architecture)**，利用 Flutter 提供丰富的客户端体验，使用 Cloudflare Workers 进行全球低延迟的 AI 处理，并使用 Supabase 作为后端即服务 (BaaS) 解决方案。

```mermaid
graph TD
    User(["用户设备 / Flutter 应用"])

    subgraph "前端层"
        Auth["认证服务 (Google/Apple 登录)"]
        Chat["聊天逻辑 (离线优先同步)"]
    end

    subgraph "边缘逻辑"
        CF["Cloudflare Workers (AI 网关/代理)"]
    end

    subgraph "数据与基础设施"
        DB[("Supabase 数据库 / PostgreSQL")]
        AI["OpenRouter API (Gemini/Claude/GPT)"]
    end

    User --> Auth
    User --> Chat

    %% 数据库交互
    Auth -->|直连 (RLS)| DB
    Chat -->|读/写 历史记录| DB

    %% AI 处理流程
    User -->|HTTPS 请求| CF
    CF -->|提示词工程| AI
    AI -->|生成回复| CF
    CF -->|JSON 响应| User
```

## 📂 项目结构

此单一代码库 (Monorepo) 分为三个不同的组件：

```text
TriTalk/
├── frontend/             # 📱 FLUTTER 应用程序
│   ├── lib/              # 客户端代码、UI、状态管理
│   └── pubspec.yaml      # 依赖项
│
├── backend/              # ⚡️ 边缘函数 (AI 代理)
│   ├── src/              # TypeScript worker 逻辑
│   ├── supabase/         # 🗄️ 数据库迁移
│   │   └── migrations/   # 有序的 SQL 迁移文件
│   └── wrangler.toml     # Cloudflare 部署配置
│
└── scripts/              # 🛠 实用脚本
    └── remove_bg.py      # 图像处理工具
```

## 🛠 技术栈

### 前端 (用户体验)

- **框架**: Flutter (Dart)
- **状态管理**: 具有本地缓存 (`SharedPreferences`) 的离线优先架构。
- **认证**: 通过 Supabase Auth 实现的原生 Google 和 Apple 登录。
- **核心功能**:
  - 实时聊天 UI
  - 支持离线的本地缓存
  - 多设备同步的冲突解决

### 后端 (AI 逻辑)

- **平台**: Cloudflare Workers
- **语言**: TypeScript
- **职责**:
  - 隐藏 API 密钥 (OpenRouter/LLM 密钥从不暴露给客户端)。
  - 提示词工程 (角色扮演、语法分析的系统提示词)。
  - 响应格式化 (JSON 解析、严格的模式强制)。

### 数据库 (存储)

- **平台**: Supabase (PostgreSQL)
- **安全性**: 行级安全 (RLS) 策略，确保用户只能访问自己的数据。
- **管理**: 通过 `backend/supabase/migrations/` 中的 Supabase CLI 管理的 SQL 迁移文件。

## 🚀 快速开始

### 1. 数据库设置

数据库模式通过 **Supabase Migration** 管理。详见 [backend/docs/database_migration.md](backend/docs/database_migration.md) 获取详细说明。

### 2. Backend 设置

详见 [backend/docs/development_guide.md](backend/docs/development_guide.md) 获取设置和部署说明。

### 3. Frontend 设置

详见 [frontend/README.md](frontend/README.md) 获取设置说明。

---

## 🔄 OpenAPI 工作流程

TriTalk 使用 OpenAPI 规范实现前后端类型安全的 API 契约。

- **后端 (生成规范)**: 见 [backend/docs/openapi_backend.md](backend/docs/openapi_backend.md)
- **前端 (同步客户端)**: 见 [frontend/openapi_frontend.md](frontend/openapi_frontend.md)

---

## 🗄️ 数据库 Migration

详细文档请见：[backend/docs/database_migration.md](backend/docs/database_migration.md)

---

## 🔐 安全说明

- **数据库**: 前端 **直接** 与 Supabase 通信。安全性通过迁移文件中定义的 **RLS 策略** 处理。
- **AI 密钥**: LLM API 密钥存储在 Cloudflare `secrets` 中，绝不会暴露给前端应用程序。
