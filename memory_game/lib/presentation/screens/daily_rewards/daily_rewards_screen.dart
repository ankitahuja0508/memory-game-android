import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/daily_reward_model.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/game_button.dart';

class DailyRewardsScreen extends StatelessWidget {
  const DailyRewardsScreen({super.key});

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
          title: Text('Daily Rewards', style: AppTextStyles.headline3),
          centerTitle: true,
        ),
        body: BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, state) {
            final status = state.dailyRewardStatus;
            const weekRewards = DailyRewards.weekCycle;

            return Column(
              children: [
                // Streak Header
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.primaryGradient),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text('${status.currentStreak} Day Streak!', style: AppTextStyles.headline2),
                      const SizedBox(height: 4),
                      Text(
                        status.canClaimToday ? 'Your reward is ready!' : 'Come back tomorrow!',
                        style: AppTextStyles.body2.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.2),

                // Week Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: weekRewards.length,
                    itemBuilder: (context, index) {
                      final reward = weekRewards[index];
                      final dayNumber = reward.day;
                      final isPast = dayNumber < status.currentDay;
                      final isToday = dayNumber == status.currentDay;
                      final isFuture = dayNumber > status.currentDay;

                      return _DayCard(
                        day: dayNumber,
                        reward: reward,
                        isPast: isPast,
                        isToday: isToday,
                        isFuture: isFuture,
                        canClaim: isToday && status.canClaimToday,
                      ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().scale(begin: const Offset(0.8, 0.8));
                    },
                  ),
                ),

                // Claim Button
                if (status.canClaimToday)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: SizedBox(
                      width: double.infinity,
                      child: GameButton(
                        text: 'CLAIM REWARD',
                        emoji: '🎁',
                        gradient: AppColors.successGradient,
                        onPressed: () => _claimReward(context),
                      ),
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3)
                else
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Come back tomorrow for more rewards!',
                      style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _claimReward(BuildContext context) async {
    final reward = await context.read<PlayerCubit>().claimDailyReward();
    if (reward != null && context.mounted) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('🎉 Reward Claimed!', textAlign: TextAlign.center),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ...reward.rewards.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  r.displayText,
                  style: AppTextStyles.headline3.copyWith(color: AppColors.accent),
                ),
              )),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Awesome!'),
            ),
          ],
        ),
      );
    }
  }
}

class _DayCard extends StatelessWidget {
  final int day;
  final DailyReward reward;
  final bool isPast;
  final bool isToday;
  final bool isFuture;
  final bool canClaim;

  const _DayCard({
    required this.day,
    required this.reward,
    required this.isPast,
    required this.isToday,
    required this.isFuture,
    required this.canClaim,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppColors.surface;
    Color borderColor = Colors.transparent;

    if (isPast) {
      bgColor = AppColors.success.withAlpha(51);
      borderColor = AppColors.success;
    } else if (isToday) {
      borderColor = canClaim ? AppColors.accent : AppColors.primary;
    }

    Widget content = Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Day $day', style: AppTextStyles.caption),
          const SizedBox(height: 4),
          Text(
            reward.isSpecial ? '🎁' : '💰',
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 4),
          Text(
            reward.rewards.first.displayText,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.accent,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isPast)
            const Icon(Icons.check_circle, color: AppColors.success, size: 20),
        ],
      ),
    );

    if (canClaim) {
      content = content.animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.seconds);
    }

    return content;
  }
}
