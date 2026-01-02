import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class AnimatedCounter extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String prefix;
  final String suffix;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.style,
    this.prefix = '',
    this.suffix = '',
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: value),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Text(
          '$prefix$value$suffix',
          style: style ?? AppTextStyles.headline2,
        );
      },
    );
  }
}

class GameTimer extends StatelessWidget {
  final Duration duration;
  final Duration? maxDuration;
  final TextStyle? style;
  final bool showWarning;

  const GameTimer({
    super.key,
    required this.duration,
    this.maxDuration,
    this.style,
    this.showWarning = true,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    final isLow = maxDuration != null && duration.inSeconds <= 10;

    return AnimatedDefaultTextStyle(
      duration: const Duration(milliseconds: 200),
      style: (style ?? AppTextStyles.headline3).copyWith(
        color: isLow && showWarning ? Colors.red : null,
      ),
      child: Text(
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
      ),
    );
  }
}
