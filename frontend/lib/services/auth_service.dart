import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user.dart' as app_models;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  app_models.User? _currentUser;
  
  app_models.User? get currentUser => _currentUser;
  bool get isAuthenticated => Supabase.instance.client.auth.currentUser != null;

  Future<void> init() async {
    // Listen to auth state changes
    Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _loadUserFromSupabase(session.user.id);
      } else {
        _currentUser = null;
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
          .maybeSingle();
          
      if (response != null) {
        // Map DB fields to User model
        _currentUser = app_models.User(
          id: response['id'],
          name: response['name'] ?? '',
          email: Supabase.instance.client.auth.currentUser?.email ?? '',
          avatarUrl: response['avatar_url'],
          gender: response['gender'] ?? 'male',
          nativeLanguage: response['native_lang'] ?? 'Chinese (Simplified)',
          targetLanguage: response['target_lang'] ?? 'English',
        );
      } else {
        // Profile doesn't exist yet (first login) - create basic user object
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
      print('Google login error: $e');
      return false;
    }
  }

  // Apple Login via Supabase OAuth
  Future<bool> loginWithApple() async {
    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.apple,
      );
      return true;
    } catch (e) {
      print('Apple login error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await Supabase.instance.client.auth.signOut();
    _currentUser = null;
  }

  // Check if user needs onboarding (no profile data yet)
  bool get needsOnboarding {
    if (_currentUser == null) return false;
    // Check if gender/languages are still defaults (meaning they haven't completed onboarding)
    return _currentUser!.gender == 'male' && 
           _currentUser!.nativeLanguage == 'Chinese (Simplified)' &&
           _currentUser!.targetLanguage == 'English';
  }
}
