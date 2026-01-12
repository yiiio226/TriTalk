import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/initializer/app_initializer.dart';
import 'features/onboarding/presentation/pages/splash_screen.dart';
import 'package:frontend/core/design/app_design_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Bootstrap app before creating ProviderScope
  // This initializes Supabase and SharedPreferences
  await AppBootstrap.initialize();

  runApp(
    ProviderScope(
      overrides: [
        // Override SharedPreferences provider with the bootstrapped instance
        sharedPreferencesProvider.overrideWithValue(AppBootstrap.prefs),
      ],
      child: const TriTalkApp(),
    ),
  );
}

/// Root application widget
class TriTalkApp extends StatelessWidget {
  const TriTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TriTalk',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.lightBackground,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          foregroundColor: AppColors.lightTextPrimary,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}
