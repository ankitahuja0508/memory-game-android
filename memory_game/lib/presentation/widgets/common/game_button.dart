import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

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
    final hPad = isSmall ? 6.0 : 12.0;
    final vPad = isSmall ? 6.0 : 10.0;
    final fontSize = isSmall ? 11.0 : 14.0;
    final iconSize = isSmall ? 14.0 : 16.0;

    return GestureDetector(
      onTap: isDisabled ? null : onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
        decoration: BoxDecoration(
          gradient: isOutlined ? null : LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(isSmall ? 10 : 14),
          border: isOutlined ? Border.all(color: colors.first, width: 1.5) : null,
          boxShadow: isOutlined
              ? null
              : [
                  BoxShadow(
                    color: colors.first.withAlpha(60),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (emoji != null) ...[
                Text(emoji!, style: TextStyle(fontSize: iconSize)),
                SizedBox(width: isSmall ? 3 : 4),
              ],
              if (icon != null) ...[
                Icon(icon, size: iconSize, color: Colors.white),
                SizedBox(width: isSmall ? 3 : 4),
              ],
              Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  color: isOutlined ? colors.first : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
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
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: (color ?? AppColors.surface).withAlpha(200),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(40),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: size * 0.5),
      ),
    );
  }
}
