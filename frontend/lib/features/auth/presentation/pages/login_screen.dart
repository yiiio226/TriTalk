import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_provider.dart';
import '../../../../core/auth/auth_state.dart';
import 'package:frontend/core/design/app_design_system.dart';
import '../../../home/presentation/pages/home_screen.dart';
import '../../../onboarding/presentation/pages/onboarding_screen.dart';

/// Login screen using Riverpod for state management
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Listen for auth state changes to navigate
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        _navigateAfterLogin(context, next.needsOnboarding);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Header Section
              _buildHeader(),

              const Spacer(flex: 2),

              // Login Buttons Section
              _buildLoginButtons(context, ref, authState),

              const SizedBox(height: AppSpacing.xl),

              // Terms and Privacy
              _buildTermsText(context),

              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // App Logo
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(25),
            boxShadow: AppShadows.md,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Image.asset(
              'assets/icon/1024.png',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // Welcome Text
        Text(
          'Welcome to TriTalk',
          style: AppTypography.headline2.copyWith(
            color: AppColors.lightTextPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Practice conversations with AI to improve your language skills',
          textAlign: TextAlign.center,
          style: AppTypography.body1.copyWith(
            color: AppColors.lightTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButtons(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
  ) {
    final loadingType = authState.loadingType;
    final isAnyLoading = loadingType != AuthLoadingType.none;

    return Column(
      children: [
        // Error Message
        if (authState.error != null) ...[
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.lightError.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.lightError,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    authState.error!,
                    style: AppTypography.body2.copyWith(
                      color: AppColors.lightError,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: AppColors.lightError,
                  onPressed: () {
                    ref.read(authProvider.notifier).clearError();
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],

        // Google Sign In (Black Button, Top)
        _buildLoginButton(
          icon: null,
          customIcon: _buildGoogleIcon(),
          label: 'Continue with Google',
          backgroundColor: Colors.black,
          textColor: Colors.white,
          isLoading: loadingType == AuthLoadingType.google,
          onPressed: isAnyLoading
              ? null
              : () => ref.read(authProvider.notifier).loginWithGoogle(),
        ),
        const SizedBox(height: AppSpacing.md),

        // Apple Sign In (White Button, Bottom)
        _buildLoginButton(
          icon: Icons.apple,
          label: 'Continue with Apple',
          backgroundColor: Colors.white,
          textColor: AppColors.lightTextPrimary,
          borderColor: AppColors.lightDivider,
          isLoading: loadingType == AuthLoadingType.apple,
          onPressed: isAnyLoading
              ? null
              : () => ref.read(authProvider.notifier).loginWithApple(),
        ),
      ],
    );
  }

  Widget _buildLoginButton({
    IconData? icon,
    Widget? customIcon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required bool isLoading,
    VoidCallback? onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1)
                : BorderSide.none,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(textColor),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (customIcon != null)
                    customIcon
                  else if (icon != null)
                    Icon(icon, size: 24),
                  const SizedBox(width: AppSpacing.md),
                  Text(
                    label,
                    style: AppTypography.button.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 24,
      height: 24,

      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            color: AppColors.darkTextPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTermsText(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: 'By continuing, you agree to our ',
        style: AppTypography.caption.copyWith(
          color: AppColors.lightTextPrimary,
        ),
        children: [
          TextSpan(
            text: 'Terms of Service',
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: AppTypography.caption.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }

  void _navigateAfterLogin(BuildContext context, bool needsOnboarding) {
    final destination = needsOnboarding
        ? const OnboardingScreen()
        : const HomeScreen();

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => destination));
  }
}
