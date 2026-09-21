import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette (iOS Modern Blue)
  static const Color primary = Color(0xFF007AFF); // Apple Blue
  static const Color primaryDark = Color(0xFF0056D6); // Deep blue for pressed states
  static const Color primaryLight = Color(0xFF5AC8FA); // Apple Cyan

  // Deep Backgrounds & Surfaces (iOS System Style)
  static const Color background = Color(0xFFF2F2F7); // iOS SystemGray6 Light
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF1F3F5);

  // Dark Mode Palette (Charcoal / Midnight Dark, Non-Pure Black)
  static const Color backgroundDark = Color(0xFF121214); // Soft Charcoal Dark
  static const Color surfaceDark = Color(0xFF1E1E22);    // System Surface Dark
  static const Color surfaceVariantDark = Color(0xFF28282D); // Raised Variant Dark
  static const Color borderDark = Color(0xFF323238);
  static const Color borderLight = Color(0xFFE5E5EA);

  // Typography Tokens
  static const Color textPrimary = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textHint = Color(0xFFADB5BD);

  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF8E8E93); // Apple SystemGray
  static const Color textHintDark = Color(0xFF636366);

  // Semantic Status & Pastel Palette
  static const Color statusApplied = Color(0xFF8E8E93);     // SystemGray
  static const Color statusInterview = Color(0xFFFBBF24);   // Honey Gold
  static const Color statusOffering = Color(0xFF34D399);    // Mint Emerald
  static const Color statusAccepted = Color(0xFF30D158);    // iOS Green
  static const Color statusRejected = Color(0xFFF87171);    // Coral Salmon
  static const Color statusNoResponse = Color(0xFF636366);  // Deep Slate

  static const Color income = Color(0xFF34D399);
  static const Color expense = Color(0xFFF87171);
  static const Color warning = Color(0xFFFBBF24);
  static const Color shadow = Color(0x0A000000);
}
