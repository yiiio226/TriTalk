import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_provider.dart';
import '../../../../core/auth/auth_state.dart';
import 'package:frontend/core/design/app_design_system.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import 'onboarding_screen.dart';

/// Splash screen with Floating Language Elements
///
/// Features:
/// - Floating multilingual text bubbles
/// - Smooth floating animations
/// - Rotation effects
/// - Language learning theme
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _floatController;
  late AnimationController _rotateController;
  
  late Animation<double> _fadeAnimation;
  
  bool _hasNavigated = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Fade animation controller
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Float animation controller (continuous)
    _floatController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat(reverse: true);

    // Rotate animation controller (continuous)
    _rotateController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _fadeController.addListener(() {
      final authState = ref.read(authProvider);
      if (authState.status != AuthStatus.unknown) {
        _navigateBasedOnAuthState(authState);
      }
    });

    _fadeController.forward();

    // Initialize auth after a short delay to show splash animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _initializeAuth();
    });
  }

  Future<void> _initializeAuth() async {
    if (_isInitialized) return;
    _isInitialized = true;
    await ref.read(authProvider.notifier).initialize();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _floatController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  void _navigateBasedOnAuthState(AuthState authState) {
    if (_hasNavigated || !mounted) return;

    // Wait for animation to complete (at least partially)
    if (_fadeController.value < 0.6) {
      return;
    }

    // Determine destination based on auth state
    Widget destination;
    switch (authState.status) {
      case AuthStatus.authenticated:
        destination = authState.needsOnboarding
            ? const OnboardingScreen()
            : const HomeScreen();
        break;
      case AuthStatus.unauthenticated:
        destination = const LoginScreen();
        break;
      case AuthStatus.unknown:
        return;
    }

    _hasNavigated = true;

    // Navigate with fade transition
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState.status != AuthStatus.unknown) {
        _navigateBasedOnAuthState(authState);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Stack(
        children: [
          // Floating language elements
          ..._buildFloatingElements(),

          // Center logo and title
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: AppShadows.xl,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset(
                        'assets/icon/icon.png',
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: AppSpacing.xl),

                  // App Name
                  Text(
                    'TriTalk',
                    style: AppTypography.headline1.copyWith(
                      color: AppColors.lightTextPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  SizedBox(height: AppSpacing.sm),
                  
                  // Tagline
                  Text(
                    'Your AI Language Practice Companion',
                    style: AppTypography.body1.copyWith(
                      color: AppColors.lightTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFloatingElements() {
    final elements = [
      // Top Left - Blue
      {'text': 'Hello', 'color': AppColors.lb100, 'x': 0.1, 'y': 0.26},
      // Top Right - Red
      {'text': '你好', 'color': AppColors.lr100, 'x': 0.72, 'y': 0.25},
      // Bottom Left - Green
      {'text': 'Bonjour', 'color': AppColors.lg100, 'x': 0.15, 'y': 0.78},
      // Bottom Right - Yellow
      {'text': 'Hola', 'color': AppColors.ly100, 'x': 0.73, 'y': 0.75},
      // Top Center - Purple
      {'text': 'こんにちは', 'color': AppColors.lp100, 'x': 0.43, 'y': 0.16},
      // Middle Left Edge - Orange (Moved further left)
      {'text': 'Ciao', 'color': AppColors.lo100, 'x': 0.08, 'y': 0.52},
      // Middle Right Edge - Blue (Moved further right)
      {'text': '안녕하세요', 'color': AppColors.lb100, 'x': 0.76, 'y': 0.42},
    ];

    return elements.asMap().entries.map((entry) {
      final index = entry.key;
      final element = entry.value;

      return AnimatedBuilder(
        animation: Listenable.merge([_floatController, _fadeAnimation]),
        builder: (context, child) {
          // Reduced float offset slightly (15 instead of 20) to maintain safe zone
          final offset =
              15 * (index % 2 == 0 ? 1 : -1) * _floatController.value;

          return Positioned(
            left: MediaQuery.of(context).size.width * (element['x'] as double),
            top:
                MediaQuery.of(context).size.height * (element['y'] as double) +
                offset,
            child: Opacity(
              opacity: _fadeAnimation.value * 0.8,
              child: Transform.rotate(
                angle:
                    _rotateController.value *
                    2 *
                    math.pi *
                    (index % 2 == 0 ? 0.1 : -0.1),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: element['color'] as Color,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Text(
                    element['text'] as String,
                    style: AppTypography.body2.copyWith(
                      color: AppColors.lightTextPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    }).toList();
  }
}
