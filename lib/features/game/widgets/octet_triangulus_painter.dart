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

  // Coordinates for the 12 nodes mapped to align with the cropped blueprint image
  static final List<NodePosition> nodes = [
    const NodePosition(
      id: 'T1',
      label: 'C',
      swaraLabel: 'S',
      relativeOffset: Offset(0.0, -0.88), // Top vertex
      color: Kri8Colors.neonBlue,
    ),
    const NodePosition(
      id: 'O1',
      label: 'Db',
      swaraLabel: 'R1',
      relativeOffset: Offset(0.24, -0.42),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'O2',
      label: 'D',
      swaraLabel: 'R2/G1',
      relativeOffset: Offset(0.24, -0.26),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'O3',
      label: 'Eb',
      swaraLabel: 'R3/G2',
      relativeOffset: Offset(0.38, 0.28),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'O4',
      label: 'E',
      swaraLabel: 'G3',
      relativeOffset: Offset(0.56, 0.34),
      color: Kri8Colors.secondary,
    ),
    const NodePosition(
      id: 'T2',
      label: 'F',
      swaraLabel: 'M1',
      relativeOffset: Offset(0.83, 0.48), // Bottom-right vertex
      color: Kri8Colors.neonBlue,
    ),
    const NodePosition(
      id: 'D1',
      label: 'F#',
      swaraLabel: 'M2',
      relativeOffset: Offset(0.0, 0.88), // Bottom vertex
      color: Colors.redAccent,
    ),
    const NodePosition(
      id: 'T3',
      label: 'G',
      swaraLabel: 'P',
      relativeOffset: Offset(-0.83, 0.48), // Bottom-left vertex
      color: Kri8Colors.neonBlue,
    ),
    const NodePosition(
      id: 'O5',
      label: 'Ab',
      swaraLabel: 'D1',
      relativeOffset: Offset(-0.38, 0.28),
      color: Kri8Colors.gold,
    ),
    const NodePosition(
      id: 'O6',
      label: 'A',
      swaraLabel: 'D2/N1',
      relativeOffset: Offset(-0.65, 0.08),
      color: Kri8Colors.gold,
    ),
    const NodePosition(
      id: 'O7',
      label: 'Bb',
      swaraLabel: 'D3/N2',
      relativeOffset: Offset(-0.28, -0.44),
      color: Kri8Colors.gold,
    ),
    const NodePosition(
      id: 'O8',
      label: 'B',
      swaraLabel: 'N3',
      relativeOffset: Offset(-0.58, -0.34),
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
          // Apply a matching layout radius
          final double R = size * 0.45;

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

          final double hitRadius = R * 0.22; // tap hit zone
          if (closestNode != null && minDistance < hitRadius) {
            controller.playNode(closestNode.id);
          }
        },
        child: Obx(() {
          final highlighted = controller.highlightedNode.value;
          final isError = controller.hasError.value;
          
          return Stack(
            alignment: Alignment.center,
            children: [
              // 1. Precise Crop of the Blueprint diagram shapes
              SizedBox(
                width: size,
                height: size,
                child: ClipRect(
                  child: Align(
                    alignment: const Alignment(-0.69, 0.22),
                    widthFactor: 0.39,
                    heightFactor: 0.52,
                    child: Image.asset(
                      'assets/images/blueprint.jpg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // 2. Transparent Interactive Highlight overlay
              CustomPaint(
                size: Size(size, size),
                painter: OctetTriangulusHighlightPainter(
                  nodes: nodes,
                  activeNodes: activeNodes,
                  highlightedNode: highlighted,
                  isErrorState: isError,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class OctetTriangulusHighlightPainter extends CustomPainter {
  final List<NodePosition> nodes;
  final List<String> activeNodes;
  final String highlightedNode;
  final bool isErrorState;

  OctetTriangulusHighlightPainter({
    required this.nodes,
    required this.activeNodes,
    required this.highlightedNode,
    required this.isErrorState,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final R = size.width * 0.45;
    final nodeRadius = R * 0.08;

    for (final node in nodes) {
      final double nodeX = center.dx + node.relativeOffset.dx * R;
      final double nodeY = center.dy + node.relativeOffset.dy * R;
      final Offset nodeOffset = Offset(nodeX, nodeY);

      final bool isHighlighted = highlightedNode == node.id;
      final bool isActive = activeNodes.contains(node.id);

      Color highlightColor = isErrorState
          ? Colors.redAccent
          : (isHighlighted ? const Color(0xFF00FF7F) : const Color(0xFFFFD700));

      if (isHighlighted || isActive) {
        // Draw elegant technical indicators on active nodes
        final Paint activePaint = Paint()
          ..color = highlightColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = isHighlighted ? 2.5 : 1.5;
        canvas.drawCircle(nodeOffset, nodeRadius * 1.3, activePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant OctetTriangulusHighlightPainter oldDelegate) {
    return oldDelegate.highlightedNode != highlightedNode ||
        oldDelegate.activeNodes != activeNodes ||
        oldDelegate.isErrorState != isErrorState;
  }
}
