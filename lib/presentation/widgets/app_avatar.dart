import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class AppAvatarPreset {
  final String id;
  final String label;
  final List<Color> gradient;
  final IconData icon;

  const AppAvatarPreset({
    required this.id,
    required this.label,
    required this.gradient,
    required this.icon,
  });
}

/// Universal Cached Avatar Widget for AppliQ:
/// - Supports instant offline illustrated presets (Google & Apple styled gradients + icons).
/// - Automatically caches web images to memory and disk storage.
/// - Sanitizes and normalizes image URLs from Google, Unsplash, Imgur, Drive, etc.
/// - Gracefully falls back to initials or person icon on error or empty URL.
class AppAvatar extends StatelessWidget {
  final String? url;
  final double radius;
  final String? fallbackName;
  final bool? isDark;
  final VoidCallback? onTap;
  final Widget? badge;

  static const List<AppAvatarPreset> presets = [
    AppAvatarPreset(
      id: 'preset:kucing_oren',
      label: 'Mascot Cat',
      gradient: [Color(0xFFFF9966), Color(0xFFFF5E62)],
      icon: CupertinoIcons.paw_solid,
    ),
    AppAvatarPreset(
      id: 'preset:robot_ai',
      label: 'AI Mascot',
      gradient: [Color(0xFF6366F1), Color(0xFF06B6D4)],
      icon: CupertinoIcons.sparkles,
    ),
    AppAvatarPreset(
      id: 'preset:google_blue',
      label: 'Developer',
      gradient: [Color(0xFF4285F4), Color(0xFF1A73E8)],
      icon: CupertinoIcons.chevron_left_slash_chevron_right,
    ),
    AppAvatarPreset(
      id: 'preset:google_emerald',
      label: 'Strategist',
      gradient: [Color(0xFF0F9D58), Color(0xFF0B8043)],
      icon: CupertinoIcons.briefcase_fill,
    ),
    AppAvatarPreset(
      id: 'preset:google_coral',
      label: 'Designer',
      gradient: [Color(0xFFEA4335), Color(0xFFD93025)],
      icon: CupertinoIcons.paintbrush_fill,
    ),
    AppAvatarPreset(
      id: 'preset:google_amber',
      label: 'Star Talent',
      gradient: [Color(0xFFFBBC04), Color(0xFFF29900)],
      icon: CupertinoIcons.star_fill,
    ),
    AppAvatarPreset(
      id: 'preset:notion_dark',
      label: 'Minimalist',
      gradient: [Color(0xFF27272A), Color(0xFF18181B)],
      icon: CupertinoIcons.person_fill,
    ),
    AppAvatarPreset(
      id: 'preset:violet_pro',
      label: 'Product Lead',
      gradient: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
      icon: CupertinoIcons.rocket_fill,
    ),
    AppAvatarPreset(
      id: 'preset:cyber_teal',
      label: 'Data Analyst',
      gradient: [Color(0xFF14B8A6), Color(0xFF0EA5E9)],
      icon: CupertinoIcons.chart_bar_alt_fill,
    ),
    AppAvatarPreset(
      id: 'preset:rose_gold',
      label: 'Recruiter',
      gradient: [Color(0xFFF43F5E), Color(0xFFFB7185)],
      icon: CupertinoIcons.heart_fill,
    ),
    AppAvatarPreset(
      id: 'preset:sapphire',
      label: 'Leader',
      gradient: [Color(0xFF1E40AF), Color(0xFF3B82F6)],
      icon: CupertinoIcons.shield_fill,
    ),
    AppAvatarPreset(
      id: 'preset:sunset',
      label: 'Explorer',
      gradient: [Color(0xFFF97316), Color(0xFFE11D48)],
      icon: CupertinoIcons.sun_max_fill,
    ),
  ];

  const AppAvatar({
    super.key,
    required this.url,
    this.radius = 24,
    this.fallbackName,
    this.isDark,
    this.onTap,
    this.badge,
  });

  /// Normalize and sanitize image URLs from various sources (Google, Drive, redirect links)
  static String? sanitizeUrl(String? rawUrl) {
    if (rawUrl == null) return null;
    var trimmed = rawUrl.trim();
    if (trimmed.isEmpty) return null;

    if (trimmed.startsWith('preset:')) {
      return trimmed;
    }

    // Handle Google redirect URLs (e.g. https://www.google.com/url?q=https://...)
    if (trimmed.contains('google.com/url?') && trimmed.contains('q=')) {
      try {
        final uri = Uri.parse(trimmed);
        final extracted = uri.queryParameters['q'];
        if (extracted != null && extracted.isNotEmpty) {
          trimmed = extracted;
        }
      } catch (_) {}
    }

    // Handle Google Drive direct view links
    if (trimmed.contains('drive.google.com/file/d/')) {
      final match = RegExp(r'file/d/([a-zA-Z0-9_-]+)').firstMatch(trimmed);
      if (match != null) {
        final fileId = match.group(1);
        return 'https://drive.google.com/uc?export=view&id=$fileId';
      }
    }

    // Ensure scheme is present
    if (!trimmed.startsWith('http://') && !trimmed.startsWith('https://')) {
      if (trimmed.startsWith('//')) {
        trimmed = 'https:$trimmed';
      } else if (trimmed.contains('.')) {
        trimmed = 'https://$trimmed';
      } else {
        return null;
      }
    }

    return trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final effectiveIsDark = isDark ?? (Theme.of(context).brightness == Brightness.dark);
    final cleanUrl = sanitizeUrl(url);
    final size = radius * 2;

    Widget avatarWidget;

    if (cleanUrl == null || cleanUrl.isEmpty) {
      avatarWidget = _buildFallback(effectiveIsDark);
    } else if (cleanUrl.startsWith('preset:')) {
      avatarWidget = _buildPreset(cleanUrl, size);
    } else {
      final cacheSize = (size * 2.5).clamp(48, 300).toInt();
      avatarWidget = ClipOval(
        child: CachedNetworkImage(
          imageUrl: cleanUrl,
          width: size,
          height: size,
          fit: BoxFit.cover,
          memCacheWidth: cacheSize,
          memCacheHeight: cacheSize,
          httpHeaders: const {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
          fadeInDuration: const Duration(milliseconds: 200),
          fadeOutDuration: const Duration(milliseconds: 100),
          placeholder: (context, _) => _buildPlaceholder(effectiveIsDark),
          errorWidget: (context, _, __) => _buildFallback(effectiveIsDark),
        ),
      );
    }

    if (badge != null || onTap != null) {
      avatarWidget = Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          avatarWidget,
          if (badge != null)
            Positioned(
              right: 0,
              bottom: 0,
              child: badge!,
            ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }

  Widget _buildPreset(String presetId, double size) {
    AppAvatarPreset? preset;
    for (final p in presets) {
      if (p.id == presetId) {
        preset = p;
        break;
      }
    }
    preset ??= presets.first;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: preset.gradient,
        ),
        boxShadow: [
          BoxShadow(
            color: preset.gradient.first.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          preset.icon,
          size: size * 0.48,
          color: Colors.white,
        ),
      ),
    );
  }

  static const List<List<Color>> _googlePalettes = [
    [Color(0xFF1A73E8), Color(0xFF4285F4)], // Google Blue
    [Color(0xFF0F9D58), Color(0xFF34A853)], // Google Green
    [Color(0xFFD93025), Color(0xFFEA4335)], // Google Red
    [Color(0xFFE37400), Color(0xFFFBBC04)], // Google Amber
    [Color(0xFF8E24AA), Color(0xFFA142F4)], // Google Purple
    [Color(0xFF00897B), Color(0xFF12B5CB)], // Google Teal/Cyan
    [Color(0xFFD81B60), Color(0xFFFF4081)], // Google Pink
    [Color(0xFF3949AB), Color(0xFF5C6BC0)], // Google Indigo
    [Color(0xFFF4511E), Color(0xFFFF7043)], // Google Deep Orange
  ];

  static List<Color> _getInitialGradient(String text) {
    if (text.isEmpty) {
      return _googlePalettes[0];
    }
    int hash = 0;
    for (int i = 0; i < text.length; i++) {
      hash = text.codeUnitAt(i) + ((hash << 5) - hash);
    }
    final index = hash.abs() % _googlePalettes.length;
    return _googlePalettes[index];
  }

  Widget _buildPlaceholder(bool dark) {
    final name = fallbackName?.trim() ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '';
    final gradient = _getInitialGradient(name);

    if (initial.isNotEmpty) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
        ),
        child: Center(
          child: Text(
            initial,
            style: TextStyle(
              fontSize: radius * 0.95,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
      );
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
        border: Border.all(
          color: dark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.8,
        ),
      ),
      child: Center(
        child: Icon(
          CupertinoIcons.person_crop_circle_fill,
          size: radius * 1.1,
          color: dark ? AppColors.textHintDark : AppColors.textHint,
        ),
      ),
    );
  }

  Widget _buildFallback(bool dark) {
    final name = fallbackName?.trim() ?? '';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '';
    final gradient = _getInitialGradient(name);

    if (initial.isNotEmpty) {
      return Container(
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            initial,
            style: TextStyle(
              fontSize: radius * 0.95,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
        ),
      );
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: dark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
        border: Border.all(
          color: dark ? AppColors.borderDark : AppColors.borderLight,
          width: 0.8,
        ),
      ),
      child: Center(
        child: Icon(
          CupertinoIcons.person_crop_circle_fill,
          size: radius * 1.1,
          color: dark ? AppColors.textHintDark : AppColors.textHint,
        ),
      ),
    );
  }
}
