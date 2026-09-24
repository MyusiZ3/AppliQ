import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../utils/theme_manager.dart';

class NotchedPillCard<T> extends StatelessWidget {
  final List<NotchedPillItem<T>> items;
  final T selectedValue;
  final ValueChanged<T> onValueChanged;
  final Widget? child;

  const NotchedPillCard({
    super.key,
    required this.items,
    required this.selectedValue,
    required this.onValueChanged,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMono = ThemeManager.isMonochrome;
    final bgColor = AppColors.getSurface(isDark: isDark, isMonochrome: isMono);
    final borderColor = AppColors.getBorder(isDark: isDark, isMonochrome: isMono);
    final scaffoldBg = AppColors.getBackground(isDark: isDark, isMonochrome: isMono);

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: borderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // Top Notch Visual (MyDuitGweh Signature)
          Positioned(
            top: -1,
            child: Container(
              width: 38,
              height: 7,
              decoration: BoxDecoration(
                color: scaffoldBg,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(10),
                ),
                border: Border(
                  left: BorderSide(color: borderColor, width: 0.8),
                  right: BorderSide(color: borderColor, width: 0.8),
                  bottom: BorderSide(color: borderColor, width: 0.8),
                ),
              ),
            ),
          ),

          // Main Card Content with Pill Switcher
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Segmented Pill Container
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isMono
                        ? (isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5))
                        : (isDark ? AppColors.darkSurfaceVariantPastel : AppColors.lightSurfaceVariantPastel),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    children: items.map((item) {
                      final isSelected = item.value == selectedValue;
                      return Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            if (!isSelected) {
                              HapticFeedback.selectionClick();
                              onValueChanged(item.value);
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (isMono
                                      ? (isDark ? const Color(0xFF3F3F46) : Colors.white)
                                      : AppColors.pastelLime)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(100),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (item.icon != null) ...[
                                  Icon(
                                    item.icon,
                                    size: 15,
                                    color: isSelected
                                        ? (item.iconColor ?? (isMono ? (isDark ? Colors.white : const Color(0xFF18181B)) : AppColors.textOnPastel))
                                        : (isDark ? AppColors.textHintDark : AppColors.textHint),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Text(
                                  item.label,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    letterSpacing: -0.2,
                                    color: isSelected
                                        ? (isMono ? (isDark ? Colors.white : AppColors.textPrimary) : AppColors.textOnPastel)
                                        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                if (child != null) ...[
                  const SizedBox(height: 14),
                  child!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class NotchedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool showTopNotch;
  final bool showBottomNotch;
  final Color? backgroundColor;
  final Color? borderColor;

  const NotchedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 22,
    this.showTopNotch = true,
    this.showBottomNotch = false,
    this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMono = ThemeManager.isMonochrome;
    final effectiveBgColor = backgroundColor ?? AppColors.getSurface(isDark: isDark, isMonochrome: isMono);
    final effectiveBorderColor = borderColor ?? AppColors.getBorder(isDark: isDark, isMonochrome: isMono);
    final scaffoldBg = Theme.of(context).scaffoldBackgroundColor;

    return Container(
      decoration: BoxDecoration(
        color: effectiveBgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: effectiveBorderColor, width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // Top Notch Visual (MyDuitGweh Signature)
          if (showTopNotch)
            Positioned(
              top: -1,
              child: Container(
                width: 38,
                height: 7,
                decoration: BoxDecoration(
                  color: scaffoldBg,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(10),
                  ),
                  border: Border(
                    left: BorderSide(color: effectiveBorderColor, width: 0.8),
                    right: BorderSide(color: effectiveBorderColor, width: 0.8),
                    bottom: BorderSide(color: effectiveBorderColor, width: 0.8),
                  ),
                ),
              ),
            ),

          // Bottom Notch Visual (MyDuitGweh Signature)
          if (showBottomNotch)
            Positioned(
              bottom: -1,
              child: Container(
                width: 38,
                height: 7,
                decoration: BoxDecoration(
                  color: scaffoldBg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                  border: Border(
                    left: BorderSide(color: effectiveBorderColor, width: 0.8),
                    right: BorderSide(color: effectiveBorderColor, width: 0.8),
                    top: BorderSide(color: effectiveBorderColor, width: 0.8),
                  ),
                ),
              ),
            ),

          Padding(
            padding: padding,
            child: child,
          ),
        ],
      ),
    );
  }
}

class NotchedPillItem<T> {
  final T value;
  final String label;
  final IconData? icon;
  final Color? iconColor;

  const NotchedPillItem({
    required this.value,
    required this.label,
    this.icon,
    this.iconColor,
  });
}

