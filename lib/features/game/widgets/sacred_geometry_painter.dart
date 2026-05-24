import 'dart:math';
import 'package:flutter/material.dart';

class SacredGeometryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final R = size.width * 0.45;

    // Paints
    final strokePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final doubleStrokePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final axisPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    // === 1. DRAW AXES ===
    // Vertical dashed axis
    double y = -R;
    const dash = 6.0;
    const gap = 4.0;
    while (y < R) {
      canvas.drawLine(
        Offset(center.dx, center.dy + y),
        Offset(center.dx, center.dy + y + dash),
        axisPaint,
      );
      y += dash + gap;
    }

    // Horizontal dashed axis
    double x = -R;
    while (x < R) {
      canvas.drawLine(
        Offset(center.dx + x, center.dy),
        Offset(center.dx + x + dash, center.dy),
        axisPaint,
      );
      x += dash + gap;
    }

    // Axis tick marks
    const tickLen = 4.0;
    for (double i = -R; i <= R; i += R / 4) {
      if (i.abs() < 1.0) continue; // skip center
      // vertical ticks on horizontal axis
      canvas.drawLine(
        Offset(center.dx + i, center.dy - tickLen),
        Offset(center.dx + i, center.dy + tickLen),
        axisPaint,
      );
      // horizontal ticks on vertical axis
      canvas.drawLine(
        Offset(center.dx - tickLen, center.dy + i),
        Offset(center.dx + tickLen, center.dy + i),
        axisPaint,
      );
    }

    // === 2. GEOMETRY DEFINITIONS ===
    final R_inner = R * 0.96;
    final circleRadius = R_inner * 0.54;
    final d = R_inner - circleRadius; // Center offset for trefoil tangent circles

    // Upright equilateral triangle vertices
    final topVertex = Offset(center.dx, center.dy - R_inner);
    final bottomLeft = Offset(center.dx - R_inner * cos(pi / 6), center.dy + R_inner * sin(pi / 6));
    final bottomRight = Offset(center.dx + R_inner * cos(pi / 6), center.dy + R_inner * sin(pi / 6));

    // Three inner circle centers
    final topCircleCenter = Offset(center.dx, center.dy - d);
    final leftCircleCenter = Offset(center.dx - d * cos(pi / 6), center.dy + d * sin(pi / 6));
    final rightCircleCenter = Offset(center.dx + d * cos(pi / 6), center.dy + d * sin(pi / 6));

    // Inverted narrow triangle vertices
    final invTopY = topCircleCenter.dy;
    final invTopXDist = (invTopY - topVertex.dy).abs() / sqrt(3);
    final invTopL = Offset(center.dx - invTopXDist, invTopY);
    final invTopR = Offset(center.dx + invTopXDist, invTopY);
    final invBottom = Offset(center.dx, center.dy + R_inner);

    // Paths
    final mainTrianglePath = Path()
      ..moveTo(topVertex.dx, topVertex.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..close();

    final invertedTrianglePath = Path()
      ..moveTo(invTopL.dx, invTopL.dy)
      ..lineTo(invTopR.dx, invTopR.dy)
      ..lineTo(invBottom.dx, invBottom.dy)
      ..close();

    // === 3. DRAW SHAPES (CORRECT ORDER) ===
    
    // Outer double concentric circles
    canvas.drawCircle(center, R, strokePaint);
    canvas.drawCircle(center, R_inner, doubleStrokePaint);

    // Three double inner circles
    canvas.drawCircle(topCircleCenter, circleRadius, strokePaint);
    canvas.drawCircle(topCircleCenter, circleRadius * 0.95, doubleStrokePaint);

    canvas.drawCircle(leftCircleCenter, circleRadius, strokePaint);
    canvas.drawCircle(leftCircleCenter, circleRadius * 0.95, doubleStrokePaint);

    canvas.drawCircle(rightCircleCenter, circleRadius, strokePaint);
    canvas.drawCircle(rightCircleCenter, circleRadius * 0.95, doubleStrokePaint);

    // Main upright triangle
    canvas.drawPath(mainTrianglePath, strokePaint);

    // Inverted triangle
    canvas.drawPath(invertedTrianglePath, strokePaint);

    // Four small node circles at the vertices
    final nodeRadius = R * 0.08;
    canvas.drawCircle(topVertex, nodeRadius, strokePaint);
    canvas.drawCircle(bottomLeft, nodeRadius, strokePaint);
    canvas.drawCircle(bottomRight, nodeRadius, strokePaint);
    canvas.drawCircle(invBottom, nodeRadius, strokePaint);

    // Draw node labels inside small circles or nearby
    _drawLabel(canvas, "C", topVertex, const Offset(0, 0));
    _drawLabel(canvas, "G", bottomLeft, const Offset(0, 0));
    _drawLabel(canvas, "F", bottomRight, const Offset(0, 0));
    _drawLabel(canvas, "F#", invBottom, const Offset(0, 0));

    // Other note labels around the geometry as shown in the blueprint
    _drawLabel(canvas, "Db", Offset(center.dx + R * 0.3, center.dy - R * 0.52), Offset.zero);
    _drawLabel(canvas, "D", Offset(center.dx + R * 0.62, center.dy - R * 0.36), Offset.zero);
    _drawLabel(canvas, "Eb", Offset(center.dx + R * 0.6, center.dy), Offset.zero);
    _drawLabel(canvas, "E", Offset(center.dx + R * 0.62, center.dy + R * 0.36), Offset.zero);

    _drawLabel(canvas, "Ab", Offset(center.dx - R * 0.62, center.dy + R * 0.36), Offset.zero);
    _drawLabel(canvas, "A", Offset(center.dx - R * 0.6, center.dy), Offset.zero);
    _drawLabel(canvas, "Bb", Offset(center.dx - R * 0.62, center.dy - R * 0.36), Offset.zero);
    _drawLabel(canvas, "B", Offset(center.dx - R * 0.3, center.dy - R * 0.52), Offset.zero);
  }

  void _drawLabel(Canvas canvas, String text, Offset position, Offset offset) {
    final textSpan = TextSpan(
      text: text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2 + offset.dx, position.dy - textPainter.height / 2 + offset.dy),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
