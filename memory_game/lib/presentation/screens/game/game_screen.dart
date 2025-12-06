import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/power_up_model.dart';
import '../../../domain/services/services.dart';
import '../../../state/game/game_cubit.dart';
import '../../../state/game/game_state.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/animated_counter.dart';
import '../../widgets/cards/game_board.dart';
import '../../widgets/cards/power_up_bar.dart';
import '../result/result_screen.dart';

class GameScreen extends StatefulWidget {
  final int level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameCubit _gameCubit;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    _gameCubit = GameCubit(
      levelGenerator: LevelGeneratorService(),
      audioService: AudioService(),
      hapticService: HapticService(),
    );

    final playerState = context.read<PlayerCubit>().state;
    final showPreview = playerState.settings.showPreview;
    _gameCubit.startLevel(widget.level, themeId: playerState.player.equippedTheme, showPreview: showPreview);
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _gameCubit.close();
    super.dispose();
  }

  void _handlePowerUp(PowerUpType type) {
    final playerCubit = context.read<PlayerCubit>();
    final powerUpId = type.name;
    final count = playerCubit.state.player.getPowerUpCount(powerUpId);

    if (count <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No ${PowerUpConfigs.getConfig(type).name} power-ups! Buy more in the shop.'),
          action: SnackBarAction(
            label: 'Shop',
            onPressed: () => Navigator.pushNamed(context, '/shop'),
          ),
        ),
      );
      return;
    }

    // Use the power-up
    playerCubit.usePowerUp(powerUpId);

    // Activate the effect
    switch (type) {
      case PowerUpType.peek:
        _gameCubit.activatePeek();
        break;
      case PowerUpType.freeze:
        _gameCubit.activateFreeze();
        break;
      case PowerUpType.hint:
        _gameCubit.activateHint();
        break;
      case PowerUpType.magnet:
        _gameCubit.activateMagnet();
        break;
      default:
        break;
    }
  }

  void _showResultDialog() {
    final result = _gameCubit.getResult();
    context.read<PlayerCubit>().updateLevelProgress(result);
    _confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ResultDialog(
        result: result,
        onNextLevel: () {
          Navigator.pop(context);
          _gameCubit.startLevel(widget.level + 1);
        },
        onReplay: () {
          Navigator.pop(context);
          _gameCubit.restartLevel();
        },
        onHome: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showTimeoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('⏰ Time\'s Up!', textAlign: TextAlign.center),
        content: const Text('You ran out of time. Try again?', textAlign: TextAlign.center),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Home'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _gameCubit.restartLevel();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _gameCubit,
      child: BlocListener<GameCubit, GameState>(
        listener: (context, state) {
          if (state.isCompleted) {
            _showResultDialog();
          } else if (state.isTimedOut) {
            _showTimeoutDialog();
          }
        },
        child: GradientBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Stack(
                children: [
                  // Main layout
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Column(
                        children: [
                          // Game Header - fixed height
                          _GameHeader(
                            onPause: () => _gameCubit.pauseGame(),
                            onHome: () => Navigator.pop(context),
                          ),

                          // Game Stats - fixed height
                          const _GameStats(),

                          // Game Board - takes remaining space
                          Expanded(
                            child: BlocBuilder<GameCubit, GameState>(
                              builder: (context, state) {
                                if (state.phase == GamePhase.loading) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    // Game Board
                                    Center(
                                      child: GameBoard(
                                        cards: state.cards,
                                        columns: state.levelConfig?.columns ?? 4,
                                        rows: state.levelConfig?.rows ?? 4,
                                        onCardTap: (index) => _gameCubit.flipCard(index),
                                        interactive: state.phase == GamePhase.playing,
                                      ),
                                    ),

                                    // Preview Overlay
                                    if (state.phase == GamePhase.preview)
                                      _PreviewOverlay(
                                        remainingTime: state.previewTimeRemaining,
                                        onSkip: () => _gameCubit.skipPreview(),
                                      ),
                                  ],
                                );
                              },
                            ),
                          ),

                          // Power-up Bar - fixed at bottom
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                            child: BlocBuilder<PlayerCubit, PlayerState>(
                              builder: (context, playerState) {
                                return BlocBuilder<GameCubit, GameState>(
                                  builder: (context, gameState) {
                                    return PowerUpBar(
                                      powerUpCounts: playerState.player.powerUpInventory,
                                      isPeekActive: gameState.isPeekActive,
                                      isFreezeActive: gameState.isFreezeActive,
                                      freezeRemaining: gameState.freezeTimeRemaining,
                                      onPowerUpTap: _handlePowerUp,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Confetti overlay
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      particleDrag: 0.05,
                      emissionFrequency: 0.05,
                      numberOfParticles: 30,
                      gravity: 0.1,
                      colors: const [
                        AppColors.primary,
                        AppColors.secondary,
                        AppColors.accent,
                        AppColors.success,
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GameHeader extends StatelessWidget {
  final VoidCallback onPause;
  final VoidCallback onHome;

  const _GameHeader({required this.onPause, required this.onHome});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.home, color: Colors.white),
                onPressed: onHome,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Level ${state.level}', style: AppTextStyles.headline3),
                  if (state.isFreezeActive)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('❄️', style: TextStyle(fontSize: 12)),
                          const SizedBox(width: 4),
                          Text(
                            'FROZEN',
                            style: AppTextStyles.caption.copyWith(color: AppColors.secondary),
                          ),
                        ],
                      ),
                    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.seconds),
                ],
              ),
              IconButton(
                icon: Icon(
                  state.isPaused ? Icons.play_arrow : Icons.pause,
                  color: Colors.white,
                ),
                onPressed: state.isPaused
                    ? () => context.read<GameCubit>().resumeGame()
                    : onPause,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GameStats extends StatelessWidget {
  const _GameStats();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GameCubit, GameState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface.withAlpha(179),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: Icons.timer,
                value: GameTimer(duration: state.remainingTime, maxDuration: state.timeLimit),
                label: 'Time',
              ),
              _StatItem(
                icon: Icons.touch_app,
                value: Text('${state.moves}', style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold)),
                label: 'Moves',
              ),
              _StatItem(
                icon: Icons.check_circle,
                value: Text(
                  '${state.matches}/${state.totalPairs}',
                  style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold),
                ),
                label: 'Matched',
              ),
              _StatItem(
                icon: Icons.local_fire_department,
                value: Text(
                  '${state.currentStreak}',
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: state.currentStreak >= 3 ? AppColors.accent : null,
                  ),
                ),
                label: 'Streak',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Widget value;
  final String label;

  const _StatItem({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 2),
            value,
          ],
        ),
        Text(label, style: AppTextStyles.caption.copyWith(fontSize: 10)),
      ],
    );
  }
}

class _PreviewOverlay extends StatelessWidget {
  final Duration remainingTime;
  final VoidCallback onSkip;

  const _PreviewOverlay({required this.remainingTime, required this.onSkip});

  @override
  Widget build(BuildContext context) {
    final seconds = (remainingTime.inMilliseconds / 1000).ceil();

    return Container(
      color: Colors.black.withAlpha(128),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppStrings.memorize,
              style: AppTextStyles.headline1.copyWith(
                color: AppColors.accent,
                shadows: [
                  Shadow(
                    color: AppColors.accent.withAlpha(128),
                    blurRadius: 20,
                  ),
                ],
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 1.seconds),
            const SizedBox(height: 16),
            Text(
              '$seconds',
              style: AppTextStyles.headline1.copyWith(
                fontSize: 72,
                color: Colors.white,
              ),
            )
                .animate()
                .scale(duration: 200.ms),
            const SizedBox(height: 24),
            TextButton(
              onPressed: onSkip,
              child: Text(
                'Skip',
                style: AppTextStyles.body2.copyWith(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
