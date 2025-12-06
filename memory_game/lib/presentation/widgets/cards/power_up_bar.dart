import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/power_up_model.dart';

class PowerUpBar extends StatelessWidget {
  final Map<String, int> powerUpCounts;
  final bool isPeekActive;
  final bool isFreezeActive;
  final Duration? freezeRemaining;
  final Function(PowerUpType) onPowerUpTap;

  const PowerUpBar({
    super.key,
    required this.powerUpCounts,
    required this.isPeekActive,
    required this.isFreezeActive,
    this.freezeRemaining,
    required this.onPowerUpTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(51),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _PowerUpButton(
            config: PowerUpConfigs.peek,
            count: powerUpCounts['peek'] ?? 0,
            isActive: isPeekActive,
            onTap: () => onPowerUpTap(PowerUpType.peek),
          ),
          const SizedBox(width: 12),
          _PowerUpButton(
            config: PowerUpConfigs.freeze,
            count: powerUpCounts['freeze'] ?? 0,
            isActive: isFreezeActive,
            remaining: freezeRemaining,
            onTap: () => onPowerUpTap(PowerUpType.freeze),
          ),
          const SizedBox(width: 12),
          _PowerUpButton(
            config: PowerUpConfigs.hint,
            count: powerUpCounts['hint'] ?? 0,
            isActive: false,
            onTap: () => onPowerUpTap(PowerUpType.hint),
          ),
          const SizedBox(width: 12),
          _PowerUpButton(
            config: PowerUpConfigs.magnet,
            count: powerUpCounts['magnet'] ?? 0,
            isActive: false,
            onTap: () => onPowerUpTap(PowerUpType.magnet),
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
  final Duration? remaining;
  final VoidCallback onTap;

  const _PowerUpButton({
    required this.config,
    required this.count,
    required this.isActive,
    this.remaining,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasCount = count > 0;
    final canUse = hasCount && !isActive;

    return GestureDetector(
      onTap: canUse ? onTap : null,
      child: Tooltip(
        message: '${config.name}: ${config.description}\n${hasCount ? "Tap to use ($count left)" : "None available"}',
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.secondary.withAlpha(51)
                : hasCount
                    ? AppColors.surface
                    : AppColors.surface.withAlpha(128),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isActive
                  ? AppColors.secondary
                  : hasCount
                      ? AppColors.primary.withAlpha(128)
                      : Colors.grey.withAlpha(77),
              width: isActive ? 2 : 1,
            ),
            boxShadow: canUse
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(51),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    config.icon,
                    style: TextStyle(
                      fontSize: 22,
                      color: hasCount ? null : Colors.grey,
                    ),
                  ),
                  if (remaining != null && isActive) ...[
                    Text(
                      '${remaining!.inSeconds}s',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              if (hasCount && !isActive)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      count.toString(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (!hasCount)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(77),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Icon(Icons.lock, size: 16, color: Colors.white54),
                    ),
                  ),
                ),
            ],
          ),
        ).animate(target: isActive ? 1 : 0).shimmer(duration: 1.seconds),
      ),
    );
  }
}
