import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/theme/app_theme.dart';
import 'features/game/views/level_selection_screen.dart';

void main() {
  runApp(const Kri8MusicApp());
}

class Kri8MusicApp extends StatelessWidget {
  const Kri8MusicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'KRI8 Music Intelligence',
      debugShowCheckedModeBanner: false,
      theme: Kri8Theme.darkTheme,
      home: LevelSelectionScreen(),
    );
  }
}
