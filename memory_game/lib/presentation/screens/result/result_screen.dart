import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/game_result_model.dart';
import '../../widgets/common/star_rating.dart';
import '../../widgets/common/game_button.dart';
import '../../widgets/common/animated_counter.dart';

/// Result dialog after completing a level
class ResultDialog extends StatefulWidget {
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
  State<ResultDialog> createState() => _ResultDialogState();
}

class _ResultDialogState extends State<ResultDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.surface,
                AppColors.background,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Title
              Text(
                widget.result.isPerfect ? '🎉 Perfect!' : '🎊 Level Complete!',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Level ${widget.result.level}',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: 24),

              // Stars
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedStar(
                    isFilled: index < widget.result.stars,
                    index: index,
                    size: 48,
                    delay: Duration(milliseconds: 300 + (index * 200)),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Stats
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _StatRow(
                      icon: '⏱️',
                      label: 'Time',
                      value: widget.result.formattedTime,
                    ),
                    const Divider(color: AppColors.surface, height: 16),
                    _StatRow(
                      icon: '🎯',
                      label: 'Moves',
                      value: '${widget.result.moves}',
                      subValue: 'Optimal: ${widget.result.optimalMoves}',
                    ),
                    const Divider(color: AppColors.surface, height: 16),
                    _StatRow(
                      icon: '🔥',
                      label: 'Best Streak',
                      value: '${widget.result.longestStreak}',
                    ),
                    if (widget.result.isPerfect) ...[
                      const Divider(color: AppColors.surface, height: 16),
                      const _StatRow(
                        icon: '💎',
                        label: 'Perfect Game',
                        value: 'No mistakes!',
                        valueColor: AppColors.matchGlow,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Rewards
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.coinColor.withOpacity(0.2),
                      AppColors.gemColor.withOpacity(0.2),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    AnimatedCurrencyCounter(
                      value: widget.result.totalCoins,
                      icon: '💰',
                      color: AppColors.coinColor,
                      fontSize: 20,
                    ),
                    AnimatedCurrencyCounter(
                      value: widget.result.xpEarned,
                      icon: '✨',
                      color: AppColors.accent,
                      fontSize: 20,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: GameButton(
                      text: 'Home',
                      emoji: '🏠',
                      isSmall: true,
                      gradient: const [Colors.grey, Colors.blueGrey],
                      onPressed: widget.onHome,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GameButton(
                      text: 'Replay',
                      emoji: '🔄',
                      isSmall: true,
                      gradient: const [Colors.orange, Colors.deepOrange],
                      onPressed: widget.onReplay,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GameButton(
                text: 'Next Level',
                emoji: '▶️',
                width: double.infinity,
                onPressed: widget.onNextLevel,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final String? subValue;
  final Color? valueColor;

  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    this.subValue,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: TextStyle(
                color: valueColor ?? AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subValue != null)
              Text(
                subValue!,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ],
    );
  }
}
