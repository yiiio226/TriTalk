import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart' as app_models;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  app_models.User? _currentUser;
  
  app_models.User? get currentUser => _currentUser;
  bool get isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  Future<void> init() async {
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
          .maybeSingle();
          
      if (response != null) {
        // Map DB fields to User model
        _currentUser = app_models.User(
          id: response['id'],
          name: response['name'] ?? '',
          email: Supabase.instance.client.auth.currentUser?.email ?? '',
          avatarUrl: response['avatar_url'],
          gender: response['gender'] ?? 'male',
          nativeLanguage: response['native_lang'] ?? 'Chinese',
          targetLanguage: response['target_lang'] ?? 'English',
        );
      } else {
        // Profile doesn't exist yet (first login)
        // We'll treat this as needing onboarding
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  // Google Login via Supabase
  Future<void> loginWithGoogle() async {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'io.supabase.tritalk://login-callback/',
    );
     // Note: The actual flow returns via deep link. 
     // We need to listen to auth state changes in main or here.
  }

  // Apple Login via Supabase
  Future<void> loginWithApple() async {
    await Supabase.instance.client.auth.signInWithApple();
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    _currentUser = null;
  }
}
