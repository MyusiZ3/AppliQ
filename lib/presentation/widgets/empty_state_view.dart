import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../utils/theme_manager.dart';
import 'appliq_loading.dart';

class EmptyStateView extends StatelessWidget {
  final IconData? icon;
  final Widget? customIcon;
  final String title;
  final String message;
  final Widget? action;
  final bool useAppLogo;
  final double logoSize;

  const EmptyStateView({
    super.key,
    this.icon,
    this.customIcon,
    required this.title,
    required this.message,
    this.action,
    this.useAppLogo = true,
    this.logoSize = 88,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMono = ThemeManager.isMonochrome;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight,
              minWidth: constraints.maxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(36, 0, 36, 110),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (customIcon != null)
                      customIcon!
                    else if (useAppLogo)
                      AppliqLoading(
                        size: logoSize,
                      )
                    else if (icon != null)
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          color: isMono
                              ? (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5))
                              : (isDark ? AppColors.darkSurfaceVariantPastel : AppColors.lightSurfaceVariantPastel),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            icon,
                            size: 36,
                            color: isMono
                                ? (isDark ? AppColors.textHintDark : AppColors.textHint)
                                : AppColors.pastelLavender,
                          ),
                        ),
                      ),
                    const SizedBox(height: 14),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.45,
                        letterSpacing: -0.2,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                    if (action != null) ...[
                      const SizedBox(height: 20),
                      action!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
