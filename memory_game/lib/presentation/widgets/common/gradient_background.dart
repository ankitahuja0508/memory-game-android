import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Gradient background widget
class GradientBackground extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;

  const GradientBackground({
    super.key,
    required this.child,
    this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: colors ?? AppColors.backgroundGradient,
        ),
      ),
      child: child,
    );
  }
}
