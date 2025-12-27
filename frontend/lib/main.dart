import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const TriTalkApp());
}

class TriTalkApp extends StatelessWidget {
  const TriTalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TriTalk',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[50],
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
