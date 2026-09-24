import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String supabaseUrl = '';
  static String supabaseAnonKey = '';
  static String googleWebClientId = '';
  static bool useMockData = true;
  static Future<void> initialize() async {
    // Prioritaskan compile-time environment variables (--dart-define / --dart-define-from-file)
    const envUrl = String.fromEnvironment('SUPABASE_URL');
    const envAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
    const envGoogleClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');
    const envMock = String.fromEnvironment('USE_MOCK_DATA');

    try {
      await dotenv.load(fileName: '.env');
    } catch (_) {
      // Jika .env tidak ditemukan, gunakan fallback default / mock mode
    }

    supabaseUrl = envUrl.isNotEmpty ? envUrl : (dotenv.env['SUPABASE_URL'] ?? '');
    supabaseAnonKey = envAnonKey.isNotEmpty ? envAnonKey : (dotenv.env['SUPABASE_ANON_KEY'] ?? '');
    googleWebClientId = envGoogleClientId.isNotEmpty ? envGoogleClientId : (dotenv.env['GOOGLE_WEB_CLIENT_ID'] ?? '');
    
    final mockStr = envMock.isNotEmpty ? envMock : (dotenv.env['USE_MOCK_DATA'] ?? '');
    final mockFlag = mockStr.toLowerCase() == 'true';
    useMockData = mockFlag || supabaseUrl.isEmpty || supabaseAnonKey.isEmpty;
  }

  static bool get isSupabaseConfigured =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
