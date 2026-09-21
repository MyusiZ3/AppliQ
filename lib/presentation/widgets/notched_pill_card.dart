import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';

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
    final bgColor = isDark ? AppColors.surfaceDark : AppColors.surface;
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final scaffoldBg = isDark ? AppColors.backgroundDark : AppColors.background;

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
                    color: isDark ? const Color(0xFF27272A) : const Color(0xFFF4F4F5),
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
                                  ? (isDark ? const Color(0xFF3F3F46) : Colors.white)
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
                                        ? (item.iconColor ?? (isDark ? Colors.white : const Color(0xFF18181B)))
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
                                        ? (isDark ? Colors.white : AppColors.textPrimary)
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
