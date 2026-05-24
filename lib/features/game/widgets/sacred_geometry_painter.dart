import 'dart:math';
import 'package:flutter/material.dart';

class SacredGeometryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width * 0.45; // Responsive scaling fitting center composition

    drawOuterCircle(canvas, center, outerRadius, strokePaint);

    final triangle = calculateTriangle(center, outerRadius);

    drawMainTriangle(canvas, triangle, strokePaint);

    drawInvertedTriangle(
      canvas,
      triangle,
      center,
      outerRadius,
      strokePaint,
    );

    drawInnerCircles(
      canvas,
      center,
      outerRadius,
      strokePaint,
    );
  }

  void drawOuterCircle(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    canvas.drawCircle(center, radius, paint);
  }

  Map<String, Offset> calculateTriangle(
    Offset center,
    double radius,
  ) {
    final double sin60 = sin(pi / 3);

    final top = Offset(
      center.dx,
      center.dy - radius,
    );

    final left = Offset(
      center.dx - radius * sin60,
      center.dy + radius * 0.5,
    );

    final right = Offset(
      center.dx + radius * sin60,
      center.dy + radius * 0.5,
    );

    return {
      'top': top,
      'left': left,
      'right': right,
    };
  }

  void drawMainTriangle(
    Canvas canvas,
    Map<String, Offset> points,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(points['top']!.dx, points['top']!.dy)
      ..lineTo(points['left']!.dx, points['left']!.dy)
      ..lineTo(points['right']!.dx, points['right']!.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  void drawInvertedTriangle(
    Canvas canvas,
    Map<String, Offset> points,
    Offset center,
    double radius,
    Paint paint,
  ) {
    // The top horizontal line is positioned at height y = -0.5 * radius.
    // The x-coordinates are mathematically calculated using the equilateral triangle
    // slope so the vertices lie exactly on the main triangle's side boundaries: x = ±(radius + y) / sqrt(3)
    final double topY = -0.5 * radius;
    final double topX = (radius + topY) / sqrt(3);

    final topL = Offset(center.dx - topX, center.dy + topY);
    final topR = Offset(center.dx + topX, center.dy + topY);
    final bottom = Offset(center.dx, center.dy + radius);

    final path = Path()
      ..moveTo(topL.dx, topL.dy)
      ..lineTo(topR.dx, topR.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..close();

    canvas.drawPath(path, paint);
  }

  void drawInnerCircles(
    Canvas canvas,
    Offset center,
    double radius,
    Paint paint,
  ) {
    final double r = radius * 0.38;
    final double d = radius * 0.32;
    final double sin60 = sin(pi / 3);

    // Top inner circle (centered on vertical axis)
    canvas.drawCircle(
      Offset(center.dx, center.dy - d),
      r,
      paint,
    );

    // Left inner circle (rotated 120 degrees counter-clockwise)
    canvas.drawCircle(
      Offset(center.dx - d * sin60, center.dy + d * 0.5),
      r,
      paint,
    );

    // Right inner circle (rotated 120 degrees clockwise)
    canvas.drawCircle(
      Offset(center.dx + d * sin60, center.dy + d * 0.5),
      r,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
