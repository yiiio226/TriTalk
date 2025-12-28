import 'dart:convert';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as app_models;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  app_models.User? _currentUser;
  bool _profileExistsInDatabase = false; // Track if user has completed onboarding
  
  app_models.User? get currentUser => _currentUser;
  bool get isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  Future<void> init() async {
    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      print('Auth state changed: ${data.event}');
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
        _currentUser = app_models.User(
          id: response['id'],
          name: response['name'] ?? '',
          email: Supabase.instance.client.auth.currentUser?.email ?? '',
          avatarUrl: response['avatar_url'],
          gender: response['gender'] ?? 'male',
          nativeLanguage: response['native_lang'] ?? 'Chinese (Simplified)',
          targetLanguage: response['target_lang'] ?? 'English',
        );
        
        // Cache user data locally
        await _saveUserToLocal(_currentUser!, true);
      } else {
        // Profile doesn't exist or gender not set - needs onboarding
        _profileExistsInDatabase = false;
        final authUser = Supabase.instance.client.auth.currentUser;
        if (authUser != null) {
          _currentUser = app_models.User(
            id: authUser.id,
            name: authUser.userMetadata?['full_name'] ?? authUser.email?.split('@')[0] ?? 'User',
            email: authUser.email ?? '',
            avatarUrl: authUser.userMetadata?['avatar_url'],
            gender: 'male',
            nativeLanguage: 'Chinese (Simplified)',
            targetLanguage: 'English',
          );
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
      // Fallback to local cache
      await _loadUserFromLocal();
    }
  }

  Future<void> _saveUserToLocal(app_models.User user, bool profileExists) async {
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
      print('Error caching user profile: $e');
    }
  }

  Future<void> _loadUserFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('cached_user_profile');
      if (userString != null) {
        final Map<String, dynamic> userMap = json.decode(userString);
        _currentUser = app_models.User(
          id: userMap['id'],
          name: userMap['name'],
          email: userMap['email'],
          avatarUrl: userMap['avatarUrl'],
          gender: userMap['gender'],
          nativeLanguage: userMap['nativeLanguage'],
          targetLanguage: userMap['targetLanguage'],
        );
        _profileExistsInDatabase = userMap['profileExists'] ?? false;
        print('Loaded user from local cache (profileExists: $_profileExistsInDatabase)');
      }
    } catch (e) {
      print('Error loading cached user profile: $e');
    }
  }

  // Google Login via Supabase OAuth
  Future<bool> loginWithGoogle() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.tritalk://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );

      return true;
    } catch (e) {
      if (e.toString().contains('PlatformException') && e.toString().contains('Error while launching')) {
        // Known issue with inAppWebView on some iOS versions where it throws but still works via deep link
        print('Suppressing launch error: $e');
        return false; 
      }
      print('Google login error: $e');
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
          print('Apple login error: Missing identity token');
          return false;
        }

        // Sign in to Supabase with the ID token
        await Supabase.instance.client.auth.signInWithIdToken(
          provider: OAuthProvider.apple,
          idToken: credential.identityToken!,
          accessToken: credential.authorizationCode, 
        );
      } else {
        // Web/other fallback
        await Supabase.instance.client.auth.signInWithOAuth(
          OAuthProvider.apple,
          redirectTo: 'io.supabase.tritalk://login-callback',
        );
      }
      return true;
    } catch (e) {
      print('Apple login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
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
