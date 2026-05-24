import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../controllers/game_controller.dart';
import '../widgets/octet_triangulus_painter.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  final GameController controller = Get.find<GameController>();
  late AnimationController _shakeController;
  final RxBool showSwara = false.obs;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // Shake the screen when user commits a note selection error
    ever(controller.hasError, (bool hasError) {
      if (hasError) {
        _shakeController.forward(from: 0.0);
      }
    });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  // Generate shake offset
  double _getShakeOffset(double progress) {
    if (progress == 0.0 || progress == 1.0) return 0.0;
    // Multi-phase sine shake
    return sin(progress * 4 * pi) * 12.0 * (1.0 - progress);
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    // Keep canvas size responsive and constrained on wider desktop viewports
    final double constrainedWidth = min(screenWidth, 800);
    final double canvasSize = min(constrainedWidth * 0.85, screenHeight * 0.38);

    return Scaffold(
      body: Stack(
        children: [
          // Ambient Background with red flashes on error
          Obx(() {
            final isError = controller.hasError.value;
            return Positioned.fill(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isError
                        ? [
                            const Color(0xFF2B0A0D),
                            const Color(0xFF140D0F),
                            const Color(0xFF0F0E17),
                          ]
                        : [
                            const Color(0xFF000000),
                            const Color(0xFF000000),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            );
          }),

          // Back button and header
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      _buildTopBar(context),
                      const SizedBox(height: 20),
                      _buildDashboardPanel(context),
                      Expanded(
                        child: Center(
                          child: AnimatedBuilder(
                            animation: _shakeController,
                            builder: (context, child) {
                              final double shakeOffset = _getShakeOffset(_shakeController.value);
                              return Transform.translate(
                                offset: Offset(shakeOffset, 0),
                                child: child,
                              );
                            },
                            child: Obx(() {
                              // Compile list of active nodes to display (for Western scales)
                              final List<String> activeNodes = [];
                              if (controller.currentLevel.value == 2 &&
                                  controller.gameMode.value == GameMode.freePlay) {
                                for (final note in controller.targetSequence) {
                                  activeNodes.add(controller.getNodeForNote(note));
                                }
                              }
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    controller.currentLevel.value == 1
                                        ? 'Level 1: Chromatic Geometry'
                                        : 'Level 2: Harmonic Traversal',
                                    style: const TextStyle(
                                      color: Kri8Colors.neonBlue,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Obx(() => Text(
                                        controller.currentLevel.value == 1
                                            ? 'Stage ${controller.currentStage.value + 1} of ${controller.level1Stages.length}'
                                            : controller.currentStage.value == 0
                                                ? 'C Major Scale'
                                                : controller.currentStage.value == 1
                                                    ? 'C Natural Minor Scale'
                                                    : 'C Harmonic Minor Scale',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18,
                                        ),
                                      )),
                                  const SizedBox(height: 20),
                                  OctetTriangulusWidget(
                                    size: canvasSize,
                                    activeNodes: activeNodes,
                                    showSwara: showSwara.value,
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                      _buildControls(context),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white, size: 18),
        ),
        Obx(() => Row(
              children: [
                const Text(
                  'Swaras Mapping',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(width: 8),
                Switch(
                  value: showSwara.value,
                  onChanged: (val) => showSwara.value = val,
                  activeThumbColor: Kri8Colors.neonBlue,
                  activeTrackColor: Kri8Colors.neonBlue.withValues(alpha: 0.2),
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildDashboardPanel(BuildContext context) {
    return Obx(() {
      final streakVal = controller.streak.value;
      final scoreVal = controller.score.value;
      final isPlay = controller.gameMode.value == GameMode.play;
      final targetLen = controller.targetSequence.length;
      final currentInp = controller.userSequence.length;

      return Kri8GlassContainer(
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const FaIcon(FontAwesomeIcons.bolt, color: Kri8Colors.gold, size: 16),
                const SizedBox(width: 6),
                Text(
                  '$streakVal Streak',
                  style: const TextStyle(color: Kri8Colors.gold, fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            if (isPlay && targetLen > 0)
              Text(
                'Notes: $currentInp / $targetLen',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              )
            else
              Text(
                'XP: $scoreVal',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
          ],
        ),
      );
    });
  }

  Widget _buildControls(BuildContext context) {
    return Column(
      children: [
        // Gameplay instruction text card
        Obx(() {
          final isError = controller.hasError.value;
          return Kri8GlassContainer(
            linearGradient: isError
                ? LinearGradient(
                    colors: [
                      Colors.redAccent.withValues(alpha: 0.15),
                      Colors.redAccent.withValues(alpha: 0.05),
                    ],
                  )
                : null,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                FaIcon(
                  isError ? FontAwesomeIcons.triangleExclamation : FontAwesomeIcons.circleInfo,
                  color: isError ? Colors.redAccent : Kri8Colors.neonBlue,
                  size: 16,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    controller.statusMessage.value,
                    style: TextStyle(
                      color: isError ? Colors.redAccent : Colors.white,
                      fontSize: 13,
                      fontWeight: isError ? FontWeight.bold : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 18),
        
        // Listen & Play buttons
        Obx(() {
          final isListening = controller.gameMode.value == GameMode.listen;
          
          return Row(
            children: [
              Expanded(
                child: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ).copyWith(elevation: ButtonStyleButton.allOrNull(0)).child(
                  onPressed: isListening ? null : () => controller.startListening(),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: isListening
                          ? const LinearGradient(colors: [Colors.grey, Colors.blueGrey])
                          : Kri8Colors.blueGradient,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Container(
                      height: 50,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FaIcon(
                            isListening ? FontAwesomeIcons.compactDisc : FontAwesomeIcons.headphones,
                            color: Colors.black,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isListening ? 'Playing...' : 'LISTEN',
                            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ElevatedButton(
                  onPressed: isListening ? null : () => controller.setupStage(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.05),
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(FontAwesomeIcons.rotateLeft, size: 14),
                      SizedBox(width: 8),
                      Text(
                        'RESET',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ],
    );
  }
}

// Helper extension to make standard ElevatedButton clean
extension ButtonHelper on ButtonStyle {
  Widget child({required VoidCallback? onPressed, required Widget child}) {
    return ElevatedButton(
      onPressed: onPressed,
      style: this,
      child: child,
    );
  }
}
