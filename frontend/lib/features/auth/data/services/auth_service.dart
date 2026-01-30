import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

import 'package:frontend/core/env/env.dart';

import 'package:frontend/features/auth/domain/models/user.dart';
import 'package:frontend/core/data/local/storage_key_service.dart';
import 'package:frontend/core/data/local/preferences_service.dart';
import 'package:frontend/core/cache/cache_initializer.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  bool _profileExistsInDatabase =
      false; // Track if user has completed onboarding

  User? get currentUser => _currentUser;
  bool get isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  Future<void> init() async {
    // First, load from local cache for fast startup
    // This ensures we have _profileExistsInDatabase set correctly before navigation
    await _loadUserFromLocal();

    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      if (kDebugMode) {
        debugPrint('Auth state changed: ${data.event}');
      }
      final session = data.session;
      if (session != null) {
        _loadUserFromSupabase(session.user.id);
      } else {
        _currentUser = null;
        _profileExistsInDatabase = false;
      }
    });

    // Load current session if exists
    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      await _loadUserFromSupabase(session.user.id);
    }
  }

  Future<void> _loadUserFromSupabase(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle()
          .timeout(const Duration(seconds: 5)); // Timeout to fallback quickly

      if (response != null && response['gender'] != null) {
        // Profile exists with gender set - user has completed onboarding
        _profileExistsInDatabase = true;

        String name = response['name'] ?? '';
        String email = Supabase.instance.client.auth.currentUser?.email ?? '';

        // Fallback for empty name
        if (name.isEmpty || name == 'User') {
          name = 'TriTalk Explorer';
        }

        // Handle Apple Private Relay email or empty email
        if (email.isEmpty || email.contains('privaterelay.appleid.com')) {
          email = 'Signed in with Apple';
        }

        _currentUser = User(
          id: response['id'],
          name: name,
          email: email,
          avatarUrl: response['avatar_url'],
          gender: response['gender'] ?? 'male',
          nativeLanguage: response['native_lang'] ?? 'Chinese (Simplified)',
          targetLanguage: response['target_lang'] ?? 'English',
        );

        // Cache user data locally
        await _saveUserToLocal(_currentUser!, true);

        // Sync language preferences from cloud to local PreferencesService
        // This ensures API calls use the latest language settings across devices
        final prefs = PreferencesService();
        await prefs.setNativeLanguage(_currentUser!.nativeLanguage);
        await prefs.setTargetLanguage(_currentUser!.targetLanguage);

        // Migrate old data to user-scoped keys
        await StorageKeyService().migrateOldDataIfNeeded();
      } else {
        // Profile doesn't exist or gender not set in database
        // Only set to false if we don't have cached confirmation from a previous successful load
        // This prevents incorrectly showing onboarding when there's a temporary database issue
        if (!_profileExistsInDatabase) {
          // _profileExistsInDatabase is already false, keep it that way
        }
        // If _profileExistsInDatabase is true from cache, keep it true
        final authUser = Supabase.instance.client.auth.currentUser;
        if (authUser != null) {
          String displayName = authUser.userMetadata?['full_name'] ?? '';
          String displayEmail = authUser.email ?? '';

          // Check if signed in with Apple
          final isAppleLogin = authUser.appMetadata['provider'] == 'apple';

          if (isAppleLogin) {
            if (displayName.isEmpty || displayName == 'User') {
              displayName = 'TriTalk Explorer';
            }
            if (displayEmail.isEmpty) {
              displayEmail = 'Signed in with Apple';
            }
          } else {
            // Default fallback for non-Apple users
            if (displayName.isEmpty) {
              displayName = authUser.email?.split('@')[0] ?? 'User';
            }
          }

          _currentUser = User(
            id: authUser.id,
            name: displayName,
            email: displayEmail,
            avatarUrl: authUser.userMetadata?['avatar_url'],
            gender: 'male',
            nativeLanguage: 'Chinese (Simplified)',
            targetLanguage: 'English',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading user profile: $e');
      }
      // Local cache already loaded in init(), just log the error
      // The cached _profileExistsInDatabase value will be used for navigation
    }
  }

  Future<void> _saveUserToLocal(User user, bool profileExists) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'avatarUrl': user.avatarUrl,
        'gender': user.gender,
        'nativeLanguage': user.nativeLanguage,
        'targetLanguage': user.targetLanguage,
        'profileExists': profileExists, // Save this flag too
      };
      await prefs.setString('cached_user_profile', json.encode(userJson));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error caching user profile: $e');
      }
    }
  }

  Future<void> _loadUserFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('cached_user_profile');
      if (userString != null) {
        final Map<String, dynamic> userMap = json.decode(userString);
        _currentUser = User(
          id: userMap['id'],
          name: userMap['name'],
          email: userMap['email'],
          avatarUrl: userMap['avatarUrl'],
          gender: userMap['gender'],
          nativeLanguage: userMap['nativeLanguage'],
          targetLanguage: userMap['targetLanguage'],
        );
        _profileExistsInDatabase = userMap['profileExists'] ?? false;
        if (kDebugMode) {
          debugPrint(
            'Loaded user from local cache (profileExists: $_profileExistsInDatabase)',
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading cached user profile: $e');
      }
    }
  }

  // Google Login via Supabase OAuth
  // Google Login via native Google Sign In
  Future<bool> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn.instance;

      // iOS needs clientId, Android is handled automatically via package name + SHA-1
      String? clientId;
      if (Platform.isIOS) {
        clientId = Env.googleOAuthIosClientId;
      }

      await googleSignIn.initialize(
        clientId: clientId,
        serverClientId: Env.googleOAuthWebClientId,
      );

      final googleUser = await googleSignIn.authenticate();

      final idToken = googleUser.authentication.idToken;
      if (idToken == null) {
        throw 'No ID Token found.';
      }
      final authClient = googleUser.authorizationClient;
      final authTokens = await authClient.authorizationForScopes([
        'openid',
        'profile',
        'email',
      ]);
      final accessToken = authTokens?.accessToken;
      if (accessToken == null) {
        throw 'No Access Token found.';
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Google login error: $e');
      }
      return false;
    }
  }

  // Apple Login via Supabase OAuth
  Future<bool> loginWithApple() async {
    try {
      if (Platform.isIOS) {
        // Native Apple Sign In on iOS
        final credential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );

        if (credential.identityToken == null) {
          if (kDebugMode) {
            debugPrint('Apple login error: Missing identity token');
          }
          return false;
        }

        // Sign in to Supabase with the ID token
        final authResponse = await Supabase.instance.client.auth
            .signInWithIdToken(
              provider: OAuthProvider.apple,
              idToken: credential.identityToken!,
              accessToken: credential.authorizationCode,
            );

        // Update user metadata with name if provided (Apple only provides this on first login)
        if (credential.givenName != null || credential.familyName != null) {
          final String fullName = [
            credential.givenName,
            credential.familyName,
          ].where((s) => s != null && s.isNotEmpty).join(' ');

          if (fullName.isNotEmpty && authResponse.user != null) {
            try {
              await Supabase.instance.client.auth.updateUser(
                UserAttributes(data: {'full_name': fullName}),
              );
              if (kDebugMode) {
                debugPrint(
                  'Updated Supabase user metadata with Apple name: $fullName',
                );
              }
            } catch (updateError) {
              if (kDebugMode) {
                debugPrint('Failed to update user metadata: $updateError');
              }
            }
          }
        }
      } else {
        // Web/other fallback
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.apple,
          redirectTo: 'io.supabase.tritalk://login-callback',
        );
      }
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Apple login error: $e');
      }
      return false;
    }
  }

  Future<void> logout() async {
    // Clear all user caches before signing out
    try {
      await clearAllUserCaches();
      if (kDebugMode) {
        debugPrint('AuthService: User caches cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Error clearing caches: $e');
      }
    }

    // Clear local user profile cache
    // This is critical for account deletion to work correctly
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_user_profile');
      if (kDebugMode) {
        debugPrint('AuthService: Local user profile cache cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('AuthService: Error clearing local profile cache: $e');
      }
    }

    await Supabase.instance.client.auth.signOut();
    _currentUser = null;
    _profileExistsInDatabase = false;
  }

  // Check if user needs onboarding (profile doesn't exist in database)
  bool get needsOnboarding {
    if (_currentUser == null) return false;
    return !_profileExistsInDatabase;
  }
}
