import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/game_result_model.dart';
import '../../../domain/services/audio_service.dart';
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

  void _playButtonSound() {
    AudioService.instance.playButton();
  }

  String _getTitle() {
    if (result.isPerfect) return '🎉 PERFECT! 🎉';
    if (result.stars == 3) return '⭐ EXCELLENT! ⭐';
    if (result.stars == 2) return '👍 WELL DONE!';
    return '✅ COMPLETE!';
  }

  String _getSubtitle() {
    if (result.isPerfect) return 'Flawless victory!';
    if (result.stars == 3) return 'Outstanding performance!';
    if (result.stars == 2) return 'Good job! Keep improving!';
    if (result.longestStreak >= 3) return 'Nice streak of ${result.longestStreak}!';
    return 'Try again for more stars!';
  }

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
            // Level indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primary.withAlpha(40),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Level ${result.level}',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ).animate().fadeIn().scale(),

            const SizedBox(height: 12),

            // Title
            Text(_getTitle(), style: AppTextStyles.headline2, textAlign: TextAlign.center)
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.5, 0.5)),
            
            // Subtitle
            const SizedBox(height: 4),
            Text(
              _getSubtitle(),
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 200.ms),

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

            // Special level bonus (if applicable)
            if (result.isSpecialLevel) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.accent.withAlpha(100)),
                ),
                child: Text(
                  result.specialLevelBonus ?? '',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 2.seconds),
              const SizedBox(height: 12),
            ],

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

            // Action Buttons - Home & Retry in row, Next Level below
            Column(
              children: [
                // Home and Retry buttons in a row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActionButton(
                      icon: Icons.home_rounded,
                      label: 'Home',
                      onTap: () {
                        _playButtonSound();
                        onHome();
                      },
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 32),
                    _ActionButton(
                      icon: Icons.replay_rounded,
                      label: 'Retry',
                      onTap: () {
                        _playButtonSound();
                        onReplay();
                      },
                      color: AppColors.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Next Level - Full width primary button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _playButtonSound();
                      onNextLevel();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 24),
                    label: Text(
                      'Level ${result.level + 1} →',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
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

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
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
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withAlpha(100), width: 1.5),
            ),
            child: Icon(
              icon,
              size: 28,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
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
