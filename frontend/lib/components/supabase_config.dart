import 'package:frontend/core/env/env.dart';

class SupabaseConfig {
  static String get url => Env.supabaseUrl;
  static String get anonKey => Env.supabaseAnonKey;
}
