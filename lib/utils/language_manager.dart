import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppLanguage {
  id,
  en,
  ja,
  ko,
}

class LanguageManager {
  static final ValueNotifier<AppLanguage> notifier = ValueNotifier(AppLanguage.id);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString('app_language_code');
    if (savedCode != null) {
      switch (savedCode) {
        case 'en':
          notifier.value = AppLanguage.en;
          break;
        case 'ja':
          notifier.value = AppLanguage.ja;
          break;
        case 'ko':
          notifier.value = AppLanguage.ko;
          break;
        case 'id':
        default:
          notifier.value = AppLanguage.id;
          break;
      }
    } else {
      // Check legacy 'app_language' string
      final legacy = prefs.getString('app_language');
      if (legacy == 'English') {
        notifier.value = AppLanguage.en;
      } else if (legacy == 'Japanese' || legacy == '日本語') {
        notifier.value = AppLanguage.ja;
      } else if (legacy == 'Korean' || legacy == '한국어') {
        notifier.value = AppLanguage.ko;
      } else {
        notifier.value = AppLanguage.id;
      }
    }
  }

  static Future<void> setLanguage(AppLanguage language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language_code', language.name);
    String legacyName = 'Bahasa Indonesia';
    if (language == AppLanguage.en) legacyName = 'English';
    if (language == AppLanguage.ja) legacyName = '日本語';
    if (language == AppLanguage.ko) legacyName = '한국어';
    await prefs.setString('app_language', legacyName);
    notifier.value = language;
  }

  static bool get isEnglish => notifier.value == AppLanguage.en;
  static bool get isIndonesian => notifier.value == AppLanguage.id;
  static bool get isJapanese => notifier.value == AppLanguage.ja;
  static bool get isKorean => notifier.value == AppLanguage.ko;
  static AppLanguage get current => notifier.value;
}
