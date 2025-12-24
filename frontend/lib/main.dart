import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const SpeakSceneApp());
}

class SpeakSceneApp extends StatelessWidget {
  const SpeakSceneApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpeakScene',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.grey[50],
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
