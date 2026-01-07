class Env {
  static const String supabaseUrl = 'https://adrbhdqyrnwoxlszzzsd.supabase.co';
  // AnnonKey is legacy, now it is recommend to use PublishableKey based on supabase doc.
  // And this is not sensitive information, so it is safe to shared publicly
  static const String supabaseAnonKey =
      'sb_publishable_nRj0KP57IDdQ7558VhbN-w_Oqvtrl9O';
  static const String localBackendUrl = 'http://192.168.1.4:8787';
  static const String prodBackendUrl =
      'https://tritalk-backend.tristart226.workers.dev';
}
