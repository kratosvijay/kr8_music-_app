import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';
import '../widgets/circular_progress_widget.dart';
import '../widgets/challenge_card.dart';
import '../widgets/live_class_item.dart';
import '../widgets/floating_bottom_nav.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/kri8_background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Dark Overlay for readability
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(context),
                  const SizedBox(height: 40),
                  _buildProgressSection(context),
                  const SizedBox(height: 40),
                  _buildDailyChallenges(context),
                  const SizedBox(height: 40),
                  _buildLiveClasses(context),
                  const SizedBox(height: 100), // Spacer for floating nav
                ],
              ),
            ),
          ),
          // Floating Bottom Nav
          const Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Kri8FloatingBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShaderMask(
              shaderCallback: (bounds) => Kri8Colors.blueGradient.createShader(bounds),
              child: Text(
                'KRI8',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hello, Kenny',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                fontSize: 28,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Kri8Colors.gold.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Kri8Colors.gold.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const FaIcon(FontAwesomeIcons.bolt, color: Kri8Colors.gold, size: 16),
              const SizedBox(width: 8),
              Text(
                '15 Day Streak',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Kri8Colors.gold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return Row(
      children: [
        const Kri8CircularProgress(progress: 0.68, level: '4'),
        const SizedBox(width: 24),
        Expanded(
          child: Kri8GlassContainer(
            height: 180,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Continue Learning',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Kri8Colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pitch Foundation',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.black,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ).copyWith(
                    elevation: ButtonStyleButton.allOrNull(0),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: Kri8Colors.goldGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Container(
                      height: 45,
                      alignment: Alignment.center,
                      child: const Text(
                        'Resume',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDailyChallenges(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Daily Challenges',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        const Row(
          children: [
            Expanded(
              child: Kri8ChallengeCard(
                title: 'Pitch Check',
                icon: Icons.mic,
                iconColor: Kri8Colors.neonBlue,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Kri8ChallengeCard(
                title: 'Raag Finder',
                icon: FontAwesomeIcons.music,
                iconColor: Kri8Colors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLiveClasses(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Live Classes Today',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'See all',
                style: TextStyle(color: Kri8Colors.onSurfaceVariant),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Kri8LiveClassItem(
          time: '18:30',
          title: 'Advanced Melodic Structures',
          teacher: 'Dr. Aranya Sen',
          isLive: true,
        ),
        const Kri8LiveClassItem(
          time: '20:00',
          title: 'Rhythmic Synchronization',
          teacher: 'Guru Prakash',
        ),
      ],
    );
  }
}
