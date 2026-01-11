import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth/auth_provider.dart';
import '../design/app_design_system.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _navigated = false;
  bool _animationDone = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward();
    _startTimer();
  }

  void _startTimer() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _animationDone = true;
      });
      _checkNavigation();
    }
  }

  void _checkNavigation() {
    if (!mounted || _navigated || !_animationDone) return;

    final authState = ref.read(authProvider);

    authState.when(
      data: (user) {
        if (user != null) {
          if (ref.read(authProvider.notifier).needsOnboarding) {
            _navigateTo(const OnboardingScreen());
          } else {
            _navigateTo(const HomeScreen());
          }
        } else {
          _navigateTo(const LoginScreen());
        }
      },
      loading: () {
        // Keep waiting
      },
      error: (_, __) {
        _navigateTo(const LoginScreen());
      },
    );
  }

  void _navigateTo(Widget screen) {
    if (_navigated) return;
    _navigated = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen for state changes
    ref.listen(authProvider, (previous, next) {
      if (_animationDone) {
        _checkNavigation();
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            // ... existing UI ...
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Use the app icon if available, or a text logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset('assets/icon/icon.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'TriTalk',
                style: AppTypography.headline1.copyWith(
                  fontSize: 40,
                  color: AppColors.lightTextPrimary,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your AI Language Companion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
