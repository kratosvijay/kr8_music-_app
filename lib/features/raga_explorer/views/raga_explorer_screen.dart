import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../../game/controllers/game_controller.dart';
import '../../game/widgets/octet_triangulus_painter.dart';
import '../controllers/raga_controller.dart';

class RagaExplorerScreen extends StatelessWidget {
  RagaExplorerScreen({super.key});

  final RagaController ragaController = Get.put(RagaController());
  final GameController gameController = Get.find<GameController>();
  final RxBool showSwara = true.obs;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;
    final double constrainedWidth = min(screenWidth, 800);
    final double canvasSize = min(constrainedWidth * 0.85, screenHeight * 0.4);

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF07070A),
                    Color(0xFF0E0E15),
                    Color(0xFF0B0A11),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Column(
                    children: [
                      _buildHeader(context),
                      const SizedBox(height: 12),
                      _buildRagaInfoCard(context),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Obx(() {
                                  final activeNodes = ragaController.getActiveRagaNodes();
                                  return OctetTriangulusWidget(
                                    size: canvasSize,
                                    activeNodes: activeNodes,
                                    showSwara: showSwara.value,
                                  );
                                }),
                                const SizedBox(height: 12),
                                _buildPlayScaleButton(context),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _buildControlPanel(context),
                      const SizedBox(height: 16),
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

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () => Get.back(),
          icon: const FaIcon(FontAwesomeIcons.arrowLeft, color: Colors.white, size: 18),
        ),
        const Text(
          'LEVEL 3: HEXIMEL RAGAS',
          style: TextStyle(
            color: Kri8Colors.gold,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            letterSpacing: 1.5,
          ),
        ),
        Obx(() => Row(
              children: [
                const Text('Swara', style: TextStyle(color: Colors.white, fontSize: 11)),
                const SizedBox(width: 6),
                Switch(
                  value: showSwara.value,
                  onChanged: (val) => showSwara.value = val,
                  activeThumbColor: Kri8Colors.gold,
                  activeTrackColor: Kri8Colors.gold.withValues(alpha: 0.2),
                ),
              ],
            )),
      ],
    );
  }

  Widget _buildRagaInfoCard(BuildContext context) {
    return Obx(() {
      final int num = ragaController.ragaNumber.value;
      final String name = ragaController.getRagaName();
      final String mCode = ragaController.mIndex.value.toString();
      final String pCode = ragaController.pIndex.value.toString();
      final String uCode = ragaController.uIndex.value.toString();

      return Kri8GlassContainer(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Melakarta No. $num',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  name,
                  style: const TextStyle(
                    color: Kri8Colors.gold,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Heximel Code',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Kri8Colors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Kri8Colors.gold.withValues(alpha: 0.25)),
                  ),
                  child: Text(
                    '[$mCode][$pCode][$uCode]',
                    style: const TextStyle(
                      color: Kri8Colors.gold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPlayScaleButton(BuildContext context) {
    return Obx(() {
      final isListening = gameController.gameMode.value == GameMode.listen;
      return ElevatedButton(
        onPressed: isListening
            ? null
            : () {
                final notes = ragaController.getRagaNotes();
                gameController.playRagaScale(notes);
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ).copyWith(elevation: ButtonStyleButton.allOrNull(0)),
        child: Ink(
          decoration: BoxDecoration(
            gradient: Kri8Colors.goldGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Kri8Colors.gold.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            width: 140,
            height: 40,
            alignment: Alignment.center,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FaIcon(
                  isListening ? FontAwesomeIcons.spinner : FontAwesomeIcons.circlePlay,
                  color: Colors.black,
                  size: 14,
                ),
                const SizedBox(width: 8),
                Text(
                  isListening ? 'Playing...' : 'PLAY SCALE',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildControlPanel(BuildContext context) {
    return Column(
      children: [
        // Raga Number Master Slider
        Kri8GlassContainer(
          height: 70,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Melakarta Selector', style: TextStyle(color: Colors.grey, fontSize: 11)),
                  Obx(() => Text(
                        'Raga #${ragaController.ragaNumber.value}',
                        style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      )),
                ],
              ),
              Obx(() => SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: Kri8Colors.gold,
                      inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                      thumbColor: Kri8Colors.gold,
                      overlayColor: Kri8Colors.gold.withValues(alpha: 0.15),
                      trackHeight: 2,
                    ),
                    child: Slider(
                      value: ragaController.ragaNumber.value.toDouble(),
                      min: 1,
                      max: 72,
                      divisions: 71,
                      onChanged: (val) {
                        ragaController.ragaNumber.value = val.toInt();
                      },
                    ),
                  )),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Heximel coordinates parameter adjusters
        Row(
          children: [
            // Madhyamam selector
            Expanded(
              flex: 2,
              child: Kri8GlassContainer(
                height: 80,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Madhyamam [M]', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildMButton('M1', 0),
                            _buildMButton('M2', 1),
                          ],
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Purvanga selector (P index)
            Expanded(
              flex: 3,
              child: Kri8GlassContainer(
                height: 80,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Purvanga [P]', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: ragaController.pIndex.value > 0
                                  ? () {
                                      ragaController.pIndex.value--;
                                      ragaController.calculateRagaFromHeximel();
                                    }
                                  : null,
                              icon: const FaIcon(FontAwesomeIcons.chevronLeft, color: Colors.white54, size: 12),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Column(
                              children: [
                                Text(
                                  'Idx: ${ragaController.pIndex.value}',
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _getPurvangaLabel(ragaController.pIndex.value),
                                  style: const TextStyle(color: Colors.grey, fontSize: 9),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: ragaController.pIndex.value < 5
                                  ? () {
                                      ragaController.pIndex.value++;
                                      ragaController.calculateRagaFromHeximel();
                                    }
                                  : null,
                              icon: const FaIcon(FontAwesomeIcons.chevronRight, color: Colors.white54, size: 12),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Uttaranga selector (U index)
            Expanded(
              flex: 3,
              child: Kri8GlassContainer(
                height: 80,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Uttaranga [U]', style: TextStyle(color: Colors.grey, fontSize: 10)),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: ragaController.uIndex.value > 0
                                  ? () {
                                      ragaController.uIndex.value--;
                                      ragaController.calculateRagaFromHeximel();
                                    }
                                  : null,
                              icon: const FaIcon(FontAwesomeIcons.chevronLeft, color: Colors.white54, size: 12),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Column(
                              children: [
                                Text(
                                  'Idx: ${ragaController.uIndex.value}',
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  _getUttarangaLabel(ragaController.uIndex.value),
                                  style: const TextStyle(color: Colors.grey, fontSize: 9),
                                ),
                              ],
                            ),
                            IconButton(
                              onPressed: ragaController.uIndex.value < 5
                                  ? () {
                                      ragaController.uIndex.value++;
                                      ragaController.calculateRagaFromHeximel();
                                    }
                                  : null,
                              icon: const FaIcon(FontAwesomeIcons.chevronRight, color: Colors.white54, size: 12),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        )),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMButton(String text, int targetIdx) {
    final bool isSelected = ragaController.mIndex.value == targetIdx;
    return GestureDetector(
      onTap: () {
        ragaController.mIndex.value = targetIdx;
        ragaController.calculateRagaFromHeximel();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? Kri8Colors.gold : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  String _getPurvangaLabel(int idx) {
    switch (idx) {
      case 0: return 'R1 G1';
      case 1: return 'R1 G2';
      case 2: return 'R1 G3';
      case 3: return 'R2 G2';
      case 4: return 'R2 G3';
      case 5: return 'R3 G3';
      default: return '';
    }
  }

  String _getUttarangaLabel(int idx) {
    switch (idx) {
      case 0: return 'D1 N1';
      case 1: return 'D1 N2';
      case 2: return 'D1 N3';
      case 3: return 'D2 N2';
      case 4: return 'D2 N3';
      case 5: return 'D3 N3';
      default: return '';
    }
  }
}
