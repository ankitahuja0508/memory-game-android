import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class GameButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final IconData? icon;
  final String? emoji;
  final List<Color>? gradient;
  final bool isOutlined;
  final bool isSmall;
  final bool isDisabled;

  const GameButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.emoji,
    this.gradient,
    this.isOutlined = false,
    this.isSmall = false,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = gradient ?? AppColors.primaryGradient;

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 8 : 16,
          vertical: isSmall ? 8 : 12,
        ),
        decoration: BoxDecoration(
          gradient: isOutlined ? null : LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
          border: isOutlined ? Border.all(color: colors.first, width: 2) : null,
          boxShadow: isOutlined
              ? null
              : [
                  BoxShadow(
                    color: colors.first.withAlpha(77),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: TextStyle(fontSize: isSmall ? 14 : 18)),
              SizedBox(width: isSmall ? 4 : 6),
            ],
            if (icon != null) ...[
              Icon(icon, size: isSmall ? 16 : 20, color: Colors.white),
              SizedBox(width: isSmall ? 4 : 6),
            ],
            Flexible(
              child: Text(
                text,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: isSmall
                    ? AppTextStyles.caption.copyWith(
                        color: isOutlined ? colors.first : Colors.white,
                        fontWeight: FontWeight.bold,
                      )
                    : AppTextStyles.body2.copyWith(
                        color: isOutlined ? colors.first : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(
      duration: 100.ms,
      curve: Curves.easeOut,
    );
  }
}

class IconGameButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color? color;
  final double size;

  const IconGameButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.color,
    this.size = 44,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: (color ?? AppColors.surface).withAlpha(204),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(51),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}
