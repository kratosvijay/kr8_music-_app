import 'dart:math';
import 'package:flutter/material.dart';

class SacredGeometryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Virtual drawing space is 1000 x 750 (4:3 aspect ratio)
    final double scale = min(size.width / 1000.0, size.height / 750.0);
    final double offsetX = (size.width - 1000.0 * scale) / 2;
    final double offsetY = (size.height - 750.0 * scale) / 2;

    canvas.save();
    canvas.translate(offsetX, offsetY);
    canvas.scale(scale);

    // Background color of the blueprint
    final Color bgColor = const Color(0xFF0F3E70);

    // 1. DRAW BACKGROUND & GRID
    final bgPaint = Paint()..color = bgColor;
    canvas.drawRect(const Rect.fromLTWH(0, 0, 1000, 750), bgPaint);

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const double gridSpacing = 20.0;
    for (double x = 0; x <= 1000; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, 750), gridPaint);
    }
    for (double y = 0; y <= 750; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(1000, y), gridPaint);
    }

    // Outer sheet border
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRect(const Rect.fromLTWH(15, 15, 970, 720), borderPaint);
    canvas.drawRect(const Rect.fromLTWH(18, 18, 964, 714), borderPaint);

    // Column dividers
    canvas.drawLine(const Offset(18, 540), const Offset(982, 540), borderPaint);
    canvas.drawLine(const Offset(550, 540), const Offset(550, 732), borderPaint);
    canvas.drawLine(const Offset(770, 540), const Offset(770, 732), borderPaint);

    // 2. BLUEPRINT TEXTS
    _drawText(
      canvas,
      "The description of right lines and\nvalues upon which geometry is\nfounded belong to Mechanics...\nGeometry does not necd teach us to\ndraw these lines, but requires to be drawn.",
      const Offset(60, 80),
      width: 440,
      fontSize: 12,
      fontStyle: FontStyle.italic,
    );
    _drawText(canvas, "- Isaac Newton.", const Offset(340, 175), fontSize: 12, fontWeight: FontWeight.bold);

    _drawText(
      canvas,
      "Drawing a Chromatic Scale",
      const Offset(580, 50),
      fontSize: 22,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
    );

    _drawText(
      canvas,
      "On an Oilet Triangulus st us start filling in vith with the 12 musical notes in the tevelve consecutive points starting from C are inside shown, you can start from any dote. We will write C on the orah noted towards right rip on the top of vertices of the upright triangle and proceed toward a the top circle inner ring and Blite Db and on the outer circle to top circle D' Moving to bottom circle inner ring write 'Fb' and 'E' on the outside.\n\nRight side Verteses of the upright triangle is F' and the tip of the Verteses of the Downwards triangle is E#\n\nThe left side Untesse of the bottom triangle is Gr, the inser ring of the top circle is Ab and A' outside the ring.",
      const Offset(580, 110),
      width: 370,
      fontSize: 10.5,
      lineHeight: 1.45,
    );

    // 3. PAINTS
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final doubleLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final maskPaint = Paint()
      ..color = bgColor
      ..style = PaintingStyle.fill;

    // === 4. GEOMETRY DEFINITIONS ===
    final center = const Offset(285, 420);
    const double R = 175.0;
    const double R_inner = R * 0.96;

    final double circleRadius = R_inner * 0.54;
    final double d = R_inner - circleRadius;

    final topVertex = Offset(center.dx, center.dy - R_inner);
    final bottomLeft = Offset(center.dx - R_inner * cos(pi / 6), center.dy + R_inner * sin(pi / 6));
    final bottomRight = Offset(center.dx + R_inner * cos(pi / 6), center.dy + R_inner * sin(pi / 6));

    final topCircleCenter = Offset(center.dx, center.dy - d);
    final leftCircleCenter = Offset(center.dx - d * cos(pi / 6), center.dy + d * sin(pi / 6));
    final rightCircleCenter = Offset(center.dx + d * cos(pi / 6), center.dy + d * sin(pi / 6));

    final double invTopY = center.dy - R_inner * 0.68;
    final double invTopXDist = R_inner * 0.16;
    final invTopL = Offset(center.dx - invTopXDist, invTopY);
    final invTopR = Offset(center.dx + invTopXDist, invTopY);
    final invBottom = Offset(center.dx, center.dy + R_inner);

    // === 5. DRAW ALL UNDERLAY SHAPES ===

    // Dashed Axes
    double curY = center.dy - R * 1.1;
    while (curY < center.dy + R * 1.1) {
      canvas.drawLine(Offset(center.dx, curY), Offset(center.dx, curY + 6.0), axisPaint);
      curY += 10.0;
    }
    double curX = center.dx - R * 1.1;
    while (curX < center.dx + R * 1.1) {
      canvas.drawLine(Offset(curX, center.dy), Offset(curX + 6.0, center.dy), axisPaint);
      curX += 10.0;
    }

    // Tick Marks
    const double tick = 4.0;
    for (double i = -R_inner; i <= R_inner; i += R_inner / 4) {
      if (i.abs() < 1.0) continue;
      canvas.drawLine(Offset(center.dx + i, center.dy - tick), Offset(center.dx + i, center.dy + tick), axisPaint);
      canvas.drawLine(Offset(center.dx - tick, center.dy + i), Offset(center.dx + tick, center.dy + i), axisPaint);
    }

    // Outer double rings
    canvas.drawCircle(center, R, linePaint);
    canvas.drawCircle(center, R_inner, doubleLinePaint);

    // Three inner double circles
    canvas.drawCircle(topCircleCenter, circleRadius, linePaint);
    canvas.drawCircle(topCircleCenter, circleRadius * 0.95, doubleLinePaint);

    canvas.drawCircle(leftCircleCenter, circleRadius, linePaint);
    canvas.drawCircle(leftCircleCenter, circleRadius * 0.95, doubleLinePaint);

    canvas.drawCircle(rightCircleCenter, circleRadius, linePaint);
    canvas.drawCircle(rightCircleCenter, circleRadius * 0.95, doubleLinePaint);

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

    // === 6. MASK / HIDE UNWANTED SHAPES UNDER NODES ===
    // We draw solid background fills on the small node circles to erase the lines underneath
    const double nodeR = 18.0;
    canvas.drawCircle(topVertex, nodeR, maskPaint);
    canvas.drawCircle(bottomLeft, nodeR, maskPaint);
    canvas.drawCircle(bottomRight, nodeR, maskPaint);
    canvas.drawCircle(invBottom, nodeR, maskPaint);

    // === 7. DRAW NODE STROKES & TEXT ON TOP OF MASK ===
    canvas.drawCircle(topVertex, nodeR, linePaint);
    canvas.drawCircle(topVertex, nodeR * 0.75, doubleLinePaint);

    canvas.drawCircle(bottomLeft, nodeR, linePaint);
    canvas.drawCircle(bottomLeft, nodeR * 0.75, doubleLinePaint);

    canvas.drawCircle(bottomRight, nodeR, linePaint);
    canvas.drawCircle(bottomRight, nodeR * 0.75, doubleLinePaint);

    canvas.drawCircle(invBottom, nodeR, linePaint);
    canvas.drawCircle(invBottom, nodeR * 0.75, doubleLinePaint);

    // Node text labels
    _drawText(canvas, "C", topVertex, alignCenter: true, fontWeight: FontWeight.bold);
    _drawText(canvas, "G", bottomLeft, alignCenter: true, fontWeight: FontWeight.bold);
    _drawText(canvas, "E#", bottomRight, alignCenter: true, fontWeight: FontWeight.bold);
    _drawText(canvas, "Gb/F#", invBottom, alignCenter: true, fontWeight: FontWeight.bold);

    // Other annotations and notes precisely placed
    _drawText(canvas, "TI", Offset(center.dx - R * 0.65, center.dy - R * 0.65), alignCenter: true);
    _drawText(canvas, "RF", Offset(center.dx + R * 0.65, center.dy - R * 0.65), alignCenter: true);
    _drawText(canvas, "LA", Offset(center.dx - R * 0.75, center.dy + R * 0.65), alignCenter: true);
    _drawText(canvas, "MI", Offset(center.dx + R * 0.75, center.dy + R * 0.65), alignCenter: true);
    _drawText(canvas, "SOL", Offset(center.dx - R * 0.35, center.dy + R * 0.65), alignCenter: true);
    _drawText(canvas, "FA", Offset(center.dx + R * 0.35, center.dy + R * 0.65), alignCenter: true);

    // Inside top circle notes (B#, DO, Bb, C#, A*, D)
    _drawText(canvas, "B#", Offset(center.dx - 18, center.dy - R_inner * 0.76), alignCenter: true);
    _drawText(canvas, "DO", Offset(center.dx + 18, center.dy - R_inner * 0.76), alignCenter: true);
    _drawText(canvas, "Bb", Offset(center.dx - 22, center.dy - R_inner * 0.44), alignCenter: true);
    _drawText(canvas, "C#", Offset(center.dx + 22, center.dy - R_inner * 0.44), alignCenter: true);
    _drawText(canvas, "A*", Offset(center.dx - 22, center.dy - R_inner * 0.28), alignCenter: true);
    _drawText(canvas, "D", Offset(center.dx + 22, center.dy - R_inner * 0.28), alignCenter: true);

    // Left circle notes
    _drawText(canvas, "Cb", Offset(center.dx - R_inner * 0.54, center.dy - R_inner * 0.44), alignCenter: true);
    _drawText(canvas, "B", Offset(center.dx - R_inner * 0.54, center.dy - R_inner * 0.34), alignCenter: true);
    _drawText(canvas, "A", Offset(center.dx - R_inner * 0.65, center.dy + R_inner * 0.08), alignCenter: true);
    _drawText(canvas, "Ab", Offset(center.dx - R_inner * 0.38, center.dy + R_inner * 0.18), alignCenter: true);
    _drawText(canvas, "G#", Offset(center.dx - R_inner * 0.38, center.dy + R_inner * 0.28), alignCenter: true);

    // Right circle notes
    _drawText(canvas, "D+", Offset(center.dx + R_inner * 0.58, center.dy - R_inner * 0.38), alignCenter: true);
    _drawText(canvas, "D#", Offset(center.dx + R_inner * 0.38, center.dy + R_inner * 0.18), alignCenter: true);
    _drawText(canvas, "Eb", Offset(center.dx + R_inner * 0.38, center.dy + R_inner * 0.28), alignCenter: true);
    _drawText(canvas, "E", Offset(center.dx + R_inner * 0.56, center.dy + R_inner * 0.34), alignCenter: true);
    _drawText(canvas, "Fb", Offset(center.dx + R_inner * 0.56, center.dy + R_inner * 0.44), alignCenter: true);
    _drawText(canvas, "F", Offset(bottomRight.dx - 22, bottomRight.dy + 8), alignCenter: true);

    // === 8. PANEL 1: CIRCLE AND RING STUDY ===
    final studyCenter = const Offset(660, 625);
    canvas.drawCircle(studyCenter, 45, linePaint);
    canvas.drawCircle(studyCenter, 43, doubleLinePaint);
    canvas.drawCircle(studyCenter, 26, linePaint);
    canvas.drawCircle(studyCenter, 24, doubleLinePaint);

    canvas.drawLine(Offset(studyCenter.dx + 25, studyCenter.dy - 20), Offset(studyCenter.dx + 48, studyCenter.dy - 35), axisPaint);
    canvas.drawLine(Offset(studyCenter.dx + 18, studyCenter.dy + 8), Offset(studyCenter.dx + 48, studyCenter.dy + 15), axisPaint);
    _drawText(canvas, "D", Offset(studyCenter.dx + 52, studyCenter.dy - 38), fontSize: 9);
    _drawText(canvas, "Eb", Offset(studyCenter.dx + 52, studyCenter.dy + 12), fontSize: 9);

    _drawText(canvas, "CIRCLE AND RING STUDY", Offset(studyCenter.dx, studyCenter.dy + 65), alignCenter: true, fontSize: 10, fontWeight: FontWeight.bold);

    // === 9. PANEL 2: UPRIGHT TRIANGLE DETAIL ===
    final triCenter = const Offset(875, 620);
    final triPath = Path()
      ..moveTo(triCenter.dx, triCenter.dy - 35)
      ..lineTo(triCenter.dx - 35 * cos(pi/6), triCenter.dy + 35 * sin(pi/6))
      ..lineTo(triCenter.dx + 35 * cos(pi/6), triCenter.dy + 35 * sin(pi/6))
      ..close();
    canvas.drawPath(triPath, linePaint);

    canvas.drawLine(Offset(triCenter.dx, triCenter.dy - 40), Offset(triCenter.dx, triCenter.dy + 25), axisPaint);
    canvas.drawArc(Rect.fromCircle(center: Offset(triCenter.dx, triCenter.dy - 35), radius: 10), pi/3, pi/3, false, axisPaint);
    
    _drawText(canvas, "C", Offset(triCenter.dx, triCenter.dy - 45), alignCenter: true, fontSize: 9);
    _drawText(canvas, "F", Offset(triCenter.dx - 35 * cos(pi/6) - 8, triCenter.dy + 18), alignCenter: true, fontSize: 9);
    _drawText(canvas, "G", Offset(triCenter.dx + 35 * cos(pi/6) + 8, triCenter.dy + 18), alignCenter: true, fontSize: 9);

    _drawText(canvas, "UPRIGHT TRIANGLE DETAIL", Offset(triCenter.dx, triCenter.dy + 70), alignCenter: true, fontSize: 10, fontWeight: FontWeight.bold);

    canvas.restore();
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset position, {
    double width = 500,
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.normal,
    FontStyle fontStyle = FontStyle.normal,
    double lineHeight = 1.3,
    double letterSpacing = 0.5,
    bool alignCenter = false,
  }) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.95),
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        height: lineHeight,
        letterSpacing: letterSpacing,
        fontFamily: 'monospace',
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout(maxWidth: width);
    
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
