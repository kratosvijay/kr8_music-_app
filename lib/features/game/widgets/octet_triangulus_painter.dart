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

  // Coordinates for the 12 nodes based on the mathematical blueprint layout
  static final List<NodePosition> nodes = [
    // Upright stabilizing triangle (Turquoise/Neon Blue)
    const NodePosition(
      id: 'T1',
      label: 'C',
      swaraLabel: 'S',
      relativeOffset: Offset(0.0, -0.96), // Top vertex
      color: Kri8Colors.neonBlue,
    ),
    const NodePosition(
      id: 'T2',
      label: 'F',
      swaraLabel: 'M1',
      relativeOffset: Offset(0.83, 0.48), // Bottom-right vertex
      color: Kri8Colors.neonBlue,
    ),
    const NodePosition(
      id: 'T3',
      label: 'G',
      swaraLabel: 'P',
      relativeOffset: Offset(-0.83, 0.48), // Bottom-left vertex
      color: Kri8Colors.neonBlue,
    ),

    // Tension apex / bottom vertex of inverted triangle (Hot Pink)
    const NodePosition(
      id: 'D1',
      label: 'F#',
      swaraLabel: 'M2',
      relativeOffset: Offset(0.0, 0.96), // Bottom center
      color: Colors.redAccent,
    ),

    // Right hemisphere chromatic notes (Violet)
    const NodePosition(
      id: 'O1',
      label: 'C#',
      swaraLabel: 'R1',
      relativeOffset: Offset(0.3, -0.52),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'O2',
      label: 'D',
      swaraLabel: 'R2/G1',
      relativeOffset: Offset(0.62, -0.36),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'O3',
      label: 'D#',
      swaraLabel: 'R3/G2',
      relativeOffset: Offset(0.6, 0.0),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'O4',
      label: 'E',
      swaraLabel: 'G3',
      relativeOffset: Offset(0.62, 0.36),
      color: Kri8Colors.secondary,
    ),

    // Left hemisphere chromatic notes (Gold)
    const NodePosition(
      id: 'O5',
      label: 'G#',
      swaraLabel: 'D1',
      relativeOffset: Offset(-0.62, 0.36),
      color: Kri8Colors.gold,
    ),
    const NodePosition(
      id: 'O6',
      label: 'A',
      swaraLabel: 'D2/N1',
      relativeOffset: Offset(-0.6, 0.0),
      color: Kri8Colors.gold,
    ),
    const NodePosition(
      id: 'O7',
      label: 'A#',
      swaraLabel: 'D3/N2',
      relativeOffset: Offset(-0.62, -0.36),
      color: Kri8Colors.gold,
    ),
    const NodePosition(
      id: 'O8',
      label: 'B',
      swaraLabel: 'N3',
      relativeOffset: Offset(-0.3, -0.52),
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
          final double R = size * 0.45; // layout radius

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

          final double hitRadius = R * 0.20; // tap hit zone radius
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
    final R = size.width * 0.45;

    // Line paints (white/translucent for dark themed game background)
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final doubleStrokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
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

    // Tick marks on axes
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
    final d = R_inner - circleRadius;

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

    // === 4. DRAW NODES & LABELS ===
    for (final node in nodes) {
      final double nodeX = center.dx + node.relativeOffset.dx * R;
      final double nodeY = center.dy + node.relativeOffset.dy * R;
      final Offset nodeOffset = Offset(nodeX, nodeY);

      final bool isHighlighted = highlightedNode == node.id;
      final bool isActive = activeNodes.contains(node.id);

      Color highlightColor = isErrorState ? Colors.redAccent : node.color;

      // Draw highlighted visual feedback
      if (isHighlighted || isActive) {
        // Double thicker ring
        final Paint activePaint = Paint()
          ..color = highlightColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = isHighlighted ? 2.5 : 1.6;
        canvas.drawCircle(nodeOffset, nodeRadius * 1.15, activePaint);
      }

      // Draw text label
      final String text = showSwara ? node.swaraLabel : node.label;
      final Color textColor = isHighlighted
          ? highlightColor
          : (isActive ? Colors.white : Colors.white.withValues(alpha: 0.6));

      final textSpan = TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: 9,
          fontWeight: (isHighlighted || isActive) ? FontWeight.bold : FontWeight.w500,
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
