import 'package:flutter/material.dart';
import 'package:frontend/core/design/app_design_system.dart';

/// Fallback error screen displayed when app initialization fails
class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TriTalk - Error',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.red.shade50,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.lr500,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Initialization Error',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.lr800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'The app failed to initialize properly.',
                    style: TextStyle(fontSize: 16, color: AppColors.lr800),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.dn900,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.lr200),
                    ),
                    child: SelectableText(
                      error.toString(),
                      style: TextStyle(
                        fontSize: 14,
                        fontFamily: 'monospace',
                        color: AppColors.lr800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
