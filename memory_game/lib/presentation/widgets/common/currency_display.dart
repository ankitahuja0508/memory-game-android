import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class CurrencyDisplay extends StatelessWidget {
  final int coins;
  final int gems;
  final VoidCallback? onCoinsTap;
  final VoidCallback? onGemsTap;

  const CurrencyDisplay({
    super.key,
    required this.coins,
    required this.gems,
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
        const SizedBox(width: 8),
        _CurrencyChip(
          icon: '💎',
          value: gems,
          color: AppColors.gemColor,
          onTap: onGemsTap,
        ),
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

  String _formatValue(int value) {
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}K';
    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(77),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withAlpha(128), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              _formatValue(value),
              style: AppTextStyles.body2.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
