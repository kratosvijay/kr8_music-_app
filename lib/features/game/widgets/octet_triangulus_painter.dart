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

  // Coordinates for the 12 nodes based on the mathematical layout
  static final List<NodePosition> nodes = [
    const NodePosition(
      id: 'T1',
      label: 'C',
      swaraLabel: 'S',
      relativeOffset: Offset(0.0, -0.96), // Top vertex
      color: Kri8Colors.neonBlue,
    ),
    const NodePosition(
      id: 'O1',
      label: 'Db',
      swaraLabel: 'R1',
      relativeOffset: Offset(0.35, -0.60),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'O2',
      label: 'D',
      swaraLabel: 'R2/G1',
      relativeOffset: Offset(0.72, -0.42),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'O3',
      label: 'Eb',
      swaraLabel: 'R3/G2',
      relativeOffset: Offset(0.7, 0.0),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'O4',
      label: 'E',
      swaraLabel: 'G3',
      relativeOffset: Offset(0.72, 0.42),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'T2',
      label: 'F',
      swaraLabel: 'M1',
      relativeOffset: Offset(0.866 * 0.96, 0.5 * 0.96), // Bottom-right vertex
      color: Kri8Colors.neonBlue,
    ),
    const NodePosition(
      id: 'D1',
      label: 'F#',
      swaraLabel: 'M2',
      relativeOffset: Offset(0.0, 0.96), // Bottom vertex of inverted triangle
      color: Colors.redAccent,
    ),
    const NodePosition(
      id: 'T3',
      label: 'G',
      swaraLabel: 'P',
      relativeOffset: Offset(-0.866 * 0.96, 0.5 * 0.96), // Bottom-left vertex
      color: Kri8Colors.neonBlue,
    ),
    const NodePosition(
      id: 'O5',
      label: 'Ab',
      swaraLabel: 'D1',
      relativeOffset: Offset(-0.72, 0.42),
      color: Kri8Colors.gold,
    ),
    const NodePosition(
      id: 'O6',
      label: 'A',
      swaraLabel: 'D2/N1',
      relativeOffset: Offset(-0.7, 0.0),
      color: Kri8Colors.gold,
    ),
    const NodePosition(
      id: 'O7',
      label: 'Bb',
      swaraLabel: 'D3/N2',
      relativeOffset: Offset(-0.72, -0.42),
      color: Kri8Colors.gold,
    ),
    const NodePosition(
      id: 'O8',
      label: 'B',
      swaraLabel: 'N3',
      relativeOffset: Offset(-0.35, -0.60),
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
          final double R = size * 0.44; // layout radius

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
    final R = size.width * 0.44;

    // 1. DRAW BACKGROUND & GRID
    final bgPaint = Paint()..color = const Color(0xFF0F3E70); // Authentic blueprint blue
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    final double gridSpacing = size.width / 16.0;
    for (double x = 0; x <= size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. PAINTS
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final doubleLinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    // === 3. DRAW AXES ===
    // Vertical dashed axis
    double y = -R * 1.1;
    final dash = 6.0;
    final gap = 4.0;
    while (y < R * 1.1) {
      canvas.drawLine(
        Offset(center.dx, center.dy + y),
        Offset(center.dx, center.dy + y + dash),
        axisPaint,
      );
      y += dash + gap;
    }

    // Horizontal dashed axis
    double x = -R * 1.1;
    while (x < R * 1.1) {
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

    // === 4. GEOMETRY DEFINITIONS ===
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

    // === 5. DRAW SHAPES (CORRECT ORDER) ===
    
    // Outer double concentric circles
    canvas.drawCircle(center, R, linePaint);
    canvas.drawCircle(center, R_inner, doubleLinePaint);

    // Three double inner circles
    canvas.drawCircle(topCircleCenter, circleRadius, linePaint);
    canvas.drawCircle(topCircleCenter, circleRadius * 0.95, doubleLinePaint);

    canvas.drawCircle(leftCircleCenter, circleRadius, linePaint);
    canvas.drawCircle(leftCircleCenter, circleRadius * 0.95, doubleLinePaint);

    canvas.drawCircle(rightCircleCenter, circleRadius, linePaint);
    canvas.drawCircle(rightCircleCenter, circleRadius * 0.95, doubleLinePaint);

    // Main upright triangle
    canvas.drawPath(mainTrianglePath, linePaint);

    // Inverted triangle
    canvas.drawPath(invertedTrianglePath, linePaint);

    // Four small node circles at the vertices
    final nodeRadius = R * 0.08;
    canvas.drawCircle(topVertex, nodeRadius, linePaint);
    canvas.drawCircle(topVertex, nodeRadius * 0.75, doubleLinePaint);

    canvas.drawCircle(bottomLeft, nodeRadius, linePaint);
    canvas.drawCircle(bottomLeft, nodeRadius * 0.75, doubleLinePaint);

    canvas.drawCircle(bottomRight, nodeRadius, linePaint);
    canvas.drawCircle(bottomRight, nodeRadius * 0.75, doubleLinePaint);

    canvas.drawCircle(invBottom, nodeRadius, linePaint);
    canvas.drawCircle(invBottom, nodeRadius * 0.75, doubleLinePaint);

    // === 6. DRAW NODES & LABELS ===
    for (final node in nodes) {
      final double nodeX = center.dx + node.relativeOffset.dx * R;
      final double nodeY = center.dy + node.relativeOffset.dy * R;
      final Offset nodeOffset = Offset(nodeX, nodeY);

      final bool isHighlighted = highlightedNode == node.id;
      final bool isActive = activeNodes.contains(node.id);

      // Yellow/green highlight color for active blueprint notes, red for errors
      Color highlightColor = isErrorState
          ? Colors.redAccent
          : (isHighlighted ? const Color(0xFF00FF7F) : const Color(0xFFFFD700));

      if (isHighlighted || isActive) {
        // Draw a highlighted ring around active notes
        final Paint activePaint = Paint()
          ..color = highlightColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = isHighlighted ? 2.0 : 1.2;
        canvas.drawCircle(nodeOffset, nodeRadius * 1.25, activePaint);
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
