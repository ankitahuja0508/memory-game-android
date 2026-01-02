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

  void _showPowerUpInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PowerUpInfoDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(51),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          // Info button (fixed on left)
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: GestureDetector(
              onTap: () => _showPowerUpInfoDialog(context),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.surface.withAlpha(128),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.textSecondary.withAlpha(77)),
                ),
                child: const Icon(
                  Icons.help_outline,
                  size: 18,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Scrollable power-ups
          Expanded(
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              itemCount: PowerUpConfigs.all.length,
              separatorBuilder: (context, index) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final config = PowerUpConfigs.all[index];
                final count = powerUpCounts[config.id] ?? 0;
                
                // Determine if this power-up is active
                bool isActive = false;
                Duration? remaining;
                
                if (config.id == 'peek') {
                  isActive = isPeekActive;
                } else if (config.id == 'freeze') {
                  isActive = isFreezeActive;
                  remaining = freezeRemaining;
                }
                
                return _PowerUpButton(
                  config: config,
                  count: count,
                  isActive: isActive,
                  remaining: remaining,
                  onTap: () => onPowerUpTap(config.type),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog showing information about all power-ups
class PowerUpInfoDialog extends StatelessWidget {
  const PowerUpInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    // Show all available power-ups
    const powerUps = PowerUpConfigs.all;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surface, AppColors.backgroundLight],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withAlpha(77)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.accent, size: 28),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Power-Ups Guide',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 12),
            
            // Power-up list
            ...powerUps.map((config) => _PowerUpInfoItem(config: config)),
            
            const SizedBox(height: 16),
            
            // Tip
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withAlpha(50)),
              ),
              child: const Row(
                children: [
                  Text('💡', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tap a power-up during the game to use it, or use the ⚡ button to access all power-ups. Get more in the Power-ups shop!',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().scale(duration: 200.ms, curve: Curves.easeOut);
  }
}

class _PowerUpInfoItem extends StatelessWidget {
  final PowerUpConfig config;

  const _PowerUpInfoItem({required this.config});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(40),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withAlpha(100)),
            ),
            child: Center(
              child: Text(config.icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  config.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  config.description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
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
