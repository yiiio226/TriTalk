# Standard Scenes Migration Plan (Clone Model)

本文档描述将前端硬编码的 `mock_scenes.dart` 迁移至后端数据库的完整技术方案。
**架构决策**：采用 **"纯克隆模式 (Pure Clone Model)"**。标准场景仅作为"种子库"，用户注册时将其完整复制到用户的 `custom_scenarios` 表中。

## 1. 核心架构 (Architecture)

### 1.1 核心概念

- **Single Source of Truth**: 前端不再维护 Mock 数据，**只查询 `custom_scenarios` 一张表**。
- **Clone on Init**: 当新用户注册时，后端自动将标准场景库中的内容 `COPY` 到该用户的 `custom_scenarios` 中。
- **Unified Management**: 排序、删除、编辑、隐藏，全部通过操作 `custom_scenarios` 表完成。
  - **排序**: `ORDER BY updated_at DESC`。置顶 = 更新 `updated_at`。
  - **删除**: `DELETE FROM custom_scenarios`。
  - **编辑**: `UPDATE custom_scenarios`。

### 1.2 数据库 Schema 变更

创建 `standard_scenes` 表，仅用于存储官方模板，**不直接对用户提供查询 API**。

#### A. 种子库 (Standard Templates)

````sql
CREATE TABLE standard_scenes (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,  -- 改为 NOT NULL
  ai_role TEXT NOT NULL,
  user_role TEXT NOT NULL,
  initial_message TEXT NOT NULL,
  goal TEXT NOT NULL,
  emoji TEXT NOT NULL DEFAULT '🎭',  -- 添加 NOT NULL
  category TEXT NOT NULL,
  difficulty TEXT NOT NULL,
  icon_path TEXT,
  color BIGINT NOT NULL,
  target_language TEXT NOT NULL DEFAULT 'en-US',
  sort_order INTEGER NOT NULL DEFAULT 0,  -- 新增：控制初始顺序
  created_at TIMESTAMPTZ DEFAULT NOW()
  -- 移除 is_active（如果不需要）
);

#### B. 用户场景表 (Custom Scenarios)

增强现有的 `custom_scenarios` 表，使其能承载标准场景的所有能力。

```sql
ALTER TABLE custom_scenarios
  ADD COLUMN origin_standard_id UUID,           -- 纯记录，无 FK 约束，允许删除 standard_scenes
  ADD COLUMN source_type TEXT DEFAULT 'custom', -- 'standard' | 'custom'
  ADD COLUMN icon_path TEXT,
  ADD COLUMN color BIGINT DEFAULT 4294967295,   -- Default White
  ADD COLUMN target_language TEXT DEFAULT 'en-US', -- BCP-47 compliant
  ADD COLUMN goal TEXT;                         -- 之前可能缺失
```

**`source_type` 语义：**
- `'standard'` - 从官方模板库克隆而来
- `'custom'` - 用户完全原创

#### C. 自动化触发器 (Triggers)

- **Trigger**: `on_auth_user_created` -> 调用函数 -> 复制 `standard_scenes` 到 `custom_scenarios`。

---

## 2. 实施进度 (Implementation Progress)

### Phase 1: 数据库与迁移 (Database & Migration)

- [ ] **1.1 Schema 升级**
  - 创建 `standard_scenes` 并填入初始种子数据 (13个场景, 使用符合 BCP-47 的语言代码如 `en-US`)。
  - 修改 `custom_scenarios` 表结构（增加字段）。
  - 废弃/删除 `user_scene_order`, `user_hidden_scenes` 表。
- [ ] **1.2 逻辑实现**
  - 编写 `handle_new_user` 函数和 Trigger (新用户自动复制)。
  - 编写一次性迁移脚本 (One-off Migration): 为**现有开发用户**补全数据。

### Phase 2: 后端 API (Backend API)

- [ ] **2.1 API 简化与规范**
  - **无需新增 API Endpoint**。前端直接使用 `SupabaseClient` 查询 `custom_scenarios` 表。
  - **查询逻辑**: 必须包含 `ORDER BY updated_at DESC` 以实现基于最近活跃时间的排序。
  - **数据校验**: 确保返回的 `target_language` 字段符合 [BCP-47](https://tools.ietf.org/html/bcp47) 标准 (如 `en-US`, `ja-JP`, `zh-CN`)。

### Phase 3: 前端改造 (Frontend Refactor)

- [ ] **3.1 移除 Mock 逻辑**
  - 删除 [lib/features/scenes/data/datasources/mock_scenes.dart](cci:7://file:///Users/yibocui/Desktop/tri/TriTalk/frontend/lib/features/scenes/data/datasources/mock_scenes.dart:0:0-0:0)
  - 删除 [SceneService](cci:2://file:///Users/yibocui/Desktop/tri/TriTalk/frontend/lib/features/scenes/data/scene_service.dart:8:0-469:1) 中：
    - `_hiddenScenesKeyBase` 常量和相关逻辑
    - `_orderKeyBase` 常量和 `_sceneOrder` Map
    - [\_applyOrder()](cci:1://file:///Users/yibocui/Desktop/tri/TriTalk/frontend/lib/features/scenes/data/scene_service.dart:392:2-400:3) 方法
    - [\_hideCloudStandard()](cci:1://file:///Users/yibocui/Desktop/tri/TriTalk/frontend/lib/features/scenes/data/scene_service.dart:348:2-360:3) 方法
    - [\_syncOrderToCloud()](cci:1://file:///Users/yibocui/Desktop/tri/TriTalk/frontend/lib/features/scenes/data/scene_service.dart:403:2-419:3) 方法
    - [isCustomScene()](cci:1://file:///Users/yibocui/Desktop/tri/TriTalk/frontend/lib/features/scenes/data/scene_service.dart:300:2-303:3) 方法（新架构下所有场景都在 custom_scenarios）
- [ ] **3.2 统一数据源**
  - [refreshScenes()](cci:1://file:///Users/yibocui/Desktop/tri/TriTalk/frontend/lib/features/scenes/data/scene_service.dart:102:2-193:3) 只查询 `custom_scenarios`，使用 `.order('updated_at', ascending: false)`
  - 删除与 `mockScenes` 合并的代码
  - 删除对 `user_hidden_scenes` 和 `user_scene_order` 的查询

## 3. 常见问答 (FAQ)

**Q: 如果官方更新了标准场景怎么办？**
A: 现有用户的场景**不会**改变（Feature, not bug）。这是用户私有的副本。如果必须强制更新，需运行后台脚本针对 specific `origin_standard_id` 进行 Update。

**Q: 怎么分辨是用户创建的还是官方的？**
A: 检查 `origin_standard_id`。如果为 NULL，则是用户完全原创；如果有值，则是基于官方模板。

**Q: 怎么做"恢复默认"？**
A: 提供一个 "Restock / Reset" 按钮，调用 API 重新从 `standard_scenes` 复制一份该场景给用户。
````
