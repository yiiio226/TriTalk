import 'package:supabase_flutter/supabase_flutter.dart';
import '../../components/supabase_config.dart';
import '../../services/preferences_service.dart';

class AppInitializer {
  static Future<void> init() async {
    // 1. Initialize Supabase
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );

    // 2. Initialize SharedPreferences
    await PreferencesService().init();
  }
}
