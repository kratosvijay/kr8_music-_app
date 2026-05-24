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
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double R = size.width * 0.45;

    final Paint linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.15);

    // 1. Draw Outer boundary circle
    canvas.drawCircle(Offset(centerX, centerY), R, linePaint);

    // 2. Draw Upright stabilizing triangle T1-T2-T3 (Cyan)
    final Offset t1 = Offset(centerX + nodes[0].relativeOffset.dx * R, centerY + nodes[0].relativeOffset.dy * R);
    final Offset t2 = Offset(centerX + nodes[1].relativeOffset.dx * R, centerY + nodes[1].relativeOffset.dy * R);
    final Offset t3 = Offset(centerX + nodes[2].relativeOffset.dx * R, centerY + nodes[2].relativeOffset.dy * R);
    
    final Paint trianglePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = isErrorState 
          ? Colors.redAccent.withValues(alpha: 0.4) 
          : Kri8Colors.neonBlue.withValues(alpha: 0.35);
    
    final Path trianglePath = Path()
      ..moveTo(t1.dx, t1.dy)
      ..lineTo(t2.dx, t2.dy)
      ..lineTo(t3.dx, t3.dy)
      ..close();

    final Paint triangleFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isErrorState
          ? Colors.redAccent.withValues(alpha: 0.08)
          : Kri8Colors.neonBlue.withValues(alpha: 0.08);
    canvas.drawPath(trianglePath, triangleFillPaint);
    canvas.drawPath(trianglePath, trianglePaint);

    // 3. Draw Downward tension apex (Hot Pink / Red)
    final Offset d1 = Offset(centerX + nodes[3].relativeOffset.dx * R, centerY + nodes[3].relativeOffset.dy * R);
    final Offset topL = Offset(centerX - R * 0.22, centerY - R * 0.5);
    final Offset topR = Offset(centerX + R * 0.22, centerY - R * 0.5);

    final Paint tensionPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = isErrorState
          ? Colors.redAccent.withValues(alpha: 0.5)
          : Colors.redAccent.withValues(alpha: 0.3);

    final Path tensionPath = Path()
      ..moveTo(topL.dx, topL.dy)
      ..lineTo(topR.dx, topR.dy)
      ..lineTo(d1.dx, d1.dy)
      ..close();

    final Paint tensionFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isErrorState
          ? Colors.redAccent.withValues(alpha: 0.08)
          : Colors.redAccent.withValues(alpha: 0.08);
    canvas.drawPath(tensionPath, tensionFillPaint);
    canvas.drawPath(tensionPath, tensionPaint);

    // 4. Draw overlapping Figure-8 loops (Left and Right hemispheres)
    // Right hemisphere circle (Purvanga)
    final Offset rightLoopCenter = Offset(centerX + R * 0.32, centerY + R * 0.05);
    final double loopRadius = R * 0.38;

    final Paint rightLoopFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isErrorState
          ? Colors.redAccent.withValues(alpha: 0.05)
          : Kri8Colors.secondary.withValues(alpha: 0.08);
    canvas.drawCircle(rightLoopCenter, loopRadius, rightLoopFillPaint);

    final Paint rightLoopPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = isErrorState 
          ? Colors.redAccent.withValues(alpha: 0.25)
          : Kri8Colors.secondary.withValues(alpha: 0.25);
    canvas.drawCircle(rightLoopCenter, loopRadius, rightLoopPaint);

    // Left hemisphere circle (Uttaranga)
    final Offset leftLoopCenter = Offset(centerX - R * 0.32, centerY + R * 0.05);

    final Paint leftLoopFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isErrorState
          ? Colors.redAccent.withValues(alpha: 0.05)
          : Kri8Colors.gold.withValues(alpha: 0.08);
    canvas.drawCircle(leftLoopCenter, loopRadius, leftLoopFillPaint);

    final Paint leftLoopPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = isErrorState
          ? Colors.redAccent.withValues(alpha: 0.25)
          : Kri8Colors.gold.withValues(alpha: 0.25);
    canvas.drawCircle(leftLoopCenter, loopRadius, leftLoopPaint);

    // Top loop circle
    final Offset topLoopCenter = Offset(centerX, centerY - R * 0.32);

    final Paint topLoopFillPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = isErrorState
          ? Colors.redAccent.withValues(alpha: 0.03)
          : Colors.white.withValues(alpha: 0.03);
    canvas.drawCircle(topLoopCenter, loopRadius, topLoopFillPaint);

    final Paint topLoopPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.1);
    canvas.drawCircle(topLoopCenter, loopRadius, topLoopPaint);

    // 5. Draw the Nodes
    for (final node in nodes) {
      final double nodeX = centerX + node.relativeOffset.dx * R;
      final double nodeY = centerY + node.relativeOffset.dy * R;
      final Offset nodeOffset = Offset(nodeX, nodeY);
      
      final bool isHighlighted = highlightedNode == node.id;
      final bool isActive = activeNodes.contains(node.id);

      // Node base style
      Color nodeColor = node.color;
      double fillOpacity = 0.15;
      double strokeWidth = 1.5;
      double radius = 18.0;

      if (isErrorState) {
        nodeColor = Colors.redAccent;
        fillOpacity = 0.2;
      } else if (isHighlighted) {
        fillOpacity = 0.85;
        radius = 23.0; // expand/pulse
        strokeWidth = 3.0;
      } else if (isActive) {
        fillOpacity = 0.45;
        radius = 20.0;
        strokeWidth = 2.0;
      }

      // Draw shadow/glow behind active or highlighted nodes
      if (isHighlighted || isActive) {
        final Paint glowPaint = Paint()
          ..color = nodeColor.withValues(alpha: isHighlighted ? 0.4 : 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
        canvas.drawCircle(nodeOffset, radius + 6, glowPaint);
      }

      // Draw node outer border
      final Paint nodeStrokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = isHighlighted 
            ? Colors.white 
            : (isActive ? nodeColor.withValues(alpha: 0.9) : nodeColor.withValues(alpha: 0.6));
      canvas.drawCircle(nodeOffset, radius, nodeStrokePaint);

      // Draw node fill
      final Paint nodeFillPaint = Paint()
        ..style = PaintingStyle.fill
        ..color = nodeColor.withValues(alpha: fillOpacity);
      canvas.drawCircle(nodeOffset, radius, nodeFillPaint);

      // 6. Draw Node Text (Label)
      final String text = showSwara ? node.swaraLabel : node.label;
      final Color textColor = (isHighlighted && !isErrorState) 
          ? Colors.black 
          : Colors.white.withValues(alpha: (isActive || isHighlighted) ? 1.0 : 0.85);

      final textSpan = TextSpan(
        text: text,
        style: TextStyle(
          color: textColor,
          fontSize: text.length > 2 ? 8.5 : 10.0,
          fontWeight: (isActive || isHighlighted) ? FontWeight.bold : FontWeight.normal,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
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
