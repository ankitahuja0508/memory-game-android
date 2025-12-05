import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Display for coins and gems
class CurrencyDisplay extends StatelessWidget {
  final int coins;
  final int gems;
  final bool showGems;
  final VoidCallback? onCoinsTap;
  final VoidCallback? onGemsTap;

  const CurrencyDisplay({
    super.key,
    required this.coins,
    this.gems = 0,
    this.showGems = true,
    this.onCoinsTap,
    this.onGemsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CurrencyChip(
          icon: '💰',
          value: coins,
          color: AppColors.coinColor,
          onTap: onCoinsTap,
        ),
        if (showGems) ...[
          const SizedBox(width: 12),
          _CurrencyChip(
            icon: '💎',
            value: gems,
            color: AppColors.gemColor,
            onTap: onGemsTap,
          ),
        ],
      ],
    );
  }
}

class _CurrencyChip extends StatelessWidget {
  final String icon;
  final int value;
  final Color color;
  final VoidCallback? onTap;

  const _CurrencyChip({
    required this.icon,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.5),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              _formatNumber(value),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.add_circle,
                color: color,
                size: 16,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    }
    return number.toString();
  }
}

/// Single coin display
class CoinDisplay extends StatelessWidget {
  final int amount;
  final double fontSize;
  final bool showIcon;

  const CoinDisplay({
    super.key,
    required this.amount,
    this.fontSize = 16,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon)
          Text('💰', style: TextStyle(fontSize: fontSize)),
        if (showIcon) const SizedBox(width: 4),
        Text(
          amount.toString(),
          style: TextStyle(
            color: AppColors.coinColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}

/// Single gem display
class GemDisplay extends StatelessWidget {
  final int amount;
  final double fontSize;
  final bool showIcon;

  const GemDisplay({
    super.key,
    required this.amount,
    this.fontSize = 16,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon)
          Text('💎', style: TextStyle(fontSize: fontSize)),
        if (showIcon) const SizedBox(width: 4),
        Text(
          amount.toString(),
          style: TextStyle(
            color: AppColors.gemColor,
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
          ),
        ),
      ],
    );
  }
}
