import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// Loading Indicator kustom AppliQ:
/// Menggunakan maskot AppliQ (Kucing 3D) berlatar putih dengan elemen 3D (Briefcase, Notes, Chat)
/// yang berkedip/pulsing lembut di sekeliling maskot sebagai indikator loading aktif.
class AppliqLoading extends StatefulWidget {
  final double size;
  final String? message;
  final bool isFullScreen;
  final bool hasWhiteBackground;

  const AppliqLoading({
    super.key,
    this.size = 160,
    this.message,
    this.isFullScreen = false,
    this.hasWhiteBackground = false,
  });

  const AppliqLoading.fullscreen({
    super.key,
    this.size = 200,
    this.message,
    this.hasWhiteBackground = false,
  }) : isFullScreen = true;

  const AppliqLoading.compact({
    super.key,
    this.size = 80,
    this.message,
    this.hasWhiteBackground = false,
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

    _opacityAnimation = Tween<double>(begin: 0.2, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.08).animate(
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

    final logoAndElements = Container(
      width: widget.size,
      height: widget.size,
      padding: widget.hasWhiteBackground ? EdgeInsets.all(widget.size * 0.04) : EdgeInsets.zero,
      decoration: widget.hasWhiteBackground
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(widget.size * 0.28),
              border: Border.all(
                color: const Color(0xFFE4E4E7),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            )
          : null,
      child: Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          // 1. Maskot Utama (Kucing 3D Hitam CV)
          Image.asset(
            'assets/images/appliq_logo.png',
            fit: BoxFit.contain,
          ),

          // 2. Elemen 3D yang Berkedip/Pulsing di Sekitar Kucing (Briefcase & Notes)
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Image.asset(
                    'assets/images/appliq_element.png',
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        logoAndElements,
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
