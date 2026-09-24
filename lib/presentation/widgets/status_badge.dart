import 'package:flutter/material.dart';
import '../../core/constants/app_enums.dart';
import '../../core/localization/app_strings.dart';
import '../../core/utils/status_helper.dart';

import '../../core/constants/app_colors.dart';
import '../../utils/theme_manager.dart';

class StatusBadge extends StatelessWidget {
  final ApplicationStatus status;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.status,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isMono = ThemeManager.isMonochrome;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color fg;
    Border? border;

    if (isMono) {
      final color = StatusHelper.getStatusColor(status);
      bg = color.withValues(alpha: 0.12);
      fg = color;
      border = Border.all(color: color.withValues(alpha: 0.28), width: 0.8);
    } else {
      switch (status) {
        case ApplicationStatus.accepted:
        case ApplicationStatus.offering:
          bg = AppColors.pastelMint;
          fg = AppColors.textOnPastel;
          border = null;
          break;
        case ApplicationStatus.interview:
          bg = AppColors.pastelSky;
          fg = AppColors.textOnPastel;
          border = null;
          break;
        case ApplicationStatus.applied:
          bg = AppColors.pastelLime;
          fg = AppColors.textOnPastel;
          border = null;
          break;
        case ApplicationStatus.rejected:
          bg = AppColors.pastelCoral;
          fg = AppColors.textOnPastel;
          border = null;
          break;
        case ApplicationStatus.noResponse:
          bg = isDark ? const Color(0xFF201E27) : const Color(0xFFF0F1F5);
          fg = isDark ? AppColors.textHintDark : AppColors.textHint;
          border = Border.all(
            color: isDark ? AppColors.darkBorderPastel : AppColors.lightBorderPastel,
            width: 0.8,
          );
          break;
      }
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100),
        border: border,
      ),
      child: Text(
        AppStrings.localizedStatus(status),
        style: TextStyle(
          color: fg,
          fontSize: isCompact ? 11 : 12,
          fontWeight: isMono ? FontWeight.w600 : FontWeight.w700,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
