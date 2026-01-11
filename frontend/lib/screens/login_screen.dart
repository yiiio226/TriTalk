import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/auth/auth_provider.dart';
import '../design/app_design_system.dart';
import 'onboarding_screen.dart';
import 'home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  Future<void> _handleGoogleLogin() async {
    if (_isGoogleLoading || _isAppleLoading) return;
    setState(() => _isGoogleLoading = true);
    try {
      final success = await ref.read(authProvider.notifier).loginWithGoogle();
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to initiate Google login. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  Future<void> _handleAppleLogin() async {
    if (_isGoogleLoading || _isAppleLoading) return;
    setState(() => _isAppleLoading = true);
    try {
      final success = await ref.read(authProvider.notifier).loginWithApple();
      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to initiate Apple login. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login Failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _isAppleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes to navigate
    ref.listen(authProvider, (previous, next) {
      next.when(
        data: (user) {
          if (user != null) {
            if (ref.read(authProvider.notifier).needsOnboarding) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const OnboardingScreen(),
                ),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            }
          }
        },
        loading: () {},
        error: (e, st) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Login Error: $e')));
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Hero Image or Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.asset('assets/icon/icon.png', fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 40),
              const Text(
                'Welcome to TriTalk',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Master languages through immersive\nroleplay conversations.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
              const Spacer(),
              _buildSocialButton(
                text: 'Continue with Google',
                icon: Icons.g_mobiledata,
                color: Colors.white,
                textColor: Colors.black,
                borderColor: Colors.grey[300],
                onPressed: _handleGoogleLogin,
                isLoading: _isGoogleLoading,
              ),
              const SizedBox(height: 16),
              _buildSocialButton(
                text: 'Continue with Apple',
                icon: Icons.apple,
                color: Colors.black,
                textColor: Colors.white,
                borderColor: Colors.transparent,
                onPressed: _handleAppleLogin,
                isLoading: _isAppleLoading,
              ),
              const SizedBox(height: 40),
              Text(
                'By continuing, you agree to our Terms & Privacy Policy',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[400]),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String text,
    required IconData icon,
    required Color color,
    required Color textColor,
    required Color? borderColor,
    required VoidCallback onPressed,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: isLoading ? () {} : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: borderColor != null
                ? BorderSide(color: borderColor)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            else
              Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
