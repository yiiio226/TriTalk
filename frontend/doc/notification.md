# Android 通知实现指南 (状态：已完成)

## ✅ 已完成工作总结

我们已经成功完成了所有实现阶段。

- **Firebase 项目**：已创建并连接。
- **配置**：
  - 已执行 `flutterfire configure`。
  - 已生成 `android/app/google-services.json`。
  - 已生成 `lib/firebase_options.dart`。
- **依赖**：已在 `pubspec.yaml` 中添加 `firebase_core`、`firebase_messaging` 和 `flutter_local_notifications`（已验证）。
- **Android 设置**：
  - 已在 `build.gradle.kts` 中成功应用 `google-services` 插件。
  - 已在 `AndroidManifest.xml` 中验证 `INTERNET` 权限。
  - `minSdkVersion`：检查了 `build.gradle.kts`，它使用的是 `flutter.minSdkVersion`。标准的 Flutter 设置通常是兼容的，但如果出现问题，我们将监控是否需要 version 21+。
- **后端实现**：✅ **已完成**
  - 数据库迁移：`backend/supabase/migrations/20260130000021_create_user_fcm_tokens.sql`
  - FCM 服务：`backend/src/services/fcm.ts`
  - 环境变量：已在 `types.ts` 和 `wrangler.toml` 中配置
- **Flutter 实现**：✅ **已完成**
  - 后台处理器：`lib/core/services/fcm_background_handler.dart`
  - FCM 服务：`lib/core/services/fcm_service.dart`
  - Firebase 初始化：在 `main.dart` 中添加
  - FCM 服务初始化：在 `AppBootstrap` 中添加
  - 登录后 Token 同步：在 `AuthProvider` 的 `loginWithGoogle/Apple` 中添加
  - 登出时 Token 注销：在 `AuthProvider` 的 `logout` 中添加

## 剩余步骤：验证与测试

### 第 4 阶段：Flutter 代码实现

本阶段将通知逻辑集成到 Flutter 应用中，遵循 TriTalk 的核心架构模式：

1.  **服务化管理**：复用 `lib/core/services/` 目录。
2.  **统一初始化**：在 `AppBootstrap` 中进行无阻塞初始化。
3.  **UI 解耦**：使用 `flutter_local_notifications` 处理前台展示。
4.  **多设备同步**：支持同一用户多设备同时接收推送。

#### 1. 文件结构

直接复用现有的 services 目录，添加 FCM 相关文件：

```
lib/core/services/
├── app_lifecycle_audio_manager.dart   # (已有)
├── streaming_tts_service.dart         # (已有)
├── fcm_background_handler.dart        # [新增] 顶层后台处理函数
└── fcm_service.dart                   # [新增] FCM 服务封装
```

#### 2. 实现后台处理器 (`fcm_background_handler.dart`)

后台消息处理器必须是 **顶级函数**，放在独立文件以便在 `main.dart` 中提前注册。

```dart
// lib/core/services/fcm_background_handler.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

/// FCM 后台消息处理器
///
/// [关键约束]
/// 1. 必须是顶级函数 (不能是类方法)
/// 2. 必须添加 @pragma 注解，防止 tree-shaking
/// 3. 必须重新初始化 Firebase (独立 isolate)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // 后台 isolate 独立运行，需重新初始化
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  if (kDebugMode) {
    debugPrint('📨 [FCM] 后台消息: ${message.messageId}');
    debugPrint('📨 [FCM] 数据: ${message.data}');
  }

  // 这里可以处理静默数据消息
  // 例如：更新本地数据库、预加载内容等
}
```

#### 4. FCM 服务 (`fcm_service.dart`)

采用单例模式，与 `StreamingTtsService` 保持一致的设计风格。

```dart
// lib/core/services/fcm_service.dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// FCM 推送通知服务
///
/// 职责：
/// - 权限请求
/// - Token 获取与持久化
/// - 前台/后台消息监听
/// - 本地通知显示
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  String? _cachedToken;

  /// 初始化 FCM 服务（在 AppBootstrap 中调用）
  ///
  /// 此方法不请求权限，仅设置监听器。
  /// 权限请求应在适当时机（如用户登录后）调用 [requestPermission]。
  Future<void> initialize() async {
    if (_initialized) return;

    // 1. 初始化本地通知插件
    await _initLocalNotifications();

    // 2. 设置前台消息监听
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 3. 设置通知点击处理
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 4. 检查是否从通知启动
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }

    // 5. 监听 Token 刷新
    _messaging.onTokenRefresh.listen(_onTokenRefresh);

    _initialized = true;
    if (kDebugMode) {
      debugPrint('🔔 [FCM] 服务初始化完成');
    }
  }

  /// 请求通知权限并同步 Token
  ///
  /// 建议在以下时机调用：
  /// - 用户登录成功后
  /// - 用户在设置中主动开启通知
  Future<bool> requestPermissionAndSyncToken() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    final authorized = settings.authorizationStatus ==
        AuthorizationStatus.authorized;

    if (kDebugMode) {
      debugPrint('🔔 [FCM] 权限状态: ${settings.authorizationStatus}');
    }

    if (authorized) {
      await _syncTokenToBackend();
    }

    return authorized;
  }

  /// 获取当前 FCM Token
  Future<String?> getToken() async {
    _cachedToken ??= await _messaging.getToken();
    return _cachedToken;
  }

  // ========== 私有方法 ==========

  Future<void> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,  // 不在此处请求权限
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );

    // 创建 Android 通知渠道 (Android 8.0+)
    await _createNotificationChannel();
  }

  Future<void> _createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'high_importance_channel',
      '重要通知',
      description: '用于显示重要的推送通知',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('📨 [FCM] 前台消息: ${message.notification?.title}');
    }

    final notification = message.notification;
    if (notification == null) return;

    // 使用本地通知显示前台消息
    _localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          '重要通知',
          icon: '@mipmap/ic_launcher',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: message.data.toString(),
    );
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (kDebugMode) {
      debugPrint('👆 [FCM] 用户点击通知: ${message.data}');
    }
    // TODO: 根据 message.data 导航到对应页面
    // 例如: navigatorKey.currentState?.pushNamed('/chat', arguments: message.data);
  }

  void _onLocalNotificationTap(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('👆 [FCM] 用户点击本地通知: ${response.payload}');
    }
    // TODO: 解析 payload 并导航
  }

  Future<void> _onTokenRefresh(String newToken) async {
    if (kDebugMode) {
      debugPrint('🔄 [FCM] Token 已刷新');
    }
    _cachedToken = newToken;
    await _syncTokenToBackend();
  }

  /// 将 FCM Token 同步到后端
  ///
  /// [多设备支持] 以 fcm_token 为主键进行 upsert：
  /// - 同一 Token 更新 user_id（处理账号切换）
  /// - 不同 Token 插入新记录（支持多设备）
  Future<void> _syncTokenToBackend() async {
    final token = await getToken();
    if (token == null) return;

    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      if (kDebugMode) {
        debugPrint('⚠️ [FCM] 用户未登录，跳过 Token 同步');
      }
      return;
    }

    try {
      // [关键] 以 fcm_token 为主键进行 upsert
      // 这样支持：
      // 1. 同一用户多台设备（每台设备有不同的 Token）
      // 2. 同一设备切换账号（Token 不变，更新 user_id）
      await Supabase.instance.client.from('user_fcm_tokens').upsert({
        'fcm_token': token,  // 主键
        'user_id': userId,
        'platform': defaultTargetPlatform.name,
        'last_active_at': DateTime.now().toIso8601String(),
      }, onConflict: 'fcm_token');

      if (kDebugMode) {
        debugPrint('✅ [FCM] Token 已同步到后端');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FCM] Token 同步失败: $e');
      }
    }
  }

  /// 注销当前设备的 FCM Token
  ///
  /// [关键] 必须在用户退出登录时调用！
  /// 否则用户退出后仍可能收到推送（隐私风险）
  Future<void> unregisterToken() async {
    final token = _cachedToken ?? await _messaging.getToken();
    if (token == null) return;

    try {
      // 从数据库中删除该 Token 记录
      await Supabase.instance.client
          .from('user_fcm_tokens')
          .delete()
          .eq('fcm_token', token);

      // 清除本地缓存
      _cachedToken = null;

      if (kDebugMode) {
        debugPrint('✅ [FCM] Token 已从后端注销');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ [FCM] Token 注销失败: $e');
      }
    }
  }
}
```

#### 5. 集成到 AppBootstrap

修改 `lib/core/initializer/app_initializer.dart`，添加 FCM 初始化：

```dart
// 在 AppBootstrap.initialize() 方法末尾添加：

// Initialize FCM Service (non-blocking)
// 权限请求会在用户登录后单独触发
try {
  await FcmService.instance.initialize();
  if (kDebugMode) {
    debugPrint('AppBootstrap: FCM service initialized');
  }
} catch (e) {
  // Non-fatal: app can still work without push notifications
  if (kDebugMode) {
    debugPrint('AppBootstrap: ⚠️ FCM init failed (non-fatal): $e');
  }
}
```

#### 6. 修改 main.dart

只需添加后台处理器注册，保持与现有代码风格一致：

```dart
// lib/main.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'core/services/fcm_background_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ... 现有的 SystemChrome 配置 ...

  Object? initError;

  try {
    // [新增] Firebase 必须在 AppBootstrap 之前初始化
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // [新增] 注册后台处理器 (必须在 runApp 之前)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    await AppBootstrap.initialize();
  } catch (e, stackTrace) {
    // ... 现有的错误处理 ...
  }

  // ... 其余代码保持不变 ...
}
```

#### 7. 权限请求时机 (最佳实践)

**不要在启动时请求权限！** 在用户登录成功后调用：

```dart
// 在登录成功的回调中
await FcmService.instance.requestPermissionAndSyncToken();
```

或者在设置页面提供手动开关：

```dart
// 用户主动开启通知
Switch(
  value: notificationsEnabled,
  onChanged: (enabled) async {
    if (enabled) {
      final granted = await FcmService.instance.requestPermissionAndSyncToken();
      setState(() => notificationsEnabled = granted);
    }
  },
)
```

#### 8. 退出登录处理 (关键！)

**必须在用户退出登录时注销 Token**，否则会导致隐私问题（用户登出后仍收到推送）。

```dart
// 在 AuthProvider 或 AuthService 的 signOut 方法中：
Future<void> signOut() async {
  // [关键] 先注销 FCM Token，再执行 Supabase 登出
  // 顺序很重要：登出后无法再访问 user_fcm_tokens 表
  await FcmService.instance.unregisterToken();

  // 然后执行正常的登出流程
  await Supabase.instance.client.auth.signOut();

  // ... 其他清理逻辑
}
```

#### 9. 数据库表结构 (多设备支持) ✅ 已完成

> **迁移文件**：`backend/supabase/migrations/20260130000021_create_user_fcm_tokens.sql`

> **设计说明**：以 `fcm_token` 为主键，支持同一用户多台设备同时接收推送。

```sql
-- migrations/20260130000021_create_user_fcm_tokens.sql
CREATE TABLE user_fcm_tokens (
  -- 每条记录代表一个 App 安装实例
  -- FCM Token 唯一标识设备，作为主键
  fcm_token TEXT PRIMARY KEY,

  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  platform TEXT NOT NULL,  -- 'android', 'iOS'

  -- 用于定期清理长期不活跃的 Token
  last_active_at TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 索引：快速查找某用户的所有设备
CREATE INDEX idx_user_fcm_tokens_user_id ON user_fcm_tokens(user_id);

-- RLS 策略
ALTER TABLE user_fcm_tokens ENABLE ROW LEVEL SECURITY;

-- 用户只能管理自己的 Token
CREATE POLICY "Users can insert own tokens"
  ON user_fcm_tokens FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own tokens"
  ON user_fcm_tokens FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own tokens"
  ON user_fcm_tokens FOR DELETE
  USING (auth.uid() = user_id);

-- 服务端推送需要 SELECT 权限（通过 service_role key）
-- 普通用户不需要 SELECT 自己的 Token
```

#### 10. 后端推送逻辑 (Cloudflare Workers 适配) ✅ 已完成

> **实现文件**：
>
> - 服务代码：`backend/src/services/fcm.ts`
> - 类型定义：`backend/src/types.ts` (Env 接口)
> - 服务导出：`backend/src/services/index.ts`

> **架构说明**：`firebase-admin` SDK 依赖 Node.js 原生 API（如 `fs`、`child_process`），**无法在 Cloudflare Workers 运行**。  
> 我们使用 **FCM HTTP v1 API** 直接发送请求，并复用现有的 `gcp-auth.ts` 认证逻辑。

##### 10.1 环境变量配置 (已完成)

> ⚠️ **重要**：Firebase 和 GCP TTS 使用**不同的账号**，需要分别配置凭证。

在 `.dev.vars` (本地) 和 Cloudflare Dashboard (生产) 中添加：

```bash
# Firebase 凭证 (与 GCP TTS 独立)
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@your-project.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n"
```

**获取凭证步骤**：

1. 进入 [Firebase Console](https://console.firebase.google.com/) → 项目设置 → 服务账号
2. 点击「生成新的私钥」下载 JSON 文件
3. 从 JSON 中提取 `project_id`、`client_email`、`private_key`

##### 10.2 FCM 推送服务实现

```typescript
// src/services/fcm.ts - 适配 Cloudflare Workers 的 FCM 服务

import { getGCPAccessToken } from "../auth/gcp-auth"; // 复用认证逻辑
import { createSupabaseClient } from "./supabase";

interface PushNotification {
  title: string;
  body: string;
  data?: Record<string, string>;
}

interface SendResult {
  sent: number;
  failed: number;
}

/**
 * 向指定用户的所有设备发送推送通知
 *
 * [多设备支持] 查询 user_fcm_tokens 表获取用户的所有设备 Token
 */
export async function sendPushToUser(
  env: Env,
  userId: string,
  notification: PushNotification,
): Promise<SendResult> {
  const supabase = createSupabaseClient(env);

  // 1. 查询用户的所有设备 Token
  const { data: tokens, error } = await supabase
    .from("user_fcm_tokens")
    .select("fcm_token")
    .eq("user_id", userId);

  if (error || !tokens?.length) {
    return { sent: 0, failed: 0 };
  }

  // 2. 获取 Firebase Access Token (使用独立的 Firebase 凭证)
  const accessToken = await getGCPAccessToken(
    env.FIREBASE_CLIENT_EMAIL,
    env.FIREBASE_PRIVATE_KEY,
    "https://www.googleapis.com/auth/firebase.messaging",
  );

  // 3. 并发发送到所有设备 (FCM HTTP v1 不支持批量，但可并发)
  const results = await Promise.allSettled(
    tokens.map((t) =>
      sendSinglePush(env, accessToken, t.fcm_token, notification),
    ),
  );

  // 4. 收集失效的 Token 并清理
  const invalidTokens: string[] = [];
  results.forEach((result, idx) => {
    if (result.status === "rejected" && isUnregisteredError(result.reason)) {
      invalidTokens.push(tokens[idx].fcm_token);
    }
  });

  if (invalidTokens.length > 0) {
    // 批量删除失效 Token
    await supabase
      .from("user_fcm_tokens")
      .delete()
      .in("fcm_token", invalidTokens);
  }

  return {
    sent: results.filter((r) => r.status === "fulfilled").length,
    failed: invalidTokens.length,
  };
}

/**
 * 使用 FCM HTTP v1 API 发送单条推送
 *
 * @see https://firebase.google.com/docs/cloud-messaging/send-message#send-messages-to-specific-devices
 */
async function sendSinglePush(
  env: Env,
  accessToken: string,
  token: string,
  notification: PushNotification,
): Promise<void> {
  const projectId = env.FIREBASE_PROJECT_ID;
  const url = `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`;

  const response = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${accessToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      message: {
        token,
        notification: {
          title: notification.title,
          body: notification.body,
        },
        data: notification.data,
      },
    }),
  });

  if (!response.ok) {
    const error = await response.json();
    throw error;
  }
}

/**
 * 检查是否为 Token 失效错误
 *
 * FCM HTTP v1 API 返回的错误格式与 Admin SDK 不同
 */
function isUnregisteredError(error: unknown): boolean {
  if (typeof error !== "object" || error === null) return false;

  const fcmError = error as {
    error?: { details?: Array<{ errorCode?: string }> };
  };
  return (
    fcmError.error?.details?.some((d) => d.errorCode === "UNREGISTERED") ??
    false
  );
}
```

##### 10.3 使用示例

```typescript
// 在需要发送推送的地方调用
import { sendPushToUser } from "../services/fcm";

// 例如：新消息到达时通知用户
const result = await sendPushToUser(env, targetUserId, {
  title: "TriTalk",
  body: "您有新的消息",
  data: { type: "new_message", conversationId: "..." },
});

console.log(`推送完成: ${result.sent} 成功, ${result.failed} 失效`);
```

##### 10.4 Admin API 测试端点 ✅ 已完成

提供两个 Admin 端点用于测试和监控 FCM 推送：

**检查 FCM 配置状态：**

```bash
curl -X GET "https://tritalk-backend.tristart226.workers.dev/admin/push/status" \
  -H "X-Admin-Key: your-admin-api-key"
```

响应示例：

```json
{
  "configured": true,
  "project_id": "tritalk-a2783",
  "client_email": "firebase-adminsdk-xxx@tritalk-a2783.iam.gserviceaccount.com"
}
```

**发送测试推送：**

```bash
curl -X POST "https://tritalk-backend.tristart226.workers.dev/admin/push/test" \
  -H "X-Admin-Key: your-admin-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "用户UUID",
    "title": "TriTalk 测试",
    "body": "这是一条测试推送 🔔",
    "data": {"type": "test"}
  }'
```

响应示例：

```json
{
  "success": true,
  "sent": 2,
  "failed": 0,
  "message": "Successfully sent to 2 device(s)"
}
```

> **注意**：需要先在 Cloudflare Dashboard 配置 `ADMIN_API_KEY` 环境变量。

#### 9. 依赖更新 (已完成)

确保 `pubspec.yaml` 包含：

```yaml
dependencies:
  firebase_core: ^3.x.x
  firebase_messaging: ^15.x.x
  flutter_local_notifications: ^18.x.x # [新增]
```

### 第 5 阶段：验证与测试

1.  **运行应用**：在 Android 设备或 Google Play 模拟器上执行 `flutter run`。
2.  **获取 Token**：复制调试控制台中打印的 FCM Token（如果使用了上面的代码，查找 `==== 设备 FCM Token ====`）。
3.  **发送测试**：
    - 前往 Firebase 控制台 > Messaging。
    - 创建新战役 (Notification)。
    - 输入标题/正文。
    - **在设备上测试**：粘贴 Token 并添加。
    - 发送。
4.  **预期结果**：
    - **前台**：出现控制台日志 / SnackBar。
    - **后台**：系统通知栏显示消息。点击它应打开应用。
