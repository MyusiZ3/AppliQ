import 'package:flutter/material.dart';

class AppColors {
  // Background & Surfaces (Clean Slate / Charcoal)
  static const Color darkBackground = Color(0xFF0F172A); // Slate 900
  static const Color darkSurface = Color(0xFF1E293B);    // Slate 800
  static const Color darkSurfaceSubtle = Color(0xFF334155); // Slate 700
  static const Color darkBorder = Color(0xFF334155);     // Slate 700

  static const Color lightBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceSubtle = Color(0xFFF1F5F9); // Slate 100
  static const Color lightBorder = Color(0xFFE2E8F0);     // Slate 200

  // Brand / Solid Accent (Solid Deep Blue & Crisp Teal)
  static const Color primary = Color(0xFF2563EB); // Blue 600
  static const Color primaryHover = Color(0xFF1D4ED8); // Blue 700
  static const Color primaryLight = Color(0xFFDBEAFE); // Blue 100

  // Semantic Status Colors (Flat & Readable)
  static const Color statusApplied = Color(0xFF64748B);     // Slate 500
  static const Color statusInterview = Color(0xFFD97706);   // Amber 600
  static const Color statusOffering = Color(0xFF059669);    // Emerald 600
  static const Color statusAccepted = Color(0xFF16A34A);    // Green 600
  static const Color statusRejected = Color(0xFFDC2626);    // Red 600
  static const Color statusNoResponse = Color(0xFF475569);  // Slate 600

  // Text Colors
  static const Color textDarkPrimary = Color(0xFFF8FAFC);
  static const Color textDarkSecondary = Color(0xFF94A3B8);
  static const Color textDarkMuted = Color(0xFF64748B);

  static const Color textLightPrimary = Color(0xFF0F172A);
  static const Color textLightSecondary = Color(0xFF475569);
  static const Color textLightMuted = Color(0xFF94A3B8);
}
