import 'package:flutter/material.dart';

/// Reusable AppliQ Logo Widget dengan opsi background putih dan radius elegan.
class AppliqLogo extends StatelessWidget {
  final double? width;
  final double? height;
  final double size;
  final bool hasWhiteBackground;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final BoxBorder? border;
  final List<BoxShadow>? boxShadow;

  const AppliqLogo({
    super.key,
    this.width,
    this.height,
    this.size = 72,
    this.hasWhiteBackground = true,
    this.borderRadius = 20,
    this.padding,
    this.border,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveWidth = width ?? size;
    final effectiveHeight = height ?? size;

    final logoImage = Image.asset(
      'assets/images/appliq_logo.png',
      width: effectiveWidth,
      height: effectiveHeight,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        return Icon(
          Icons.work_rounded,
          size: size * 0.6,
          color: const Color(0xFF18181B),
        );
      },
    );

    if (!hasWhiteBackground) {
      return logoImage;
    }

    return Container(
      width: effectiveWidth,
      height: effectiveHeight,
      padding: padding ?? EdgeInsets.all(size * 0.14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border ?? Border.all(
          color: const Color(0xFFE4E4E7),
          width: 1.0,
        ),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: logoImage),
    );
  }
}
