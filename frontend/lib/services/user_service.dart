import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'auth_service.dart';
import 'preferences_service.dart';
import 'api_service.dart';

class UserService {
  final AuthService _authService = AuthService();
  
  // Update user profile (local + backend sync)
  Future<void> updateUserProfile({
    String? gender,
    String? nativeLanguage,
    String? targetLanguage,
    String? name,
    String? avatarUrl,
  }) async {
    final currentUser = _authService.currentUser;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(
      gender: gender,
      nativeLanguage: nativeLanguage,
      targetLanguage: targetLanguage,
      name: name,
      avatarUrl: avatarUrl,
    );

    // 1. Update local storage
    await _authService.updateUser(updatedUser);

    // 3. Update legacy PreferencesService for backward compatibility
    final prefs = PreferencesService();
    if (nativeLanguage != null) {
      await prefs.setNativeLanguage(nativeLanguage);
    }
    if (targetLanguage != null) {
      await prefs.setTargetLanguage(targetLanguage);
    }
    
    // 4. Sync with Backend
    try {
      // Use the base URL from ApiService or hardcode for now if ApiService isn't easily accessible statically
      // Assuming ApiService has a static getter or we construct it.
      // Let's rely on a hardcoded path relative to what we know about ApiService in this project
      // But typically we should use the same baseUrl.
      // For now, I'll define sync logic here.
      
      const baseUrl = 'http://localhost:8787'; // or production URL
      // In a real app, use the configured environment URL.
      // We will skip the actual HTTP call integration here for the first pass or use a placeholder
      // until we confirm the backend endpoint exists.
      
      // await _syncWithBackend(updatedUser);
    } catch (e) {
      print('Failed to sync user: $e');
    }
  }

  Future<void> syncWithBackend(User user) async {
    try {
       // We can iterate this later to use the actual ApiService.baseUrl
       final url = Uri.parse('http://localhost:8787/user/sync');
       
       final response = await http.post(
         url,
         headers: {'Content-Type': 'application/json'},
         body: user.toJson(),
       );
       
       if (response.statusCode != 200) {
         throw Exception('Failed to sync user data: ${response.statusCode}');
       }
    } catch (e) {
      print('Sync error: $e');
      rethrow;
    }
  }
}
