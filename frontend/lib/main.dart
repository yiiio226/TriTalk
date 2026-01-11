import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/initializer/app_initializer.dart';
import 'screens/splash_screen.dart';
import 'design/app_design_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await AppInitializer.init();

    runApp(const ProviderScope(child: TriTalkApp()));
  } catch (e, stack) {
    debugPrint('Initialization failed: $e\n$stack');
    runApp(InitializationErrorApp(error: e.toString()));
  }
}

class InitializationErrorApp extends StatelessWidget {
  final String error;
  const InitializationErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Failed to initialize app: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

class TriTalkApp extends StatelessWidget {
  const TriTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TriTalk',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode
          .light, // You can change this to ThemeMode.system for automatic switching
      home: const SplashScreen(),
      routes: {
        '/login-callback': (context) =>
            const Scaffold(body: Center(child: CircularProgressIndicator())),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
