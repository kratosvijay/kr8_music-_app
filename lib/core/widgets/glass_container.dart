import 'dart:ui';
import 'package:flutter/material.dart';

class Kri8GlassContainer extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget child;
  final double borderRadius;
  final double blur;
  final double border;
  final LinearGradient? borderGradient;
  final LinearGradient? linearGradient;
  final EdgeInsetsGeometry? padding;
  final double opacity;

  const Kri8GlassContainer({
    super.key,
    this.width,
    this.height,
    required this.child,
    this.borderRadius = 16,
    this.blur = 20,
    this.border = 1,
    this.borderGradient,
    this.linearGradient,
    this.padding,
    this.opacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = linearGradient ?? LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.white.withValues(alpha: opacity),
        Colors.white.withValues(alpha: opacity * 0.5),
      ],
      stops: const [0.1, 1],
    );

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: effectiveGradient,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: border,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
