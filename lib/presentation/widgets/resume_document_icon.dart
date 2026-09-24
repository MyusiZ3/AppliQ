import 'package:flutter/material.dart';

/// Custom ATS Resume Document Icon matching the profile/cv document illustration
class ResumeDocumentIcon extends StatelessWidget {
  final double size;
  final Color color;

  const ResumeDocumentIcon({
    super.key,
    this.size = 20,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ResumeDocumentIconPainter(color),
      ),
    );
  }
}

class _ResumeDocumentIconPainter extends CustomPainter {
  final Color color;

  _ResumeDocumentIconPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 24.0;
    canvas.save();
    canvas.scale(scale, scale);

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // 1. Outer rounded document frame
    final outerRRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(2.2, 1.5, 19.6, 21),
      const Radius.circular(4.2),
    );
    canvas.drawRRect(outerRRect, strokePaint);

    // 2. Avatar head
    canvas.drawCircle(const Offset(7.8, 6.3), 2.1, fillPaint);

    // 3. Avatar shoulders / torso
    final bodyPath = Path()
      ..moveTo(4.8, 11.5)
      ..arcToPoint(
        const Offset(10.8, 11.5),
        radius: const Radius.circular(3.5),
        clockwise: true,
      )
      ..close();
    canvas.drawPath(bodyPath, fillPaint);

    // 4. Top-right bars
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(13.2, 5.2, 5.2, 1.8),
        const Radius.circular(0.9),
      ),
      fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(13.2, 8.2, 3.8, 1.8),
        const Radius.circular(0.9),
      ),
      fillPaint,
    );

    // 5. Bottom 3 bullet lines
    // Row 1
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(4.8, 13.8, 2.2, 1.6),
        const Radius.circular(0.8),
      ),
      fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8.8, 13.8, 9.6, 1.6),
        const Radius.circular(0.8),
      ),
      fillPaint,
    );

    // Row 2
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(4.8, 16.6, 2.2, 1.6),
        const Radius.circular(0.8),
      ),
      fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8.8, 16.6, 6.8, 1.6),
        const Radius.circular(0.8),
      ),
      fillPaint,
    );

    // Row 3
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(4.8, 19.4, 2.2, 1.6),
        const Radius.circular(0.8),
      ),
      fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8.8, 19.4, 8.6, 1.6),
        const Radius.circular(0.8),
      ),
      fillPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _ResumeDocumentIconPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
