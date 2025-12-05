import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/currency_display.dart';
import '../../widgets/common/game_button.dart';

/// Main menu screen
class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: BlocBuilder<PlayerCubit, PlayerState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Top bar with currency
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CurrencyDisplay(
                          coins: state.player.coins,
                          gems: state.player.gems,
                          onCoinsTap: () => Navigator.pushNamed(context, '/shop'),
                          onGemsTap: () => Navigator.pushNamed(context, '/shop'),
                        ),
                        GameIconButton(
                          icon: Icons.settings,
                          onPressed: () => Navigator.pushNamed(context, '/settings'),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),

                    const Spacer(),

                    // Logo and title
                    Column(
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: AppColors.primaryGradient,
                            ),
                            borderRadius: BorderRadius.circular(35),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.4),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '🧠',
                              style: TextStyle(fontSize: 70),
                            ),
                          ),
                        )
                            .animate()
                            .scale(
                              begin: const Offset(0.8, 0.8),
                              duration: 600.ms,
                              curve: Curves.elasticOut,
                            )
                            .fadeIn(),
                        const SizedBox(height: 24),
                        const Text(
                          AppStrings.appName,
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                            letterSpacing: 2,
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Player level
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '⭐',
                            style: TextStyle(fontSize: 20),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Level ${state.player.playerLevel}',
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${state.totalStars} Stars',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 300.ms),

                    const Spacer(),

                    // Menu buttons
                    Column(
                      children: [
                        GameButton(
                          text: AppStrings.play,
                          emoji: '🎮',
                          width: double.infinity,
                          onPressed: () => Navigator.pushNamed(context, '/levels'),
                        ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: GameButton(
                                text: AppStrings.shop,
                                emoji: '🛒',
                                height: 50,
                                gradient: const [
                                  Color(0xFF00D9FF),
                                  Color(0xFF00A8C6),
                                ],
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/shop'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GameButton(
                                text: AppStrings.achievements,
                                emoji: '🏆',
                                height: 50,
                                gradient: const [
                                  Color(0xFFFFD93D),
                                  Color(0xFFE6C235),
                                ],
                                onPressed: () =>
                                    Navigator.pushNamed(context, '/achievements'),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                        const SizedBox(height: 16),
                        // Daily rewards button with notification
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            GameButton(
                              text: AppStrings.dailyRewards,
                              emoji: '🎁',
                              width: double.infinity,
                              height: 50,
                              gradient: AppColors.successGradient,
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/daily-rewards'),
                            ),
                            if (state.dailyRewardStatus.canClaimToday)
                              Positioned(
                                top: -8,
                                right: -8,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Text(
                                    '!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
