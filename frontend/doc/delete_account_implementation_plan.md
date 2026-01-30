# 账号删除功能实施方案 (Delete Account Implementation Plan)

## 1. 目标

在 Profile 界面增加删除账号功能，确保点击后删除后端 User、Supabase Auth User 及所有关联数据。

## 2. 数据库变更 (关键步骤)

目前 `profiles` 表的外键引用缺少 `ON DELETE CASCADE`，这会导致删除 Auth 用户时失败。

**需新建 Migration 文件**: `backend/supabase/migrations/20260130000023_fix_profiles_cascade.sql`

```sql
-- 修改 profiles 表的外键，添加级联删除
--
-- 设计说明：profiles 表不需要 DELETE RLS 策略，原因如下：
-- 1. 账号删除通过 Supabase Auth Admin API 执行，会自动触发 ON DELETE CASCADE
-- 2. 普通用户不应该有直接删除 profiles 记录的权限
-- 3. Admin 操作使用 service_role key 绕过 RLS

ALTER TABLE profiles
DROP CONSTRAINT profiles_id_fkey;

ALTER TABLE profiles
ADD CONSTRAINT profiles_id_fkey
    FOREIGN KEY (id)
    REFERENCES auth.users(id)
    ON DELETE CASCADE;
```

---

## 3. 后端开发 (Backend)

> **规范提示**: 本接口应遵循 [OpenAPI 后端指南](../backend/docs/openapi_backend.md)，使用 zod 定义 Schema 以便自动生成文档。

目标文件: `backend/src/server.ts` 及 `backend/src/schemas.ts`

### 3.1 定义 Schema (`schemas.ts`)

```typescript
// Request: Empty Body (或者包含 reason)
export const DeleteAccountRequestSchema = z.object({});

// Response
export const DeleteAccountResponseSchema = z.object({
  success: z.boolean(),
  message: z.string(),
});
```

### 3.2 实现接口 (`server.ts`)

**新增接口**:

- **Method**: `DELETE`
- **Path**: `/user/account`
- **Auth**: `authMiddleware`

**代码实现**:

```typescript
const deleteAccountRoute = createRoute({
  method: "delete",
  path: "/user/account",
  responses: {
    200: {
      content: { "application/json": { schema: DeleteAccountResponseSchema } },
      description: "Account deleted successfully",
    },
    401: {
      content: { "application/json": { schema: ErrorSchema } },
      description: "Unauthorized - Invalid or expired token",
    },
    404: {
      content: { "application/json": { schema: ErrorSchema } },
      description: "User not found",
    },
    500: {
      content: { "application/json": { schema: ErrorSchema } },
      description: "Server error",
    },
  },
});

app.openapi(deleteAccountRoute, async (c) => {
  const user = c.get("user");
  const env = c.env as Env;

  // 初始化 Admin Client (需确保 Env 中配置了 SUPABASE_SERVICE_ROLE_KEY)
  const supabaseAdmin = createSupabaseAdminClient(env);

  // 删除 Auth 用户 -> 触发 DB 级联删除
  const { error } = await supabaseAdmin.auth.admin.deleteUser(user.id);

  if (error) {
    if (error.message.includes("not found")) {
      return c.json({ error: "User not found" }, 404);
    }
    throw error; // Global error handler will catch this
  }

  return c.json({ success: true, message: "Account permanently deleted" }, 200);
});
```

---

## 4. 前端开发 (Frontend)

> **规范提示**:
>
> 1.  严格遵循 [OpenAPI 前端指南](../frontend/openapi_frontend.md)，如已集成生成器，请使用生成的 Client 调用接口。
> 2.  严格遵循 Design System (使用 `AppColors`, `AppTypography` 等)。
> 3.  **必须使用 i18n**，禁止 Hardcode 字符串。

目标文件: `frontend/lib/features/profile/presentation/pages/profile_screen.dart`

### 4.1 Localization (l10n)

需在 `intl_en.arb` (及其他语言文件) 中添加:

```json
"deleteAccount": "Delete Account",
"deleteAccountConfirmationTitle": "Delete Account?",
"deleteAccountConfirmationContent": "This action is permanent and cannot be undone. All your data will be erased and cannot be recovered.",
"deleteAccountSubscriptionWarning": "Deleting your account does NOT cancel your subscription. Please manage subscriptions in your device settings.",
"deleteAccountTypeConfirm": "Type DELETE to confirm",
"deleteAccountTypeHint": "DELETE",
"deleteAction": "Delete",
"cancelAction": "Cancel",
"deleteAccountLoading": "Deleting account...",
"deleteAccountFailed": "Failed to delete account"
```

### 4.2 UI 修改

在 Profile 界面底部新增 **"Danger Zone"** 分组，将删除账号按钮与其他菜单分开，突出危险操作的视觉警示。

```dart
// 在 Logout 按钮之后，Version Info 之前添加

const SizedBox(height: AppSpacing.xl),

// Danger Zone Section
Text(
  context.l10n.profile_dangerZone, // 需添加 i18n: "Danger Zone"
  style: AppTypography.subtitle1.copyWith(
    fontWeight: FontWeight.bold,
    color: AppColors.error,
  ),
),
const SizedBox(height: AppSpacing.md),

// Delete Account Button
_buildMenuCard(
  context,
  title: context.l10n.deleteAccount,
  icon: Icons.delete_forever_rounded,
  iconColor: AppColors.error,
  onTap: _handleDeleteAccount,
),
```

### 4.3 逻辑实现

```dart
Future<void> _handleDeleteAccount() async {
  // 1. 第一步确认弹窗：显示警告信息（包含订阅提醒）
  final firstConfirm = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.deleteAccountConfirmationTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.l10n.deleteAccountConfirmationContent),
          const SizedBox(height: AppSpacing.md),
          // 订阅警告 (使用 i18n)
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.warning),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    context.l10n.deleteAccountSubscriptionWarning,
                    style: AppTypography.caption.copyWith(color: AppColors.warning),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            context.l10n.cancelAction,
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(
            context.l10n.deleteAction,
            style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  if (firstConfirm != true) return;

  // 2. 第二步确认：要求用户输入 "DELETE" 进行二次确认
  final TextEditingController confirmController = TextEditingController();
  final secondConfirm = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(context.l10n.deleteAccountConfirmationTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.deleteAccountTypeConfirm),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: confirmController,
            decoration: InputDecoration(
              hintText: context.l10n.deleteAccountTypeHint,
              border: const OutlineInputBorder(),
            ),
            autofocus: true,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(context.l10n.cancelAction),
        ),
        TextButton(
          onPressed: () {
            if (confirmController.text.trim().toUpperCase() == 'DELETE') {
              Navigator.pop(dialogContext, true);
            }
          },
          child: Text(
            context.l10n.deleteAction,
            style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );

  if (secondConfirm != true) return;

  try {
    // 3. Show Loading (使用统一的 Loading 组件)
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.xl),
            decoration: BoxDecoration(
              color: AppColors.lightSurface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: AppSpacing.md),
                Text(context.l10n.deleteAccountLoading),
              ],
            ),
          ),
        ),
      ),
    );

    // 4. 先注销 FCM Token (可选，如果失败不阻塞删除流程)
    try {
      await FcmService.instance.deregisterToken();
    } catch (_) {
      // FCM 注销失败不阻塞账号删除
      debugPrint('FCM deregister failed, continuing with account deletion');
    }

    // 5. Call API
    // 推荐方式: 使用生成的 Swagger Client
    // await ClientProvider.client.userAccountDelete();

    // 替代方式 (如果 Client 未生成):
    // await _userService.deleteAccount();

    if (!mounted) return;
    Navigator.pop(context); // Close Loading

    // 6. Local Logout & Navigate
    ref.read(authProvider.notifier).logout();

  } catch (e) {
    if (!mounted) return;
    Navigator.pop(context); // Close Loading on Error

    // 错误处理：不暴露技术细节给用户
    debugPrint('Delete account error: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.deleteAccountFailed),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
```

---

## 5. 风险提示与兜底

1.  **订阅 (Subscriptions)**:
    - 删除账号**不会**取消 App Store / Google Play 的自动续费。
    - **已在 UI 弹窗中通过 i18n 明确告知用户** (`deleteAccountSubscriptionWarning`)。

2.  **性能 (Performance)**:
    - 由于所有关联表 (`chat_history`, `vocabulary` 等) 均已在 `user_id` 上建立了索引，级联删除通常是瞬间完成的。
    - 即便数据量较大，Postgres 的级联删除也比手动分步删除更高效且事务安全。

3.  **文件存储 (Storage)**:
    - 本方案暂不包含 R2/Storage 文件的物理删除。

4.  **FCM Token**:
    - 删除账号前会尝试注销 FCM Token，即使失败也不会阻塞删除流程。
    - `user_fcm_tokens` 表已配置 `ON DELETE CASCADE`，会自动清理。

---

## 6. l10n 完整清单

以下是需要添加到各语言 `.arb` 文件的完整 key 列表：

### `intl_en.arb`

```json
"deleteAccount": "Delete Account",
"deleteAccountConfirmationTitle": "Delete Account?",
"deleteAccountConfirmationContent": "This action is permanent and cannot be undone. All your data will be erased and cannot be recovered.",
"deleteAccountSubscriptionWarning": "Deleting your account does NOT cancel your subscription. Please manage subscriptions in your device settings.",
"deleteAccountTypeConfirm": "Type DELETE to confirm",
"deleteAccountTypeHint": "DELETE",
"deleteAction": "Delete",
"cancelAction": "Cancel",
"deleteAccountLoading": "Deleting account...",
"deleteAccountFailed": "Failed to delete account",
"profile_dangerZone": "Danger Zone"
```

### `intl_zh.arb`

```json
"deleteAccount": "删除账号",
"deleteAccountConfirmationTitle": "确认删除账号？",
"deleteAccountConfirmationContent": "此操作不可撤销。您的所有数据将被永久删除且无法恢复。",
"deleteAccountSubscriptionWarning": "删除账号不会取消您的订阅。请在设备设置中管理订阅。",
"deleteAccountTypeConfirm": "输入 DELETE 以确认",
"deleteAccountTypeHint": "DELETE",
"deleteAction": "删除",
"cancelAction": "取消",
"deleteAccountLoading": "正在删除账号...",
"deleteAccountFailed": "删除账号失败",
"profile_dangerZone": "危险操作"
```
