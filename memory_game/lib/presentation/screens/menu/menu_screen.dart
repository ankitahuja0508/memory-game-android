import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/currency_display.dart';
import '../../widgets/common/game_button.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: BlocBuilder<PlayerCubit, PlayerState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Top Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CurrencyDisplay(
                          coins: state.player.coins,
                          gems: state.player.gems,
                        ),
                        IconGameButton(
                          icon: Icons.settings,
                          onPressed: () => Navigator.pushNamed(context, '/settings'),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),

                    const Spacer(),

                    // Logo
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: AppColors.primaryGradient),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(77),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🧠', style: TextStyle(fontSize: 56)),
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 24),

                    Text('Memory Match', style: AppTextStyles.headline1)
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.2),

                    const SizedBox(height: 8),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatChip(icon: '⭐', value: state.totalStars.toString()),
                        const SizedBox(width: 16),
                        _StatChip(icon: '🎮', value: 'Lv ${state.highestUnlockedLevel}'),
                      ],
                    ).animate().fadeIn(delay: 300.ms),

                    const Spacer(),

                    // Menu Buttons
                    SizedBox(
                      width: double.infinity,
                      child: GameButton(
                        text: 'PLAY',
                        emoji: '🎮',
                        onPressed: () => Navigator.pushNamed(context, '/levels'),
                        gradient: AppColors.successGradient,
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: GameButton(
                            text: 'Shop',
                            emoji: '🛒',
                            onPressed: () => Navigator.pushNamed(context, '/shop'),
                            isOutlined: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GameButton(
                            text: 'Rewards',
                            emoji: '🎁',
                            onPressed: () => Navigator.pushNamed(context, '/daily'),
                            isOutlined: true,
                          ),
                        ),
                      ],
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),

                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      child: GameButton(
                        text: 'Achievements',
                        emoji: '🏆',
                        onPressed: () => Navigator.pushNamed(context, '/achievements'),
                        isOutlined: true,
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),

                    const SizedBox(height: 32),
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

class _StatChip extends StatelessWidget {
  final String icon;
  final String value;

  const _StatChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(value, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
