import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/power_up_model.dart';

/// Power-up button bar
class PowerUpBar extends StatelessWidget {
  final Map<String, int> inventory;
  final bool peekActive;
  final bool freezeActive;
  final Duration? freezeRemaining;
  final Function(PowerUpType) onUsePowerUp;

  const PowerUpBar({
    super.key,
    required this.inventory,
    this.peekActive = false,
    this.freezeActive = false,
    this.freezeRemaining,
    required this.onUsePowerUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PowerUpButton(
            config: PowerUpConfigs.peek,
            count: inventory['peek'] ?? 0,
            isActive: peekActive,
            onTap: () => onUsePowerUp(PowerUpType.peek),
          ),
          const SizedBox(width: 12),
          _PowerUpButton(
            config: PowerUpConfigs.freeze,
            count: inventory['freeze'] ?? 0,
            isActive: freezeActive,
            remainingTime: freezeRemaining,
            onTap: () => onUsePowerUp(PowerUpType.freeze),
          ),
          const SizedBox(width: 12),
          _PowerUpButton(
            config: PowerUpConfigs.hint,
            count: inventory['hint'] ?? 0,
            onTap: () => onUsePowerUp(PowerUpType.hint),
          ),
          const SizedBox(width: 12),
          _PowerUpButton(
            config: PowerUpConfigs.magnet,
            count: inventory['magnet'] ?? 0,
            onTap: () => onUsePowerUp(PowerUpType.magnet),
          ),
        ],
      ),
    );
  }
}

class _PowerUpButton extends StatelessWidget {
  final PowerUpConfig config;
  final int count;
  final bool isActive;
  final Duration? remainingTime;
  final VoidCallback onTap;

  const _PowerUpButton({
    required this.config,
    required this.count,
    this.isActive = false,
    this.remainingTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasStock = count > 0;
    final canUse = hasStock && !isActive;

    return GestureDetector(
      onTap: canUse ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.accent.withOpacity(0.3)
              : hasStock
                  ? AppColors.primary.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive
                ? AppColors.accent
                : hasStock
                    ? AppColors.primary.withOpacity(0.5)
                    : Colors.grey.withOpacity(0.3),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    config.icon,
                    style: TextStyle(
                      fontSize: 24,
                      color: hasStock ? null : Colors.grey,
                    ),
                  ),
                  if (remainingTime != null)
                    Text(
                      '${remainingTime!.inSeconds}s',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
            if (count > 0)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Single power-up button for shop/inventory
class PowerUpCard extends StatelessWidget {
  final PowerUpConfig config;
  final int count;
  final VoidCallback? onBuy;
  final VoidCallback? onUse;
  final bool showBuyButton;

  const PowerUpCard({
    super.key,
    required this.config,
    this.count = 0,
    this.onBuy,
    this.onUse,
    this.showBuyButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            config.icon,
            style: const TextStyle(fontSize: 40),
          ),
          const SizedBox(height: 8),
          Text(
            config.name,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            config.description,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Owned: $count',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.accent,
            ),
          ),
          const SizedBox(height: 12),
          if (showBuyButton)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBuyButton(
                  '💰 ${config.coinCost}',
                  onBuy,
                ),
                const SizedBox(width: 8),
                _buildBuyButton(
                  '💎 ${config.gemCost}',
                  onBuy,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBuyButton(String text, VoidCallback? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
