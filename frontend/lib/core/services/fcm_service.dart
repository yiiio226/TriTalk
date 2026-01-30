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
  /// 权限请求应在适当时机（如用户登录后）调用 [requestPermissionAndSyncToken]。
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

    final authorized =
        settings.authorizationStatus == AuthorizationStatus.authorized;

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
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false, // 不在此处请求权限
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings: initSettings,
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
          AndroidFlutterLocalNotificationsPlugin
        >()
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
      id: notification.hashCode,
      title: notification.title,
      body: notification.body,
      notificationDetails: const NotificationDetails(
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
        'fcm_token': token, // 主键
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
