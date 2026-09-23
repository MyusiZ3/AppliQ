import 'package:flutter/material.dart';
import '../../core/constants/app_enums.dart';
import '../../core/localization/app_strings.dart';
import '../../core/utils/status_helper.dart';

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
    final color = StatusHelper.getStatusColor(status);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 8 : 10,
        vertical: isCompact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
          width: 0.8,
        ),
      ),
      child: Text(
        AppStrings.localizedStatus(status),
        style: TextStyle(
          color: color,
          fontSize: isCompact ? 11 : 12,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
        ),
      ),
    );
  }
}
