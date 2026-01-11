import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../services/auth_service.dart';
import '../../models/user.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AsyncValue<User?>>((
  ref,
) {
  return AuthNotifier(AuthService());
});

class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AsyncValue.loading()) {
    _init();
  }

  Future<void> _init() async {
    // Initialize AuthService (loads from local storage)
    await _authService.init();
    _updateState();

    // Listen to Supabase auth changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      if (event == AuthChangeEvent.signedIn) {
        state = const AsyncValue.loading();
        // Wait for AuthService to populate user profile
        await _waitForUser();
      } else if (event == AuthChangeEvent.signedOut) {
        _updateState();
      }
    });
  }

  void _updateState() {
    state = AsyncValue.data(_authService.currentUser);
  }

  Future<void> _waitForUser() async {
    int attempts = 0;
    // Wait for AuthService to fetching profile (up to 6 seconds)
    while (attempts < 20 && _authService.currentUser == null) {
      await Future.delayed(const Duration(milliseconds: 300));
      attempts++;
    }
    _updateState();
  }

  Future<bool> loginWithGoogle() async {
    state = const AsyncValue.loading();
    try {
      final success = await _authService.loginWithGoogle();
      if (!success) {
        // If failed or cancelled, restore state
        _updateState();
        return false;
      }
      // If success, the auth listener will handle the loading -> data transition
      // But we can also wait here to be sure
      await _waitForUser();
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> loginWithApple() async {
    state = const AsyncValue.loading();
    try {
      final success = await _authService.loginWithApple();
      if (!success) {
        _updateState();
        return false;
      }
      await _waitForUser();
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _updateState();
  }

  bool get needsOnboarding => _authService.needsOnboarding;
}
