这是一个为您生成的、针对本项目 (`backend/src/index.ts`) 的 Hono 迁移终极指南。
这个文档本身就是为了让你复制给 AI (Cursor Composer) 用的。

# Hono 迁移计划 & AI 指令

**目标**：将当前的 Cloudflare Worker (原生 fetch 模式, 1700+行) 迁移到 Hono 框架，以获得更好的路由管理、中间件支持和代码可维护性。

## 使用步骤

1. **安装依赖** 【已完成】
   在 `backend` 目录下运行终端命令：

   ```bash
   npm install hono
   ```

2. **启动 Cursor Composer** 【已完成】

   - 按 `Cmd + I` (或 `Ctrl + I`) 打开 Composer。
   - 确保 **Context** 包含：`@src/index.ts`, `@src/types.ts`, `@package.json`。

3. **发送指令** 【已完成】
   复制下方的 **[MASTER PROMPT]** 全部内容，粘贴到 Composer 对话框中发送。

   ✅ **迁移已完成！** 已成功将 backend/src/index.ts 从原生 Cloudflare Worker 模式迁移到 Hono 框架。

---

## [MASTER PROMPT] (复制以下内容)

````markdown
# Role

You are a Senior Backend Architect expert in Cloudflare Workers, TypeScript, and the Hono framework.

# Context

We have a legacy Cloudflare Worker currently implemented in a single massive file (`src/index.ts`, ~1700 lines) using the native `export default { fetch }` pattern. We need to refactor this to use the **Hono** framework to improve maintainability, verify middleware usage, and clean up route handling.

# The Mission

Refactor `src/index.ts` to use Hono. You must preserve ALL business logic exactly as is, but change the "wiring" to use Hono's idioms.

# Architecture & Rules

## 1. App Initialization & Global Middleware

- Initialize `const app = new Hono<{ Bindings: Env }>()`.
- **CORS**: Remove the manual `corsHeaders()` helper function usage. Instead, use Hono's built-in `cors()` middleware globally:
  ```typescript
  import { cors } from "hono/cors";
  app.use(
    "/*",
    cors({
      origin: (origin) => {
        // Keep existing logic: allow localhost and specific domains
        return origin;
      },
      allowMethods: ["GET", "POST", "DELETE", "OPTIONS"],
      allowHeaders: ["Content-Type", "Authorization", "X-API-Key"],
      exposeHeaders: ["Content-Length"],
    })
  );
  ```
````

## 2. Authentication Middleware (Critical)

- **Current State**: We manually call `authenticateUser(request, env)` inside specific routes.
- **New State**: Create a Hono middleware `authMiddleware`.
  - Apply it to protected routes (e.g., `/chat/messages`, `/user/sync` logic if applicable).
  - Note: Some routes like `/health` or logic inside existing handlers might process auth optionally. If a route currently returns 401 on missing auth, apply the strict middleware. If it just checks user but carries on (mock usage), keep logic inside the handler or use a "soft auth" middleware.
  - **Reference**: See lines ~1602 in current `index.ts` for the global auth check logic. Adapt this into a middleware that sets the user in `c.set('user', user)`.

## 3. Route Migration Strategy

Map the following existing `if (url.pathname === ...)` checks to Hono routes.

| Method | Path                | Notes                                                                                                                          |
| ------ | ------------------- | ------------------------------------------------------------------------------------------------------------------------------ |
| GET    | `/`                 | Root message                                                                                                                   |
| GET    | `/health`           | Health check                                                                                                                   |
| POST   | `/chat/send`        | Main chat logic                                                                                                                |
| POST   | `/chat/transcribe`  | **Multimodal**: Handles generic audio upload                                                                                   |
| POST   | `/chat/send-voice`  | **Multimodal**: Handles audio + text context                                                                                   |
| POST   | `/chat/hint`        |                                                                                                                                |
| POST   | `/chat/analyze`     | **Streaming**: Uses `TransformStream`. Ensure `c.req.json()` is used for body. Return native `Response` or Hono stream helper. |
| POST   | `/chat/shadow`      |                                                                                                                                |
| POST   | `/chat/optimize`    |                                                                                                                                |
| POST   | `/scene/generate`   |                                                                                                                                |
| POST   | `/scene/polish`     |                                                                                                                                |
| POST   | `/common/translate` |                                                                                                                                |
| POST   | `/tts/generate`     | **Streaming**: Uses MiniMax API. Keep streaming logic intact.                                                                  |
| DELETE | `/chat/messages`    | Requires Auth                                                                                                                  |
| POST   | `/user/sync`        |                                                                                                                                |

## 4. Code Transformation Patterns

### A. Context & Env

- Old: `async function handleX(request, env)`
- New: `app.post('/path', async (c) => { const env = c.env; ... })`

### B. Request Parsing

- Old: `await request.json()` / `await request.formData()`
- New: `await c.req.json()` / `await c.req.parseBody()` (Note: Hono's `parseBody` handles FormData, but check if `c.req.formData()` is preferred for native Worker compat). **Stick to `await c.req.formData()` if dealing with file uploads** to be safe with standard Web API usage in Workers.

### C. Response

- Old: `return new Response(JSON.stringify(data), { headers: ... })`
- New: `return c.json(data)` (Hono handles headers automatically).
- **Streaming Responses**: For `/chat/analyze` and `/tts/generate`, you can keep returning `new Response(readableStream, ...)` as Hono supports returning standard Response objects directly.

### D. Error Handling

- Use `c.json({ error: '...' }, 500)` instead of manually constructing responses with headers.

## 5. Execution Steps for You

1.  **Imports**: Add `import { Hono } from 'hono'` and clean up unused imports.
2.  **Helpers**: Keep helpers like `parseJSON`, `callOpenRouter`, `sanitizeText` at the bottom or top, but ensure they don't depend on the old `request` object unless passed explicitly.
3.  **Routes**: logic. Convert each massive handler function (e.g., `handleChatSend`) into a route:
    ```typescript
    app.post("/chat/send", async (c) => {
      // ... copy body of handleChatSend here ...
      // replace `request` with `c.req.raw` if strictly needed, or adopt Hono `c.req` methods
      // replace `env` with `c.env`
    });
    ```
4.  **Refactoring Tip**: It is okay to keep the large functions defined separately (e.g. `async function handleChatSend(c: Context)`) and just bind them: `app.post('/chat/send', handleChatSend)`. This keeps `index.ts` cleaner during the migration. **Do this approach for minimal risk.**

# Final Output Requirement

Produce the complete, runnable `src/index.ts` file content.

```

```
