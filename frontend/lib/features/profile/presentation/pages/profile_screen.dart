import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/auth/auth_provider.dart';
import '../../../../core/providers/locale_provider.dart';
import 'package:frontend/features/auth/data/services/auth_service.dart';
import 'package:frontend/features/profile/data/services/user_service.dart';
import 'package:frontend/core/data/language_constants.dart';
import 'package:frontend/core/design/app_design_system.dart';
import 'favorites_screen.dart'; // Import UnifiedFavoritesScreen
import 'package:frontend/features/subscription/data/services/revenue_cat_service.dart';
import 'package:frontend/features/subscription/domain/models/subscription_tier.dart';
import '../../../subscription/presentation/pages/paywall_screen.dart';
import '../../../onboarding/presentation/pages/splash_screen.dart'; // For logout navigation
import 'package:frontend/core/utils/l10n_ext.dart';
import 'package:frontend/core/data/api/client_provider.dart';
import 'package:frontend/core/services/fcm_service.dart';
import 'package:frontend/core/widgets/top_toast.dart';

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

  // App version info
  String _version = '';
  String _buildNumber = '';
  late String _targetLanguage;

  // Statistics
  final String _chatsCount = '24';
  final String _studyMins = '750';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadVersionInfo();
    RevenueCatService().addListener(_onSubscriptionUpdate);
  }

  @override
  void dispose() {
    RevenueCatService().removeListener(_onSubscriptionUpdate);
    super.dispose();
  }

  void _onSubscriptionUpdate() {
    if (mounted) setState(() {});
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    if (user != null) {
      setState(() {
        _name = user.name;
        _email = user.email;
        _avatarUrl =
            user.avatarUrl ?? 'assets/images/avatars/user_avatar_male.png';
        _gender = user.gender;
        // Ensure we handle both legacy names and new codes gracefully
        _nativeLanguage = LanguageConstants.getIsoCode(user.nativeLanguage);
        _targetLanguage = LanguageConstants.getIsoCode(user.targetLanguage);
      });
    } else {
      // Fallback if accessed without auth
      setState(() {
        _name = 'Guest';
        _email = 'guest@example.com';
        _avatarUrl = 'assets/images/avatars/user_avatar_male.png';
        _gender = 'male';
        _nativeLanguage = LanguageConstants.defaultNativeLanguageCode;
        _targetLanguage = LanguageConstants.defaultTargetLanguageCode;
      });
    }
  }

  Future<void> _loadVersionInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = packageInfo.version;
        _buildNumber = packageInfo.buildNumber;
      });
    }
  }

  Future<void> _updateNativeLanguage(String languageCode) async {
    await _userService.updateUserProfile(nativeLanguage: languageCode);
    _loadUserData(); // Reload to reflect changes
  }

  Future<void> _updateTargetLanguage(String languageCode) async {
    await _userService.updateUserProfile(targetLanguage: languageCode);
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

  // ============================================================================
  // Delete Account Methods
  // ============================================================================

  /// 处理删除账号 - 双重确认后调用 API
  Future<void> _handleDeleteAccount() async {
    // Step 1: 显示警告确认对话框
    final firstConfirm = await _showDeleteWarning();
    if (firstConfirm != true) return;

    // Step 2: 要求输入 "DELETE" 进行二次确认，并执行删除
    final success = await _showDeleteTypeConfirmDialog();

    // Step 3: 如果删除成功，则执行登出跳转
    if (success == true) {
      _handleLogout();
    }
  }

  /// 显示删除账号警告对话框（包含订阅提醒）
  Future<bool?> _showDeleteWarning() {
    return showModalBottomSheet<bool>(
      context: context,
      backgroundColor: AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (dialogContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.lightDivider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              Text(
                context.l10n.deleteAccountConfirmationTitle,
                style: AppTypography.headline4.copyWith(
                  color: AppColors.lightError,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                context.l10n.deleteAccountConfirmationContent,
                style: AppTypography.body1.copyWith(
                  color: AppColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              _buildSubscriptionWarningBanner(),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(dialogContext, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: AppColors.ln200),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        context.l10n.cancelAction,
                        style: TextStyle(color: AppColors.lightTextPrimary),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(dialogContext, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lightError,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        context.l10n.deleteAction,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 显示输入 DELETE 确认对话框
  Future<bool?> _showDeleteTypeConfirmDialog() {
    final confirmController = TextEditingController();

    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.lightSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (dialogContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.lightDivider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),

                Text(
                  context.l10n.deleteAccountConfirmationTitle,
                  style: AppTypography.headline4.copyWith(
                    color: AppColors.lightError,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  context.l10n.deleteAccountTypeConfirm,
                  style: AppTypography.body1.copyWith(
                    color: AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  controller: confirmController,
                  decoration: InputDecoration(
                    hintText: context.l10n.deleteAccountTypeHint,
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: AppSpacing.xl),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(dialogContext, false),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: AppColors.ln200),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: Text(
                          context.l10n.cancelAction,
                          style: TextStyle(color: AppColors.lightTextPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final isMatch =
                              confirmController.text.trim().toUpperCase() ==
                              'DELETE';
                          if (!isMatch) return;

                          // 关闭键盘，确保 Toast 可见
                          FocusManager.instance.primaryFocus?.unfocus();

                          // 执行删除，成功才关闭弹窗
                          final success = await _performDeletion();
                          if (success && dialogContext.mounted) {
                            Navigator.pop(dialogContext, true);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.lightError,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                        child: Text(
                          context.l10n.deleteAction,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 执行账号删除操作 API 调用
  Future<bool> _performDeletion() async {
    if (!mounted) return false;

    showTopToast(context, context.l10n.deleteAccountLoading);

    try {
      // 尝试注销 FCM Token（失败不阻塞）
      await _tryDeregisterFcmToken();

      // 调用 API 删除账号
      final response = await ClientProvider.client.userAccountDelete();

      if (!response.isSuccessful) {
        throw Exception(
          'Failed to delete account: ${response.statusCode} ${response.error}',
        );
      }

      return true;
    } catch (e) {
      debugPrint('Delete account error: $e');
      if (mounted) {
        showTopToast(context, context.l10n.deleteAccountFailed, isError: true);
      }
      return false;
    }
  }

  /// 构建订阅警告横幅
  Widget _buildSubscriptionWarningBanner() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.lightWarning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.lightWarning),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.lightWarning,
            size: 20,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              context.l10n.deleteAccountSubscriptionWarning,
              style: AppTypography.caption.copyWith(
                color: AppColors.lightWarning,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 显示加载对话框

  /// 尝试注销 FCM Token
  Future<void> _tryDeregisterFcmToken() async {
    try {
      await FcmService.instance.unregisterToken();
    } catch (_) {
      debugPrint('FCM deregister failed, continuing with account deletion');
    }
  }

  /// 显示 App 语言选择对话框
  void _showAppLanguageDialog() {
    final currentLocaleState = ref.read(localeProvider);

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
              context.l10n.profile_selectAppLanguage,
              style: AppTypography.headline4.copyWith(
                color: AppColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: AppLanguages.supportedLanguages.map((option) {
                  final isSelected =
                      option.code == currentLocaleState.selectedCode;
                  return InkWell(
                    onTap: () {
                      ref.read(localeProvider.notifier).setLocale(option.code);
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
                          Row(
                            children: [
                              // Use Icon for "System Default", emoji for others
                              if (option.code == 'system') ...[
                                Container(
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.language,
                                    color: AppColors.ln700,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                              ] else if (option.flag.isNotEmpty) ...[
                                Text(
                                  option.flag,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: AppSpacing.md),
                              ],
                              Text(
                                option.code == 'system'
                                    ? context.l10n.profile_systemDefault
                                    : option.label,
                                style: AppTypography.body1.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
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

  void _showLanguageDialog(
    String title,
    String currentLanguageCode,
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
                children: LanguageConstants.supportedLanguages.map((option) {
                  final isSelected = option.code == currentLanguageCode;
                  return InkWell(
                    onTap: () {
                      onSelect(option.code);
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
                          Row(
                            children: [
                              if (option.flag.isNotEmpty) ...[
                                Text(
                                  option.flag,
                                  style: const TextStyle(fontSize: 24),
                                ),
                                const SizedBox(width: AppSpacing.md),
                              ],
                              Text(
                                LanguageConstants.getLocalizedLabel(
                                  context,
                                  option.code,
                                ),
                                style: AppTypography.body1.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                            ],
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
            // Custom Header - Fixed at the top
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[100],
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppColors.lightTextPrimary,
                        size: 24,
                      ),
                    ),
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

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Profile Info
                      Row(
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
                                            ? 'assets/images/avatars/user_avatar_female.png'
                                            : 'assets/images/avatars/user_avatar_male.png';
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

                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md,
                        ),
                        child: _buildSubscriptionSection(context),
                      ),

                      const SizedBox(height: AppSpacing.md),

                      const SizedBox(height: AppSpacing.md),

                      _buildStatisticsSection(context),

                      const SizedBox(height: AppSpacing.md),

                      Text(
                        // TODO: Add 'Statistics' and labels to l10n
                        context.l10n.profile_languageSettings,
                        style: AppTypography.subtitle1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // App Language Setting
                      Consumer(
                        builder: (context, ref, child) {
                          final localeState = ref.watch(localeProvider);
                          return _buildMenuCard(
                            context,
                            title: context.l10n.profile_appLanguage,
                            subtitle: localeState.selectedCode == 'system'
                                ? context.l10n.profile_systemDefault
                                : localeState.displayLabel,
                            icon: Icons.language,
                            iconColor: AppColors.lightTextSecondary,
                            onTap: _showAppLanguageDialog,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildMenuCard(
                        context,
                        title: context.l10n.profile_nativeLanguage,
                        subtitle: LanguageConstants.getLocalizedLabel(
                          context,
                          _nativeLanguage,
                        ),
                        icon: Icons.public,
                        iconColor: AppColors.lightTextSecondary,
                        onTap: () {
                          _showLanguageDialog(
                            context.l10n.profile_selectNative,
                            _nativeLanguage,
                            _updateNativeLanguage,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildMenuCard(
                        context,
                        title: context.l10n.profile_learningLanguage,
                        subtitle: LanguageConstants.getLocalizedLabel(
                          context,
                          _targetLanguage,
                        ),
                        icon: Icons.school,
                        iconColor: AppColors.lightTextSecondary,
                        onTap: () {
                          _showLanguageDialog(
                            context.l10n.profile_selectLearning,
                            _targetLanguage,
                            _updateTargetLanguage,
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      Text(
                        context.l10n.profile_tools,
                        style: AppTypography.subtitle1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _buildMenuCard(
                        context,
                        title: context.l10n.scenes_favorites, // Unified title
                        subtitle:
                            context.l10n.profile_vocabularySentencesChatHistory,

                        icon: Icons.bookmark,
                        iconColor: AppColors.lightTextSecondary,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const UnifiedFavoritesScreen(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.md),
                      // Logout Button
                      _buildMenuCard(
                        context,
                        title: context.l10n.profile_logOut,
                        icon: Icons.arrow_circle_right,
                        iconColor: AppColors.lightTextSecondary,
                        onTap: _handleLogout,
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Danger Zone Section
                      Text(
                        context.l10n.profile_dangerZone,
                        style: AppTypography.subtitle1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.lightError,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      // Delete Account Button
                      _buildMenuCard(
                        context,
                        title: context.l10n.deleteAccount,
                        icon: Icons.delete_forever_rounded,
                        iconColor: AppColors.lightError,
                        onTap: _handleDeleteAccount,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      // Version Info
                      if (_version.isNotEmpty)
                        Center(
                          child: Text(
                            'Version $_version ($_buildNumber)',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Text(
            'Statistics',
            style: AppTypography.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.lightTextPrimary,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.chat_bubble_rounded,
                value: _chatsCount,
                label: context.l10n.profile_statsChats,
                // Blue theme for Chats
                iconColor: const Color(0xFF2563EB),
                iconBgColor: const Color(0xFFEFF6FF), // Light Blue
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.timer_rounded,
                value: _studyMins,
                label: context.l10n.profile_statsMins,
                // Red/Rose theme for Minutes
                iconColor: const Color(0xFFE11D48),
                iconBgColor: const Color(0xFFFFF1F2), // Light Rose
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String label,
    required Color iconColor,
    required Color iconBgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 22, color: iconColor),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            value,
            style: AppTypography.headline3.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.lightTextPrimary,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTypography.body2.copyWith(
              color: AppColors.lightTextSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionSection(BuildContext context) {
    final tier = RevenueCatService().currentTier;
    if (tier == SubscriptionTier.free) {
      return _buildUpgradeCard(context);
    } else {
      return _buildRefinedSubscriptionCard(context, tier);
    }
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

  Widget _buildUpgradeCard(BuildContext context) {
    // Premium Teal/Cyan Palette for Upgrade Card
    const baseStart = AppColors.secondary; // Base Teal
    final baseEnd = AppColors.secondary.withOpacity(0.8);
    final accentGlow = Colors.white.withOpacity(0.3); // Bright White/Teal Glow

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.lg,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          children: [
            // 1. Base Gradient Background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [baseStart, baseEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // 2. Top-Right Large Glow
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [accentGlow, Colors.transparent],
                    stops: const [0.0, 0.8],
                  ),
                ),
              ),
            ),

            // 3. Bottom-Right Medium Glow
            Positioned(
              bottom: -40,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),

            // 4. Top-Left Subtle Highlight
            Positioned(
              top: -40,
              left: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                    stops: const [0.0, 0.6],
                  ),
                ),
              ),
            ),

            // 5. Content
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaywallScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(AppRadius.xl),
                splashColor: Colors.white.withOpacity(0.1),
                highlightColor: Colors.white.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      // Icon Badge
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.star_rounded,
                          color: AppColors.secondary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 18),
                      // Text
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              context.l10n.profile_upgradeToPro,
                              style: AppTypography.headline4.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "Unlock unlimited power",
                              style: AppTypography.body2.copyWith(
                                color: Colors.white.withOpacity(0.95),
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Arrow
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefinedSubscriptionCard(
    BuildContext context,
    SubscriptionTier tier,
  ) {
    final isPro = tier == SubscriptionTier.pro;

    // Premium Color Palette
    final baseStart = isPro
        ? const Color(0xFF7C3AED) // Rich Purple
        : const Color(0xFF2563EB); // Royal Blue
    final baseEnd = isPro
        ? const Color(0xFF5B21B6) // Deep Purple
        : const Color(0xFF1E40AF); // Deep Blue
    final accentGlow = isPro
        ? const Color(0xFFA78BFA).withOpacity(0.5) // Light Purple Glow
        : const Color(0xFF60A5FA).withOpacity(0.5); // Light Blue Glow

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.md,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Stack(
          children: [
            // 1. Base Gradient Background
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [baseStart, baseEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),

            // 2. Top-Right Large Glow (Ambient Light)
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [accentGlow.withOpacity(0.4), Colors.transparent],
                    stops: const [0.0, 0.8],
                  ),
                ),
              ),
            ),

            // 3. Bottom-Right Medium Glow (Secondary Light)
            Positioned(
              bottom: -40,
              right: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      isPro
                          ? const Color(0xFFC4B5FD).withOpacity(0.15)
                          : const Color(0xFF93C5FD).withOpacity(0.15),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.7],
                  ),
                ),
              ),
            ),

            // 4. Top-Left Subtle Highlight (Depth)
            Positioned(
              top: -40,
              left: -40,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                    stops: const [0.0, 0.6],
                  ),
                ),
              ),
            ),

            // 5. Content with Glass-like touch
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PaywallScreen(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(AppRadius.xl),
                splashColor: Colors.white.withOpacity(0.1),
                highlightColor: Colors.white.withOpacity(0.05),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 24, 24, isPro ? 24 : 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon Badge
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: baseStart.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          isPro ? Icons.diamond_rounded : Icons.star_rounded,
                          color: baseStart, // Match the theme color
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 18),
                      // Text Content
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    isPro ? 'TriTalk Pro' : 'TriTalk Plus',
                                    style: AppTypography.headline4.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20, // Slightly larger
                                      height: 1.2,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 0.5,
                                    ),
                                  ),
                                  child: Text(
                                    'ACTIVE',
                                    style: AppTypography.overline.copyWith(
                                      color: Colors.white,
                                      letterSpacing: 0.8,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              isPro
                                  ? 'Unlimited AI Practice'
                                  : 'Advanced Features Unlocked',
                              style: AppTypography.body2.copyWith(
                                color: Colors.white.withOpacity(0.95),
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Upgrade Button (Only for Plus)
                            if (!isPro) ...[
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const PaywallScreen(
                                              showProOnly: true,
                                            ),
                                      ),
                                    );
                                  },
                                  // Refined Button Design
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(
                                        30,
                                      ), // Pill shape
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'UPGRADE TO PRO',
                                          style: AppTypography.button.copyWith(
                                            color: baseStart, // Theme color
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Icon(
                                          Icons.arrow_forward_rounded,
                                          color: baseStart,
                                          size: 14,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
