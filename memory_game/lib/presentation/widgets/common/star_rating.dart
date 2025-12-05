import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Star rating display
class StarRating extends StatelessWidget {
  final int stars;
  final int maxStars;
  final double size;
  final bool animated;

  const StarRating({
    super.key,
    required this.stars,
    this.maxStars = 3,
    this.size = 32,
    this.animated = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxStars, (index) {
        final isFilled = index < stars;

        if (animated) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: isFilled ? 1.0 : 0.0),
            duration: Duration(milliseconds: 300 + (index * 200)),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              return Transform.scale(
                scale: 0.5 + (value * 0.5),
                child: Opacity(
                  opacity: 0.3 + (value * 0.7),
                  child: _buildStar(isFilled),
                ),
              );
            },
          );
        }

        return _buildStar(isFilled);
      }),
    );
  }

  Widget _buildStar(bool isFilled) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: size * 0.1),
      child: Icon(
        isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
        color: isFilled ? AppColors.starFilled : AppColors.starEmpty,
        size: size,
        shadows: isFilled
            ? [
                Shadow(
                  color: AppColors.starFilled.withOpacity(0.5),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
    );
  }
}

/// Animated star for level complete
class AnimatedStar extends StatefulWidget {
  final bool isFilled;
  final int index;
  final double size;
  final Duration delay;

  const AnimatedStar({
    super.key,
    required this.isFilled,
    required this.index,
    this.size = 48,
    this.delay = Duration.zero,
  });

  @override
  State<AnimatedStar> createState() => _AnimatedStarState();
}

class _AnimatedStarState extends State<AnimatedStar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );

    _rotationAnimation = Tween<double>(begin: -0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    if (widget.isFilled) {
      Future.delayed(widget.delay, () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isFilled) {
      return Icon(
        Icons.star_outline_rounded,
        color: AppColors.starEmpty,
        size: widget.size,
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: Icon(
              Icons.star_rounded,
              color: AppColors.starFilled,
              size: widget.size,
              shadows: [
                Shadow(
                  color: AppColors.starFilled.withOpacity(0.5),
                  blurRadius: 15,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
