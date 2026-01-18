import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/features/auth/data/services/auth_service.dart';
import 'package:frontend/core/data/local/preferences_service.dart';

class UserService {
  final AuthService _authService = AuthService();
  final PreferencesService _preferencesService = PreferencesService();
  final _supabase = Supabase.instance.client;

  Future<void> updateUserProfile({
    String? gender,
    String? nativeLanguage,
    String? targetLanguage,
    String? name,
    String? avatarUrl,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final updates = {
      'id': user.id,
      'updated_at': DateTime.now().toIso8601String(),
      if (name != null) 'name': name,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (gender != null) 'gender': gender,
      if (nativeLanguage != null) 'native_lang': nativeLanguage,
      if (targetLanguage != null) 'target_lang': targetLanguage,
    };

    try {
      await _supabase.from('profiles').upsert(updates);

      // Update local preferences so API calls use the new language settings
      if (nativeLanguage != null) {
        await _preferencesService.setNativeLanguage(nativeLanguage);
      }
      if (targetLanguage != null) {
        await _preferencesService.setTargetLanguage(targetLanguage);
      }

      // Update local state by reloading
      await _authService.init();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating profile: $e');
      }
      rethrow;
    }
  }
}
