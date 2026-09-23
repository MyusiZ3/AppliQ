import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/localization/app_strings.dart';
import '../../core/utils/status_helper.dart';
import '../../data/models/job_application.dart';
import 'status_badge.dart';

class ApplicationCard extends StatelessWidget {
  final JobApplication application;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  static final DateFormat _cardDateFormat = DateFormat('dd MMM yyyy');

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
    final formattedDate = _cardDateFormat.format(application.appliedDate);

    return RepaintBoundary(
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 0.8,
          ),
        ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Position & Bookmark
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            application.positionTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            application.companyName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        application.isFavorite
                            ? CupertinoIcons.bookmark_fill
                            : CupertinoIcons.bookmark,
                        color: application.isFavorite
                            ? AppColors.warning
                            : (isDark ? AppColors.textHintDark : AppColors.textHint),
                        size: 20,
                      ),
                      onPressed: onToggleFavorite,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    if (application.location != null && application.location!.isNotEmpty)
                      _buildMetaTag(
                        CupertinoIcons.location_solid,
                        application.location!,
                        isDark,
                        maxWidth: 150,
                      ),
                    _buildMetaTag(
                      CupertinoIcons.briefcase,
                      AppStrings.localizedWorkSystem(application.workSystem),
                      isDark,
                    ),
                    _buildMetaTag(
                      CupertinoIcons.globe,
                      application.jobPortalCustom ?? AppStrings.localizedJobPortal(application.jobPortal),
                      isDark,
                      maxWidth: 130,
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Divider(
                  height: 1,
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),

                const SizedBox(height: 10),

                // Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            CupertinoIcons.clock,
                            size: 13,
                            color: isDark ? AppColors.textHintDark : AppColors.textHint,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              '$formattedDate • $feedbackText',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                                fontWeight: FontWeight.w500,
                                letterSpacing: -0.1,
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
        ),
      ),
    ),
  );
}

  Widget _buildMetaTag(IconData icon, String label, bool isDark, {double? maxWidth}) {
    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 11,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              letterSpacing: -0.1,
            ),
          ),
        ),
      ],
    );

    if (maxWidth != null) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: content,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceVariantDark : AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: content,
    );
  }
}
