import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class Kri8LiveClassItem extends StatelessWidget {
  final String time;
  final String title;
  final String teacher;
  final bool isLive;

  const Kri8LiveClassItem({
    super.key,
    required this.time,
    required this.title,
    required this.teacher,
    this.isLive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                time,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: Kri8Colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              if (isLive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'LIVE',
                    style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                Text(
                  teacher,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Kri8Colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Kri8Colors.onSurfaceVariant),
        ],
      ),
    );
  }
}
