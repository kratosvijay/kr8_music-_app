import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Kri8Colors {
  static const Color surface = Color(0xFF131313);
  static const Color surfaceDim = Color(0xFF131313);
  static const Color surfaceBright = Color(0xFF3A3939);
  static const Color surfaceContainerLowest = Color(0xFF0E0E0E);
  static const Color surfaceContainerLow = Color(0xFF1C1B1B);
  static const Color surfaceContainer = Color(0xFF201F1F);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353534);
  
  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant = Color(0xFFBAC9CC);
  
  static const Color primary = Color(0xFFC3F5FF);
  static const Color neonBlue = Color(0xFF00E5FF);
  static const Color primaryContainer = Color(0xFF00E5FF);
  static const Color onPrimaryContainer = Color(0xFF00626E);
  
  static const Color secondary = Color(0xFFDAB9FF);
  static const Color vibrantViolet = Color(0xFF8F03FF);
  
  static const Color tertiary = Color(0xFFFFECBB);
  static const Color gold = Color(0xFFF4CD52);
  
  static const Color background = Color(0xFF131313);
  static const Color onBackground = Color(0xFFE5E2E1);

  static const LinearGradient violetGradient = LinearGradient(
    colors: [Color(0xFF8F03FF), Color(0xFFDAB9FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFF4CD52), Color(0xFFFFECBB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF00E5FF), Color(0xFFC3F5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class Kri8Theme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Kri8Colors.background,
      colorScheme: const ColorScheme.dark(
        surface: Kri8Colors.surface,
        onSurface: Kri8Colors.onSurface,
        primary: Kri8Colors.primary,
        secondary: Kri8Colors.secondary,
        tertiary: Kri8Colors.tertiary,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          height: 1.1,
          letterSpacing: -0.96,
          color: Kri8Colors.onSurface,
        ),
        displayMedium: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          height: 1.2,
          letterSpacing: -0.32,
          color: Kri8Colors.onSurface,
        ),
        headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w500,
          height: 1.3,
          color: Kri8Colors.onSurface,
        ),
        bodyLarge: GoogleFonts.manrope(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: Kri8Colors.onSurface,
        ),
        bodyMedium: GoogleFonts.manrope(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.6,
          color: Kri8Colors.onSurface,
        ),
        labelLarge: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          height: 1.0,
          letterSpacing: 1.2,
          color: Kri8Colors.onSurface,
        ),
      ),
    );
  }
}
