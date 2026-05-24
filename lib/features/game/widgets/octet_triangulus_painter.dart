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
    // Upright stabilizing triangle (Turquoise)
    const NodePosition(
      id: 'T1',
      label: 'C',
      swaraLabel: 'S',
      relativeOffset: Offset(-0.866, 0.50),
      color: Kri8Colors.neonBlue,
    ),
    const NodePosition(
      id: 'T2',
      label: 'F',
      swaraLabel: 'M1',
      relativeOffset: Offset(0.866, 0.50),
      color: Kri8Colors.neonBlue,
    ),
    const NodePosition(
      id: 'T3',
      label: 'G',
      swaraLabel: 'P',
      relativeOffset: Offset(0.0, -1.0),
      color: Kri8Colors.neonBlue,
    ),

    // Tension apex (Hot Pink)
    const NodePosition(
      id: 'D1',
      label: 'F#',
      swaraLabel: 'M2',
      relativeOffset: Offset(0.0, 1.0),
      color: Colors.redAccent,
    ),

    // Right Hemisphere / Purvanga Loops (Purple / Violet)
    const NodePosition(
      id: 'O1',
      label: 'C#',
      swaraLabel: 'R1',
      relativeOffset: Offset(0.50, 0.26),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'O2',
      label: 'D',
      swaraLabel: 'R2/G1',
      relativeOffset: Offset(0.66, -0.06),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'O3',
      label: 'D#',
      swaraLabel: 'R3/G2',
      relativeOffset: Offset(0.30, 0.14),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'O4',
      label: 'E',
      swaraLabel: 'G3',
      relativeOffset: Offset(0.24, -0.24),
      color: Kri8Colors.secondary,
    ),

    // Left Hemisphere / Uttaranga Loops (Gold)
    const NodePosition(
      id: 'O5',
      label: 'G#',
      swaraLabel: 'D1',
      relativeOffset: Offset(-0.50, 0.26),
      color: Kri8Colors.gold,
    ),
    const NodePosition(
      id: 'O6',
      label: 'A',
      swaraLabel: 'D2/N1',
      relativeOffset: Offset(-0.66, -0.06),
      color: Kri8Colors.gold,
    ),
    const NodePosition(
      id: 'O7',
      label: 'A#',
      swaraLabel: 'D3/N2',
      relativeOffset: Offset(-0.30, 0.14),
      color: Kri8Colors.gold,
    ),
    const NodePosition(
      id: 'O8',
      label: 'B',
      swaraLabel: 'N3',
      relativeOffset: Offset(-0.24, -0.24),
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

          final double hitRadius = R * 0.18; // scaled hit radius
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
    final strokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width * 0.45;

    // 1. Outer circle
    canvas.drawCircle(center, outerRadius, strokePaint);

    // 2. Derive main triangle geometry
    final side = outerRadius * 1.52;
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
    final circleRadius = outerRadius * 0.42;

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

    // 6. Draw inner arcs (partial — clean sacred geometry)

    final topRect = Rect.fromCircle(
      center: topCircleCenter,
      radius: circleRadius,
    );

    canvas.drawArc(
      topRect,
      pi * 0.95,
      pi * 1.1,
      false,
      strokePaint,
    );

    final leftRect = Rect.fromCircle(
      center: leftCircleCenter,
      radius: circleRadius,
    );

    canvas.drawArc(
      leftRect,
      -pi * 0.15,
      pi * 1.3,
      false,
      strokePaint,
    );

    final rightRect = Rect.fromCircle(
      center: rightCircleCenter,
      radius: circleRadius,
    );

    canvas.drawArc(
      rightRect,
      -pi * 0.85,
      pi * 1.3,
      false,
      strokePaint,
    );
  }

  @override
  bool shouldRepaint(covariant OctetTriangulusPainter oldDelegate) {
    return oldDelegate.highlightedNode != highlightedNode ||
        oldDelegate.activeNodes != activeNodes ||
        oldDelegate.showSwara != showSwara ||
        oldDelegate.isErrorState != isErrorState;
  }
}
