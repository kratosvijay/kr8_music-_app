import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';
import '../../../core/theme/app_theme.dart';

class NodePosition {
  final String id;
  final String label;
  final String swaraLabel;
  final Offset relativeOffset; // normalized offset from center (-1.0 to 1.0)
  final Color color;

  const NodePosition({
    required this.id,
    required this.label,
    required this.swaraLabel,
    required this.relativeOffset,
    required this.color,
  });
}

class OctetTriangulusWidget extends StatelessWidget {
  final double size;
  final GameController controller = Get.find<GameController>();
  final List<String> activeNodes; // List of node IDs to highlight (e.g. scales or active chords)
  final bool showSwara; // Toggle between Western note names and Carnatic swaras

  OctetTriangulusWidget({
    super.key,
    required this.size,
    this.activeNodes = const [],
    this.showSwara = false,
  });

  // Coordinates for the 12 nodes based on the mathematical layout of the blueprint
  static final List<NodePosition> nodes = [
    const NodePosition(
      id: 'T1',
      label: 'C',
      swaraLabel: 'S',
      relativeOffset: Offset(0.0, -0.685), // Top vertex small circle (R_tri = 0.685)
      color: Kri8Colors.neonBlue,
    ),
    const NodePosition(
      id: 'O1',
      label: 'Db',
      swaraLabel: 'R1',
      relativeOffset: Offset(0.168, -0.336),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'O2',
      label: 'D',
      swaraLabel: 'R2/G1',
      relativeOffset: Offset(0.168, -0.214),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'O3',
      label: 'Eb',
      swaraLabel: 'R3/G2',
      relativeOffset: Offset(0.290, 0.214),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'O4',
      label: 'E',
      swaraLabel: 'G3',
      relativeOffset: Offset(0.427, 0.259),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'T2',
      label: 'F',
      swaraLabel: 'M1',
      relativeOffset: Offset(0.63, 0.37), // Bottom-right vertex small circle (manually balanced)
      color: Kri8Colors.neonBlue,
    ),
    const NodePosition(
      id: 'D1',
      label: 'F#',
      swaraLabel: 'M2',
      relativeOffset: Offset(0.0, 0.685), // Bottom center small circle (Gb/F#)
      color: Colors.redAccent,
    ),
    const NodePosition(
      id: 'T3',
      label: 'G',
      swaraLabel: 'P',
      relativeOffset: Offset(-0.63, 0.37), // Bottom-left vertex small circle (manually balanced)
      color: Kri8Colors.neonBlue,
    ),
    const NodePosition(
      id: 'O5',
      label: 'Ab',
      swaraLabel: 'D1',
      relativeOffset: Offset(-0.290, 0.214),
      color: Kri8Colors.gold,
    ),
    const NodePosition(
      id: 'O6',
      label: 'A',
      swaraLabel: 'D2/N1',
      relativeOffset: Offset(-0.496, 0.061),
      color: Kri8Colors.gold,
    ),
    const NodePosition(
      id: 'O7',
      label: 'Bb',
      swaraLabel: 'D3/N2',
      relativeOffset: Offset(-0.214, -0.336),
      color: Kri8Colors.gold,
    ),
    const NodePosition(
      id: 'O8',
      label: 'B',
      swaraLabel: 'N3',
      relativeOffset: Offset(-0.442, -0.259),
      color: Kri8Colors.gold,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (details) {
          final localPos = details.localPosition;
          
          final double centerX = size / 2;
          final double centerY = size / 2;
          final double R = size * 0.44 * 0.95; // layout radius scaled down by 5%

          // Find the closest node to the tapped coordinate
          NodePosition? closestNode;
          double minDistance = double.infinity;

          for (final node in nodes) {
            final double nodeX = centerX + node.relativeOffset.dx * R;
            final double nodeY = centerY + node.relativeOffset.dy * R;
            
            final double distance = sqrt(pow(localPos.dx - nodeX, 2) + pow(localPos.dy - nodeY, 2));
            if (distance < minDistance) {
              minDistance = distance;
              closestNode = node;
            }
          }

          final double hitRadius = R * 0.22; // tap hit zone radius
          if (closestNode != null && minDistance < hitRadius) {
            controller.playNode(closestNode.id);
          }
        },
        child: Obx(() {
          final highlighted = controller.highlightedNode.value;
          final isError = controller.hasError.value;
          
          return CustomPaint(
            size: Size(size, size),
            painter: OctetTriangulusPainter(
              nodes: nodes,
              activeNodes: activeNodes,
              highlightedNode: highlighted,
              showSwara: showSwara,
              isErrorState: isError,
            ),
          );
        }),
      ),
    );
  }
}

class OctetTriangulusPainter extends CustomPainter {
  final List<NodePosition> nodes;
  final List<String> activeNodes;
  final String highlightedNode;
  final bool showSwara;
  final bool isErrorState;

  OctetTriangulusPainter({
    required this.nodes,
    required this.activeNodes,
    required this.highlightedNode,
    required this.showSwara,
    required this.isErrorState,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final R = size.width * 0.44 * 0.95;

    // Paints (white lines for dark background, transparent canvas)
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.75;

    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    final erasePaint = Paint()
      ..blendMode = BlendMode.dstOut
      ..style = PaintingStyle.fill;

    // === 1. START SAVE LAYER FOR TRANSPARENT MASKING ===
    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());

    // === 2. DRAW ALL UNDERLAY SHAPES ===

    // Vertical dashed centerline
    double curY = -R * 1.1;
    final dash = 6.0;
    final gap = 4.0;
    while (curY < R * 1.1) {
      canvas.drawLine(
        Offset(center.dx, center.dy + curY),
        Offset(center.dx, center.dy + curY + dash),
        axisPaint,
      );
      curY += dash + gap;
    }

    // Horizontal dashed centerline
    double curX = -R * 1.1;
    while (curX < R * 1.1) {
      canvas.drawLine(
        Offset(center.dx + curX, center.dy),
        Offset(center.dx + curX + dash, center.dy),
        axisPaint,
      );
      curX += dash + gap;
    }

    // Tick marks on axes
    const tickLen = 4.0;
    for (double i = -R; i <= R; i += R / 4) {
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

    // Bottom flat triangle
    final bottomTrianglePath = Path()
      ..moveTo(bottomLeft.dx, bottomLeft.dy)
      ..lineTo(invBottom.dx, invBottom.dy)
      ..lineTo(bottomRight.dx, bottomRight.dy)
      ..close();

    // One Main Outer Circle
    canvas.drawCircle(center, R, linePaint);

    // Central Circle (centered at origin)
    canvas.drawCircle(center, R * 0.43, linePaint);

    // Three inner circles built on triangle sides (single thin lines)
    canvas.drawCircle(leftCircleCenter, circleRadius, linePaint);
    canvas.drawCircle(rightCircleCenter, circleRadius, linePaint);
    canvas.drawCircle(bottomCircleCenter, circleRadius, linePaint);

    // Main upright triangle
    canvas.drawPath(mainTrianglePath, linePaint);

    // Inverted triangle
    canvas.drawPath(invertedTrianglePath, linePaint);

    // Bottom flat triangle
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

    // === 5. DRAW NODE STROKES ON TOP ===
    canvas.drawCircle(topVertex, topNodeRadius, linePaint);
    canvas.drawCircle(bottomLeft, nodeRadius, linePaint);
    canvas.drawCircle(bottomRight, nodeRadius, linePaint);
    canvas.drawCircle(invBottom, nodeRadius, linePaint);

    // Draw the 12 chromatic note labels & active highlights
    for (final node in nodes) {
      final double nodeX = center.dx + node.relativeOffset.dx * R;
      final double nodeY = center.dy + node.relativeOffset.dy * R;
      final Offset nodeOffset = Offset(nodeX, nodeY);

      final bool isHighlighted = highlightedNode == node.id;
      final bool isActive = activeNodes.contains(node.id);

      Color highlightColor = isErrorState
          ? Colors.redAccent
          : (isHighlighted ? const Color(0xFF00FF7F) : const Color(0xFFFFD700));

      final double currentRadius = (node.id == 'T1' ? topNodeRadius : nodeRadius);

      if (isHighlighted || isActive) {
        final Paint activePaint = Paint()
          ..color = highlightColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = isHighlighted ? 2.0 : 1.2;
        canvas.drawCircle(nodeOffset, currentRadius * 1.25, activePaint);
      }

      // Draw text label
      final String text = showSwara ? node.swaraLabel : node.label;
      final Color textColor = isHighlighted
          ? highlightColor
          : (isActive ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.9));

      final textSpan = TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: (isHighlighted || isActive) ? FontWeight.bold : FontWeight.w500,
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
        Offset(nodeX - textPainter.width / 2, nodeY - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant OctetTriangulusPainter oldDelegate) {
    return oldDelegate.highlightedNode != highlightedNode ||
        oldDelegate.activeNodes != activeNodes ||
        oldDelegate.showSwara != showSwara ||
        oldDelegate.isErrorState != isErrorState;
  }
}
