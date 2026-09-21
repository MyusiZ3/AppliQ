import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/status_helper.dart';
import '../../data/models/job_application.dart';
import 'status_badge.dart';

class ApplicationCard extends StatelessWidget {
  final JobApplication application;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const ApplicationCard({
    super.key,
    required this.application,
    required this.onTap,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final feedbackText = StatusHelper.getFeedbackText(
      application.status,
      application.appliedDate,
    );
    final formattedDate = DateFormat('dd MMM yyyy').format(application.appliedDate);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Company Name & Favorite Button
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.positionTitle,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textDarkPrimary
                              : AppColors.textLightPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        application.companyName,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textDarkSecondary
                              : AppColors.textLightSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    application.isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    color: application.isFavorite
                        ? AppColors.statusInterview
                        : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                    size: 20,
                  ),
                  onPressed: onToggleFavorite,
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Tags: Location, Work System, Portal
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                if (application.location != null && application.location!.isNotEmpty)
                  _buildMetaTag(
                    Icons.location_on_outlined,
                    application.location!,
                    isDark,
                  ),
                _buildMetaTag(
                  Icons.work_outline,
                  application.workSystem.label,
                  isDark,
                ),
                _buildMetaTag(
                  Icons.language_outlined,
                  application.jobPortalCustom ?? application.jobPortal.label,
                  isDark,
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Divider
            Divider(
              height: 1,
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),

            const SizedBox(height: 10),

            // Footer: Smart Dynamic Feedback & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: isDark
                            ? AppColors.textDarkMuted
                            : AppColors.textLightMuted,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          '$formattedDate • $feedbackText',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textDarkSecondary
                                : AppColors.textLightSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: application.status, isCompact: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaTag(IconData icon, String label, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceSubtle : AppColors.lightSurfaceSubtle,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textDarkSecondary
                  : AppColors.textLightSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
