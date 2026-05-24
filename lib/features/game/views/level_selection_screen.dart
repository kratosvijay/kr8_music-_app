import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../controllers/game_controller.dart';
import 'game_screen.dart';
import '../../raga_explorer/views/raga_explorer_screen.dart';
import 'sacred_geometry_screen.dart';

class LevelSelectionScreen extends StatelessWidget {
  LevelSelectionScreen({super.key});

  final GameController controller = Get.put(GameController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Ambient Space Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0A0A0E),
                    Color(0xFF14131C),
                    Color(0xFF0F0E17),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          
          // Outer decorative glowing spheres
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Kri8Colors.neonBlue.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Kri8Colors.vibrantViolet.withValues(alpha: 0.1),
              ),
            ),
          ),

          Positioned.fill(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 30),
                        _buildStatsPanel(context),
                        const SizedBox(height: 35),
                        Text(
                          'Select Core Level',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: -0.5,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _buildLevelCard(
                          context: context,
                          levelNum: 1,
                          title: 'Level 1: Colors & Shapes',
                          description: 'Learn the 12 spatial nodes of the Octet Triangulus. Train your ear by matching interactive note sequences.',
                          gradientColors: [Kri8Colors.neonBlue, Kri8Colors.primary],
                          icon: FontAwesomeIcons.shapes,
                          onTap: () {
                            controller.startLevel(1);
                            Get.to(() => const GameScreen());
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildLevelCard(
                          context: context,
                          levelNum: 2,
                          title: 'Level 2: Western Scales',
                          description: 'Explore scale construction. Learn how Major represents Radial Expansion, while Minor represents Radial Contraction.',
                          gradientColors: [Kri8Colors.secondary, Kri8Colors.vibrantViolet],
                          icon: FontAwesomeIcons.scaleBalanced,
                          onTap: () {
                            controller.startLevel(2);
                            Get.to(() => const GameScreen());
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildLevelCard(
                          context: context,
                          levelNum: 3,
                          title: 'Level 3: Heximel Ragas',
                          description: 'Deconstruct the 72 Melakarta ragas. Synthesize scales dynamically using Base-6 Purvanga and Uttaranga spatial coordinates.',
                          gradientColors: [Kri8Colors.gold, Kri8Colors.tertiary],
                          icon: FontAwesomeIcons.music,
                          onTap: () {
                            Get.to(() => RagaExplorerScreen());
                          },
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
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
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => Kri8Colors.blueGradient.createShader(bounds),
                child: Text(
                  'OCTET TRIANGULUS',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 3,
                        color: Colors.white,
                      ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Music Intelligence',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => Get.to(() => const SacredGeometryScreen()),
              icon: const FaIcon(FontAwesomeIcons.circleNodes, color: Kri8Colors.primary, size: 20),
              tooltip: 'Sacred Geometry Wireframe',
            ),
            const SizedBox(width: 8),
            Obx(() => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Kri8Colors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Kri8Colors.gold.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      const FaIcon(FontAwesomeIcons.bolt, color: Kri8Colors.gold, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        '${controller.streak.value} Days',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Kri8Colors.gold,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsPanel(BuildContext context) {
    return Kri8GlassContainer(
      height: 90,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: Kri8Colors.violetGradient,
                  shape: BoxShape.circle,
                ),
                child: const FaIcon(FontAwesomeIcons.award, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 14),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Score',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Obx(() => Text(
                        '${controller.score.value} XP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                ],
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: const Row(
              children: [
                Text(
                  'Leaderboard',
                  style: TextStyle(color: Kri8Colors.neonBlue, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 4),
                FaIcon(FontAwesomeIcons.angleRight, color: Kri8Colors.neonBlue, size: 12),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLevelCard({
    required BuildContext context,
    required int levelNum,
    required String title,
    required String description,
    required List<Color> gradientColors,
    required dynamic icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Kri8GlassContainer(
        borderRadius: 20,
        padding: const EdgeInsets.only(left: 28, right: 20, top: 20, bottom: 20),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: gradientColors[0].withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: gradientColors[0].withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'LEVEL $levelNum',
                      style: TextStyle(
                        color: gradientColors[0],
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Start Journey',
                        style: TextStyle(
                          color: gradientColors[0],
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      FaIcon(FontAwesomeIcons.circlePlay, color: gradientColors[0], size: 14),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors[0].withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: FaIcon(icon, color: Colors.white, size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
