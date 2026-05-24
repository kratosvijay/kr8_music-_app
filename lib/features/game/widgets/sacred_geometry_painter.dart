import 'dart:math';
import 'package:flutter/material.dart';

/// The visual-only "Harmonic Blueprint" diagram.
/// Wraps [HarmonicBlueprintPainter] in an AspectRatio(1) for plug-and-play use.
class HarmonicBlueprintWidget extends StatelessWidget {
  const HarmonicBlueprintWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: CustomPaint(
        painter: HarmonicBlueprintPainter(),
      ),
    );
  }
}

/// Draws the mathematically precise "Harmonic Blueprint" diagram.
///
/// Geometric construction:
///   radius       = min(w, h) * 0.4
///   middle ring  = radius * 0.75
///   inner ring   = radius * 0.45
///   triangle     = apex top, base at ±120° on outer circle
///   petal curves = quadratic Bézier through inner-circle / horizontal-axis intersections
class HarmonicBlueprintPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final double radius = min(size.width, size.height) * 0.4;

    // --- Derived radii ---
    final double rMid = radius * 0.75;
    final double rInner = radius * 0.45;

    // --- Paints ---
    final linePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final erasePaint = Paint()
      ..blendMode = BlendMode.dstOut
      ..style = PaintingStyle.fill;

    // ================================================================
    // Save layer so we can punch transparent holes under node circles
    // ================================================================
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // ========================
    // Layer 1 — Concentric Rings
    // ========================
    canvas.drawCircle(center, radius, linePaint);   // Outer
    canvas.drawCircle(center, rMid, linePaint);      // Middle
    canvas.drawCircle(center, rInner, linePaint);    // Inner

    // ========================
    // Layer 2 — Core Axes
    // ========================
    // Vertical axis
    canvas.drawLine(
      Offset(center.dx, center.dy - radius),
      Offset(center.dx, center.dy + radius),
      linePaint,
    );
    // Horizontal axis
    canvas.drawLine(
      Offset(center.dx - radius, center.dy),
      Offset(center.dx + radius, center.dy),
      linePaint,
    );

    // ========================
    // Layer 3 — Harmonic Triangle (Isosceles)
    // ========================
    // Apex at 90° (top of circle in screen coords)
    // Base corners at ±120° from the apex on the outer circle
    //   → 90° + 120° = 210°   and   90° - 120° = -30° (= 330°)
    // Using math-convention angles (counter-clockwise from +x):
    //   210° → cos(210°) = -√3/2 ≈ -0.866, sin(210°) = -0.5
    //   330° → cos(330°) =  √3/2 ≈  0.866, sin(330°) = -0.5
    // In screen coords (y-down): offset.dy = center.dy - R*sin(θ)

    final topVertex = Offset(center.dx, center.dy - radius);
    final bottomLeft = Offset(
      center.dx + radius * cos(210 * pi / 180),  // -0.866 R
      center.dy - radius * sin(210 * pi / 180),  // +0.5 R
    );
    final bottomRight = Offset(
      center.dx + radius * cos(330 * pi / 180),   //  0.866 R
      center.dy - radius * sin(330 * pi / 180),   // +0.5 R
    );
    final bottomCenter = Offset(center.dx, center.dy + radius);

    final trianglePath = Path()
      ..moveTo(topVertex.dx, topVertex.dy)
      ..lineTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..close();
    canvas.drawPath(trianglePath, linePaint);

    // ========================
    // Layer 4 — Inner "Lens" / Petal Curves
    // ========================
    // Two symmetrical quadratic Bézier arcs forming a vertical eye.
    //   Start : top of middle circle    (center.dx, center.dy - rMid)
    //   End   : bottom of middle circle (center.dx, center.dy + rMid)
    //   Pass-through: inner circle ∩ horizontal axis  (center.dx ± rInner, center.dy)
    //
    // For a quad-Bézier B(t) with endpoints P0, P2 and control P1:
    //   B(0.5) = 0.25*P0 + 0.5*P1 + 0.25*P2
    // Setting B(0.5).x = center.dx - rInner:
    //   0.25*cx + 0.5*P1x + 0.25*cx = cx - rInner
    //   P1x = cx - 2*rInner
    //
    // So control.x = center.dx ± 2*rInner
    final leftPetalPath = Path()
      ..moveTo(center.dx, center.dy - rMid)
      ..quadraticBezierTo(
        center.dx - 2 * rInner, center.dy,
        center.dx, center.dy + rMid,
      );
    canvas.drawPath(leftPetalPath, linePaint);

    final rightPetalPath = Path()
      ..moveTo(center.dx, center.dy - rMid)
      ..quadraticBezierTo(
        center.dx + 2 * rInner, center.dy,
        center.dx, center.dy + rMid,
      );
    canvas.drawPath(rightPetalPath, linePaint);

    // ========================
    // Erase geometry under node circles
    // ========================
    final double nodeR = radius * 0.08;
    canvas.drawCircle(topVertex, nodeR, erasePaint);
    canvas.drawCircle(bottomLeft, nodeR, erasePaint);
    canvas.drawCircle(bottomRight, nodeR, erasePaint);
    canvas.drawCircle(bottomCenter, nodeR, erasePaint);

    // Restore the compositing layer
    canvas.restore();

    // ========================
    // Layer 5 — Node circles (stroked on top)
    // ========================
    canvas.drawCircle(topVertex, nodeR, linePaint);
    canvas.drawCircle(bottomLeft, nodeR, linePaint);
    canvas.drawCircle(bottomRight, nodeR, linePaint);
    canvas.drawCircle(bottomCenter, nodeR, linePaint);

    // ========================
    // Layer 6 — Labels
    // ========================
    final double fs = radius * 0.1;   // main label size
    final double sm = fs * 0.72;      // small / secondary label size

    // --- 4 vertex labels ---
    _label(canvas, 'C', topVertex.translate(0, -fs * 0.45), fs, bold: true);
    _label(canvas, 'B#', topVertex.translate(-nodeR * 0.75, fs * 0.32), sm);
    _label(canvas, 'DO', topVertex.translate(nodeR * 0.75, fs * 0.32), sm);

    _label(canvas, 'G', bottomLeft, fs, bold: true);

    _label(canvas, 'F', bottomRight.translate(-nodeR * 0.6, fs * 0.28), fs, bold: true);
    _label(canvas, 'E#', bottomRight.translate(nodeR * 0.6, fs * 0.28), sm);

    _label(canvas, 'Gb/F#', bottomCenter, fs, bold: true);

    // --- Outer-ring solfège (between outer & middle circles) ---
    _label(canvas, 'TI', Offset(center.dx - radius * 0.62, center.dy - radius * 0.62), fs);
    _label(canvas, 'RE', Offset(center.dx + radius * 0.62, center.dy - radius * 0.62), fs);
    _label(canvas, 'LA', Offset(center.dx - radius * 0.72, center.dy + radius * 0.62), fs);
    _label(canvas, 'Mi', Offset(center.dx + radius * 0.72, center.dy + radius * 0.62), fs);
    _label(canvas, 'SOL', Offset(center.dx - radius * 0.32, center.dy + radius * 0.62), fs);
    _label(canvas, 'FA', Offset(center.dx + radius * 0.32, center.dy + radius * 0.62), fs);

    // --- Inner petal / between-circle chromatic labels ---
    // Upper inner pair
    _label(canvas, 'Bb', Offset(center.dx - rInner * 0.42, center.dy - rMid * 0.42), sm);
    _label(canvas, 'C#', Offset(center.dx + rInner * 0.42, center.dy - rMid * 0.42), sm);
    _label(canvas, 'A#', Offset(center.dx - rInner * 0.42, center.dy - rMid * 0.22), sm);
    _label(canvas, 'Db', Offset(center.dx + rInner * 0.42, center.dy - rMid * 0.22), sm);

    // Left region
    _label(canvas, 'Cb', Offset(center.dx - rMid * 0.58, center.dy - rMid * 0.38), sm);
    _label(canvas, 'B', Offset(center.dx - rMid * 0.58, center.dy - rMid * 0.22), sm);
    _label(canvas, 'A', Offset(center.dx - rMid * 0.68, center.dy + rMid * 0.06), sm);
    _label(canvas, 'Ab', Offset(center.dx - rMid * 0.42, center.dy + rMid * 0.16), sm);
    _label(canvas, 'G#', Offset(center.dx - rMid * 0.42, center.dy + rMid * 0.30), sm);

    // Right region
    _label(canvas, 'D', Offset(center.dx + rMid * 0.60, center.dy - rMid * 0.32), sm);
    _label(canvas, 'D#', Offset(center.dx + rMid * 0.42, center.dy + rMid * 0.16), sm);
    _label(canvas, 'Eb', Offset(center.dx + rMid * 0.42, center.dy + rMid * 0.30), sm);
    _label(canvas, 'E', Offset(center.dx + rMid * 0.60, center.dy + rMid * 0.30), sm);
    _label(canvas, 'Fb', Offset(center.dx + rMid * 0.60, center.dy + rMid * 0.44), sm);
  }

  /// Draws a centered white text label at [pos].
  void _label(
    Canvas canvas,
    String text,
    Offset pos,
    double fontSize, {
    bool bold = false,
  }) {
    final span = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.95),
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.bold : FontWeight.normal,
        fontFamily: 'Helvetica',
      ),
    );
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr)
      ..layout();
    tp.paint(canvas, Offset(pos.dx - tp.width / 2, pos.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
