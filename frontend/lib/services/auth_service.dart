import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? _currentUser;
  
  User? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('current_user');
    if (userJson != null) {
      _currentUser = User.fromJson(userJson);
    }
  }

  // Mock Google Login
  Future<User> loginWithGoogle() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Create mock user
    final user = User(
      id: 'google_12345',
      name: 'Google User',
      email: 'user@gmail.com',
      gender: 'male', // Default, will be set in onboarding
      nativeLanguage: 'Chinese',
      targetLanguage: 'English',
    );
    
    await _saveUser(user);
    return user;
  }

  // Mock Apple Login
  Future<User> loginWithApple() async {
     // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    // Create mock user
    final user = User(
      id: 'apple_67890',
      name: 'Apple User',
      email: 'user@icloud.com',
      gender: 'female', // Default
      nativeLanguage: 'Chinese',
      targetLanguage: 'English',
    );
    
    await _saveUser(user);
    return user;
  }

  Future<void> _saveUser(User user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', user.toJson());
  }

  Future<void> updateUser(User user) async {
    await _saveUser(user);
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
  }
  
  // Method to check if onboarding is needed
  // We'll assume if gender/languages are defaults or empty, we need onboarding
  // But for this flow, let's just use a flag or simple check
  bool get needsOnboarding {
    if (_currentUser == null) return false;
    // Simple check: if we just logged in with defaults, we might want to force onboarding.
    // However, for this implementation, we will always navigate to onboarding after login 
    // in the UI flow, unless we restore session.
    // A better way is to store an 'onboarded' flag in user or prefs.
    return false; 
  }
}
