import 'package:flutter/material.dart';
import 'dart:math';

class RectDotProgress extends StatelessWidget {
  final double percent;
  final String? label;
  final double size;
  final Color color;
  final Color backgroundColor;

  const RectDotProgress({
    super.key,
    required this.percent,
    this.label,
    this.size = 120,
    this.color = Colors.blue,
    this.backgroundColor = const Color(0xFFE0E0E0),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: RectDotPainter(percent: percent, color: color, backgroundColor: backgroundColor),
          ),

          /// Percentage text
          // Column(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     Text("${percent.toInt()}%", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),

          //     if (label != null) Text(label!, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          //   ],
          // ),
        ],
      ),
    );
  }
}

/// Painter
class RectDotPainter extends CustomPainter {
  final double? percent;
  final Color color;
  final Color backgroundColor;

  RectDotPainter({this.percent, required this.color, required this.backgroundColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    const double dotWidth = 12;
    const double dotHeight = 4;
    const double gap = 2;

    final double fullCircle = 2 * pi;
    final double step = (dotWidth + gap) / radius;
    final double progressAngle = fullCircle * (percent! / 100);

    /// Background dots
    final bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    for (double angle = 0; angle < fullCircle; angle += step) {
      _drawDot(canvas, center, radius, angle, dotWidth, dotHeight, bgPaint);
    }

    /// Progress dots
    final fgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    for (double angle = 0; angle < progressAngle; angle += step) {
      _drawDot(canvas, center, radius, angle, dotWidth, dotHeight, fgPaint);
    }
  }

  void _drawDot(Canvas canvas, Offset center, double radius, double angle, double w, double h, Paint paint) {
    final dx = center.dx + radius * cos(angle - pi / 2);
    final dy = center.dy + radius * sin(angle - pi / 2);

    canvas.save();
    canvas.translate(dx, dy);
    canvas.rotate(angle - pi / 2);

    canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: w, height: h), paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
