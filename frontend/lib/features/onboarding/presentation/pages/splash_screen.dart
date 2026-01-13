import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/auth/auth_provider.dart';
import '../../../../core/auth/auth_state.dart';
import 'package:frontend/core/design/app_design_system.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../../auth/presentation/pages/login_screen.dart';
import 'onboarding_screen.dart';

/// Splash screen that handles initial navigation based on auth state
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _hasNavigated = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();

    // Setup animations
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();

    // Initialize auth after a short delay to show splash animation
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      _initializeAuth();
    });
  }

  Future<void> _initializeAuth() async {
    if (_isInitialized) return;
    _isInitialized = true;

    // Initialize auth state
    await ref.read(authProvider.notifier).initialize();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateBasedOnAuthState(AuthState authState) {
    if (_hasNavigated || !mounted) return;

    // Wait for animation to complete (at least partially)
    if (_animationController.value < 0.6) {
      return;
    }

    // Determine destination based on auth state
    Widget destination;
    switch (authState.status) {
      case AuthStatus.authenticated:
        if (authState.needsOnboarding) {
          destination = const OnboardingScreen();
        } else {
          destination = const HomeScreen();
        }
        break;
      case AuthStatus.unauthenticated:
        destination = const LoginScreen();
        break;
      case AuthStatus.unknown:
        // Still loading, don't navigate yet
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
    // Listen to auth state changes
    final authState = ref.watch(authProvider);

    // Use post-frame callback to navigate after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (authState.status != AuthStatus.unknown) {
        _navigateBasedOnAuthState(authState);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Logo with Shimmer overlay
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Original Logo Layer
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              blurRadius: 30,
                              offset: const Offset(0, 15),
                            ),
                          ],
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
                      // Shimmer Overlay Layer
                      Shimmer.fromColors(
                        baseColor: Colors.white.withValues(alpha: 0.0),
                        highlightColor: Colors.white.withValues(alpha: 0.4),
                        period: const Duration(milliseconds: 1500),
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // App Name with Shimmer overlay
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Original Text Layer
                      Text(
                        'TriTalk',
                        style: AppTypography.headline1.copyWith(
                          color: AppColors.lightTextPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Shimmer Overlay Layer
                      Shimmer.fromColors(
                        baseColor: Colors.white.withValues(alpha: 0.0),
                        highlightColor: Colors.white.withValues(alpha: 0.4),
                        period: const Duration(milliseconds: 1500),
                        child: Text(
                          'TriTalk',
                          style: AppTypography.headline1.copyWith(
                            color: AppColors.lightTextPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  // Tagline
                  Text(
                    'Your AI Language Practice Companion',
                    style: AppTypography.body1.copyWith(
                      color: AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                  // Loading indicator removed as per request
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
