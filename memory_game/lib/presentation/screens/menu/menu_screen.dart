import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/services/audio_service.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/currency_display.dart';
import '../../widgets/common/game_button.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late AudioService _audioService;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService.instance;
    
    // Sync settings and start background music when entering menu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playerState = context.read<PlayerCubit>().state;
      _audioService.updateSettings(playerState.settings);
      _audioService.startMusic();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: BlocBuilder<PlayerCubit, PlayerState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Top Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: CurrencyDisplay(
                            coins: state.player.coins,
                            gems: state.player.gems,
                          ),
                        ),
                        IconGameButton(
                          icon: Icons.settings,
                          onPressed: () {
                            _audioService.playButton();
                            Navigator.pushNamed(context, '/settings');
                          },
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),

                    const Spacer(),

                    // Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: AppColors.primaryGradient),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(77),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🧠', style: TextStyle(fontSize: 48)),
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 16),

                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Memory Match', style: AppTextStyles.headline1),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.2),

                    const SizedBox(height: 8),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatChip(icon: '⭐', value: state.totalStars.toString()),
                        const SizedBox(width: 12),
                        _StatChip(icon: '🎮', value: 'Lv ${state.highestUnlockedLevel}'),
                      ],
                    ).animate().fadeIn(delay: 300.ms),

                    const Spacer(),

                    // Menu Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: GameButton(
                        text: 'PLAY',
                        emoji: '🎮',
                        onPressed: () {
                          _audioService.playButton();
                          Navigator.pushNamed(context, '/levels');
                        },
                        gradient: AppColors.successGradient,
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 44,
                      child: Row(
                        children: [
                          Expanded(
                            child: GameButton(
                              text: 'Shop',
                              emoji: '🛒',
                              onPressed: () {
                                _audioService.playButton();
                                Navigator.pushNamed(context, '/shop');
                              },
                              isOutlined: true,
                              isSmall: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GameButton(
                              text: 'Rewards',
                              emoji: '🎁',
                              onPressed: () {
                                _audioService.playButton();
                                Navigator.pushNamed(context, '/daily');
                              },
                              isOutlined: true,
                              isSmall: true,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: GameButton(
                        text: 'Achievements',
                        emoji: '🏆',
                        onPressed: () {
                          _audioService.playButton();
                          Navigator.pushNamed(context, '/achievements');
                        },
                        isOutlined: true,
                        isSmall: true,
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),

                    const SizedBox(height: 24),
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(value, style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
