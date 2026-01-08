# OpenAPI 后端指南

本文档描述 TriTalk 后端如何通过 `@hono/zod-openapi` 实现类型安全的 API，并自动生成 OpenAPI 规范。

---

## 📁 核心文件结构

| 文件                          | 描述                                  |
| ----------------------------- | ------------------------------------- |
| `src/server.ts`               | Hono OpenAPI 主服务，包含所有路由定义 |
| `src/schemas.ts`              | Zod 请求/响应验证模式                 |
| `scripts/generate-openapi.ts` | 规范生成脚本                          |

---

## 🔧 本地开发

```bash
cd backend
npm install
npm run dev
```

验证：

- **Swagger UI**: [http://localhost:8787/ui](http://localhost:8787/ui)
- **JSON Spec**: [http://localhost:8787/doc](http://localhost:8787/doc)

---

## 📤 生成与发布流程

### 本地生成

```bash
npm run gen:spec
# 输出: backend/swagger.json
```

### 自动 CI/CD

当代码推送到 `main` 分支时，GitHub Actions 自动执行：

1. **触发条件**: `backend/src/**` 或 `backend/scripts/**` 文件变更
2. **执行步骤**:
   - 安装依赖 → 生成 `swagger.json`
   - 上传到 R2: `tritalk/latest/swagger.json`
   - 上传版本快照: `tritalk/v{version}/swagger.json`

> 📌 版本号读取自 `backend/package.json` 的 `version` 字段

### 配置文件

- **Workflow**: `.github/workflows/deploy-client.yml`
- **所需 Secrets**:
  - `CLOUDFLARE_API_TOKEN`
  - `CLOUDFLARE_ACCOUNT_ID`

---

## 🔄 版本管理

更新 API 时，请同步更新 `package.json` 中的版本号：

```json
{
  "version": "1.0.1" // 修改此处
}
```

这样 CI 会自动创建对应版本的快照，前端可以锁定特定版本使用。
