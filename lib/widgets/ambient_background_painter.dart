import 'package:flutter/material.dart';

/// Draws overlapping radial gradient circles for a warm ambient background effect.
/// The [color1], [color2], and [color3] parameters control the three gradient circles.
class AmbientBackgroundPainter extends CustomPainter {
  final Color color1;
  final Color color2;
  final Color color3;

  const AmbientBackgroundPainter({
    this.color1 = const Color(0x26FF9A00),
    this.color2 = const Color(0x1AFF5A00),
    this.color3 = const Color(0x0FFFE808),
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawCircle(
      canvas,
      size,
      color: color1,
      centerX: 0.9,
      centerY: 0.1,
      radiusFactor: 0.7,
    );
    _drawCircle(
      canvas,
      size,
      color: color2,
      centerX: 0.15,
      centerY: 0.75,
      radiusFactor: 0.55,
    );
    _drawCircle(
      canvas,
      size,
      color: color3,
      centerX: 0.5,
      centerY: 0.5,
      radiusFactor: 0.4,
    );
  }

  void _drawCircle(
    Canvas canvas,
    Size size, {
    required Color color,
    required double centerX,
    required double centerY,
    required double radiusFactor,
  }) {
    final center = Offset(size.width * centerX, size.height * centerY);
    final radius = size.width * radiusFactor;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, Colors.transparent],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
