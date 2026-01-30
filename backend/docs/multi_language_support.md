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

#### B. 移除旧触发器

不再在用户创建时立即生成场景，因为此时我们还不知道用户想学什么。

```sql
DROP TRIGGER IF EXISTS on_auth_user_created_scenes ON auth.users;
DROP FUNCTION IF EXISTS handle_new_user_scenes();
```

#### C. 创建新触发器 (监听 `profiles`)

我们在 `profiles` 表上创建一个新的触发器。当用户的 `target_lang` 被设置或更新时，执行场景实例化逻辑。

- **监听事件**：`AFTER INSERT OR UPDATE OF target_lang` ON `profiles`
- **触发条件**：在函数内部判断，避免 PostgreSQL `WHEN` 子句对 INSERT 操作引用 `OLD` 的语法限制。

```sql
CREATE TRIGGER on_profile_language_updated
  AFTER INSERT OR UPDATE OF target_lang ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION handle_user_scene_generation();
```

### 2.2 函数逻辑升级 (`handle_user_scene_generation`)

该数据库函数将承担核心逻辑：智能筛选与多语言适配。

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
   - 如果 `target_lang` 为空，直接返回（用户未完成 Onboarding）
   - 如果是 UPDATE 且语言未变化，跳过（防止无关更新触发）

2. **场景筛选与降级**：
   - 优先选择 `target_language = NEW.target_lang` 的场景
   - 如果该语言没有任何场景，降级使用 `en-US` 英语场景

3. **内容本地化**：
   - `title`、`description`、`goal` 三个字段支持翻译
   - 优先级：用户母语 → 英语 → 原文

4. **去重处理**：
   - 使用 `ON CONFLICT DO NOTHING` 防止重复生成

### 2.3 前端配合 (Frontend)

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

---

## 3. 实施步骤

### 3.1 Migration 文件清单

为实现上述方案，需要创建以下 Migration 文件：

| 序号 | 文件名                                                   | 目的                           |
| ---- | -------------------------------------------------------- | ------------------------------ |
| 1    | `20260130100000_add_translations_to_standard_scenes.sql` | 添加 `translations` JSONB 字段 |
| 2    | `20260130100001_seed_scene_translations.sql`             | 填充中文/日文/韩文翻译数据     |
| 3    | `20260130100002_migrate_scene_trigger_to_profiles.sql`   | 删除旧触发器，创建新触发器     |

### 3.2 Migration 1: 添加 translations 字段

```sql
-- Migration: Add translations JSONB field to standard_scenes
-- File: 20260130100000_add_translations_to_standard_scenes.sql

ALTER TABLE standard_scenes
  ADD COLUMN IF NOT EXISTS translations JSONB DEFAULT '{}';

COMMENT ON COLUMN standard_scenes.translations IS
  'Localized content for title/description/goal. Structure: {"zh-CN": {"title": "...", "description": "...", "goal": "..."}}';
```

### 3.3 Migration 2: 填充翻译数据

```sql
-- Migration: Seed translations for standard scenes
-- File: 20260130100001_seed_scene_translations.sql

UPDATE standard_scenes SET translations = '{
  "zh-CN": {"title": "点咖啡", "description": "点一杯咖啡", "goal": "点一杯咖啡"},
  "ja-JP": {"title": "コーヒーを注文する", "description": "コーヒーを注文する", "goal": "コーヒーを注文する"}
}'::jsonb WHERE id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';

UPDATE standard_scenes SET translations = '{
  "zh-CN": {"title": "入境检查", "description": "回答问题并通过入境检查", "goal": "回答问题并通过入境检查"},
  "ja-JP": {"title": "入国審査", "description": "質問に答えて入国審査を通過する", "goal": "質問に答えて入国審査を通過する"}
}'::jsonb WHERE id = 'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380a12';

-- ... 其余场景翻译（完整版在实施时补充）
```

### 3.4 Migration 3: 迁移触发器

```sql
-- Migration: Migrate scene generation trigger from auth.users to profiles
-- File: 20260130100002_migrate_scene_trigger_to_profiles.sql

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
