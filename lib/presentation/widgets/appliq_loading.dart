import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Loading Indicator kustom AppliQ:
/// Menggunakan logo AppliQ dengan background putih dan elemen AppliQ yang berkedip/pulsing sebagai indikator loading aktif.
class AppliqLoading extends StatefulWidget {
  final double logoSize;
  final double elementSize;
  final String? message;
  final bool isFullScreen;

  const AppliqLoading({
    super.key,
    this.logoSize = 68,
    this.elementSize = 32,
    this.message,
    this.isFullScreen = false,
  });

  const AppliqLoading.fullscreen({
    super.key,
    this.logoSize = 78,
    this.elementSize = 36,
    this.message,
  }) : isFullScreen = true;

  const AppliqLoading.compact({
    super.key,
    this.logoSize = 44,
    this.elementSize = 22,
    this.message,
  }) : isFullScreen = false;

  @override
  State<AppliqLoading> createState() => _AppliqLoadingState();
}

class _AppliqLoadingState extends State<AppliqLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacityAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _opacityAnimation = Tween<double>(begin: 0.25, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.90, end: 1.08).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Stack Logo + Blinking Graphic Element
        Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // AppliQ Logo dengan Background Putih
            Container(
              width: widget.logoSize,
              height: widget.logoSize,
              padding: EdgeInsets.all(widget.logoSize * 0.14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(widget.logoSize * 0.28),
                border: Border.all(
                  color: const Color(0xFFE4E4E7),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/appliq_logo.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.work_rounded,
                    color: Color(0xFF18181B),
                  ),
                ),
              ),
            ),

            // Blinking Element Indicator (Pulsing di pojok kanan bawah atau center overlay)
            Positioned(
              right: -widget.elementSize * 0.25,
              bottom: -widget.elementSize * 0.25,
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Container(
                        width: widget.elementSize,
                        height: widget.elementSize,
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF18181B) : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isDark ? const Color(0xFF3F3F46) : const Color(0xFFE4E4E7),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.25 * _opacityAnimation.value),
                              blurRadius: 12,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Image.asset(
                          'assets/images/appliq_element.png',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.auto_awesome,
                            size: 14,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        if (widget.message != null && widget.message!.isNotEmpty) ...[
          const SizedBox(height: 18),
          Text(
            widget.message!,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ],
    );

    if (widget.isFullScreen) {
      return Center(child: content);
    }

    return content;
  }
}
