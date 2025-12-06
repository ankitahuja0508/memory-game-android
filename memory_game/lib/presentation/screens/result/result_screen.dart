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
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        constraints: const BoxConstraints(maxWidth: 340),
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
            Text(
              result.isPerfect ? '🎉 PERFECT! 🎉' : '🏆 COMPLETE!',
              style: AppTextStyles.headline2,
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.5, 0.5)),

            const SizedBox(height: 20),

            // Stars
            AnimatedStarRating(stars: result.stars, size: 44),

            const SizedBox(height: 20),

            // Stats
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _StatRow(icon: '⏱️', label: 'Time', value: result.formattedTime),
                  const Divider(color: Colors.white24, height: 20),
                  _StatRow(icon: '👆', label: 'Moves', value: '${result.moves}'),
                  const Divider(color: Colors.white24, height: 20),
                  _StatRow(icon: '🔥', label: 'Streak', value: '${result.longestStreak}'),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 400.ms)
                .slideY(begin: 0.2),

            const SizedBox(height: 16),

            // Rewards
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.coinColor.withAlpha(40),
                    AppColors.gemColor.withAlpha(40),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('💰', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 6),
                  Text(
                    '+${result.totalCoins}',
                    style: AppTextStyles.headline3.copyWith(color: AppColors.coinColor),
                  ),
                  const SizedBox(width: 20),
                  const Text('✨', style: TextStyle(fontSize: 22)),
                  const SizedBox(width: 6),
                  Text(
                    '+${result.xpEarned}XP',
                    style: AppTextStyles.headline3.copyWith(color: AppColors.secondary),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 600.ms)
                .shimmer(delay: 800.ms, duration: 1.seconds),

            const SizedBox(height: 20),

            // Action Buttons - Icon buttons with labels below
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(
                  icon: Icons.home_rounded,
                  label: 'Home',
                  onTap: onHome,
                  color: AppColors.textSecondary,
                ),
                _ActionButton(
                  icon: Icons.replay_rounded,
                  label: 'Retry',
                  onTap: onReplay,
                  color: AppColors.secondary,
                ),
                _ActionButton(
                  icon: Icons.arrow_forward_rounded,
                  label: 'Next',
                  onTap: onNextLevel,
                  color: AppColors.success,
                  isPrimary: true,
                ),
              ],
            )
                .animate()
                .fadeIn(delay: 800.ms)
                .slideY(begin: 0.3),
          ],
        ),
      ).animate().scale(duration: 300.ms, curve: Curves.elasticOut),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isPrimary;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: isPrimary
                  ? const LinearGradient(colors: AppColors.successGradient)
                  : null,
              color: isPrimary ? null : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: isPrimary
                  ? null
                  : Border.all(color: color.withAlpha(100), width: 1.5),
              boxShadow: isPrimary
                  ? [
                      BoxShadow(
                        color: AppColors.success.withAlpha(80),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              icon,
              size: 28,
              color: isPrimary ? Colors.white : color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isPrimary ? AppColors.success : color,
            ),
          ),
        ],
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
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Text(label, style: AppTextStyles.body2),
        const Spacer(),
        Text(
          value,
          style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
