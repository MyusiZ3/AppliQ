import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String supabaseUrl = '';
  static String supabaseAnonKey = '';
  static String googleWebClientId = '';
  static bool useMockData = true;

  static Future<void> initialize() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Jika .env tidak ditemukan, gunakan fallback default / mock mode
    }

    supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
    supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';
    googleWebClientId = dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '';
    
    final mockFlag = dotenv.env['USE_MOCK_DATA']?.toLowerCase() == 'true';
    useMockData = mockFlag || supabaseUrl.isEmpty || supabaseAnonKey.isEmpty;
  }

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
