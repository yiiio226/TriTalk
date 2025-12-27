import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
    
    _setupAuthListener();
    _checkAuthAndNavigate();
  }

  void _setupAuthListener() {
    // Listen for auth state changes (e.g., after OAuth redirect)
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (!mounted || _navigated) return;
      
      final session = data.session;
      if (session != null) {
        _navigateBasedOnProfile();
      }
    });
  }

  Future<void> _checkAuthAndNavigate() async {
    // Initialize Auth Service
    await AuthService().init();
    
    // Wait for animation
    await Future.delayed(const Duration(seconds: 2));
    
    if (!mounted || _navigated) return;

    if (AuthService().isAuthenticated) {
      _navigateBasedOnProfile();
    } else {
      _navigateTo(const LoginScreen());
    }
  }

  void _navigateBasedOnProfile() async {
    // Wait a bit for profile to load
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted || _navigated) return;

    // Check if user needs onboarding
    if (AuthService().currentUser == null || AuthService().needsOnboarding) {
      _navigateTo(const OnboardingScreen());
    } else {
      _navigateTo(const HomeScreen());
    }
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
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
                child: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Colors.white,
                  size: 60,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'TriTalk',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Your AI English Companion',
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
