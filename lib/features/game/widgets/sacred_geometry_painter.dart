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
    final outerRadius = size.width * 0.45;

    // Derive triangle geometry
    final side = outerRadius * 1.65;
    final triangleHeight = sqrt(3) / 2 * side;

    final top = Offset(
      center.dx,
      center.dy - triangleHeight / 2,
    );

    final left = Offset(
      center.dx - side / 2,
      center.dy + triangleHeight / 2,
    );

    final right = Offset(
      center.dx + side / 2,
      center.dy + triangleHeight / 2,
    );

    // Derive circle geometry
    final circleRadius = outerRadius * 0.33;

    final topCircleCenter = Offset(
      center.dx,
      center.dy - outerRadius * 0.48,
    );

    final leftCircleCenter = Offset(
      center.dx - outerRadius * 0.36,
      center.dy + outerRadius * 0.18,
    );

    final rightCircleCenter = Offset(
      center.dx + outerRadius * 0.36,
      center.dy + outerRadius * 0.18,
    );

    // Derive inverted triangle
    final invertedTriangleTopY = topCircleCenter.dy;
    final invertedTriangleTopXDist = (invertedTriangleTopY - top.dy) / sqrt(3);

    final invertedTopL = Offset(center.dx - invertedTriangleTopXDist, invertedTriangleTopY);
    final invertedTopR = Offset(center.dx + invertedTriangleTopXDist, invertedTriangleTopY);
    final invertedBottom = Offset(center.dx, center.dy + outerRadius);

    // Build paths
    final mainTrianglePath = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();

    final invertedTrianglePath = Path()
      ..moveTo(invertedTopL.dx, invertedTopL.dy)
      ..lineTo(invertedTopR.dx, invertedTopR.dy)
      ..lineTo(invertedBottom.dx, invertedBottom.dy)
      ..close();

    // === DRAW ORDER ===

    // 1. Outer circle
    canvas.drawCircle(center, outerRadius, strokePaint);

    // 2. Three inner circles (full)
    canvas.drawCircle(topCircleCenter, circleRadius, strokePaint);
    canvas.drawCircle(leftCircleCenter, circleRadius, strokePaint);
    canvas.drawCircle(rightCircleCenter, circleRadius, strokePaint);

    // 3. Main triangle
    canvas.drawPath(mainTrianglePath, strokePaint);

    // 4. Inverted triangle
    canvas.drawPath(invertedTrianglePath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
