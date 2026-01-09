import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'components/supabase_config.dart';
import 'design/app_design_system.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const TriTalkApp());
}

class TriTalkApp extends StatelessWidget {
  const TriTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TriTalk',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light, // You can change this to ThemeMode.system for automatic switching
      home: const SplashScreen(),
      routes: {
        '/login-callback': (context) => const Scaffold(body: Center(child: CircularProgressIndicator())),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
