# 账号删除功能实施方案 (Delete Account Implementation Plan)

## 1. 目标与概述

在前端设置页面增加“删除账号”功能。当用户确认删除时，系统将：

1.  **后端执行**: 彻底删除 Supabase 认证系统中的用户身份 (`auth.users`)。
2.  **数据清理**: 自动清理数据库中与该用户关联的所有业务数据（利用数据库外键的 `ON DELETE CASCADE` 机制）。
3.  **前端动作**: 执行登出清理操作，并返回登录页。

---

## 2. 核心架构设计

由于 Supabase 的客户端 SDK (Client Side) 出于安全考虑，默认**不支持**用户直接删除自身账号 (`deleteUser` 需要 Admin 权限)。因此，必须采用 **后端 API 驱动** 的模式。

### 交互流程

1.  **前端 (Client)**: 弹出红色警示框确认，用户确认后发送 DELETE 请求到后端。
2.  **后端 (Backend)**: 接收请求 -> 验证 Token -> 获取 User ID。
3.  **后端 (Admin)**: 使用 `Service Role Key` 初始化 Supabase Admin 客户端，调用 `auth.admin.deleteUser(userId)`。
4.  **数据库 (Postgres)**: 触发 `ON DELETE CASCADE`，自动级联删除引用该 User ID 的所有行（Profile, Chat History, Scenarios 等）。

---

## 3. 详细实施步骤

### 3.1 数据库层面 (Database)

**状态**: ✅ 无需修改
已确认核心业务表均配置了级联删除 (`ON DELETE CASCADE`)，包括但不限于：

- `profiles` (用户信息)
- `chat_history` (聊天记录)
- `custom_scenarios` (自定义场景)
- `vocabulary` (生词本)
- `bookmarked_conversations` (收藏对话)
- `user_scene_order` (场景排序)
- `user_subscriptions` (订阅记录)

### 3.2 后端开发 (Backend)

**目标文件**: `backend/src/server.ts`

**新增接口**:

- **Method**: `DELETE`
- **Path**: `/common/account` (或 `/user/account`)
- **Middleware**: `authMiddleware` (必须验证用户身份)

**伪代码逻辑**:

```typescript
app.delete("/common/account", authMiddleware, async (c) => {
  const user = c.get("user");
  const env = c.env;

  // 1. 初始化 Admin Client
  const supabaseAdmin = createSupabaseAdminClient(env);

  // 2. 删除用户 (这也将触发数据库级联删除)
  const { error } = await supabaseAdmin.auth.admin.deleteUser(user.id);

  if (error) {
    throw error;
  }

  return c.json({ success: true, message: "Account deleted" });
});
```

### 3.3 前端开发 (Frontend)

#### A. 服务层 (`UserService`)

**目标文件**: `frontend/lib/features/profile/data/services/user_service.dart`

**新增方法**:

```dart
Future<void> deleteAccount() async {
  // 调用后端 API: DELETE /common/account
  final response = await http.delete(
    Uri.parse('${Env.apiBaseUrl}/common/account'),
    headers: _authService.getAuthHeaders(),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to delete account');
  }
}
```

#### B. 界面交互 (`ProfileScreen`)

**目标文件**: `frontend/lib/features/profile/presentation/pages/profile_screen.dart`

**UI 变更**:
在 "Log Out" 按钮下方添加 "Delete Account" 按钮。

**交互逻辑**:

1.  点击 "Delete Account"。
2.  弹出 `AlertDialog`:
    - **Title**: "Delete Account?"
    - **Content**: "This action is permanent and cannot be undone. All your data including chat history and custom scenes will be lost."
    - **Actions**: Cancel / **Delete (Red)**
3.  确认后的处理:
    - 显示全屏 Loading 或具体的 HUD。
    - 调用 `await _userService.deleteAccount()`。
    - 成功后，调用 `ref.read(authProvider.notifier).logout()` 清除本地状态。
    - 导航至 `SplashScreen`。

---

## 4. 注意事项与风险提示

1.  **订阅 (Subscriptions)**:
    - 删除 App 账号**不会**取消 Apple App Store 或 Google Play 的自动续费订阅。
    - **必须**在 UI 上提示用户："Deleting your account does not cancel your subscription. Please manage your subscriptions in the App Store/Play Store settings."

2.  **存储 (Storage)**:
    - 如果用户有上传头像到 R2 或 Supabase Storage，当前的数据库级联删除不会自动删除物理文件。
    - **决策**: 鉴于头像文件较小，暂时不处理。未来可通过 Supabase Edge Function 监听 `auth.users` 删除事件来清理文件。

3.  **RevenueCat**:
    - RevenueCat 侧的 Customer Info 将保留，但会因为 App User ID 失效而变成匿名/孤立数据。不影响新用户注册。
