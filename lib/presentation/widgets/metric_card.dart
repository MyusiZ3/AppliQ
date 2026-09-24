import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../utils/theme_manager.dart';

class MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color accentColor;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Border? border;

  const MetricCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.backgroundColor,
    this.foregroundColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMono = ThemeManager.isMonochrome;

    final bg = backgroundColor ?? AppColors.getSurface(isDark: isDark, isMonochrome: isMono);
    final cardBorder = border ?? Border.all(
      color: AppColors.getBorder(isDark: isDark, isMonochrome: isMono),
      width: 0.8,
    );

    final titleColor = foregroundColor != null
        ? foregroundColor!.withValues(alpha: 0.75)
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);

    final valueColor = foregroundColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    final iconBg = foregroundColor != null
        ? foregroundColor!.withValues(alpha: 0.14)
        : (isMono
            ? (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5))
            : (isDark
                ? AppColors.darkSurfaceVariantPastel
                : AppColors.pastelLavender.withValues(alpha: 0.22)));

    final iconFg = foregroundColor ?? (isMono
        ? (isDark ? Colors.white : const Color(0xFF18181B))
        : (isDark ? AppColors.pastelLavender : const Color(0xFF6B4EE6)));

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: cardBorder,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: titleColor,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 15,
                  color: iconFg,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
