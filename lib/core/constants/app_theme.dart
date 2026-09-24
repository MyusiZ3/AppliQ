import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../utils/theme_manager.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get lightTheme => buildLightTheme(ThemeManager.accentNotifier.value);
  static ThemeData get darkTheme => buildDarkTheme(ThemeManager.accentNotifier.value);

  static ThemeData buildLightTheme([AccentThemeMode accentMode = AccentThemeMode.color]) =>
      _buildTheme(Brightness.light, accentMode);

  static ThemeData buildDarkTheme([AccentThemeMode accentMode = AccentThemeMode.color]) =>
      _buildTheme(Brightness.dark, accentMode);

  static ThemeData _buildTheme(Brightness brightness, AccentThemeMode accentMode) {
    final isDark = brightness == Brightness.dark;
    final isMonochrome = accentMode == AccentThemeMode.monochrome;

    final primary = isMonochrome
        ? (isDark ? Colors.white : const Color(0xFF18181B))
        : AppColors.pastelLavender;

    final secondary = isMonochrome
        ? (isDark ? const Color(0xFFA1A1AA) : const Color(0xFF71717A))
        : AppColors.pastelLime;

    final background = AppColors.getBackground(isDark: isDark, isMonochrome: isMonochrome);
    final surface = AppColors.getSurface(isDark: isDark, isMonochrome: isMonochrome);
    final surfaceVariant = AppColors.getSurfaceVariant(isDark: isDark, isMonochrome: isMonochrome);
    final border = AppColors.getBorder(isDark: isDark, isMonochrome: isMonochrome);

    final textPrimary = isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final textHint = isDark ? AppColors.textHintDark : AppColors.textHint;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: isMonochrome ? (isDark ? const Color(0xFF18181B) : Colors.white) : AppColors.textOnPastel,
      secondary: secondary,
      onSecondary: AppColors.textOnPastel,
      surface: surface,
      onSurface: textPrimary,
      error: AppColors.expense,
      onError: AppColors.textOnPastel,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      textTheme: GoogleFonts.interTextTheme(
        TextTheme(
          displayLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: textPrimary,
            letterSpacing: -1.0,
          ),
          titleLarge: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: -0.2,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: textPrimary,
            letterSpacing: -0.4,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: textSecondary,
            letterSpacing: -0.2,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: textHint,
            letterSpacing: -0.1,
          ),
          labelLarge: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            letterSpacing: -0.3,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: isMonochrome
              ? (isDark ? const Color(0xFF18181B) : Colors.white)
              : AppColors.textOnPastel,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: border, width: 0.8),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: border, width: 0.8),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: textHint,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
          color: textPrimary,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 0.8,
        space: 0,
      ),
    );
  }
}
