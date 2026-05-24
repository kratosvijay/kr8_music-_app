import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/game_controller.dart';

/// Each note's tap zone definition: ID, label, position (fraction of image),
/// hit radius fraction, and its unique constant glow color.
class NoteZone {
  final String id;
  final String label;
  final String swaraLabel;
  final double fx; // fractional x (0.0–1.0) of the image
  final double fy; // fractional y (0.0–1.0) of the image
  final double hitRadius; // fraction of image size for the tap zone
  final Color color;

  const NoteZone({
    required this.id,
    required this.label,
    required this.swaraLabel,
    required this.fx,
    required this.fy,
    this.hitRadius = 0.06,
    required this.color,
  });
}

/// Interactive Harmonic Blueprint widget.
///
/// Uses the actual blueprint image as the visual layer, with invisible
/// circular tap zones overlaid at each note position. When tapped,
/// a radial glow of the note's unique color illuminates that area.
class OctetTriangulusWidget extends StatelessWidget {
  final double size;
  final GameController controller = Get.find<GameController>();
  final List<String> activeNodes;
  final bool showSwara;

  OctetTriangulusWidget({
    super.key,
    required this.size,
    this.activeNodes = const [],
    this.showSwara = false,
  });

  // 12 chromatic note zones — positions calibrated to the reference image
  // Colors: Scriabin-inspired chromatic color wheel (constant per note)
  static const List<NoteZone> noteZones = [
    // === Triangle vertices (on outer circle) ===
    NoteZone(
      id: 'T1', label: 'C', swaraLabel: 'S',
      fx: 0.50, fy: 0.055,
      hitRadius: 0.055,
      color: Color(0xFFFF3B30), // Red
    ),
    NoteZone(
      id: 'T2', label: 'F', swaraLabel: 'M1',
      fx: 0.745, fy: 0.77,
      hitRadius: 0.055,
      color: Color(0xFF34C759), // Green
    ),
    NoteZone(
      id: 'T3', label: 'G', swaraLabel: 'P',
      fx: 0.255, fy: 0.77,
      hitRadius: 0.055,
      color: Color(0xFF007AFF), // Blue
    ),
    // === Bottom center (Gb/F#) ===
    NoteZone(
      id: 'D1', label: 'F#', swaraLabel: 'M2',
      fx: 0.50, fy: 0.88,
      hitRadius: 0.055,
      color: Color(0xFF30D5C8), // Teal
    ),
    // === Inner notes — left side ===
    NoteZone(
      id: 'O7', label: 'Bb', swaraLabel: 'D3/N2',
      fx: 0.395, fy: 0.31,
      hitRadius: 0.048,
      color: Color(0xFFAF52DE), // Purple
    ),
    NoteZone(
      id: 'O8', label: 'B', swaraLabel: 'N3',
      fx: 0.275, fy: 0.305,
      hitRadius: 0.048,
      color: Color(0xFFFF2D78), // Pink
    ),
    NoteZone(
      id: 'O6', label: 'A', swaraLabel: 'D2/N1',
      fx: 0.24, fy: 0.465,
      hitRadius: 0.048,
      color: Color(0xFF5856D6), // Indigo
    ),
    NoteZone(
      id: 'O5', label: 'Ab', swaraLabel: 'D1',
      fx: 0.37, fy: 0.445,
      hitRadius: 0.048,
      color: Color(0xFF5AC8FA), // Light Blue
    ),
    // === Inner notes — right side ===
    NoteZone(
      id: 'O1', label: 'Db', swaraLabel: 'R1',
      fx: 0.585, fy: 0.31,
      hitRadius: 0.048,
      color: Color(0xFFFF6B35), // Orange-Red
    ),
    NoteZone(
      id: 'O2', label: 'D', swaraLabel: 'R2/G1',
      fx: 0.74, fy: 0.305,
      hitRadius: 0.048,
      color: Color(0xFFFF9500), // Orange
    ),
    NoteZone(
      id: 'O3', label: 'Eb', swaraLabel: 'R3/G2',
      fx: 0.615, fy: 0.445,
      hitRadius: 0.048,
      color: Color(0xFFFFCC00), // Gold
    ),
    NoteZone(
      id: 'O4', label: 'E', swaraLabel: 'G3',
      fx: 0.725, fy: 0.555,
      hitRadius: 0.048,
      color: Color(0xFFA8E600), // Yellow-Green
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: size,
        height: size,
        child: Obx(() {
          final highlighted = controller.highlightedNode.value;
          final isError = controller.hasError.value;

          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: (details) {
              _handleTap(details.localPosition);
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Layer 1: The actual blueprint image (visual only)
                Image.asset(
                  'assets/images/harmonic_blueprint.png',
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),

                // Layer 2: Glow overlays for active/highlighted notes
                ...noteZones.map((zone) {
                  final bool isHighlighted = highlighted == zone.id;
                  final bool isActive = activeNodes.contains(zone.id);

                  if (!isHighlighted && !isActive) {
                    return const SizedBox.shrink();
                  }

                  final Color glowColor = isError
                      ? Colors.redAccent
                      : (isHighlighted ? zone.color : zone.color.withValues(alpha: 0.6));

                  return Positioned(
                    left: (zone.fx - zone.hitRadius) * size,
                    top: (zone.fy - zone.hitRadius) * size,
                    width: zone.hitRadius * 2 * size,
                    height: zone.hitRadius * 2 * size,
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              glowColor.withValues(alpha: isHighlighted ? 0.7 : 0.4),
                              glowColor.withValues(alpha: isHighlighted ? 0.35 : 0.15),
                              glowColor.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                          boxShadow: isHighlighted
                              ? [
                                  BoxShadow(
                                    color: glowColor.withValues(alpha: 0.6),
                                    blurRadius: zone.hitRadius * size * 0.8,
                                    spreadRadius: zone.hitRadius * size * 0.15,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    ),
                  );
                }),

                // Layer 3: Swara labels overlay (only if showSwara is on)
                if (showSwara)
                  ...noteZones.map((zone) {
                    return Positioned(
                      left: zone.fx * size - 16,
                      top: zone.fy * size - 8,
                      child: IgnorePointer(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            zone.swaraLabel,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Helvetica',
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        }),
      ),
    );
  }

  void _handleTap(Offset localPos) {
    NoteZone? closestZone;
    double minDistance = double.infinity;

    for (final zone in noteZones) {
      final double zoneX = zone.fx * size;
      final double zoneY = zone.fy * size;
      final double distance =
          sqrt(pow(localPos.dx - zoneX, 2) + pow(localPos.dy - zoneY, 2));
      if (distance < minDistance) {
        minDistance = distance;
        closestZone = zone;
      }
    }

    final double hitThreshold =
        (closestZone?.hitRadius ?? 0.06) * size * 1.5; // generous tap zone
    if (closestZone != null && minDistance < hitThreshold) {
      controller.playNode(closestZone.id);
    }
  }
}
