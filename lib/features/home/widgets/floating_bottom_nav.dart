import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/glass_container.dart';

class Kri8FloatingBottomNav extends StatelessWidget {
  const Kri8FloatingBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Kri8GlassContainer(
        height: 70,
        borderRadius: 35,
        blur: 30,
        opacity: 0.15,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _NavItem(icon: Icons.home_filled, isSelected: true),
            _NavItem(icon: Icons.explore_outlined),
            _NavItem(icon: Icons.mic_none_rounded),
            _NavItem(icon: Icons.person_outline_rounded),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;

  const _NavItem({required this.icon, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      color: isSelected ? Kri8Colors.neonBlue : Kri8Colors.onSurfaceVariant,
      size: 28,
    );
  }
}
