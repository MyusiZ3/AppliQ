import 'package:flutter/material.dart';

class AppColors {
  // Option 2: Electric Indigo & Royal Cobalt Palette Tokens
  static const Color primaryIndigo = Color(0xFF6366F1);       // Electric Indigo 500
  static const Color primaryCobalt = Color(0xFF4F46E5);       // Royal Cobalt 600
  static const Color primaryCobaltDark = Color(0xFF4338CA);   // Deep Cobalt 700
  static const Color indigoLight = Color(0xFF818CF8);         // Indigo 400
  static const Color indigoSubtle = Color(0xFFEEF2FF);        // Indigo 50
  static const Color indigoBorder = Color(0xFFC7D2FE);        // Indigo 200
  static const Color cyanAccent = Color(0xFF38BDF8);          // Electric Cyan

  // Option 2 Dark Surface Tokens (Deep Indigo Night)
  static const Color darkBackgroundIndigo = Color(0xFF0B0E17);     // Deep Blue-Black
  static const Color darkSurfaceIndigo = Color(0xFF131826);        // Midnight Indigo Card
  static const Color darkSurfaceVariantIndigo = Color(0xFF1C2438); // Raised Slate Card
  static const Color darkBorderIndigo = Color(0xFF263248);         // Subtle Slate Border

  // Option 2 Light Surface Tokens (Royal Slate Mist)
  static const Color lightBackgroundIndigo = Color(0xFFF4F6FB);    // Slate Mist
  static const Color lightSurfaceIndigo = Colors.white;
  static const Color lightSurfaceVariantIndigo = Color(0xFFEEF2F6);
  static const Color lightBorderIndigo = Color(0xFFE2E8F0);

  // Default / Monochrome Palette Tokens
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryDark = Color(0xFF4338CA);
  static const Color primaryLight = Color(0xFF6366F1);

  static const Color background = Color(0xFFF4F4F5);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F3F5);

  static const Color backgroundDark = Color(0xFF121214);
  static const Color surfaceDark = Color(0xFF1E1E22);
  static const Color surfaceVariantDark = Color(0xFF28282D);
  static const Color borderDark = Color(0xFF323238);
  static const Color borderLight = Color(0xFFE5E5EA);

  // Typography Tokens
  static const Color textPrimary = Color(0xFF0F172A);      // Slate 900 (High Contrast)
  static const Color textSecondary = Color(0xFF475569);    // Slate 600
  static const Color textHint = Color(0xFF94A3B8);         // Slate 400

  static const Color textPrimaryDark = Color(0xFFF8FAFC);  // Crisp Pure White
  static const Color textSecondaryDark = Color(0xFF94A3B8);// Slate 400
  static const Color textHintDark = Color(0xFF64748B);     // Slate 500

  // Semantic Status & Action Palette
  static const Color statusApplied = Color(0xFF94A3B8);    // Slate
  static const Color statusInterview = Color(0xFFF59E0B);  // Amber Gold
  static const Color statusOffering = Color(0xFF10B981);   // Emerald Mint
  static const Color statusAccepted = Color(0xFF22C55E);   // Green
  static const Color statusRejected = Color(0xFFEF4444);   // Rose Red
  static const Color statusNoResponse = Color(0xFF64748B); // Slate Muted

  static const Color income = Color(0xFF10B981);
  static const Color expense = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color shadow = Color(0x0A000000);

  // Dynamic Theme Resolvers
  static Color getPrimary({required bool isDark, required bool isMonochrome}) {
    if (isMonochrome) {
      return isDark ? Colors.white : const Color(0xFF18181B);
    }
    return isDark ? primaryIndigo : primaryCobalt;
  }

  static Color getBackground({required bool isDark, required bool isMonochrome}) {
    if (isMonochrome) {
      return isDark ? backgroundDark : background;
    }
    return isDark ? darkBackgroundIndigo : lightBackgroundIndigo;
  }

  static Color getSurface({required bool isDark, required bool isMonochrome}) {
    if (isMonochrome) {
      return isDark ? surfaceDark : surface;
    }
    return isDark ? darkSurfaceIndigo : lightSurfaceIndigo;
  }

  static Color getSurfaceVariant({required bool isDark, required bool isMonochrome}) {
    if (isMonochrome) {
      return isDark ? surfaceVariantDark : surfaceVariant;
    }
    return isDark ? darkSurfaceVariantIndigo : lightSurfaceVariantIndigo;
  }

  static Color getBorder({required bool isDark, required bool isMonochrome}) {
    if (isMonochrome) {
      return isDark ? borderDark : borderLight;
    }
    return isDark ? darkBorderIndigo : lightBorderIndigo;
  }
}
