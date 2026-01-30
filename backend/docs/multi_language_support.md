# 多语言支持方案：Onboarding 流程集成

本文档详细阐述如何将多语言场景实例化逻辑与 APP 的 Onboarding（新手引导）流程深度集成。目标是确保用户点击 "Get Started" 按钮时，系统根据其选择的语言自动生成对应的学习场景。

---

## 1. 核心流程变更

### 1.1 现状 (Old Flow)

- **触发时机**：用户注册账号 (Sign Up) 瞬间。
- **数据来源**：依赖 `auth.users` 的元数据（若注册时未携带语言信息，则默认为英语）。
- **问题**：用户通常在注册完成后的 Onboarding 阶段才选择"母语"和"学习语言"。此时触发器已执行完毕，导致生成了错误的默认场景。

### 1.2 改进方案 (New Flow)

- **触发时机**：用户在 Onboarding 界面完成选择并点击 **"Get Started"** 按钮时。
- **技术实现**：
  - 前端 `onboarding_screen.dart` 调用 `UserService().updateUserProfile()` 更新 `profiles` 表。
  - **后端将触发器从 `auth.users` 迁移至 `profiles` 表**，监听 `target_lang` 字段的变更。

---

## 2. 详细设计方案

### 2.1 数据库层改造 (Database)

#### A. 添加 `translations` JSONB 字段 （已完成）

在 `standard_scenes` 表中添加多语言翻译字段：

```sql
ALTER TABLE standard_scenes ADD COLUMN IF NOT EXISTS translations JSONB DEFAULT '{}';
```

**`translations` 字段结构定义**：

```jsonc
{
  "zh-CN": {
    "title": "点咖啡",
    "description": "在咖啡店点一杯咖啡",
    "goal": "成功点一杯咖啡",
  },
  "ja-JP": {
    "title": "コーヒーを注文する",
    "description": "カフェでコーヒーを注文する",
    "goal": "コーヒーを注文する",
  },
  "ko-KR": {
    "title": "커피 주문하기",
    "description": "카페에서 커피를 주문하세요",
    "goal": "커피를 성공적으로 주문하세요",
  },
  // ... 其他语言
}
```

#### B. 移除旧触发器（已完成）

不再在用户创建时立即生成场景，因为此时我们还不知道用户想学什么。

```sql
DROP TRIGGER IF EXISTS on_auth_user_created_scenes ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user_scenes();
```

#### C. 创建新触发器 (监听 `profiles`)（已完成）

我们在 `profiles` 表上创建一个新的触发器。**仅在 Onboarding 完成时**（首次设置 `target_lang`）执行场景实例化逻辑。

- **监听事件**：`AFTER INSERT OR UPDATE OF target_lang` ON `profiles`
- **触发条件**：函数内部判断用户是否已有场景，**已有场景则跳过**（即 Profile 页面修改语言不会重新生成）

```sql
CREATE TRIGGER on_profile_language_updated
  AFTER INSERT OR UPDATE OF target_lang ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION handle_user_scene_generation();
```

### 2.2 函数逻辑升级 (`handle_user_scene_generation`)（已完成）

该数据库函数将承担核心逻辑：**仅在 Onboarding 时生成场景**，之后的语言修改不会触发重新生成。

#### A. 完整函数实现

```sql
CREATE OR REPLACE FUNCTION handle_user_scene_generation()
RETURNS TRIGGER AS $$
BEGIN
  -- Guard 1: target_lang 必须已设置
  IF NEW.target_lang IS NULL THEN
    RETURN NEW;
  END IF;

  -- Guard 2: UPDATE 时，只有 target_lang 真正变化才继续
  IF TG_OP = 'UPDATE' AND OLD.target_lang IS NOT DISTINCT FROM NEW.target_lang THEN
    RETURN NEW;
  END IF;

  -- Guard 3: 如果用户已有场景，跳过（仅 Onboarding 时生成）
  -- 这确保 Profile 页面修改语言不会重新生成场景
  IF EXISTS (SELECT 1 FROM custom_scenarios WHERE user_id = NEW.id LIMIT 1) THEN
    RETURN NEW;
  END IF;

  -- 插入场景，带降级逻辑和去重
  INSERT INTO custom_scenarios (
    user_id,
    title,
    description,
    ai_role,
    user_role,
    initial_message,
    goal,
    emoji,
    category,
    difficulty,
    icon_path,
    color,
    target_language,
    origin_standard_id,
    source_type,
    updated_at
  )
  SELECT
    NEW.id,
    -- 标题本地化：优先母语翻译 -> 英语翻译 -> 原文
    COALESCE(
      s.translations -> NEW.native_lang ->> 'title',
      s.translations -> 'en-US' ->> 'title',
      s.title
    ),
    -- 描述本地化
    COALESCE(
      s.translations -> NEW.native_lang ->> 'description',
      s.translations -> 'en-US' ->> 'description',
      s.description
    ),
    s.ai_role,
    s.user_role,
    s.initial_message,
    -- 目标本地化
    COALESCE(
      s.translations -> NEW.native_lang ->> 'goal',
      s.translations -> 'en-US' ->> 'goal',
      s.goal
    ),
    s.emoji,
    s.category,
    s.difficulty,
    s.icon_path,
    s.color,
    s.target_language,
    s.id,
    'standard',
    NOW() - (ROW_NUMBER() OVER (ORDER BY s.id) * INTERVAL '1 second')
  FROM standard_scenes s
  WHERE s.target_language = NEW.target_lang
     OR (
       -- 降级逻辑：如果目标语言没有场景，使用英语场景
       NOT EXISTS (SELECT 1 FROM standard_scenes WHERE target_language = NEW.target_lang)
       AND s.target_language = 'en-US'
     )
  ON CONFLICT DO NOTHING;  -- 防止重复插入

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

#### B. 逻辑流程说明

1. **Guard 条件**：
   - Guard 1: 如果 `target_lang` 为空，直接返回（用户未完成 Onboarding）
   - Guard 2: 如果是 UPDATE 且语言未变化，跳过（防止无关更新触发）
   - **Guard 3: 如果用户已有场景，跳过**（确保仅 Onboarding 时生成，Profile 页面修改语言不触发）

2. **场景筛选与降级**：
   - 优先选择 `target_language = NEW.target_lang` 的场景
   - 如果该语言没有任何场景，降级使用 `en-US` 英语场景

3. **内容本地化**：
   - `title`、`description`、`goal` 三个字段支持翻译
   - 优先级：用户母语 → 英语 → 原文

4. **去重处理**：
   - 使用 `ON CONFLICT DO NOTHING` 防止重复生成

### 2.3 前端配合 (Frontend)（已完成 ✅）

#### ⚠️ 重要修复：使用 ISO Code 而非 Label

当前 `onboarding_screen.dart` 中的默认值使用的是 **Label 名称**，需要修改为 **ISO Code**：

```dart
// ❌ 错误 - 使用 Label
String _selectedNativeLang = 'Chinese (Simplified)';
String _selectedTargetLang = 'English';

// ✅ 正确 - 使用 ISO Code
String _selectedNativeLang = 'zh-CN';
String _selectedTargetLang = 'en-US';
```

#### 修复后的完整代码片段

```dart
class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String _selectedGender = 'male';
  String _selectedNativeLang = 'zh-CN';   // ✅ ISO Code
  String _selectedTargetLang = 'en-US';   // ✅ ISO Code

  // ... 其余代码不变
}
```

#### 行为预期

1. 用户点击 "Get Started"
2. 前端调用 `updateUserProfile(nativeLanguage: 'zh-CN', targetLanguage: 'en-US')`
3. Supabase 更新 `profiles` 表中的语言字段
4. **数据库触发器自动捕获此更新**，并在后台从 `standard_scenes` 实例化适合该用户的场景
5. 前端在跳转到主页 (`HomeScreen`) 后，查询场景列表即可看到新生成的个性化数据

#### ⚠️ 时序注意事项：确保场景加载完成（已完成 ✅）

由于数据库触发器是在 `AFTER UPDATE` 时异步执行的，前端需要确保在跳转到 `HomeScreen` 前场景已生成。

**推荐方案：轮询查询确认**（已在 `onboarding_screen.dart` 中实现）

```dart
Future<void> _completeOnboarding() async {
  setState(() => _isSaving = true);

  try {
    // Step 1: 更新用户 Profile，触发数据库触发器
    await UserService().updateUserProfile(
      gender: _selectedGender,
      nativeLanguage: _selectedNativeLang,
      targetLanguage: _selectedTargetLang,
      avatarUrl: avatarPath,
    );

    // Step 2: 轮询等待场景生成完成（最多等待 3 秒）
    await _waitForScenesGenerated();

    // Step 3: 刷新场景缓存
    await SceneService().refreshScenes();

    // Step 4: 导航到首页
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  } catch (e) {
    // 错误处理...
  }
}

/// 轮询查询 custom_scenarios 表，确认场景已生成
Future<void> _waitForScenesGenerated({
  int maxAttempts = 6,
  Duration interval = const Duration(milliseconds: 500),
}) async {
  final supabase = Supabase.instance.client;
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return;

  for (int i = 0; i < maxAttempts; i++) {
    final response = await supabase
        .from('custom_scenarios')
        .select('id')
        .eq('user_id', userId)
        .limit(1);

    if (response.isNotEmpty) {
      debugPrint('✅ Scenes generated after ${(i + 1) * 500}ms');
      return; // 场景已存在，退出轮询
    }

    await Future.delayed(interval);
  }

  debugPrint('⚠️ Scenes not found after max attempts, proceeding anyway');
}
```

**关键点**：

- 使用轮询而非固定延迟，响应更快
- 最多等待 3 秒（6 次 × 500ms）
- 即使超时也继续导航（首页会自动刷新）

---

## 3. 实施步骤

### 3.1 Migration 文件清单（已完成 ✅）

为实现上述方案，已创建以下 Migration 文件：

| 序号 | 文件名                                                   | 目的                                      |
| ---- | -------------------------------------------------------- | ----------------------------------------- |
| 1    | `20260130000025_add_translations_to_standard_scenes.sql` | 添加 `translations` JSONB 字段 + 填充翻译 |
| 2    | `20260130000026_migrate_scene_trigger_to_profiles.sql`   | 删除旧触发器，创建新触发器（含 Guard 3）  |

### 3.2 Migration 1: 添加 translations 字段 + 填充翻译数据（已完成 ✅）

此 migration 文件合并了添加字段和填充数据两个步骤。详见 `20260130000025_add_translations_to_standard_scenes.sql`。

**关键内容摘要**：

```sql
-- 1. 添加 translations 字段
ALTER TABLE standard_scenes
  ADD COLUMN IF NOT EXISTS translations JSONB DEFAULT '{}';

-- 2. 填充所有 13 个标准场景的翻译数据
-- 支持语言: en-GB, zh-CN, ja-JP, ko-KR, es-ES, es-MX, fr-FR, de-DE
UPDATE standard_scenes SET translations = '{
  "zh-CN": {"title": "点咖啡", "description": "在咖啡店点一杯咖啡", "goal": "成功点一杯咖啡"},
  "ja-JP": {"title": "コーヒーを注文する", ...},
  ...
}'::jsonb WHERE id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';

-- ... 其余 12 个场景
```

### 3.3 Migration 2: 迁移触发器（已完成 ✅）

```sql
-- Migration: Migrate scene generation trigger from auth.users to profiles
-- File: 20260130000026_migrate_scene_trigger_to_profiles.sql

-- Step 1: Remove old trigger and function
DROP TRIGGER IF EXISTS on_auth_user_created_scenes ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user_scenes();

-- Step 2: Create new function with localization support
CREATE OR REPLACE FUNCTION handle_user_scene_generation()
RETURNS TRIGGER AS $$
BEGIN
  -- Guard 1: target_lang must be set
  IF NEW.target_lang IS NULL THEN
    RETURN NEW;
  END IF;

  -- Guard 2: On UPDATE, only proceed if target_lang actually changed
  IF TG_OP = 'UPDATE' AND OLD.target_lang IS NOT DISTINCT FROM NEW.target_lang THEN
    RETURN NEW;
  END IF;

  -- Guard 3: If user already has scenes, skip (only generate during Onboarding)
  -- This ensures Profile page language changes do NOT regenerate scenes
  IF EXISTS (SELECT 1 FROM custom_scenarios WHERE user_id = NEW.id LIMIT 1) THEN
    RETURN NEW;
  END IF;

  -- Insert scenes with localization fallback
  INSERT INTO custom_scenarios (
    user_id, title, description, ai_role, user_role, initial_message,
    goal, emoji, category, difficulty, icon_path, color,
    target_language, origin_standard_id, source_type, updated_at
  )
  SELECT
    NEW.id,
    COALESCE(s.translations -> NEW.native_lang ->> 'title', s.translations -> 'en-US' ->> 'title', s.title),
    COALESCE(s.translations -> NEW.native_lang ->> 'description', s.translations -> 'en-US' ->> 'description', s.description),
    s.ai_role, s.user_role, s.initial_message,
    COALESCE(s.translations -> NEW.native_lang ->> 'goal', s.translations -> 'en-US' ->> 'goal', s.goal),
    s.emoji, s.category, s.difficulty, s.icon_path, s.color,
    s.target_language, s.id, 'standard',
    NOW() - (ROW_NUMBER() OVER (ORDER BY s.id) * INTERVAL '1 second')
  FROM standard_scenes s
  WHERE s.target_language = NEW.target_lang
     OR (NOT EXISTS (SELECT 1 FROM standard_scenes WHERE target_language = NEW.target_lang) AND s.target_language = 'en-US')
  ON CONFLICT DO NOTHING;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 3: Create new trigger on profiles table
DROP TRIGGER IF EXISTS on_profile_language_updated ON profiles;
CREATE TRIGGER on_profile_language_updated
  AFTER INSERT OR UPDATE OF target_lang ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION handle_user_scene_generation();
```

---

## 4. 回滚策略

如果新触发器出现问题，可以快速回滚：

```sql
-- Rollback Script: Restore old trigger mechanism
-- Only use in emergency!

-- Step 1: Remove new trigger
DROP TRIGGER IF EXISTS on_profile_language_updated ON profiles;
DROP FUNCTION IF EXISTS handle_user_scene_generation();

-- Step 2: Restore old function
CREATE OR REPLACE FUNCTION handle_new_user_scenes()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO custom_scenarios (
    user_id, title, description, ai_role, user_role, initial_message,
    goal, emoji, category, difficulty, icon_path, color,
    target_language, origin_standard_id, source_type, updated_at
  )
  SELECT
    NEW.id, s.title, s.description, s.ai_role, s.user_role, s.initial_message,
    s.goal, s.emoji, s.category, s.difficulty, s.icon_path, s.color,
    s.target_language, s.id, 'standard',
    NOW() - (ROW_NUMBER() OVER (ORDER BY s.id) * INTERVAL '1 second')
  FROM standard_scenes s;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Step 3: Restore old trigger
CREATE TRIGGER on_auth_user_created_scenes
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user_scenes();
```

---

## 5. 测试用例

| #   | 测试场景                                      | 预期结果                               |
| --- | --------------------------------------------- | -------------------------------------- |
| 1   | 新用户注册 → Onboarding 选 `zh-CN` 学 `en-US` | 生成英语场景，标题显示中文             |
| 2   | 新用户注册 → 跳过 Onboarding（不选语言）      | 不生成任何场景                         |
| 3   | 新用户选择学习 `es-ES`（无西班牙语场景）      | 降级生成英语场景，标题显示用户母语     |
| 4   | 用户多次点击 Get Started                      | 不产生重复场景                         |
| 5   | Profile Update 触发器正常工作                 | 场景在 `custom_scenarios` 表中正确生成 |

---

## 6. 效果预览

当中国用户 (`zh-CN`) 在 Onboarding 选定学习英语 (`en-US`) 并点击 "Get Started"：

1. `profiles` 表更新：`target_lang = 'en-US'`, `native_lang = 'zh-CN'`
2. 触发器 `on_profile_language_updated` 启动
3. 系统找到所有 `target_language = 'en-US'` 的标准场景
4. 系统读取场景的 `translations -> 'zh-CN'` 中文翻译
5. 用户的首页出现卡片："**点咖啡** - 在咖啡店点单" (对话内容为英文)，而不是 "**Order Coffee**"

---

## 7. 场景内容多语言化 (Initial Message)

### 7.1 问题背景

目前的方案中，General Standard Scenes (如 "Order Coffee") 默认是英语内容。即使我们翻译了标题（Metadata），场景的第一条消息 (`initial_message`) 仍然是英语。
如果用户选择学习 "西班牙语"，系统可能会复用 "Order Coffee" 这个英语标准场景作为通用模板，此时 UI 标题虽然根据 `native_lang` 显示为中文，但 AI 发出的第一句话 `initial_message` 仍然是英文 ("Hi! What can I get for you today?")。这对于学习非英语语言的用户来说是不正确的。

### 7.2 解决方案：分离 UI 语言与内容语言

我们需要明确区分 `translations` 字段中数据的用途：

1.  **UI/元数据 (Metadata)**: `title`, `description`, `goal`
    - **用途**: 展示给用户看，解释场景内容
    - **匹配语言**: 用户的 **母语 (Native Language)**
2.  **内容数据 (Content)**: `initial_message`
    - **用途**: 作为对话的开始，AI 说出的第一句话
    - **匹配语言**: 用户的 **学习语言 (Target Language)**

### 7.3 数据结构调整 (`translations`)

`translations` JSON 需扩充，在同一结构中包含不同用途的翻译片段。

**示例 JSON** (Standard Scene: "Order Coffee", ID: ...):

```json
{
  "zh-CN": {
    "title": "点咖啡", // 元数据: 用于 native_lang=zh-CN 的用户
    "description": "在咖啡店点单",
    "goal": "成功点一杯咖啡",
    "initial_message": "你好！今天要喝点什么？" // 内容: 用于 target_lang=zh-CN 的用户
  },
  "es-ES": {
    "title": "Pedir café", // 元数据: 用于 native_lang=es-ES 的用户
    "initial_message": "¡Hola! ¿Qué le pongo hoy?" // 内容: 用于 target_lang=es-ES 的用户
  },
  "fr-FR": {
    "title": "Commander un café",
    "initial_message": "Bonjour ! Que puis-je vous servir ?" // 内容: 用于 target_lang=fr-FR 的用户
  }
}
```

### 7.4 数据库逻辑调整 (`handle_user_scene_generation`)

一定要使用新的 sql migration file, 不能修改之前的 sql 文件。

在生成场景时，字段取值逻辑需要分流。`initial_message` 必须优先匹配 `target_lang`，而其他字段优先匹配 `native_lang`。

````sql
INSERT INTO custom_scenarios (
  ...
  initial_message, -- 内容字段
  title,           -- UI 字段
  ...
)
SELECT
  ...
  -- 1. Content: 使用 target_lang 查找 (AI 说的话)
  -- 场景: 用户学西语(target=es-ES)，母语中文(native=zh-CN)。
  -- 逻辑: 查 es-ES 的 initial_message。如果找不到，回退到标准场景默认值(英文)。
  COALESCE(
    s.translations -> NEW.target_lang ->> 'initial_message',
    s.initial_message -- 降级: 默认英语
  ),

  -- 2. Metadata: 使用 native_lang 查找 (用户看的标题)
  -- 逻辑: 查 zh-CN 的 title。如果找不到，查 en-US，最后回退原文。
  COALESCE(
    s.translations -> NEW.native_lang ->> 'title',
    s.translations -> 'en-US' ->> 'title',
    s.title
  ),
  ...

---

## 8. 架构升级：Pure Translation 模式 (移除冗余列)

为了保持数据源的唯一性 (Single Source of Truth)，我们决定进一步优化：从 `standard_scenes` 表中移除 `title`, `description`, `initial_message`, `goal` 等冗余的文本字段，完全依赖 `translations` JSON 字段。

这意味着 `en-US` (英语) 不再特殊地存储在列中，而是作为 `translations` JSON 中的一个普通语言 Key 存在。

### 8.1 数据库 Schema 变更

`standard_scenes` 表将执行 Schema 清理：

```sql
-- 移除文本列
ALTER TABLE standard_scenes
  DROP COLUMN title,
  DROP COLUMN description,
  DROP COLUMN initial_message,
  DROP COLUMN goal,
  DROP COLUMN ai_role,   -- 角色名也应该本地化，建议一并放入 translations
  DROP COLUMN user_role; -- 同上

-- 确保 translations 非空且包含数据
ALTER TABLE standard_scenes
  ALTER COLUMN translations SET NOT NULL;
````

**新的数据要求**：
`translations` 字段**必须**包含默认语言（通常是 `en-US`）的完整数据，作为所有查找的最终 Fallback。

### 8.2 调整后的生成逻辑 (`handle_user_scene_generation`)

由于列已不存在，所有字段获取都必须指明具体的 JSON 路径，并以 `en-US` 作为兜底。

```sql
INSERT INTO custom_scenarios (
  ...
  initial_message, title, description, goal, ...
)
SELECT
  ...
  -- 1. Initial Message (Content)
  -- 优先取 target_lang (即使是中文场景，若用户学英文，也要英文开场白)
  -- Fallback: en-US
  COALESCE(
    s.translations -> NEW.target_lang ->> 'initial_message',
    s.translations -> 'en-US' ->> 'initial_message'
  ),

  -- 2. Title (Metadata)
  -- 优先取 native_lang (用户能看懂的语言)
  -- Fallback: en-US
  COALESCE(
    s.translations -> NEW.native_lang ->> 'title',
    s.translations -> 'en-US' ->> 'title'
  ),

  -- 3. Description (Metadata)
  COALESCE(
    s.translations -> NEW.native_lang ->> 'description',
    s.translations -> 'en-US' ->> 'description'
  ),

  -- 4. Goal (Metadata)
  COALESCE(
    s.translations -> NEW.native_lang ->> 'goal',
    s.translations -> 'en-US' ->> 'goal'
  ),
  ...
FROM standard_scenes s;
```

### 8.3 方案优势

1.  **消除数据不一致风险**：避免了 `title` 列和 `translations['en-US']['title']` 可能内容不同步的问题。
2.  **逻辑统一**：所有语言（包括英文）都统一从 JSON 获取，代码逻辑更简洁，不需要判断是取列还是取 JSON。
3.  **更灵活的 Schema**：未来如果要增加新的文本字段（如 "Review Prompt"），只需改 JSON 结构，不用改表结构。
