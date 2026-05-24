import 'dart:math';
import 'package:flutter/material.dart';

class SacredGeometryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    // Reduce overall geometry scale by 8% to increase margins
    final outerRadius = size.width * 0.45 * 0.92;

    final strokePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final doubleStrokePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    final axisPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    // === 1. GUIDE LINES (subtle dashed lines) ===
    // Vertical dashed centerline
    double y = -outerRadius * 1.1;
    const dash = 5.0;
    const gap = 4.0;
    while (y < outerRadius * 1.1) {
      canvas.drawLine(
        Offset(center.dx, center.dy + y),
        Offset(center.dx, center.dy + y + dash),
        axisPaint,
      );
      y += dash + gap;
    }

    // Horizontal dashed centerline
    double x = -outerRadius * 1.1;
    while (x < outerRadius * 1.1) {
      canvas.drawLine(
        Offset(center.dx + x, center.dy),
        Offset(center.dx + x + dash, center.dy),
        axisPaint,
      );
      x += dash + gap;
    }

    // Tick marks on axes
    const tickLen = 3.0;
    for (double i = -outerRadius; i <= outerRadius; i += outerRadius / 4) {
      if (i.abs() < 1.0) continue;
      canvas.drawLine(
        Offset(center.dx + i, center.dy - tickLen),
        Offset(center.dx + i, center.dy + tickLen),
        axisPaint,
      );
      canvas.drawLine(
        Offset(center.dx - tickLen, center.dy + i),
        Offset(center.dx + tickLen, center.dy + i),
        axisPaint,
      );
    }

    // === 2. GEOMETRY DEFINITIONS ===
    final R_inner = outerRadius * 0.96;

    // Main upright triangle (wider and flatter, using side = outerRadius * 1.78)
    final side = outerRadius * 1.78;
    final triangleHeight = sqrt(3) / 2 * side;

    // Apex should not touch top outer ring directly
    final top = Offset(
      center.dx,
      center.dy - triangleHeight / 2 + outerRadius * 0.05,
    );

    final left = Offset(
      center.dx - side / 2,
      center.dy + triangleHeight / 2 + outerRadius * 0.05,
    );

    final right = Offset(
      center.dx + side / 2,
      center.dy + triangleHeight / 2 + outerRadius * 0.05,
    );

    // Inner circles (reduced radius, moved outward horizontally and slightly upward)
    final circleRadius = outerRadius * 0.29;

    final topCircleCenter = Offset(
      center.dx,
      center.dy - outerRadius * 0.36,
    );

    final leftCircleCenter = Offset(
      center.dx - outerRadius * 0.42,
      center.dy + outerRadius * 0.12,
    );

    final rightCircleCenter = Offset(
      center.dx + outerRadius * 0.42,
      center.dy + outerRadius * 0.12,
    );

    // Inverted triangle (widened upper section, stops slightly above outer edge)
    final invTopY = topCircleCenter.dy;
    final invTopXDist = (invTopY - top.dy).abs() / sqrt(3);
    final invTopL = Offset(center.dx - invTopXDist * 1.4, invTopY);
    final invTopR = Offset(center.dx + invTopXDist * 1.4, invTopY);
    final invBottom = Offset(center.dx, center.dy + outerRadius * 0.88);

    // Paths
    final mainTrianglePath = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close();

    final invertedTrianglePath = Path()
      ..moveTo(invTopL.dx, invTopL.dy)
      ..lineTo(invTopR.dx, invTopR.dy)
      ..lineTo(invBottom.dx, invBottom.dy)
      ..close();

    // === 3. DRAW SHAPES ===
    // Outer rings
    canvas.drawCircle(center, outerRadius, strokePaint);
    canvas.drawCircle(center, R_inner, doubleStrokePaint);

    // Three inner circles (full)
    canvas.drawCircle(topCircleCenter, circleRadius, strokePaint);
    canvas.drawCircle(leftCircleCenter, circleRadius, strokePaint);
    canvas.drawCircle(rightCircleCenter, circleRadius, strokePaint);

    // Main upright triangle
    canvas.drawPath(mainTrianglePath, strokePaint);

    // Inverted triangle
    canvas.drawPath(invertedTrianglePath, strokePaint);

    // Small node circles (40% smaller)
    final nodeRadius = outerRadius * 0.048;
    canvas.drawCircle(top, nodeRadius, strokePaint);
    canvas.drawCircle(left, nodeRadius, strokePaint);
    canvas.drawCircle(right, nodeRadius, strokePaint);
    canvas.drawCircle(invBottom, nodeRadius, strokePaint);

    // === 4. TECHNICAL TEXT LABELS ===
    final labelRadius = outerRadius * 1.05;
    final notes = [
      "C", "Db", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"
    ];

    for (int i = 0; i < 12; i++) {
      final double angle = -pi / 2 + i * (pi / 6);
      Offset labelPos = center + Offset.fromDirection(angle, labelRadius);
      
      // Fine-tune offset spacing for drafting readability
      if (i == 0) labelPos = Offset(labelPos.dx, labelPos.dy - 6);
      if (i == 6) labelPos = Offset(labelPos.dx, labelPos.dy + 6);
      if (i == 3) labelPos = Offset(labelPos.dx + 6, labelPos.dy);
      if (i == 9) labelPos = Offset(labelPos.dx - 6, labelPos.dy);

      _drawText(canvas, notes[i], labelPos, Colors.black.withValues(alpha: 0.85));
    }
  }

  void _drawText(Canvas canvas, String text, Offset position, Color color) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: 8.5,
        fontWeight: FontWeight.w600,
        fontFamily: 'monospace',
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
