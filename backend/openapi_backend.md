# OpenAPI Backend Migration Manual

Status: `[ ] Not Started`

Follow this guide step-by-step to migrate the TriTalk backend to a strictly typed OpenAPI system.
This document is designed to be executable by you (the developer) and context-aware for AI assistants (like Cursor).

---

## Phase 1: Setup

- [ ] **Install Dependencies**
      Run the following commands in the `backend/` directory:
  ```bash
  npm install @hono/zod-openapi zod
  npm install -D tsx
  ```

---

## Phase 2: Code Refactoring (AI Assisted)

- [ ] **Refactor `src/server.ts`**
      Copy the following prompt and send it to your AI assistant (Cursor), keeping `src/server.ts` open.

  ```markdown
  # Role

  You are an expert Backend Engineer specializing in Cloudflare Workers, Hono, and OpenAPI.

  # Task

  Refactor the existing `backend/src/server.ts` to use `@hono/zod-openapi`.

  # Context

  - Current File: `backend/src/server.ts`
  - Existing Imports: We have `services/*`, `prompts/*`, `utils/*`, and `types.ts`. Keep these integrations intact.
  - Global Middleware: We use `cors` and `authMiddleware`.

  # Requirements

  1.  **Switch to OpenAPIHono**:
      Replace `new Hono(...)` with `new OpenAPIHono(...)`.

  2.  **Define Zod Schemas**:

      - Create a new file `src/schemas.ts` (or define in `server.ts` if short) to map our existing interfaces from `src/types.ts` to Zod schemas.
      - Example: `ChatRequest` -> `z.object({ message: z.string(), ... })`.
      - Ensure all Zod schemas use `.openapi({ example: ... })` for documentation.

  3.  **Route Configuration**:

      - For each existing route (`/chat/send`, `/chat/transcribe`, etc.), create a `const routeConfig = createRoute({...})`.
      - Define strictly typed `request.json` (or `request.body.content` for file uploads) and `responses`.

  4.  **Implementation**:

      - Use `app.openapi(routeConfig, async (c) => { ... })`.
      - Inside the handler, utilize `c.req.valid('json')` to get validated data.
      - **Crucial**: Preserve the existing business logic (calling `services`, `prompts`, etc.) inside the new handlers. Do not delete logic, only re-wrap it.

  5.  **Documentation Endpoints**:
      - Add `app.doc('/doc', ...)` for the OpenAPI spec.
      - Add `app.get('/ui', swaggerUI({ url: '/doc' }))` for visualization.

  # Execution Steps

  1. Define the Zod schemas first.
  2. Create the route configs for all endpoints:
     - `/chat/send`
     - `/chat/transcribe` (Note: This is multipart/form-data)
     - `/chat/send-voice` (Note: Multipart + Streaming response)
     - `/chat/hint`
     - `/chat/analyze`
     - `/scene/generate`
     - `/scene/polish`
     - `/common/translate`
     - `/chat/shadow`
     - `/chat/optimize`
     - `/tts/generate`
  3. Rewrite the app initialization and handlers.
  ```

- [ ] **Verify Application**
      Run `npm run dev` and visit `http://localhost:8787/ui`. You should see the Swagger UI.

---

## Phase 3: Spec Generation Script

- [ ] **Create Extraction Script**
      Create `backend/scripts/generate-openapi.ts`:

  ```typescript
  import { writeFileSync } from "fs";
  import app from "../src/server"; // Ensure server.ts exports 'app'

  const doc = app.getOpenAPI31Document({
    openapi: "3.1.0",
    info: {
      version: "1.0.0",
      title: "TriTalk API",
    },
  });

  writeFileSync("swagger.json", JSON.stringify(doc, null, 2));
  console.log("✅ string generated to ./swagger.json");
  ```

- [ ] **Update `package.json`**
      Add string script:

  ```json
  "scripts": {
    "gen:spec": "tsx scripts/generate-openapi.ts"
  }
  ```

- [ ] **Test Generation**
      Run: `npm run gen:spec` -> Check if `swagger.json` is created.

---

## Phase 4: CI/CD Pipeline

- [ ] **Configure GitHub Actions**
      Create/Update `.github/workflows/deploy-spec.yml`:

  ```yaml
  name: Deploy OpenAPI Spec
  on:
    push:
      branches: [main]
      paths: ["backend/src/**", "backend/scripts/**"]

  jobs:
    deploy-spec:
      runs-on: ubuntu-latest
      defaults:
        run:
          working-directory: ./backend
      steps:
        - uses: actions/checkout@v4
        - uses: actions/setup-node@v4
          with:
            node-version: "20"
            cache: "npm"
            cache-dependency-path: backend/package-lock.json

        - run: npm ci
        - run: npm run gen:spec

        - name: Upload to R2
          uses: ryand56/r2-upload-action@v1.2
          with:
            r2-account-id: ${{ secrets.R2_ACCOUNT_ID }}
            r2-access-key-id: ${{ secrets.R2_ACCESS_KEY_ID }}
            r2-secret-access-key: ${{ secrets.R2_SECRET_ACCESS_KEY }}
            r2-bucket: "api-docs"
            source-file: "./backend/swagger.json"
            destination-file: "tritalk/swagger.json"
  ```

## Phase 5: Complete

Mark the task as done when you can successfully access the Swagger UI and the JSON is auto-deployed to R2.

Status: `[ ] Complete`
