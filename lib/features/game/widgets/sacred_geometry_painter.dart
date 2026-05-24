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

    // 1. Draw outer circle
    canvas.drawCircle(center, outerRadius, strokePaint);

    // 2. Derive main triangle geometry
    final side = outerRadius * 1.73;
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

    // 3. Draw main triangle
    final mainTrianglePath = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();
    canvas.drawPath(mainTrianglePath, strokePaint);

    // 4. Derive circle geometry
    final circleRadius = side * 0.32;

    final topCircleCenter = Offset(
      center.dx,
      top.dy + circleRadius,
    );

    final leftCircleCenter = Offset(
      left.dx + circleRadius * 0.9,
      left.dy - circleRadius * 0.5,
    );

    final rightCircleCenter = Offset(
      right.dx - circleRadius * 0.9,
      right.dy - circleRadius * 0.5,
    );

    // 5. Draw inverted triangle
    // The top vertices are derived from the side boundary slope of the main triangle
    // at the height of topCircleCenter.dy.
    final invertedTriangleTopY = topCircleCenter.dy;
    final invertedTriangleTopXDist = (invertedTriangleTopY - top.dy) / sqrt(3);

    final invertedTopL = Offset(center.dx - invertedTriangleTopXDist, invertedTriangleTopY);
    final invertedTopR = Offset(center.dx + invertedTriangleTopXDist, invertedTriangleTopY);
    final invertedBottom = Offset(center.dx, center.dy + outerRadius);

    final invertedTrianglePath = Path()
      ..moveTo(invertedTopL.dx, invertedTopL.dy)
      ..lineTo(invertedTopR.dx, invertedTopR.dy)
      ..lineTo(invertedBottom.dx, invertedBottom.dy)
      ..close();
    canvas.drawPath(invertedTrianglePath, strokePaint);

    // 6. Draw inner arcs (partial — hides backside overlaps for clean geometry)

    // Top circle — only lower visible portion
    final topRect = Rect.fromCircle(center: topCircleCenter, radius: circleRadius);
    canvas.drawArc(topRect, pi * 0.1, pi * 0.8, false, strokePaint);

    // Left circle — visible arc facing inward/right
    final leftRect = Rect.fromCircle(center: leftCircleCenter, radius: circleRadius);
    canvas.drawArc(leftRect, pi * 0.75, pi * 1.5, false, strokePaint);

    // Right circle — visible arc facing inward/left
    final rightRect = Rect.fromCircle(center: rightCircleCenter, radius: circleRadius);
    canvas.drawArc(rightRect, -pi * 0.25, pi * 1.5, false, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
