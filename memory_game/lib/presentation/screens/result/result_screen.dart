import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/game_result_model.dart';
import '../../widgets/common/star_rating.dart';
import '../../widgets/common/game_button.dart';

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
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surface, AppColors.backgroundLight],
          ),
          borderRadius: BorderRadius.circular(24),
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
              result.isPerfect ? '🎉 PERFECT! 🎉' : '🏆 LEVEL COMPLETE!',
              style: AppTextStyles.headline2,
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.5, 0.5)),

            const SizedBox(height: 24),

            // Stars
            AnimatedStarRating(stars: result.stars, size: 48),

            const SizedBox(height: 24),

            // Stats Grid
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(51),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  _StatRow(
                    icon: '⏱️',
                    label: 'Time',
                    value: result.formattedTime,
                  ),
                  const Divider(color: Colors.white24),
                  _StatRow(
                    icon: '👆',
                    label: 'Moves',
                    value: '${result.moves} (optimal: ${result.optimalMoves})',
                  ),
                  const Divider(color: Colors.white24),
                  _StatRow(
                    icon: '🔥',
                    label: 'Best Streak',
                    value: result.longestStreak.toString(),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms)
                .slideY(begin: 0.2),

            const SizedBox(height: 16),

            // Rewards
            Container(
              padding: const EdgeInsets.all(12),
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
                children: [
                  const Text('💰', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    '+${result.totalCoins}',
                    style: AppTextStyles.headline3.copyWith(color: AppColors.coinColor),
                  ),
                  const SizedBox(width: 24),
                  const Text('✨', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Text(
                    '+${result.xpEarned} XP',
                    style: AppTextStyles.headline3.copyWith(color: AppColors.secondary),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 700.ms)
                .shimmer(delay: 900.ms, duration: 1.seconds),

            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: GameButton(
                    text: 'Home',
                    emoji: '🏠',
                    onPressed: onHome,
                    isOutlined: true,
                    isSmall: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GameButton(
                    text: 'Replay',
                    emoji: '🔄',
                    onPressed: onReplay,
                    isOutlined: true,
                    isSmall: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GameButton(
                    text: 'Next',
                    emoji: '➡️',
                    onPressed: onNextLevel,
                    gradient: AppColors.successGradient,
                    isSmall: true,
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Text(label, style: AppTextStyles.body2),
          const Spacer(),
          Text(value, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
