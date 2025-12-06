import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/game_result_model.dart';
import '../../widgets/common/star_rating.dart';

class ResultDialog extends StatelessWidget {
  final GameResult result;
  final VoidCallback onNextLevel;
  final VoidCallback onReplay;
  final VoidCallback onHome;

  const ResultDialog({
    super.key,
    required this.result,
    required this.onNextLevel,
    required this.onReplay,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surface, AppColors.backgroundLight],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withAlpha(77)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withAlpha(51),
              blurRadius: 24,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                result.isPerfect ? '🎉 PERFECT! 🎉' : '🏆 COMPLETE!',
                style: AppTextStyles.headline3,
                textAlign: TextAlign.center,
              ),
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.5, 0.5)),

            const SizedBox(height: 16),

            // Stars
            AnimatedStarRating(stars: result.stars, size: isSmallScreen ? 36 : 44),

            const SizedBox(height: 16),

            // Stats Grid
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _StatRow(icon: '⏱️', label: 'Time', value: result.formattedTime),
                  const Divider(color: Colors.white24, height: 16),
                  _StatRow(icon: '👆', label: 'Moves', value: '${result.moves}'),
                  const Divider(color: Colors.white24, height: 16),
                  _StatRow(icon: '🔥', label: 'Streak', value: result.longestStreak.toString()),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms)
                .slideY(begin: 0.2),

            const SizedBox(height: 12),

            // Rewards
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.coinColor.withAlpha(51),
                    AppColors.gemColor.withAlpha(51),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('💰', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 4),
                  Text(
                    '+${result.totalCoins}',
                    style: AppTextStyles.body1.copyWith(color: AppColors.coinColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 16),
                  const Text('✨', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 4),
                  Text(
                    '+${result.xpEarned}XP',
                    style: AppTextStyles.body1.copyWith(color: AppColors.secondary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms)
                .shimmer(delay: 900.ms, duration: 1.seconds),

            const SizedBox(height: 16),

            // Buttons - Use icons only on very small screens
            Row(
              children: [
                Expanded(
                  child: _CompactButton(
                    icon: Icons.home,
                    label: isSmallScreen ? null : 'Home',
                    onTap: onHome,
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _CompactButton(
                    icon: Icons.replay,
                    label: isSmallScreen ? null : 'Retry',
                    onTap: onReplay,
                    isOutlined: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: isSmallScreen ? 1 : 2,
                  child: _CompactButton(
                    icon: Icons.arrow_forward,
                    label: 'Next',
                    onTap: onNextLevel,
                    isPrimary: true,
                  ),
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 900.ms)
                .slideY(begin: 0.3),
          ],
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
    );
  }
}

class _CompactButton extends StatelessWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final bool isOutlined;
  final bool isPrimary;

  const _CompactButton({
    required this.icon,
    this.label,
    required this.onTap,
    this.isOutlined = false,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          gradient: isPrimary ? const LinearGradient(colors: AppColors.successGradient) : null,
          color: isOutlined ? null : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: isOutlined ? Border.all(color: AppColors.primary, width: 1.5) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isOutlined ? AppColors.primary : Colors.white),
            if (label != null) ...[
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label!,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.caption.copyWith(
                    color: isOutlined ? AppColors.primary : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.caption),
        const Spacer(),
        Text(value, style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
