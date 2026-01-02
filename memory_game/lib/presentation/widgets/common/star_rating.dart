import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';

class StarRating extends StatelessWidget {
  final int stars;
  final int maxStars;
  final double size;
  final bool animated;

  const StarRating({
    super.key,
    required this.stars,
    this.maxStars = 3,
    this.size = 24,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final isFilled = index < stars;
        final star = Icon(
          isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
          color: isFilled ? AppColors.starFilled : AppColors.starEmpty,
          size: size,
        );

        if (animated && isFilled) {
          return star
              .animate(delay: Duration(milliseconds: 200 * index))
              .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 300.ms, curve: Curves.elasticOut)
              .shimmer(duration: 500.ms, delay: 300.ms);
        }
        return star;
      }),
    );
  }
}

class AnimatedStarRating extends StatefulWidget {
  final int stars;
  final int maxStars;
  final double size;

  const AnimatedStarRating({
    super.key,
    required this.stars,
    this.maxStars = 3,
    this.size = 48,
  });

  @override
  State<AnimatedStarRating> createState() => _AnimatedStarRatingState();
}

class _AnimatedStarRatingState extends State<AnimatedStarRating> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(widget.maxStars, (index) {
        final isFilled = index < widget.stars;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Icon(
            isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
            color: isFilled ? AppColors.starFilled : AppColors.starEmpty.withAlpha(128),
            size: widget.size,
          )
              .animate(delay: Duration(milliseconds: 300 + (index * 200)))
              .scale(begin: const Offset(0, 0), end: const Offset(1, 1), duration: 400.ms, curve: Curves.elasticOut)
              .then()
              .shimmer(duration: 600.ms),
        );
      }),
    );
  }
}
