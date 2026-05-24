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
      relativeOffset: Offset(0.0, -0.72), // Top vertex
      color: Kri8Colors.neonBlue,
    ),
    const NodePosition(
      id: 'O1',
      label: 'Db',
      swaraLabel: 'R1',
      relativeOffset: Offset(0.525, -0.91),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'O2',
      label: 'D',
      swaraLabel: 'R2/G1',
      relativeOffset: Offset(0.91, -0.525),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'O3',
      label: 'Eb',
      swaraLabel: 'R3/G2',
      relativeOffset: Offset(1.05, 0.0),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'O4',
      label: 'E',
      swaraLabel: 'G3',
      relativeOffset: Offset(0.91, 0.525),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'T2',
      label: 'F',
      swaraLabel: 'M1',
      relativeOffset: Offset(0.89, 0.82), // Bottom-right vertex
      color: Kri8Colors.neonBlue,
    ),
    const NodePosition(
      id: 'D1',
      label: 'F#',
      swaraLabel: 'M2',
      relativeOffset: Offset(0.0, 0.88), // Bottom vertex of inverted triangle
      color: Colors.redAccent,
    ),
    const NodePosition(
      id: 'T3',
      label: 'G',
      swaraLabel: 'P',
      relativeOffset: Offset(-0.89, 0.82), // Bottom-left vertex
      color: Kri8Colors.neonBlue,
    ),
    const NodePosition(
      id: 'O5',
      label: 'Ab',
      swaraLabel: 'D1',
      relativeOffset: Offset(-0.91, 0.525),
      color: Kri8Colors.gold,
    ),
    const NodePosition(
      id: 'O6',
      label: 'A',
      swaraLabel: 'D2/N1',
      relativeOffset: Offset(-1.05, 0.0),
      color: Kri8Colors.gold,
    ),
    const NodePosition(
      id: 'O7',
      label: 'Bb',
      swaraLabel: 'D3/N2',
      relativeOffset: Offset(-0.91, -0.525),
      color: Kri8Colors.gold,
    ),
    const NodePosition(
      id: 'O8',
      label: 'B',
      swaraLabel: 'N3',
      relativeOffset: Offset(-0.525, -0.91),
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
          final double R = size * 0.45 * 0.92; // layout radius

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

          final double hitRadius = R * 0.25; // tap hit zone radius
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
    // Reduce overall geometry scale by 8%
    final outerRadius = size.width * 0.45 * 0.92;

    // Paints (white/translucent for dark themed game background, transparent canvas)
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.9;

    final doubleStrokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;

    final axisPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6;

    // === 1. GUIDE LINES (subtle dashed lines) ===
    // Vertical dashed centerline
    double y = -outerRadius * 1.1;
    final dash = 5.0;
    final gap = 4.0;
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

    // Main upright triangle
    final side = outerRadius * 1.78;
    final triangleHeight = sqrt(3) / 2 * side;

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

    // Inner circles
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

    // Inverted triangle
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

    // === 3. DRAW SHAPES (CORRECT ORDER) ===
    
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

    // === 4. DRAW NODES & LABELS ===
    final labelRadius = outerRadius * 1.05;

    for (final node in nodes) {
      final double nodeX = center.dx + node.relativeOffset.dx * outerRadius;
      final double nodeY = center.dy + node.relativeOffset.dy * outerRadius;
      final Offset nodeOffset = Offset(nodeX, nodeY);

      final bool isHighlighted = highlightedNode == node.id;
      final bool isActive = activeNodes.contains(node.id);

      Color highlightColor = isErrorState
          ? Colors.redAccent
          : (isHighlighted ? const Color(0xFF00FF7F) : const Color(0xFFFFD700));

      if (isHighlighted || isActive) {
        final Paint activePaint = Paint()
          ..color = highlightColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = isHighlighted ? 1.8 : 1.2;
        canvas.drawCircle(nodeOffset, nodeRadius * 1.25, activePaint);
      }

      // Draw text label
      final String text = showSwara ? node.swaraLabel : node.label;
      final Color textColor = isHighlighted
          ? highlightColor
          : (isActive ? const Color(0xFFFFD700) : Colors.white.withValues(alpha: 0.95));

      final textSpan = TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: 8.5,
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
