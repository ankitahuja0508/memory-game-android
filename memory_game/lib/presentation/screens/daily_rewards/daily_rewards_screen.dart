import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../domain/services/daily_reward_service.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/game_button.dart';

/// Daily rewards screen
class DailyRewardsScreen extends StatelessWidget {
  const DailyRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: BlocBuilder<PlayerCubit, PlayerState>(
            builder: (context, state) {
              final dailyService = DailyRewardService();
              dailyService.init(state.dailyRewardStatus);
              final weekRewards = dailyService.getWeekRewards();

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
                            AppStrings.dailyRewardsTitle,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  // Streak info
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '🔥',
                          style: TextStyle(fontSize: 40),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          children: [
                            Text(
                              '${dailyService.currentStreak} Day Streak!',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Text(
                              'Keep it going!',
                              style: TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Weekly rewards grid
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 1.1,
                        ),
                        itemCount: weekRewards.length,
                        itemBuilder: (context, index) {
                          final dayReward = weekRewards[index];
                          return _DailyRewardCard(
                            dayReward: dayReward,
                            onClaim: () => _claimReward(context),
                          );
                        },
                      ),
                    ),
                  ),

                  // Claim button
                  if (dailyService.canClaim)
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: GameButton(
                        text: 'Claim Today\'s Reward!',
                        emoji: '🎁',
                        width: double.infinity,
                        onPressed: () => _claimReward(context),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.timer,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppStrings.comeBackTomorrow,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
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

  void _claimReward(BuildContext context) async {
    final reward = await context.read<PlayerCubit>().claimDailyReward();
    if (reward != null && context.mounted) {
      _showRewardDialog(context, reward);
    }
  }

  void _showRewardDialog(BuildContext context, dynamic reward) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '🎁 Reward Claimed!',
          style: TextStyle(color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🎉',
              style: TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 16),
            Text(
              'You received:',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            ...reward.rewards.map<Widget>((r) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    r.displayText,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                )),
          ],
        ),
        actions: [
          GameButton(
            text: 'Awesome!',
            width: double.infinity,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _DailyRewardCard extends StatelessWidget {
  final DailyRewardDay dayReward;
  final VoidCallback onClaim;

  const _DailyRewardCard({
    required this.dayReward,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    final isClaimed = dayReward.status == DailyRewardDayStatus.claimed;
    final isAvailable = dayReward.status == DailyRewardDayStatus.available;
    final isLocked = dayReward.status == DailyRewardDayStatus.locked;

    return GestureDetector(
      onTap: isAvailable ? onClaim : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isClaimed
              ? AppColors.success.withOpacity(0.2)
              : isAvailable
                  ? AppColors.accent.withOpacity(0.2)
                  : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isClaimed
                ? AppColors.success
                : isAvailable
                    ? AppColors.accent
                    : AppColors.primary.withOpacity(0.2),
            width: isAvailable ? 3 : 1,
          ),
          boxShadow: isAvailable
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 10,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Day number
            Text(
              '${AppStrings.day} ${dayReward.day}',
              style: TextStyle(
                color: isLocked ? AppColors.textSecondary : AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Reward icon
            Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  dayReward.reward.isSpecial ? '🎁' : '💰',
                  style: TextStyle(
                    fontSize: 36,
                    color: isLocked ? Colors.grey : null,
                  ),
                ),
                if (isClaimed)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                if (isLocked)
                  const Icon(
                    Icons.lock,
                    color: Colors.grey,
                    size: 24,
                  ),
              ],
            ),

            const SizedBox(height: 8),

            // Reward value
            Column(
              children: dayReward.reward.rewards.map((r) {
                return Text(
                  r.displayText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isLocked ? AppColors.textSecondary : AppColors.accent,
                  ),
                );
              }).toList(),
            ),

            if (dayReward.reward.isSpecial)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'BONUS',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
