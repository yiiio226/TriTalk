import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_provider.dart';
import 'package:frontend/features/auth/data/services/auth_service.dart';
import 'package:frontend/features/profile/data/services/user_service.dart';
import 'package:frontend/core/data/language_constants.dart';
import 'package:frontend/core/design/app_design_system.dart';
import 'favorites_screen.dart'; // Import UnifiedFavoritesScreen
import '../../../subscription/presentation/pages/paywall_screen.dart';
import '../../../onboarding/presentation/pages/splash_screen.dart'; // For logout navigation

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  // Local state for immediate UI updates, reflecting auth service state
  late String _name;
  late String _email;
  late String _avatarUrl;
  late String _gender;
  late String _nativeLanguage;
  late String _targetLanguage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _name = user.name;
        _email = user.email;
        _avatarUrl = user.avatarUrl ?? 'assets/images/user_avatar_male.png';
        _gender = user.gender;
        _nativeLanguage = user.nativeLanguage;
        _targetLanguage = user.targetLanguage;
      });
    } else {
      // Fallback if accessed without auth (shouldn't happen in new flow)
      setState(() {
        _name = 'Guest';
        _email = 'guest@example.com';
        _avatarUrl = 'assets/images/user_avatar_male.png';
        _gender = 'male';
        _nativeLanguage = LanguageConstants.defaultNativeLanguage;
        _targetLanguage = LanguageConstants.defaultTargetLanguage;
      });
    }
  }

  Future<void> _updateNativeLanguage(String language) async {
    await _userService.updateUserProfile(nativeLanguage: language);
    _loadUserData(); // Reload to reflect changes
  }

  Future<void> _updateTargetLanguage(String language) async {
    await _userService.updateUserProfile(targetLanguage: language);
    _loadUserData();
  }

  Future<void> _handleLogout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const SplashScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  void _showLanguageDialog(
    String title,
    String currentLanguage,
    Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.md),
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightDivider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: AppTypography.headline4.copyWith(
                color: AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: LanguageConstants.supportedLanguages.map((lang) {
                  final isSelected = lang == currentLanguage;
                  return InkWell(
                    onTap: () {
                      onSelect(lang);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: AppColors.lightDivider,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            lang,
                            style: AppTypography.body1.copyWith(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.lightTextPrimary,
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check,
                              color: AppColors.primary,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.sm),
            // Custom Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.lightTextPrimary,
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Profile',
                    style: AppTypography.headline1.copyWith(
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Profile Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.secondary,
                    ),
                    child: ClipOval(
                      child: _avatarUrl.startsWith('assets/')
                          ? Image.asset(_avatarUrl, fit: BoxFit.cover)
                          : Image.network(
                              _avatarUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Fallback to gender-based avatar
                                final fallbackPath = _gender == 'female'
                                    ? 'assets/images/user_avatar_female.png'
                                    : 'assets/images/user_avatar_male.png';
                                return Image.asset(
                                  fallbackPath,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _name,
                          style: AppTypography.headline3.copyWith(
                            color: AppColors.lightTextPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _email,
                          style: AppTypography.body2.copyWith(
                            color: AppColors.lightTextPrimary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                children: [
                  Text(
                    'Language Settings',
                    style: AppTypography.subtitle1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildMenuCard(
                    context,
                    title: 'Native Language',
                    subtitle: _nativeLanguage,
                    icon: Icons.public,
                    iconColor: AppColors.lightTextSecondary,
                    onTap: () {
                      _showLanguageDialog(
                        'Select Native Language',
                        _nativeLanguage,
                        _updateNativeLanguage,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildMenuCard(
                    context,
                    title: 'Learning Language',
                    subtitle: _targetLanguage,
                    icon: Icons.school,
                    iconColor: AppColors.lightTextSecondary,
                    onTap: () {
                      _showLanguageDialog(
                        'Select Learning Language',
                        _targetLanguage,
                        _updateTargetLanguage,
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'Tools',
                    style: AppTypography.subtitle1.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildMenuCard(
                    context,
                    title: 'Favorites', // Unified title
                    subtitle: 'Vocabulary, Sentences, Chat History',
               
                    icon: Icons.bookmark,
                    iconColor: AppColors.lightTextSecondary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UnifiedFavoritesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildMenuCard(
                    context,
                    title: 'Upgrade to Pro',
                    subtitle: 'Get unlimited chats and advanced feedback',
                    icon: Icons.star,
                    iconColor: AppColors.lightTextSecondary,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaywallScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Logout Button
                  _buildMenuCard(
                    context,
                    title: 'Log Out',
                    icon: Icons.power_settings_new,
                    iconColor: AppColors.lightError,
                    onTap: _handleLogout,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    String? subtitle,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: AppShadows.sm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.subtitle2.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          subtitle,
                          style: AppTypography.caption.copyWith(
                            color: AppColors.lightTextSecondary,
                            fontWeight: FontWeight
                                .w500, // Make subtitle slightly more visible
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppColors.lightTextPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
