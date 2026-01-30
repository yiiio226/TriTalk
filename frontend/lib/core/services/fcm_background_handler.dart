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
