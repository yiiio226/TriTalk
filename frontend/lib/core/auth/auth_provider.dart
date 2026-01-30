import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:frontend/features/auth/domain/models/user.dart';
import 'package:frontend/features/auth/data/services/auth_service.dart';
import 'package:frontend/features/subscription/data/services/revenue_cat_service.dart';
import 'package:frontend/core/data/language_constants.dart';
import 'package:frontend/core/services/fcm_service.dart';
import '../data/local/storage_key_service.dart';
import 'auth_state.dart';

/// Provider for accessing auth state globally
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

/// StateNotifier for managing authentication state
///
/// This class wraps the existing AuthService and exposes it through Riverpod,
/// providing reactive state updates to the UI.
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(const AuthState());

  /// Initialize auth state by checking current session
  Future<void> initialize() async {
    try {
      // Initialize the auth service (loads cached user, sets up listeners)
      await _authService.init();

      // Check current authentication status
      if (_authService.isAuthenticated) {
        final user = _authService.currentUser;
        final needsOnboarding = _authService.needsOnboarding;

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          needsOnboarding: needsOnboarding,
        );

        // Initialize RevenueCat with user ID
        if (user != null) {
          await RevenueCatService().initialize(user.id);
        }

        if (kDebugMode) {
          debugPrint(
            'AuthNotifier: initialized - authenticated (needsOnboarding: $needsOnboarding)',
          );
        }
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          needsOnboarding: false,
        );

        if (kDebugMode) {
          debugPrint('AuthNotifier: initialized - unauthenticated');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthNotifier: initialization error - $e');
      }
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  /// Login with Google
  Future<bool> loginWithGoogle() async {
    state = state.copyWith(loadingType: AuthLoadingType.google, error: null);

    try {
      final success = await _authService.loginWithGoogle();

      if (success) {
        // Re-initialize to get fresh user data
        await _authService.init();
        final user = _authService.currentUser;

        state = state.copyWith(
          loadingType: AuthLoadingType.none,
          status: AuthStatus.authenticated,
          user: user,
          needsOnboarding: _authService.needsOnboarding,
        );

        // Initialize RevenueCat
        if (user != null) {
          await RevenueCatService().initialize(user.id);
          await RevenueCatService().login(user.id);
        }

        // Migrate old data if needed
        await StorageKeyService().migrateOldDataIfNeeded();

        // [FCM] 请求通知权限并同步 Token
        // 不阻塞登录流程，后台执行
        FcmService.instance
            .requestPermissionAndSyncToken()
            .then((_) {
              if (kDebugMode) {
                debugPrint('AuthNotifier: FCM token synced after Google login');
              }
            })
            .catchError((e) {
              if (kDebugMode) {
                debugPrint('AuthNotifier: FCM sync failed (non-fatal): $e');
              }
            });

        return true;
      } else {
        state = state.copyWith(
          loadingType: AuthLoadingType.none,
          error: 'Google login failed',
        );
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthNotifier: Google login error - $e');
      }
      state = state.copyWith(
        loadingType: AuthLoadingType.none,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Login with Apple
  Future<bool> loginWithApple() async {
    state = state.copyWith(loadingType: AuthLoadingType.apple, error: null);

    try {
      final success = await _authService.loginWithApple();

      if (success) {
        // Re-initialize to get fresh user data
        await _authService.init();
        final user = _authService.currentUser;

        state = state.copyWith(
          loadingType: AuthLoadingType.none,
          status: AuthStatus.authenticated,
          user: user,
          needsOnboarding: _authService.needsOnboarding,
        );

        // Initialize RevenueCat
        if (user != null) {
          await RevenueCatService().initialize(user.id);
          await RevenueCatService().login(user.id);
        }

        // Migrate old data if needed
        await StorageKeyService().migrateOldDataIfNeeded();

        // [FCM] 请求通知权限并同步 Token
        // 不阻塞登录流程，后台执行
        FcmService.instance
            .requestPermissionAndSyncToken()
            .then((_) {
              if (kDebugMode) {
                debugPrint('AuthNotifier: FCM token synced after Apple login');
              }
            })
            .catchError((e) {
              if (kDebugMode) {
                debugPrint('AuthNotifier: FCM sync failed (non-fatal): $e');
              }
            });

        return true;
      } else {
        state = state.copyWith(
          loadingType: AuthLoadingType.none,
          error: 'Apple login failed',
        );
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthNotifier: Apple login error - $e');
      }
      state = state.copyWith(
        loadingType: AuthLoadingType.none,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    state = state.copyWith(loadingType: AuthLoadingType.general);

    try {
      // [关键] 先注销 FCM Token，再执行 Supabase 登出
      // 顺序很重要：登出后无法再访问 user_fcm_tokens 表
      await FcmService.instance.unregisterToken();

      await _authService.logout();
      await RevenueCatService().logout();

      state = const AuthState(status: AuthStatus.unauthenticated);

      if (kDebugMode) {
        debugPrint('AuthNotifier: logged out');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthNotifier: logout error - $e');
      }
      // Even if logout fails, mark as unauthenticated locally
      state = state.copyWith(
        loadingType: AuthLoadingType.none,
        status: AuthStatus.unauthenticated,
        error: e.toString(),
      );
    }
  }

  /// Clear any error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh user data (e.g., after profile update)
  Future<void> refreshUser() async {
    try {
      await _authService.init();

      if (_authService.isAuthenticated) {
        state = state.copyWith(
          user: _authService.currentUser,
          needsOnboarding: _authService.needsOnboarding,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthNotifier: refresh error - $e');
      }
    }
  }

  /// Mark onboarding as complete
  void onboardingComplete() {
    state = state.copyWith(needsOnboarding: false);
  }

  /// Get the current user (convenience getter)
  User? get currentUser => state.user;

  /// Check if authenticated (convenience getter)
  bool get isAuthenticated => state.status == AuthStatus.authenticated;
}

/// Provider for accessing current user's target language
///
/// This is the single source of truth for getting the user's target language.
/// All services (TTS, Speech Assessment, etc.) should use this provider
/// instead of querying the database directly.
///
/// Returns:
/// - User's target language (BCP-47 format like 'en-US', 'ja-JP')
/// - Falls back to default if user is not authenticated
final currentUserTargetLanguageProvider = Provider<String>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) {
    return LanguageConstants.defaultTargetLanguageCode;
  }
  // Normalize to ensure BCP-47 format (handles legacy data)
  return LanguageConstants.getIsoCode(user.targetLanguage);
});
