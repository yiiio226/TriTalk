import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../env.dart';
import '../data/local/preferences_service.dart';
import '../auth/auth_provider.dart';

/// Provider for SharedPreferences instance
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences not initialized');
});

/// Provider for app initialization status
final appInitializerProvider = FutureProvider<bool>((ref) async {
  return AppInitializer.initialize(ref);
});

/// Handles all app initialization logic
///
/// This class centralizes initialization of:
/// - Supabase client
/// - SharedPreferences
/// - Auth state
class AppInitializer {
  /// Initialize all app dependencies
  ///
  /// This should be called before the app starts rendering.
  /// Returns true if initialization was successful.
  static Future<bool> initialize(Ref ref) async {
    try {
      if (kDebugMode) {
        debugPrint('AppInitializer: Starting initialization...');
      }

      // 1. Initialize Supabase
      await _initSupabase();
      if (kDebugMode) {
        debugPrint('AppInitializer: Supabase initialized');
      }

      // 2. Initialize SharedPreferences
      await _initPreferences();
      if (kDebugMode) {
        debugPrint('AppInitializer: SharedPreferences initialized');
      }

      // 3. Initialize Auth State
      await ref.read(authProvider.notifier).initialize();
      if (kDebugMode) {
        debugPrint('AppInitializer: Auth state initialized');
      }

      if (kDebugMode) {
        debugPrint('AppInitializer: ✅ All initializations complete');
      }

      return true;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('AppInitializer: ❌ Initialization failed: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return false;
    }
  }

  /// Initialize Supabase client
  static Future<void> _initSupabase() async {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      debug: kDebugMode,
    );
  }

  /// Initialize SharedPreferences and PreferencesService
  static Future<void> _initPreferences() async {
    await PreferencesService().init();
  }
}

/// Alternative initialization method for use in main.dart
/// before ProviderScope is created
class AppBootstrap {
  static SharedPreferences? _prefs;

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('AppBootstrap.initialize() must be called first');
    }
    return _prefs!;
  }

  /// Bootstrap the app before creating ProviderScope
  ///
  /// This initializes dependencies that need to be available
  /// before Riverpod providers are created.
  static Future<void> initialize() async {
    if (kDebugMode) {
      debugPrint('AppBootstrap: Starting bootstrap...');
    }

    // Initialize Supabase first
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      debug: kDebugMode,
    );

    // Initialize SharedPreferences
    _prefs = await SharedPreferences.getInstance();

    // Initialize PreferencesService
    await PreferencesService().init();

    if (kDebugMode) {
      debugPrint('AppBootstrap: ✅ Bootstrap complete');
    }
  }
}
