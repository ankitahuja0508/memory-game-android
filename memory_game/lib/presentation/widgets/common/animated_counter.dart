import 'package:flutter/material.dart';

/// Animated counter that counts up/down
class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String? prefix;
  final String? suffix;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix,
    this.suffix,
    this.duration = const Duration(milliseconds: 500),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: duration,
      builder: (context, animatedValue, child) {
        return Text(
          '${prefix ?? ''}$animatedValue${suffix ?? ''}',
          style: style ?? Theme.of(context).textTheme.headlineMedium,
        );
      },
    );
  }
}

/// Animated coin/gem counter with icon
class AnimatedCurrencyCounter extends StatelessWidget {
  final int value;
  final String icon;
  final Color color;
  final double fontSize;
  final Duration duration;

  const AnimatedCurrencyCounter({
    super.key,
    required this.value,
    required this.icon,
    required this.color,
    this.fontSize = 24,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: TextStyle(fontSize: fontSize)),
        const SizedBox(width: 8),
        TweenAnimationBuilder<int>(
          tween: IntTween(begin: 0, end: value),
          duration: duration,
          curve: Curves.easeOutCubic,
          builder: (context, animatedValue, child) {
            return Text(
              '+$animatedValue',
              style: TextStyle(
                color: color,
                fontSize: fontSize,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Timer display with animated color change
class GameTimer extends StatelessWidget {
  final Duration duration;
  final Duration totalDuration;
  final TextStyle? style;
  final bool showWarning;

  const GameTimer({
    super.key,
    required this.duration,
    required this.totalDuration,
    this.style,
    this.showWarning = true,
  });

  @override
  Widget build(BuildContext context) {
    final remaining = totalDuration - duration;
    final isWarning = remaining.inSeconds <= 10;
    final isCritical = remaining.inSeconds <= 5;

    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;

    Color textColor = Colors.white;
    if (showWarning) {
      if (isCritical) {
        textColor = Colors.red;
      } else if (isWarning) {
        textColor = Colors.orange;
      }
    }

    return AnimatedDefaultTextStyle(
      style: (style ?? Theme.of(context).textTheme.headlineMedium!).copyWith(
        color: textColor,
      ),
      duration: const Duration(milliseconds: 200),
      child: Text(
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
      ),
    );
  }
}
