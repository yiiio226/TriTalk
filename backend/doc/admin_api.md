# Admin API 文档

本文档描述 TriTalk Admin API 的使用方法，用于管理 `standard_scenes` 表（官方场景模板）。

## 认证方式

Admin API 使用 **API Key** 认证，需要在请求头中添加 `X-Admin-Key`：

```
X-Admin-Key: <your-admin-api-key>
```

**配置方式**：在 Cloudflare Workers 环境变量中设置 `ADMIN_API_KEY`。

## API 端点

### 1. 列出所有标准场景

```http
GET /admin/standard-scenes
X-Admin-Key: <your-admin-api-key>
```

**响应示例**：

```json
{
  "success": true,
  "count": 13,
  "scenes": [
    {
      "id": "a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11",
      "title": "Order Coffee",
      "description": "Order a coffee",
      "ai_role": "Barista",
      "user_role": "Customer",
      "initial_message": "Hi! What can I get for you today?",
      "goal": "Order a coffee",
      "emoji": "☕",
      "category": "Daily Life",
      "difficulty": "Easy",
      "icon_path": "assets/images/scenes/coffee_3d.png",
      "color": 4292932337,
      "target_language": "en-US",
      "created_at": "2026-01-20T00:00:00.000Z"
    }
  ]
}
```

---

### 2. 批量创建场景

```http
POST /admin/standard-scenes
Content-Type: application/json
X-Admin-Key: <your-admin-api-key>

{
  "scenes": [
    {
      "title": "Bank Account",
      "description": "Open a bank account",
      "ai_role": "Bank Clerk",
      "user_role": "Customer",
      "initial_message": "Welcome to XYZ Bank. How can I help you today?",
      "goal": "Successfully open a bank account",
      "emoji": "🏦",
      "category": "Business",
      "difficulty": "Hard",
      "color": 4294703591,
      "target_language": "en-US"
    },
    {
      "title": "Pharmacy Visit",
      "description": "Buy medicine at a pharmacy",
      "ai_role": "Pharmacist",
      "user_role": "Customer",
      "initial_message": "Hello! What can I help you with today?",
      "goal": "Get the right medicine",
      "emoji": "💊",
      "category": "Daily Life",
      "difficulty": "Medium",
      "color": 4292932337,
      "target_language": "en-US"
    }
  ]
}
```

**请求字段说明**：

| 字段              | 类型   | 必填 | 说明                                                  |
| ----------------- | ------ | :--: | ----------------------------------------------------- |
| `id`              | UUID   |  ❌  | 可选，不提供则自动生成                                |
| `title`           | string |  ✅  | 场景标题                                              |
| `description`     | string |  ✅  | 场景描述                                              |
| `ai_role`         | string |  ✅  | AI 扮演的角色                                         |
| `user_role`       | string |  ✅  | 用户扮演的角色                                        |
| `initial_message` | string |  ✅  | AI 的开场白                                           |
| `goal`            | string |  ✅  | 对话目标                                              |
| `emoji`           | string |  ❌  | 场景图标，默认 `🎭`                                   |
| `category`        | string |  ✅  | 分类：Daily Life, Travel, Business, Social, Emergency |
| `difficulty`      | string |  ✅  | 难度：Easy, Medium, Hard                              |
| `icon_path`       | string |  ❌  | 图标路径                                              |
| `color`           | number |  ✅  | 颜色值（Flutter Color int）                           |
| `target_language` | string |  ❌  | BCP-47 语言代码，默认 `en-US`                         |

**响应示例**：

```json
{
  "success": true,
  "created_count": 2,
  "scenes": [
    { "id": "123e4567-e89b-12d3-a456-426614174000", "title": "Bank Account" },
    { "id": "987fcdeb-51a2-3d4e-b678-426614174001", "title": "Pharmacy Visit" }
  ]
}
```

---

### 3. 删除场景

```http
DELETE /admin/standard-scenes/:id
X-Admin-Key: <your-admin-api-key>
```

**响应示例**：

```json
{
  "success": true,
  "deleted_count": 1
}
```

---

## cURL 示例

### 列出场景

```bash
curl -X GET https://your-worker.dev/admin/standard-scenes \
  -H "X-Admin-Key: your-secret-key"
```

### 批量创建场景

```bash
curl -X POST https://your-worker.dev/admin/standard-scenes \
  -H "X-Admin-Key: your-secret-key" \
  -H "Content-Type: application/json" \
  -d '{
    "scenes": [
      {
        "title": "Bank Account",
        "description": "Open a bank account",
        "ai_role": "Bank Clerk",
        "user_role": "Customer",
        "initial_message": "Welcome! How can I assist you today?",
        "goal": "Open a bank account",
        "emoji": "🏦",
        "category": "Business",
        "difficulty": "Hard",
        "color": 4294703591,
        "target_language": "en-US"
      }
    ]
  }'
```

### 删除场景

```bash
curl -X DELETE https://your-worker.dev/admin/standard-scenes/a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11 \
  -H "X-Admin-Key: your-secret-key"
```

---

## 环境变量配置

在 Cloudflare Workers 中配置以下环境变量：

| 变量名                      | 说明                                   |
| --------------------------- | -------------------------------------- |
| `ADMIN_API_KEY`             | Admin API 认证密钥                     |
| `SUPABASE_SERVICE_ROLE_KEY` | Supabase service role 密钥（绕过 RLS） |

**本地开发**（`.dev.vars`）：

```env
ADMIN_API_KEY=your-local-dev-admin-key
SUPABASE_SERVICE_ROLE_KEY=eyJhbGci...
```

**生产环境**（`wrangler secret put`）：

```bash
wrangler secret put ADMIN_API_KEY
wrangler secret put SUPABASE_SERVICE_ROLE_KEY
```

---

## 权限说明

| 操作                   |    普通用户     | Admin API |
| ---------------------- | :-------------: | :-------: |
| 读取 `standard_scenes` | ✅ (RLS SELECT) |    ✅     |
| 创建 `standard_scenes` |       ❌        |    ✅     |
| 修改 `standard_scenes` |       ❌        |    ✅     |
| 删除 `standard_scenes` |       ❌        |    ✅     |

---

## 错误响应

### 403 Forbidden

```json
{ "error": "Forbidden: Invalid or missing admin key" }
```

**原因**：`X-Admin-Key` 缺失或不正确。

### 500 Internal Server Error

```json
{ "error": "SUPABASE_SERVICE_ROLE_KEY is not configured" }
```

**原因**：后端未配置 `SUPABASE_SERVICE_ROLE_KEY` 环境变量。
