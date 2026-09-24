import 'package:flutter/material.dart';

class AppColors {
  // Neo-Pastel Palette Tokens (Non-Monochrome Mode)
  static const Color pastelLime = Color(0xFFECFF8E);       // Kuning / Lime Pastel (#ecff8e)
  static const Color pastelLavender = Color(0xFFBFAEF8);   // Ungu Pastel (#bfaef8)
  static const Color pastelSky = Color(0xFF8EEFFE);        // Biru Muda Pastel (#8eeffe)
  static const Color pastelMint = Color(0xFF9EF5CF);       // Mint / Soft Emerald
  static const Color pastelCoral = Color(0xFFFFB2BA);      // Coral / Rose
  static const Color pastelAmber = Color(0xFFFED888);      // Amber / Warm Gold
  static const Color textOnPastel = Color(0xFF0D0C0F);     // Hitam Pekat (#0d0c0f)

  // Neo-Pastel Dark Surface Tokens (#0d0c0f system)
  static const Color darkBackgroundPastel = Color(0xFF0D0C0F);     // Deep Obsidian Black
  static const Color darkSurfacePastel = Color(0xFF17161B);        // Deep Charcoal Card
  static const Color darkSurfaceVariantPastel = Color(0xFF201E27); // Raised Card
  static const Color darkBorderPastel = Color(0xFF292735);         // Subtle Border

  // Neo-Pastel Light Surface Tokens
  static const Color lightBackgroundPastel = Color(0xFFF8F9FB);
  static const Color lightSurfacePastel = Colors.white;
  static const Color lightSurfaceVariantPastel = Color(0xFFF0F1F5);
  static const Color lightBorderPastel = Color(0xFFE4E4EB);

  // Legacy / Fallback Indigo Tokens for backward compatibility
  static const Color primaryIndigo = Color(0xFFBFAEF8);       // Neo-Pastel Lavender primary
  static const Color primaryCobalt = Color(0xFFBFAEF8);
  static const Color primaryCobaltDark = Color(0xFF9F8EE0);
  static const Color indigoLight = Color(0xFFD6CBFC);
  static const Color indigoSubtle = Color(0xFFF4F0FF);
  static const Color indigoBorder = Color(0xFFE0D8FD);
  static const Color cyanAccent = Color(0xFF8EEFFE);          // Neo-Pastel Sky

  // Default / Monochrome Palette Tokens
  static const Color primary = Color(0xFFBFAEF8);
  static const Color primaryDark = Color(0xFF9F8EE0);
  static const Color primaryLight = Color(0xFFD6CBFC);

  static const Color background = Color(0xFFF4F4F5);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F3F5);

  static const Color backgroundDark = Color(0xFF121214);
  static const Color surfaceDark = Color(0xFF1E1E22);
  static const Color surfaceVariantDark = Color(0xFF28282D);
  static const Color borderDark = Color(0xFF323238);
  static const Color borderLight = Color(0xFFE5E5EA);

  // Typography Tokens
  static const Color textPrimary = Color(0xFF0D0C0F);      // Dark Obsidian (High Contrast)
  static const Color textSecondary = Color(0xFF5C5A69);    // Muted Slate
  static const Color textHint = Color(0xFF9896A4);         // Subtle Hint

  static const Color textPrimaryDark = Color(0xFFF8FAFC);  // Crisp Pure White
  static const Color textSecondaryDark = Color(0xFF9896A4);// Slate 400
  static const Color textHintDark = Color(0xFF666472);     // Slate 500

  // Semantic Status & Action Palette
  static const Color statusApplied = Color(0xFF9896A4);    // Muted Slate
  static const Color statusInterview = Color(0xFFFED888);  // Pastel Amber
  static const Color statusOffering = Color(0xFF9EF5CF);   // Pastel Mint
  static const Color statusAccepted = Color(0xFFECFF8E);   // Pastel Lime
  static const Color statusRejected = Color(0xFFFFB2BA);   // Pastel Coral
  static const Color statusNoResponse = Color(0xFF666472); // Slate Muted

  static const Color income = Color(0xFF9EF5CF);
  static const Color expense = Color(0xFFFFB2BA);
  static const Color warning = Color(0xFFFED888);
  static const Color shadow = Color(0x0A000000);

  // Dynamic Theme Resolvers
  static Color getPrimary({required bool isDark, required bool isMonochrome}) {
    if (isMonochrome) {
      return isDark ? Colors.white : const Color(0xFF18181B);
    }
    return pastelLavender;
  }

  static Color getBackground({required bool isDark, required bool isMonochrome}) {
    if (isMonochrome) {
      return isDark ? backgroundDark : background;
    }
    return isDark ? darkBackgroundPastel : lightBackgroundPastel;
  }

  static Color getSurface({required bool isDark, required bool isMonochrome}) {
    if (isMonochrome) {
      return isDark ? surfaceDark : surface;
    }
    return isDark ? darkSurfacePastel : lightSurfacePastel;
  }

  static Color getSurfaceVariant({required bool isDark, required bool isMonochrome}) {
    if (isMonochrome) {
      return isDark ? surfaceVariantDark : surfaceVariant;
    }
    return isDark ? darkSurfaceVariantPastel : lightSurfaceVariantPastel;
  }

  static Color getBorder({required bool isDark, required bool isMonochrome}) {
    if (isMonochrome) {
      return isDark ? borderDark : borderLight;
    }
    return isDark ? darkBorderPastel : lightBorderPastel;
  }
}
