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
  late AudioService _audioService;
  int _currentLevel = 1;

  @override
  void initState() {
    super.initState();
    _currentLevel = widget.level;
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    
    _audioService = AudioService.instance;

    final playerState = context.read<PlayerCubit>().state;
    _audioService.updateSettings(playerState.settings);

    _gameCubit = GameCubit(
      levelGenerator: LevelGeneratorService(),
      audioService: _audioService,
      hapticService: HapticService(),
    );

    final showPreview = playerState.settings.showPreview;
    
    // Start the level immediately - tutorial is shown separately on welcome screen
    _gameCubit.startLevel(_currentLevel, themeId: playerState.player.equippedTheme, showPreview: showPreview);
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
    final config = PowerUpConfigs.getConfig(type);

    if (count <= 0) {
      _gameCubit.pauseGame();
      _showPurchasePowerUpDialog(config);
      return;
    }

    playerCubit.usePowerUp(powerUpId);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(config.icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 8),
            Text('${config.name} activated!'),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 1),
      ),
    );

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

  void _showPurchasePowerUpDialog(PowerUpConfig config) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(config.icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Text('No ${config.name}!', style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(config.description, style: const TextStyle(color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Row(
                        children: [
                          const Text('💰', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text('${config.coinCost}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.coinColor)),
                        ],
                      ),
                      const Text('Coins', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                  const Text('or', style: TextStyle(color: AppColors.textSecondary)),
                  Column(
                    children: [
                      Row(
                        children: [
                          const Text('💎', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 4),
                          Text('${config.gemCost}',
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.gemColor)),
                        ],
                      ),
                      const Text('Gems', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _gameCubit.resumeGame();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushNamed(context, '/shop').then((_) {
                _gameCubit.resumeGame();
              });
            },
            icon: const Icon(Icons.shopping_bag, size: 18),
            label: const Text('Go to Shop'),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
          ),
        ],
      ),
    );
  }

  void _startNextLevel() {
    // Stop confetti
    _confettiController.stop();
    
    // Increment level
    setState(() {
      _currentLevel++;
    });
    
    // Play button sound
    _audioService.playButton();
    
    // Start the new level
    final playerState = context.read<PlayerCubit>().state;
    _gameCubit.startLevel(_currentLevel, 
      themeId: playerState.player.equippedTheme, 
      showPreview: playerState.settings.showPreview);
  }

  void _restartLevel() {
    // Stop confetti
    _confettiController.stop();
    
    // Play button sound
    _audioService.playButton();
    
    // Restart
    _gameCubit.restartLevel();
  }

  void _showResultDialog() {
    final result = _gameCubit.getResult();
    context.read<PlayerCubit>().updateLevelProgress(result);
    
    // Play success sound and show confetti
    _audioService.playSuccess();
    _confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ResultDialog(
        result: result,
        onNextLevel: () {
          Navigator.pop(context);
          _startNextLevel();
        },
        onReplay: () {
          Navigator.pop(context);
          _restartLevel();
        },
        onHome: () {
          Navigator.pop(context);
          _confettiController.stop();
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showTimeoutDialog() {
    _audioService.playMismatch();
    
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
              _restartLevel();
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
                          // Game Header
                          _GameHeader(
                            level: _currentLevel,
                            onPause: () => _gameCubit.pauseGame(),
                            onHome: () => Navigator.pop(context),
                          ),

                          // Game Stats
                          const _GameStats(),

                          // Game Board
                          Expanded(
                            child: BlocBuilder<GameCubit, GameState>(
                              builder: (context, state) {
                                if (state.phase == GamePhase.loading) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                return Stack(
                                  fit: StackFit.expand,
                                  children: [
                                    Center(
                                      child: GameBoard(
                                        cards: state.cards,
                                        columns: state.levelConfig?.columns ?? 4,
                                        rows: state.levelConfig?.rows ?? 4,
                                        onCardTap: (index) => _gameCubit.flipCard(index),
                                        interactive: state.phase == GamePhase.playing,
                                      ),
                                    ),

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

                          // Power-up Bar
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

                  // Confetti
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
  final int level;
  final VoidCallback onPause;
  final VoidCallback onHome;

  const _GameHeader({required this.level, required this.onPause, required this.onHome});

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
                  Text('Level $level', style: AppTextStyles.headline3),
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
                          Text('FROZEN',
                            style: AppTextStyles.caption.copyWith(color: AppColors.secondary)),
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
                value: Text('${state.matches}/${state.totalPairs}',
                  style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold)),
                label: 'Matched',
              ),
              _StatItem(
                icon: Icons.local_fire_department,
                value: Text('${state.currentStreak}',
                  style: AppTextStyles.body2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: state.currentStreak >= 3 ? AppColors.accent : null,
                  )),
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
                shadows: [Shadow(color: AppColors.accent.withAlpha(128), blurRadius: 20)],
              ),
            ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.seconds),
            const SizedBox(height: 16),
            Text('$seconds',
              style: AppTextStyles.headline1.copyWith(fontSize: 72, color: Colors.white),
            ).animate().scale(duration: 200.ms),
            const SizedBox(height: 24),
            TextButton(
              onPressed: onSkip,
              child: Text('Skip', style: AppTextStyles.body2.copyWith(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}
