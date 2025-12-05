import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/power_up_model.dart';
import '../../../state/game/game_cubit.dart';
import '../../../state/game/game_state.dart';
import '../../../state/player/player_cubit.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/game_button.dart';
import '../../widgets/cards/game_board.dart';
import '../../widgets/cards/power_up_bar.dart';
import '../result/result_screen.dart';

/// Main game screen
class GameScreen extends StatefulWidget {
  final int level;

  const GameScreen({super.key, required this.level});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));

    // Start game
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final playerState = context.read<PlayerCubit>().state;
      context.read<GameCubit>().startGame(
            widget.level,
            themeId: playerState.player.equippedTheme,
          );
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameCubit, GameState>(
      listener: (context, state) {
        if (state.status == GameStatus.completed) {
          _confettiController.play();

          // Update player progress
          if (state.result != null) {
            context.read<PlayerCubit>().updateLevelProgress(state.result!);
          }

          // Show result dialog
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              _showResultDialog(context, state);
            }
          });
        } else if (state.status == GameStatus.timeOut) {
          _showTimeOutDialog(context);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: GradientBackground(
            child: SafeArea(
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Header
                      _buildHeader(context, state),

                      // Game info
                      _buildGameInfo(context, state),

                      // Game board
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: state.cards.isNotEmpty
                              ? GameBoard(
                                  cards: state.cards,
                                  columns: state.levelConfig?.columns ?? 4,
                                  onCardTap: (index) {
                                    context.read<GameCubit>().flipCard(index);
                                  },
                                  isInteractive: state.status == GameStatus.playing,
                                )
                              : const Center(
                                  child: CircularProgressIndicator(),
                                ),
                        ),
                      ),

                      // Power-up bar
                      if (state.status == GameStatus.playing)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: PowerUpBar(
                            inventory: context.read<PlayerCubit>().state.player.powerUpInventory,
                            peekActive: state.isPeekActive,
                            freezeActive: state.isTimeFrozen,
                            freezeRemaining: state.freezeTimeRemaining,
                            onUsePowerUp: (type) => _usePowerUp(context, type),
                          ),
                        ),
                    ],
                  ),

                  // Confetti
                  Align(
                    alignment: Alignment.topCenter,
                    child: ConfettiWidget(
                      confettiController: _confettiController,
                      blastDirectionality: BlastDirectionality.explosive,
                      shouldLoop: false,
                      colors: const [
                        Colors.red,
                        Colors.blue,
                        Colors.green,
                        Colors.yellow,
                        Colors.purple,
                        Colors.orange,
                      ],
                    ),
                  ),

                  // Peek overlay
                  if (state.isPeekActive)
                    Container(
                      color: Colors.transparent,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Memorize! ${state.peekTimeRemaining?.inSeconds ?? 0}s',
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                  // Freeze overlay
                  if (state.isTimeFrozen)
                    Positioned(
                      top: 100,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('❄️', style: TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(
                                'Frozen ${state.freezeTimeRemaining?.inSeconds ?? 0}s',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, GameState state) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
            onPressed: () => _showExitDialog(context),
          ),
          // Level
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Level ${widget.level}',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Pause button
          IconButton(
            icon: Icon(
              state.isPaused ? Icons.play_arrow : Icons.pause,
              color: AppColors.textPrimary,
            ),
            onPressed: () {
              if (state.isPaused) {
                context.read<GameCubit>().resumeGame();
              } else {
                context.read<GameCubit>().pauseGame();
                _showPauseDialog(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGameInfo(BuildContext context, GameState state) {
    final config = state.levelConfig;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Timer
          Column(
            children: [
              const Text('⏱️', style: TextStyle(fontSize: 20)),
              Text(
                _formatDuration(state.remainingTime),
                style: TextStyle(
                  color: state.remainingTime.inSeconds <= 10
                      ? Colors.red
                      : AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Moves
          Column(
            children: [
              const Text('🎯', style: TextStyle(fontSize: 20)),
              Text(
                '${state.moves} moves',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Matches
          Column(
            children: [
              const Text('✓', style: TextStyle(fontSize: 20)),
              Text(
                '${state.matches}/${state.totalPairs}',
                style: const TextStyle(
                  color: AppColors.matchGlow,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          // Streak
          if (state.currentStreak > 1)
            Column(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 20)),
                Text(
                  'x${state.currentStreak}',
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _usePowerUp(BuildContext context, PowerUpType type) async {
    final playerCubit = context.read<PlayerCubit>();
    final gameCubit = context.read<GameCubit>();

    final config = PowerUpConfigs.getConfig(type);
    final hasInInventory = playerCubit.state.player.getPowerUpCount(config.id) > 0;

    if (hasInInventory) {
      final used = await playerCubit.usePowerUp(config.id);
      if (used) {
        switch (type) {
          case PowerUpType.peek:
            gameCubit.usePeek();
            break;
          case PowerUpType.freeze:
            gameCubit.useFreeze();
            break;
          case PowerUpType.hint:
            gameCubit.useHint();
            break;
          case PowerUpType.magnet:
            gameCubit.useMagnet();
            break;
          case PowerUpType.undo:
            gameCubit.useUndo();
            break;
          case PowerUpType.doubleCoins:
            gameCubit.activateDoubleCoins();
            break;
          case PowerUpType.shield:
            gameCubit.activateShield();
            break;
        }
      }
    } else {
      // Show buy dialog
      _showBuyPowerUpDialog(context, config);
    }
  }

  void _showBuyPowerUpDialog(BuildContext context, PowerUpConfig config) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Buy ${config.name}?',
          style: const TextStyle(color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              config.icon,
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(height: 12),
            Text(
              config.description,
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final player = context.read<PlayerCubit>();
              if (player.state.player.coins >= config.coinCost) {
                await player.spendCoins(config.coinCost);
                await player.addPowerUp(config.id);
                if (mounted) Navigator.pop(context);
              }
            },
            child: Text('💰 ${config.coinCost}'),
          ),
        ],
      ),
    );
  }

  void _showPauseDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Game Paused',
          style: TextStyle(color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GameButton(
              text: 'Resume',
              emoji: '▶️',
              width: double.infinity,
              onPressed: () {
                Navigator.pop(context);
                context.read<GameCubit>().resumeGame();
              },
            ),
            const SizedBox(height: 12),
            GameButton(
              text: 'Restart',
              emoji: '🔄',
              width: double.infinity,
              gradient: const [Colors.orange, Colors.deepOrange],
              onPressed: () {
                Navigator.pop(context);
                context.read<GameCubit>().startGame(widget.level);
              },
            ),
            const SizedBox(height: 12),
            GameButton(
              text: 'Quit',
              emoji: '🚪',
              width: double.infinity,
              gradient: const [Colors.red, Colors.redAccent],
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog(BuildContext context) {
    context.read<GameCubit>().pauseGame();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Exit Game?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Your progress will be lost.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<GameCubit>().resumeGame();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  void _showResultDialog(BuildContext context, GameState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => ResultDialog(
        result: state.result!,
        onNextLevel: () {
          Navigator.pop(dialogContext);
          context.read<GameCubit>().startGame(widget.level + 1);
        },
        onReplay: () {
          Navigator.pop(dialogContext);
          context.read<GameCubit>().startGame(widget.level);
        },
        onHome: () {
          Navigator.pop(dialogContext);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showTimeOutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '⏰ Time\'s Up!',
          style: TextStyle(color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You ran out of time!',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            GameButton(
              text: 'Try Again',
              emoji: '🔄',
              width: double.infinity,
              onPressed: () {
                Navigator.pop(context);
                this.context.read<GameCubit>().startGame(widget.level);
              },
            ),
            const SizedBox(height: 12),
            GameButton(
              text: 'Back to Levels',
              emoji: '🏠',
              width: double.infinity,
              gradient: const [Colors.grey, Colors.blueGrey],
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
