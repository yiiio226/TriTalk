# Shadowing Practice Schema & Cache Design

> **Version:** 2.0  
> **Date:** 2026-01-18  
> **Status:** Design Document

## 1. Overview

### 1.1 Goals

- **每个句子/来源只保留最新一条练习记录** — 简化存储，减少 API 调用
- **优先本地缓存** — 点击 Shadow 按钮时立即显示，无网络阻塞
- **支持多入口独立记录** — 同一句子在不同来源（消息/反馈）分别记录

### 1.2 Entry Points

| 入口                               | 文件                  | source_type         |
| ---------------------------------- | --------------------- | ------------------- |
| Chat Bubble - Shadow 按钮          | `chat_bubble.dart`    | `ai_message`        |
| Feedback Sheet - Native Expression | `feedback_sheet.dart` | `native_expression` |
| Feedback Sheet - Reference Answer  | `feedback_sheet.dart` | `reference_answer`  |

---

## 2. Unique Key Design

### 2.1 Problem

同一个 `target_text` (如 "Hello, how are you?") 可能出现在多个地方：

| 入口                               | source_type         | source_id    | 示例                          |
| ---------------------------------- | ------------------- | ------------ | ----------------------------- |
| chat_bubble (Shadow)               | `ai_message`        | `message_id` | 消息 msg_001 的内容           |
| feedback_sheet (Native Expression) | `native_expression` | `message_id` | 消息 msg_001 的反馈中地道表达 |
| feedback_sheet (Reference Answer)  | `reference_answer`  | `message_id` | 消息 msg_001 的反馈中参考答案 |

### 2.2 Solution

使用组合唯一键：

```
唯一标识 = user_id + source_type + source_id
```

**示例：**

| source_type         | source_id | 描述                                     |
| ------------------- | --------- | ---------------------------------------- |
| `ai_message`        | `msg_001` | 用户对 AI 消息 msg_001 的 shadow 练习    |
| `native_expression` | `msg_001` | 用户对 msg_001 的 native expression 练习 |
| `reference_answer`  | `msg_001` | 用户对 msg_001 的 reference answer 练习  |

即使它们的 `target_text` 完全相同，也会分别记录。

---

## 3. Database Schema

### 3.1 Table: `shadowing_latest`

```sql
CREATE TABLE shadowing_latest (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- 唯一键组合
  source_type VARCHAR(50) NOT NULL,  -- 'ai_message', 'native_expression', 'reference_answer'
  source_id VARCHAR(255) NOT NULL,   -- message_id

  -- 实际内容 (记录用于显示，但不参与唯一性判断)
  target_text TEXT NOT NULL,
  scene_key VARCHAR(255),            -- 场景 key (仅记录，不参与唯一性)

  -- 最新练习结果
  pronunciation_score INTEGER NOT NULL,
  accuracy_score DECIMAL(5,2),
  fluency_score DECIMAL(5,2),
  completeness_score DECIMAL(5,2),
  prosody_score DECIMAL(5,2),

  -- 详细反馈
  word_feedback JSONB,
  feedback_text TEXT,
  segments JSONB,

  -- 时间戳
  practiced_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- 唯一约束: 每个用户 + 来源类型 + 来源ID 只有一条记录
  UNIQUE(user_id, source_type, source_id)
);

-- Index for fast lookup
CREATE INDEX idx_shadowing_lookup
  ON shadowing_latest (user_id, source_type, source_id);

-- Row Level Security
ALTER TABLE shadowing_latest ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own practices"
  ON shadowing_latest FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own practices"
  ON shadowing_latest FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own practices"
  ON shadowing_latest FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own practices"
  ON shadowing_latest FOR DELETE
  USING (auth.uid() = user_id);
```

### 3.2 Key Differences from Old Design

| 对比项       | 旧设计 (`shadowing_practices`) | 新设计 (`shadowing_latest`)                           |
| ------------ | ------------------------------ | ----------------------------------------------------- |
| 操作         | `INSERT` (每次新增)            | `UPSERT` (存在则更新)                                 |
| 数据量       | 每次练习一行 (无限增长)        | 每个来源最多一行                                      |
| 唯一键       | 无                             | `user_id + source_type + source_id`                   |
| 查询         | 需要 `ORDER BY + LIMIT 1`      | 直接 `SELECT WHERE source_type = ? AND source_id = ?` |
| `audio_path` | 有 (本地路径)                  | ❌ 移除 (本地路径在云端无意义)                        |

---

## 4. API Design

### 4.1 Save/Update: `PUT /shadowing/upsert`

**Request:**

```typescript
{
  source_type: 'ai_message' | 'native_expression' | 'reference_answer',
  source_id: string,           // message_id
  target_text: string,         // 实际文本内容
  scene_key?: string,
  pronunciation_score: number,
  accuracy_score?: number,
  fluency_score?: number,
  completeness_score?: number,
  prosody_score?: number,
  word_feedback?: object[],
  feedback_text?: string,
  segments?: object[]
}
```

**Response:**

```typescript
{
  success: true,
  data: {
    id: string,
    practiced_at: string
  }
}
```

**Backend Logic:**

```typescript
await supabase.from("shadowing_latest").upsert(
  {
    user_id: user.id,
    source_type: body.source_type,
    source_id: body.source_id,
    target_text: body.target_text,
    // ...其他字段
    updated_at: new Date().toISOString(),
  },
  {
    onConflict: "user_id,source_type,source_id",
  },
);
```

### 4.2 Query: `GET /shadowing/get`

**Request (query params):**

```
?source_type=ai_message&source_id=msg_001
```

**Response:**

```typescript
{
  success: true,
  data: {
    id: string,
    source_type: string,
    source_id: string,
    target_text: string,
    scene_key?: string,
    pronunciation_score: number,
    accuracy_score?: number,
    fluency_score?: number,
    completeness_score?: number,
    prosody_score?: number,
    word_feedback?: object[],
    feedback_text?: string,
    segments?: object[],
    practiced_at: string
  } | null  // null if no record exists
}
```

---

## 5. Backend Implementation Changes

### 5.1 Schema Changes (`src/schemas.ts`)

#### 5.1.1 Changes to Save Schema

**Current (`ShadowingPracticeSaveSchema`):**

```typescript
export const ShadowingPracticeSaveSchema = z.object({
  target_text: z.string(),
  source_type: z.enum([
    "ai_message",
    "native_expression",
    "reference_answer",
    "custom",
  ]),
  source_id: z.string().optional(), // ← 可选
  scene_key: z.string().nullable(),
  pronunciation_score: z.number(),
  accuracy_score: z.number().optional(),
  fluency_score: z.number().optional(),
  completeness_score: z.number().optional(),
  prosody_score: z.number().optional(),
  word_feedback: z.array(WordFeedbackSchema).optional(),
  feedback_text: z.string().optional(),
  audio_path: z.string().optional(), // ← 要移除
  segments: z.array(SmartSegmentSchema).optional(),
});
```

**New (`ShadowingUpsertSchema`):**

```typescript
export const ShadowingUpsertSchema = z.object({
  target_text: z.string(),
  source_type: z.enum(["ai_message", "native_expression", "reference_answer"]), // 移除 "custom"
  source_id: z.string(), // ← 必填 (不再 optional)
  scene_key: z.string().nullable(),
  pronunciation_score: z.number(),
  accuracy_score: z.number().optional(),
  fluency_score: z.number().optional(),
  completeness_score: z.number().optional(),
  prosody_score: z.number().optional(),
  word_feedback: z.array(WordFeedbackSchema).optional(),
  feedback_text: z.string().optional(),
  // audio_path 移除
  segments: z.array(SmartSegmentSchema).optional(),
});
```

#### 5.1.2 New Response Schema for GET

**Current (`ShadowingHistoryResponseSchema`):**

```typescript
export const ShadowingHistoryResponseSchema = z.object({
  success: z.boolean(),
  data: z.object({
    practices: z.array(...),  // ← 返回数组
    total: z.number(),
  }),
});
```

**New (`ShadowingGetResponseSchema`):**

```typescript
export const ShadowingGetResponseSchema = z.object({
  success: z.boolean(),
  data: z
    .object({
      id: z.string(),
      source_type: z.string(),
      source_id: z.string(),
      target_text: z.string(),
      scene_key: z.string().nullable(),
      pronunciation_score: z.number(),
      accuracy_score: z.number().nullable(),
      fluency_score: z.number().nullable(),
      completeness_score: z.number().nullable(),
      prosody_score: z.number().nullable(),
      word_feedback: z.array(WordFeedbackSchema).nullable(),
      feedback_text: z.string().nullable(),
      segments: z.array(SmartSegmentSchema).nullable(),
      practiced_at: z.string(),
    })
    .nullable(), // ← 返回单条或 null
});
```

### 5.2 Route Changes (`src/server.ts`)

#### 5.2.1 Replace `POST /shadowing/save` with `PUT /shadowing/upsert`

**Current Implementation:**

```typescript
// POST /shadowing/save - INSERT new record every time
const shadowingSaveRoute = createRoute({
  method: "post",
  path: "/shadowing/save",
  // ...
});

app.openapi(shadowingSaveRoute, async (c) => {
  const { data, error } = await supabase
    .from("shadowing_practices")
    .insert({
      user_id: user.id,
      // ...fields
    })
    .select("id, practiced_at")
    .single();
});
```

**New Implementation:**

```typescript
// PUT /shadowing/upsert - UPSERT (insert or update)
const shadowingUpsertRoute = createRoute({
  method: "put",
  path: "/shadowing/upsert",
  request: {
    body: {
      content: { "application/json": { schema: ShadowingUpsertSchema } },
    },
  },
  responses: {
    200: {
      content: {
        "application/json": { schema: ShadowingPracticeResponseSchema },
      },
      description: "Practice saved/updated",
    },
    500: {
      content: { "application/json": { schema: ErrorSchema } },
      description: "Error",
    },
  },
});

app.openapi(shadowingUpsertRoute, async (c) => {
  const body = c.req.valid("json");
  const user = c.get("user");
  // ...

  const { data, error } = await supabase
    .from("shadowing_latest")
    .upsert(
      {
        user_id: user.id,
        source_type: body.source_type,
        source_id: body.source_id,
        target_text: body.target_text,
        scene_key: body.scene_key,
        pronunciation_score: body.pronunciation_score,
        accuracy_score: body.accuracy_score,
        fluency_score: body.fluency_score,
        completeness_score: body.completeness_score,
        prosody_score: body.prosody_score,
        word_feedback: body.word_feedback,
        feedback_text: body.feedback_text,
        segments: body.segments,
        updated_at: new Date().toISOString(),
      },
      {
        onConflict: "user_id,source_type,source_id",
      },
    )
    .select("id, practiced_at")
    .single();

  if (error) throw error;
  return c.json({ success: true, data }, 200);
});
```

#### 5.2.2 Replace `GET /shadowing/history` with `GET /shadowing/get`

**Current Implementation:**

```typescript
// GET /shadowing/history - Returns paginated list
const shadowingHistoryRoute = createRoute({
  method: "get",
  path: "/shadowing/history",
  request: {
    query: z.object({
      source_id: z.string().optional(),
      target_text: z.string().optional(),
      scene_key: z.string().optional(),
      limit: z.string().optional(),
      offset: z.string().optional(),
    }),
  },
  // ...
});

app.openapi(shadowingHistoryRoute, async (c) => {
  let query = supabase
    .from("shadowing_practices")
    .select("*", { count: "exact" })
    .eq("user_id", user.id)
    .order("practiced_at", { ascending: false })
    .range(offsetVal, offsetVal + limitVal - 1);

  // ...returns { practices: [...], total: n }
});
```

**New Implementation:**

```typescript
// GET /shadowing/get - Returns single record or null
const shadowingGetRoute = createRoute({
  method: "get",
  path: "/shadowing/get",
  request: {
    query: z.object({
      source_type: z.enum([
        "ai_message",
        "native_expression",
        "reference_answer",
      ]),
      source_id: z.string(),
    }),
  },
  responses: {
    200: {
      content: { "application/json": { schema: ShadowingGetResponseSchema } },
      description: "Practice record or null",
    },
    500: {
      content: { "application/json": { schema: ErrorSchema } },
      description: "Error",
    },
  },
});

app.openapi(shadowingGetRoute, async (c) => {
  const user = c.get("user");
  const { source_type, source_id } = c.req.valid("query");
  // ...

  const { data, error } = await supabase
    .from("shadowing_latest")
    .select("*")
    .eq("user_id", user.id)
    .eq("source_type", source_type)
    .eq("source_id", source_id)
    .maybeSingle(); // Returns single record or null

  if (error) throw error;
  return c.json({ success: true, data }, 200);
});
```

### 5.3 Routes to Remove

| Route                    | Reason                              |
| ------------------------ | ----------------------------------- |
| `POST /shadowing/save`   | Replaced by `PUT /shadowing/upsert` |
| `GET /shadowing/history` | Replaced by `GET /shadowing/get`    |

### 5.4 Database Migration

Create new migration file: `supabase/migrations/xxx_create_shadowing_latest.sql`

```sql
-- Drop old table (no backward compatibility needed)
DROP TABLE IF EXISTS shadowing_practices;

-- Create new table (see Section 3.1 for full SQL)
CREATE TABLE shadowing_latest (...);
```

---

## 6. Frontend Cache Design

### 6.1 Cache Key Format

```dart
// Cache Key = "shadow_v2_{source_type}_{source_id}"
// 不需要 user_id，因为本地缓存天然属于当前用户

class ShadowingCacheKey {
  /// 生成 cache key
  /// - sourceType: 'ai_message' | 'native_expression' | 'reference_answer'
  /// - sourceId: message_id
  static String generate(String sourceType, String sourceId) {
    return 'shadow_v2_${sourceType}_$sourceId';
  }
}
```

**Examples:**

| 场景                                    | Cache Key                             |
| --------------------------------------- | ------------------------------------- |
| 消息 msg_001 的 Shadow 按钮             | `shadow_v2_ai_message_msg_001`        |
| 消息 msg_001 反馈中的 Native Expression | `shadow_v2_native_expression_msg_001` |
| 消息 msg_001 反馈中的 Reference Answer  | `shadow_v2_reference_answer_msg_001`  |

### 6.2 Cache Storage Structure

Using **SharedPreferences** or **Hive**:

```dart
// Key: "shadow_v2_ai_message_msg_001"
// Value (JSON string):
{
  "data": {
    "pronunciation_score": 85,
    "accuracy_score": 90.5,
    "fluency_score": 80.2,
    "completeness_score": 95.0,
    "prosody_score": 78.5,
    "word_feedback": [...],
    "feedback_text": "Great job!",
    "segments": [...]
  },
  "practiced_at": "2026-01-18T17:30:00Z",
  "synced_at": "2026-01-18T17:30:05Z"
}
```

### 6.3 Cache Service Interface

```dart
class ShadowingCacheService {
  /// Get cached practice data
  Future<ShadowingPractice?> get(String sourceType, String sourceId);

  /// Save practice data to cache
  Future<void> set(String sourceType, String sourceId, ShadowingPractice data);

  /// Remove cached data
  Future<void> remove(String sourceType, String sourceId);

  /// Clear all shadow cache
  Future<void> clearAll();
}
```

---

## 7. Frontend Entry Points

### 7.1 chat_bubble.dart (Shadow 按钮)

```dart
ShadowingSheet(
  targetText: message.content,
  messageId: message.id,
  sourceType: 'ai_message',           // ← 固定
  sourceId: message.id,               // ← message.id
  sceneKey: widget.sceneId,
  // ...
)
```

### 7.2 feedback_sheet.dart (Mic 按钮)

**Native Expression:**

```dart
ShadowingSheet(
  targetText: feedback.nativeExpression,
  messageId: widget.message.id,
  sourceType: 'native_expression',    // ← 固定
  sourceId: widget.message.id,        // ← 父消息 id
  sceneKey: widget.sceneId,
  // ...
)
```

**Reference Answer:**

```dart
ShadowingSheet(
  targetText: feedback.exampleAnswer,
  messageId: widget.message.id,
  sourceType: 'reference_answer',     // ← 固定
  sourceId: widget.message.id,        // ← 父消息 id
  sceneKey: widget.sceneId,
  // ...
)
```

---

## 8. Data Flow

### 8.1 Opening ShadowingSheet

```
用户点击 Shadow/Mic 按钮
         │
         ├── 入口1: chat_bubble
         │   sourceType = 'ai_message'
         │   sourceId = message.id
         │
         └── 入口2: feedback_sheet
             sourceType = 'native_expression' 或 'reference_answer'
             sourceId = message.id
         │
         ▼
生成 cacheKey = "shadow_v2_{sourceType}_{sourceId}"
         │
         ▼
检查本地缓存 ShadowingCacheService.get(sourceType, sourceId)
         │
    ┌────┴────┐
    ▼         ▼
  [有缓存]   [无缓存]
    │         │
    ▼         ▼
立即显示    立即显示
历史数据    空白状态
    │         │
    └────┬────┘
         │
         ▼ (可选：后台静默同步)
   GET /shadowing/get?source_type=...&source_id=...
         │
         ▼
   更新本地缓存（如果云端更新）
```

### 8.2 Saving Practice Result

```
┌────────────────────────────────────────────────────────────────┐
│                      用户完成 Shadow 练习                        │
└────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌────────────────────────────────────────────────────────────────┐
│  1. 立即更新本地缓存                                             │
│     ShadowingCacheService.set(sourceType, sourceId, data)       │
│                                                                  │
│  2. 后台异步调用 PUT /shadowing/upsert                           │
│     (不阻塞 UI，失败可重试)                                       │
└────────────────────────────────────────────────────────────────┘
```

---

## 9. Files to Modify

| Layer        | File                                                           | Changes                                                        |
| ------------ | -------------------------------------------------------------- | -------------------------------------------------------------- |
| **DB**       | `supabase/migrations/xxx_create_shadowing_latest.sql`          | Create new table, drop old table                               |
| **Backend**  | `src/schemas.ts`                                               | Add `ShadowingUpsertSchema` + `ShadowingGetResponseSchema`     |
| **Backend**  | `src/server.ts`                                                | Replace routes: `PUT /shadowing/upsert` + `GET /shadowing/get` |
| **Frontend** | `lib/features/study/data/shadowing_cache_service.dart`         | New: local cache service                                       |
| **Frontend** | `lib/features/study/data/shadowing_history_service.dart`       | Update API calls to use new endpoints                          |
| **Frontend** | `lib/features/study/domain/models/shadowing_practice.dart`     | Remove `audioPath` field                                       |
| **Frontend** | `lib/features/chat/presentation/widgets/chat_bubble.dart`      | Use cache-first pattern, pass `sourceType`/`sourceId`          |
| **Frontend** | `lib/features/chat/presentation/widgets/feedback_sheet.dart`   | Use cache-first pattern, pass `sourceType`/`sourceId`          |
| **Frontend** | `lib/features/study/presentation/widgets/shadowing_sheet.dart` | Save to cache on complete, remove `audioPath` from save        |

---

## 10. Migration Notes

- **No backward compatibility** — Old `shadowing_practices` table can be dropped
- **Clean slate** — All users will start fresh with shadowing history
