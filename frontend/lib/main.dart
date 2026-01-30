import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'l10n/app_localizations.dart';

import 'core/initializer/app_initializer.dart';
import 'core/services/fcm_background_handler.dart';
import 'firebase_options.dart';
import 'core/providers/locale_provider.dart';
import 'core/services/app_lifecycle_audio_manager.dart';
import 'features/onboarding/presentation/pages/splash_screen.dart';
import 'package:frontend/core/design/app_design_system.dart';
import 'package:frontend/core/widgets/error_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for a seamless status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      // Status bar (top)
      statusBarColor: Colors.transparent,
      statusBarIconBrightness:
          Brightness.dark, // Dark icons for light background
      statusBarBrightness:
          Brightness.light, // iOS: light status bar background means dark icons
      // Navigation bar (bottom) - Android
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  Object? initError;

  try {
    // [FCM] Firebase 必须在 AppBootstrap 之前初始化
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // [FCM] 注册后台处理器 (必须在 runApp 之前)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Bootstrap app before creating ProviderScope
    // This initializes Supabase and SharedPreferences
    await AppBootstrap.initialize();
  } catch (e, stackTrace) {
    // Log the initialization error
    debugPrint('AppBootstrap.initialize() failed: $e');
    debugPrint('Stack trace: $stackTrace');
    initError = e;
  }

  // Build overrides list - only include sharedPreferencesProvider if prefs is available
  final overrides = <Override>[];
  try {
    // Attempt to access AppBootstrap.prefs - this may throw if initialization failed
    overrides.add(
      sharedPreferencesProvider.overrideWithValue(AppBootstrap.prefs),
    );
  } catch (_) {
    // AppBootstrap.prefs not available, skip the override
    debugPrint(
      'AppBootstrap.prefs not available, skipping sharedPreferencesProvider override',
    );
  }

  runApp(
    ProviderScope(
      overrides: overrides,
      child: initError != null
          ? ErrorScreen(error: initError)
          : const TriTalkApp(),
    ),
  );
}

/// Root application widget with locale support
class TriTalkApp extends ConsumerStatefulWidget {
  const TriTalkApp({super.key});

  @override
  ConsumerState<TriTalkApp> createState() => _TriTalkAppState();
}

class _TriTalkAppState extends ConsumerState<TriTalkApp> {
  @override
  void initState() {
    super.initState();
    // Initialize the app lifecycle audio manager to handle
    // stopping audio when app goes to background or is terminated
    AppLifecycleAudioManager.instance.initialize();
  }

  @override
  void dispose() {
    // Clean up the lifecycle manager
    AppLifecycleAudioManager.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch locale state for changes
    final localeState = ref.watch(localeProvider);

    return MaterialApp(
      title: 'TriTalk',
      debugShowCheckedModeBanner: false,
      // i18n 配置 - 使用用户选择的语言或跟随系统
      locale: localeState.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode
          .light, // Force light mode until dark mode is fully developed
      home: const SplashScreen(),
    );
  }
}
