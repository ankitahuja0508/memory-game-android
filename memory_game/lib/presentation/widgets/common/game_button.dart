import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Custom game button with gradient
class GameButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final List<Color>? gradient;
  final double? width;
  final double height;
  final IconData? icon;
  final String? emoji;
  final bool isLoading;
  final bool isSmall;

  const GameButton({
    super.key,
    required this.text,
    this.onPressed,
    this.gradient,
    this.width,
    this.height = 56,
    this.icon,
    this.emoji,
    this.isLoading = false,
    this.isSmall = false,
  });

  @override
  State<GameButton> createState() => _GameButtonState();
}

class _GameButtonState extends State<GameButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonHeight = widget.isSmall ? 44.0 : widget.height;
    final fontSize = widget.isSmall ? 14.0 : 18.0;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: Container(
          width: widget.width,
          height: buttonHeight,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: widget.gradient ?? AppColors.primaryGradient,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(buttonHeight / 2),
            boxShadow: [
              BoxShadow(
                color: (widget.gradient?.first ?? AppColors.primary)
                    .withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(buttonHeight / 2),
              onTap: widget.isLoading ? null : widget.onPressed,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: widget.isSmall ? 16 : 24,
                ),
                child: Row(
                  mainAxisSize:
                      widget.width == null ? MainAxisSize.min : MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.isLoading)
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    else ...[
                      if (widget.emoji != null) ...[
                        Text(
                          widget.emoji!,
                          style: TextStyle(fontSize: fontSize + 4),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: Colors.white,
                          size: fontSize + 4,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        widget.text,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Icon button with circle background
class GameIconButton extends StatelessWidget {
  final IconData? icon;
  final String? emoji;
  final VoidCallback? onPressed;
  final Color? color;
  final double size;

  const GameIconButton({
    super.key,
    this.icon,
    this.emoji,
    this.onPressed,
    this.color,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color ?? AppColors.surface,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: emoji != null
              ? Text(
                  emoji!,
                  style: TextStyle(fontSize: size * 0.5),
                )
              : Icon(
                  icon,
                  color: AppColors.textPrimary,
                  size: size * 0.5,
                ),
        ),
      ),
    );
  }
}
