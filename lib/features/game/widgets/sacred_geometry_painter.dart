import 'package:flutter/material.dart';

class SacredGeometryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final R = size.width * 0.44 * 0.95;

    // Paints
    final linePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75;

    final axisPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final erasePaint = Paint()
      ..blendMode = BlendMode.dstOut
      ..style = PaintingStyle.fill;

    // === 1. START SAVE LAYER FOR TRANSPARENT MASKING ===
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // === 2. DRAW ALL UNDERLAY SHAPES ===

    // Dashed Axes
    double curY = center.dy - R * 1.1;
    final dash = 6.0;
    final gap = 4.0;
    while (curY < center.dy + R * 1.1) {
      canvas.drawLine(Offset(center.dx, curY), Offset(center.dx, curY + dash), axisPaint);
      curY += dash + gap;
    }

    double curX = center.dx - R * 1.1;
    while (curX < center.dx + R * 1.1) {
      canvas.drawLine(Offset(curX, center.dy), Offset(curX + dash, center.dy), axisPaint);
      curX += dash + gap;
    }

    // Tick Marks on axes
    const double tick = 4.0;
    for (double i = -R; i <= R; i += R / 4) {
      if (i.abs() < 1.0) continue;
      canvas.drawLine(Offset(center.dx + i, center.dy - tick), Offset(center.dx + i, center.dy + tick), axisPaint);
      canvas.drawLine(Offset(center.dx - tick, center.dy + i), Offset(center.dx + tick, center.dy + i), axisPaint);
    }

    // Geometry parameters
    final double R_tri = R * 0.685;
    final double circleRadius = R * 0.36;

    final topVertex = Offset(center.dx, center.dy - R_tri);
    final bottomLeft = Offset(
      center.dx - R_tri * 0.92,
      center.dy + R_tri * 0.54,
    );
    final bottomRight = Offset(
      center.dx + R_tri * 0.92,
      center.dy + R_tri * 0.54,
    );

    // Midpoints / Custom Centers
    final leftCircleCenter = Offset(
      center.dx - R * 0.28,
      center.dy + R * 0.08,
    );
    final rightCircleCenter = Offset(
      center.dx + R * 0.28,
      center.dy + R * 0.08,
    );
    final bottomCircleCenter = Offset(center.dx, center.dy + R_tri / 2);

    final double invTopY = center.dy - R_tri * 0.58;
    final double invTopXDist = R_tri * 0.24;
    final invTopL = Offset(center.dx - invTopXDist, invTopY);
    final invTopR = Offset(center.dx + invTopXDist, invTopY);
    final invBottom = Offset(center.dx, center.dy + R_tri);

    // One Main Outer Circle
    canvas.drawCircle(center, R, linePaint);

    // Central Circle (centered at origin)
    canvas.drawCircle(center, R * 0.43, linePaint);

    // Three inner circles built on triangle sides (single thin lines)
    canvas.drawCircle(leftCircleCenter, circleRadius, linePaint);
    canvas.drawCircle(rightCircleCenter, circleRadius, linePaint);
    canvas.drawCircle(bottomCircleCenter, circleRadius, linePaint);

    // Upright equilateral triangle
    final mainTrianglePath = Path()
      ..moveTo(topVertex.dx, topVertex.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..close();
    canvas.drawPath(mainTrianglePath, linePaint);

    // Inverted narrow triangle
    final invertedTrianglePath = Path()
      ..moveTo(invTopL.dx, invTopL.dy)
      ..lineTo(invTopR.dx, invTopR.dy)
      ..lineTo(invBottom.dx, invBottom.dy)
      ..close();
    canvas.drawPath(invertedTrianglePath, linePaint);

    // Bottom wide triangle connecting G, Gb/F#, E#
    final bottomTrianglePath = Path()
      ..moveTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(invBottom.dx, invBottom.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..close();
    canvas.drawPath(bottomTrianglePath, linePaint);

    // Horizontal tick/minus mark inside top lens
    canvas.drawLine(
      Offset(center.dx - R * 0.04, center.dy - R_tri * 0.62),
      Offset(center.dx + R * 0.04, center.dy - R_tri * 0.62),
      linePaint,
    );

    // === 3. ERASE PORTIONS UNDER NODES (cookie-cutter transparent masking) ===
    final topNodeRadius = R * 0.095;
    final nodeRadius = R * 0.076;
    canvas.drawCircle(topVertex, topNodeRadius, erasePaint);
    canvas.drawCircle(bottomLeft, nodeRadius, erasePaint);
    canvas.drawCircle(bottomRight, nodeRadius, erasePaint);
    canvas.drawCircle(invBottom, nodeRadius, erasePaint);

    // === 4. RESTORE LAYER TO FINALIZE TRANSPARENT HOLES ===
    canvas.restore();

    // === 5. DRAW NODE STROKES & LABELS ON TOP ===
    canvas.drawCircle(topVertex, topNodeRadius, linePaint);
    canvas.drawCircle(bottomLeft, nodeRadius, linePaint);
    canvas.drawCircle(bottomRight, nodeRadius, linePaint);
    canvas.drawCircle(invBottom, nodeRadius, linePaint);

    // Note labels inside vertex circles (tightly placed within nodes)
    _drawText(canvas, "C", Offset(topVertex.dx, topVertex.dy - 10), alignCenter: true, fontWeight: FontWeight.bold);
    _drawText(canvas, "B#", Offset(topVertex.dx - 12, topVertex.dy + 8), alignCenter: true, fontSize: 8);
    _drawText(canvas, "DO", Offset(topVertex.dx + 12, topVertex.dy + 8), alignCenter: true, fontSize: 8);

    _drawText(canvas, "G", bottomLeft, alignCenter: true, fontWeight: FontWeight.bold);

    _drawText(canvas, "E#", Offset(bottomRight.dx + 12, bottomRight.dy + 8), alignCenter: true, fontSize: 8);
    _drawText(canvas, "F", Offset(bottomRight.dx - 12, bottomRight.dy + 8), alignCenter: true, fontSize: 8);

    _drawText(canvas, "Gb/F#", invBottom, alignCenter: true, fontWeight: FontWeight.bold);

    // Outer solfege indicators
    _drawText(canvas, "TI", Offset(center.dx - R * 0.65, center.dy - R * 0.65), alignCenter: true);
    _drawText(canvas, "RF", Offset(center.dx + R * 0.65, center.dy - R * 0.65), alignCenter: true);
    _drawText(canvas, "LA", Offset(center.dx - R * 0.75, center.dy + R * 0.65), alignCenter: true);
    _drawText(canvas, "MI", Offset(center.dx + R * 0.75, center.dy + R * 0.65), alignCenter: true);
    _drawText(canvas, "SOL", Offset(center.dx - R * 0.35, center.dy + R * 0.65), alignCenter: true);
    _drawText(canvas, "FA", Offset(center.dx + R * 0.35, center.dy + R * 0.65), alignCenter: true);

    // Inside top circle notes (Bb, C#, A*, D) - C, B#, DO are handled inside topVertex C circle above
    _drawText(canvas, "Bb", Offset(center.dx - 16, center.dy - R_tri * 0.44), alignCenter: true);
    _drawText(canvas, "C#", Offset(center.dx + 16, center.dy - R_tri * 0.44), alignCenter: true);
    _drawText(canvas, "A*", Offset(center.dx - 16, center.dy - R_tri * 0.28), alignCenter: true);
    _drawText(canvas, "D", Offset(center.dx + 16, center.dy - R_tri * 0.28), alignCenter: true);

    // Left circle notes
    _drawText(canvas, "Cb", Offset(center.dx - R_tri * 0.54, center.dy - R_tri * 0.44), alignCenter: true);
    _drawText(canvas, "B", Offset(center.dx - R_tri * 0.54, center.dy - R_tri * 0.34), alignCenter: true);
    _drawText(canvas, "A", Offset(center.dx - R_tri * 0.65, center.dy + R_tri * 0.08), alignCenter: true);
    _drawText(canvas, "Ab", Offset(center.dx - R_tri * 0.38, center.dy + R_tri * 0.18), alignCenter: true);
    _drawText(canvas, "G#", Offset(center.dx - R_tri * 0.38, center.dy + R_tri * 0.28), alignCenter: true);

    // Right circle notes
    _drawText(canvas, "D+", Offset(center.dx + R_tri * 0.58, center.dy - R_tri * 0.38), alignCenter: true);
    _drawText(canvas, "D#", Offset(center.dx + R_tri * 0.38, center.dy + R_tri * 0.18), alignCenter: true);
    _drawText(canvas, "Eb", Offset(center.dx + R_tri * 0.38, center.dy + R_tri * 0.28), alignCenter: true);
    _drawText(canvas, "E", Offset(center.dx + R_tri * 0.56, center.dy + R_tri * 0.34), alignCenter: true);
    _drawText(canvas, "Fb", Offset(center.dx + R_tri * 0.56, center.dy + R_tri * 0.44), alignCenter: true);
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    double fontSize = 9.5,
    FontWeight fontWeight = FontWeight.normal,
    bool alignCenter = false,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.black.withValues(alpha: 0.85),
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontFamily: 'monospace',
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    final paintOffset = alignCenter
        ? Offset(position.dx - textPainter.width / 2, position.dy - textPainter.height / 2)
        : position;
    textPainter.paint(canvas, paintOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
