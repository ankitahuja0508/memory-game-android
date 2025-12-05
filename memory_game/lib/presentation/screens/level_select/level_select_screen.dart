import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/currency_display.dart';
import '../../widgets/common/star_rating.dart';

/// Level selection screen
class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  final ScrollController _scrollController = ScrollController();
  final int _levelsPerPage = 20;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: BlocBuilder<PlayerCubit, PlayerState>(
            builder: (context, state) {
              final highestLevel = state.highestUnlockedLevel;
              final displayLevels = ((highestLevel ~/ _levelsPerPage) + 1) * _levelsPerPage;

              return Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            AppStrings.selectLevel,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        CurrencyDisplay(
                          coins: state.player.coins,
                          gems: state.player.gems,
                          showGems: false,
                        ),
                      ],
                    ),
                  ),

                  // Stats bar
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _StatItem(
                          label: 'Completed',
                          value: state.completedLevelsCount.toString(),
                          icon: '✓',
                        ),
                        _StatItem(
                          label: 'Stars',
                          value: state.totalStars.toString(),
                          icon: '⭐',
                        ),
                        _StatItem(
                          label: 'Perfect',
                          value: state.player.perfectGames.toString(),
                          icon: '💎',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Level grid
                  Expanded(
                    child: GridView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: displayLevels,
                      itemBuilder: (context, index) {
                        final level = index + 1;
                        final isUnlocked = state.isLevelUnlocked(level);
                        final progress = state.getLevelProgress(level);

                        return _LevelTile(
                          level: level,
                          isUnlocked: isUnlocked,
                          stars: progress?.stars ?? 0,
                          isCompleted: progress?.completed ?? false,
                          onTap: isUnlocked
                              ? () => _startLevel(context, level)
                              : null,
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _startLevel(BuildContext context, int level) {
    Navigator.pushNamed(context, '/game', arguments: level);
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _LevelTile extends StatelessWidget {
  final int level;
  final bool isUnlocked;
  final int stars;
  final bool isCompleted;
  final VoidCallback? onTap;

  const _LevelTile({
    required this.level,
    required this.isUnlocked,
    required this.stars,
    required this.isCompleted,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final difficulty = _getDifficultyColor(level);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: isUnlocked
              ? LinearGradient(
                  colors: [
                    difficulty.withAlpha(204),
                    difficulty.withAlpha(153),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isUnlocked ? null : AppColors.surface.withAlpha(128),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? difficulty
                : AppColors.textSecondary.withAlpha(77),
            width: 2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: difficulty.withAlpha(77),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!isUnlocked)
              Icon(
                Icons.lock,
                color: AppColors.textSecondary.withAlpha(128),
                size: 24,
              )
            else
              Text(
                level.toString(),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            if (isCompleted) ...[
              const SizedBox(height: 4),
              StarRating(stars: stars, size: 14),
            ],
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(int level) {
    if (level <= 10) return AppColors.levelBeginner;
    if (level <= 30) return AppColors.levelEasy;
    if (level <= 60) return AppColors.levelMedium;
    if (level <= 100) return AppColors.levelHard;
    return AppColors.levelExpert;
  }
}
