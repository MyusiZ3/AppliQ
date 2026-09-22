import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  id,
  en,
}

class LanguageManager {
  static final ValueNotifier<AppLanguage> notifier = ValueNotifier(AppLanguage.id);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('app_language_code');
    if (savedCode != null) {
      if (savedCode == 'en') {
        notifier.value = AppLanguage.en;
      } else {
        notifier.value = AppLanguage.id;
      }
    } else {
      // Check legacy 'app_language' string
      final legacy = prefs.getString('app_language');
      if (legacy == 'English') {
        notifier.value = AppLanguage.en;
      } else {
        notifier.value = AppLanguage.id;
      }
    }
  }

  static Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language_code', language.name);
    await prefs.setString(
      'app_language',
      language == AppLanguage.en ? 'English' : 'Bahasa Indonesia',
    );
    notifier.value = language;
  }

  static bool get isEnglish => notifier.value == AppLanguage.en;
  static bool get isIndonesian => notifier.value == AppLanguage.id;
  static AppLanguage get current => notifier.value;
}
