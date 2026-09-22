import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AccentThemeMode {
  monochrome,
  color,
}

class ThemeManager {
  static final ValueNotifier<ThemeMode> notifier = ValueNotifier(ThemeMode.system);
  static final ValueNotifier<AccentThemeMode> accentNotifier = ValueNotifier(AccentThemeMode.monochrome);

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt('app_theme_mode_index') ?? 0;
    if (index >= 0 && index < ThemeMode.values.length) {
      notifier.value = ThemeMode.values[index];
    }
    
    final accentIndex = prefs.getInt('app_accent_mode_index') ?? 0;
    if (accentIndex >= 0 && accentIndex < AccentThemeMode.values.length) {
      accentNotifier.value = AccentThemeMode.values[accentIndex];
    }

    _updateSystemOverlay();
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_theme_mode_index', mode.index);
    notifier.value = mode;
    _updateSystemOverlay();
  }

  static Future<void> setAccentThemeMode(AccentThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('app_accent_mode_index', mode.index);
    accentNotifier.value = mode;
  }

  static void _updateSystemOverlay() {
    SystemChrome.setSystemUIOverlayStyle(
      isDarkMode
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  static bool get isDarkMode {
    if (notifier.value == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;
    }
    return notifier.value == ThemeMode.dark;
  }

  static bool get isMonochrome => accentNotifier.value == AccentThemeMode.monochrome;
}
