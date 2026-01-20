# Standard Scenes Data Migration Plan

本文档描述将前端硬编码的 `mock_scenes.dart` 迁移至后端数据库的完整技术方案与实施计划。

## 1. 背景与目标 (Background & Objectives)

**现状**：目前所有标准场景数据（如 Cafe, Immigration, Taxi）都硬编码在前端 `mock_scenes.dart` 中。
**问题**：扩展性差（新增场景需发版）、多语言支持困难、无法进行 A/B 测试。
**目标**：

1.  **后端化**：建立 `standard_scenes` 数据库表存储场景数据。
2.  **动态化**：前端通过 API 获取场景，支持热更新。
3.  **兼容性**：保留本地 Mock 数据作为离线/网络错误时的 Fallback。
4.  **多语言**：支持根据用户学习目标语言（Target Language）获取对应场景。

---

## 2. 架构设计 (Architecture Design)

### 2.1 数据库 Schema (Supabase)

新建 `standard_scenes` 表，存储官方提供的标准场景。

```sql
-- migration: create_standard_scenes.sql

CREATE TABLE standard_scenes (
  id TEXT PRIMARY KEY,           -- 保持与前端兼容的 ID (如 's1', 'coffee_order')

  -- 核心内容
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  ai_role TEXT NOT NULL,
  user_role TEXT NOT NULL,
  initial_message TEXT NOT NULL,
  goal TEXT NOT NULL,

  -- 元数据
  emoji TEXT NOT NULL DEFAULT '🎭',
  category TEXT NOT NULL,        -- 'Daily Life', 'Travel', 'Business'
  difficulty TEXT NOT NULL,      -- 'Easy', 'Medium', 'Hard'
  icon_path TEXT,                -- 'assets/images/...' (保留用于兼容旧版或直到图片完全远端化)
  color INTEGER NOT NULL,        -- Hex Color (e.g. 4293914865)

  -- 语言与排序
  target_language TEXT NOT NULL DEFAULT 'English', -- 该场景用于练习的语言
  display_order INTEGER DEFAULT 0,                 -- 排序权重
  is_active BOOLEAN DEFAULT true,                  -- 软删除/上下架控制

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 索引
CREATE INDEX idx_standard_scenes_language ON standard_scenes(target_language);
CREATE INDEX idx_standard_scenes_order ON standard_scenes(display_order);

-- RLS: 公开只读
ALTER TABLE standard_scenes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Standard scenes are publicly readable"
  ON standard_scenes FOR SELECT
  USING (is_active = true);
```

### 2.2 后端 API (Hono)

**Endpoint**: `GET /api/scenes/standard`

**Query Parameters**:

- `target_language`: (Required) 用户学习的目标语言，如 `English`, `Chinese`.

**Response**:

```json
{
  "scenes": [
    {
      "id": "s1",
      "title": "Order Coffee",
      "targetLanguage": "English"
      // ... other fields
    }
  ]
}
```

### 2.3 前端改造 (Flutter)

**`SceneService` 逻辑变更**:

1.  **初始化**: 检查 `SceneCache` 是否有该 `targetLanguage` 的缓存。
2.  **获取**:
    - **优先**: 调用 API `/api/scenes/standard` 获取最新数据并更新缓存。
    - **失败/离线**: 使用本地缓存。
    - **兜底**: 使用代码中的 `fallback_scenes.dart` (原 `mock_scenes.dart`)。
3.  **合并**:
    - Display List = (API/Cache Scenes) + (Custom Scenes) - (Hidden Scenes)
    - 应用 `SceneOrder` 进行排序。

---

## 3. 实施进度 (Implementation Progress)

请在完成每个步骤后勾选 ✅。

### Phase 1: 数据库层 (Database Layer)

- [x] **1.1 创建 Migration 文件**
  - 创建 `standard_scenes` 表结构。
  - 添加 RLS Policies。
- [x] **1.2 数据迁移 (Data Seeding)**
  - 将 `mock_scenes.dart` 中的 13 个场景转换为 SQL 插入语句。
  - 执行 Migration，确保数据库中有初始数据。

### Phase 2: 后端 API 开发 (Backend API)

- [ ] **2.1 新增 API Endpoint**
  - 在 `backend/src/server.ts` (或其他路由文件) 添加 `GET /api/scenes/standard`。
  - 实现根据 `target_language` 过滤查询。
  - 确保 `icon_path` 等字段正确返回。

### Phase 3: 前端数据层改造 (Frontend Data Layer)

- [ ] **3.1 重构 Mock Scenes**
  - 重命名 `mock_scenes.dart` 为 `fallback_scenes.dart`，明确其兜底用途。
- [ ] **3.2 实现 API Client**
  - 在前端添加获取 standard scenes 的 HTTP 请求方法。
- [ ] **3.3 改造 `SceneService`**
  - 实现 `_fetchStandardScenes` 方法 (API -> Cache -> Fallback)。
  - 更新 `refreshScenes` 逻辑，整合远程数据。
- [ ] **3.4 本地缓存 (可选但推荐)**
  - 使用 `SharedPreferences` 或文件缓存 API 响应，减少启动时的网络依赖。

### Phase 4: 测试与清理 (Testing & Cleanup)

- [ ] **4.1 验证测试**
  - 测试正常联网加载（数据来自 DB）。
  - 测试断网加载（数据来自 Fallback）。
  - 测试新增场景（在 DB 插入一条新数据，刷新 App 可见）。
- [ ] **4.2 代码清理**
  - 确保不再有直接依赖 `mockScenes` 列表的硬编码逻辑（除了 Fallback）。

---

## 4. 后续规划 (Future Tasks)

- [ ] **多语言 UI**: 为 Standard Scenes 添加 `standard_scene_translations` 表，支持标题和描述的 UI 本地化（如用中文显示场景卡片，但进入后练习英文）。
- [ ] **版本控制**:通过 ETag 或 version 字段优化通过流量，仅在数据变更时下载。
