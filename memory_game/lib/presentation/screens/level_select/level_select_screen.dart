import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/star_rating.dart';

class LevelSelectScreen extends StatelessWidget {
  const LevelSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Select Level', style: AppTextStyles.headline3),
          centerTitle: true,
        ),
        body: BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, state) {
            final highestLevel = state.highestUnlockedLevel;
            // Show more levels - display up to highest unlocked + 30 or minimum 100
            final displayLevels = (highestLevel + 30).clamp(100, 9999);

            return Column(
              children: [
                // Stats Header
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withAlpha(179),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _StatItem(
                        icon: '⭐',
                        value: state.totalStars.toString(),
                        label: 'Total Stars',
                      ),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _StatItem(
                        icon: '✅',
                        value: state.completedLevels.toString(),
                        label: 'Completed',
                      ),
                      Container(width: 1, height: 40, color: Colors.white24),
                      _StatItem(
                        icon: '🔓',
                        value: highestLevel.toString(),
                        label: 'Unlocked',
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.2),

                // Level Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: displayLevels,
                    itemBuilder: (context, index) {
                      final level = index + 1;
                      final progress = state.levelProgress[level];
                      final isUnlocked = level <= highestLevel;
                      final isCompleted = progress?.completed ?? false;
                      final stars = progress?.stars ?? 0;

                      return _LevelTile(
                        level: level,
                        stars: stars,
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
                        onTap: isUnlocked
                            ? () => Navigator.pushNamed(
                                  context,
                                  '/game',
                                  arguments: {'level': level},
                                )
                            : null,
                      ).animate(delay: Duration(milliseconds: 20 * (index % 25))).fadeIn().scale(
                            begin: const Offset(0.8, 0.8),
                            duration: 200.ms,
                          );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 4),
            Text(value, style: AppTextStyles.headline3),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }
}

class _LevelTile extends StatelessWidget {
  final int level;
  final int stars;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _LevelTile({
    required this.level,
    required this.stars,
    required this.isUnlocked,
    required this.isCompleted,
    this.onTap,
  });

  Color _getDifficultyColor() {
    if (level <= 10) return AppColors.levelBeginner;
    if (level <= 25) return AppColors.levelEasy;
    if (level <= 50) return AppColors.levelMedium;
    if (level <= 100) return AppColors.levelHard;
    return AppColors.levelExpert;
  }

  @override
  Widget build(BuildContext context) {
    final color = _getDifficultyColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withAlpha(179)],
                )
              : null,
          color: isUnlocked ? null : Colors.grey.withAlpha(77),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted ? AppColors.starFilled : Colors.transparent,
            width: 2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: color.withAlpha(77),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              Icon(Icons.lock, color: Colors.white.withAlpha(128), size: 24)
            else ...[
              Text(
                level.toString(),
                style: AppTextStyles.headline3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              StarRating(stars: stars, size: 12),
            ],
          ],
        ),
      ),
    );
  }
}
