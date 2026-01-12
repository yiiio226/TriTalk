import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user.dart';
import '../../features/auth/data/services/auth_service.dart';
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
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _authService.loginWithGoogle();

      if (success) {
        // Re-initialize to get fresh user data
        await _authService.init();

        state = state.copyWith(
          isLoading: false,
          status: AuthStatus.authenticated,
          user: _authService.currentUser,
          needsOnboarding: _authService.needsOnboarding,
        );

        // Migrate old data if needed
        await StorageKeyService().migrateOldDataIfNeeded();

        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Google login failed');
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthNotifier: Google login error - $e');
      }
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Login with Apple
  Future<bool> loginWithApple() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await _authService.loginWithApple();

      if (success) {
        // Re-initialize to get fresh user data
        await _authService.init();

        state = state.copyWith(
          isLoading: false,
          status: AuthStatus.authenticated,
          user: _authService.currentUser,
          needsOnboarding: _authService.needsOnboarding,
        );

        // Migrate old data if needed
        await StorageKeyService().migrateOldDataIfNeeded();

        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Apple login failed');
        return false;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthNotifier: Apple login error - $e');
      }
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Logout the current user
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.logout();

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
        isLoading: false,
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
