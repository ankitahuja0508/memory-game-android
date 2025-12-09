import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:confetti/confetti.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/achievement_model.dart';
import '../../../data/models/level_model.dart';
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

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late GameCubit _gameCubit;
  late ConfettiController _confettiController;
  late AudioService _audioService;
  int _currentLevel = 1;
  bool _wasPlayingBeforeBackground = false;
  bool _showConfetti = false; // Controls confetti visibility - false clears all particles

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    
    // Check if we should show memorization tutorial dialog
    if (showPreview) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showMemorizationDialog();
      });
    } else {
      // Start the level immediately if preview is disabled
      _gameCubit.startLevel(_currentLevel, themeId: playerState.player.equippedTheme, showPreview: false);
    }
    
    // Show power-up tutorial on first level if user has power-ups
    if (_currentLevel == 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) _showPowerUpTutorial();
        });
      });
    }
  }
  
  void _showMemorizationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool dontShowAgain = false;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                children: [
                  const Text('👀', style: TextStyle(fontSize: 40)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Memorization Time!',
                      style: AppTextStyles.headline3.copyWith(fontSize: 20),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Before the game starts, you\'ll have a few seconds to memorize the card positions.',
                    style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Study the cards carefully - it will help you match them faster!',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Don't show again checkbox
                  InkWell(
                    onTap: () {
                      setState(() {
                        dontShowAgain = !dontShowAgain;
                      });
                    },
                    child: Row(
                      children: [
                        Checkbox(
                          value: dontShowAgain,
                          onChanged: (value) {
                            setState(() {
                              dontShowAgain = value ?? false;
                            });
                          },
                          activeColor: AppColors.accent,
                        ),
                        Expanded(
                          child: Text(
                            'Don\'t show this again',
                            style: AppTextStyles.body2.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    // Save preference if checkbox is checked
                    if (dontShowAgain) {
                      final playerCubit = context.read<PlayerCubit>();
                      playerCubit.updateSettings(
                        playerCubit.state.settings.copyWith(showPreview: false),
                      );
                    }
                    // Start the level with preview/countdown
                    _gameCubit.startLevel(
                      _currentLevel,
                      themeId: context.read<PlayerCubit>().state.player.equippedTheme,
                      showPreview: true,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  ),
                  child: const Text('Got it! Let\'s Go!'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _confettiController.dispose();
    _gameCubit.close();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // App going to background or screen locked
      final gameState = _gameCubit.state;
      _wasPlayingBeforeBackground = gameState.phase == GamePhase.playing || 
                                     gameState.phase == GamePhase.preview;
      
      if (_wasPlayingBeforeBackground && !gameState.isPaused) {
        _gameCubit.pauseGame();
      }
    } else if (state == AppLifecycleState.resumed) {
      // App coming back to foreground
      // Game stays paused - user needs to manually resume via pause dialog
      // This is intentional so user can see the game state before continuing
      if (_wasPlayingBeforeBackground) {
        // Show pause dialog when returning
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _gameCubit.state.isPaused) {
            _showPauseDialog();
          }
        });
      }
    }
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
    // Stop and hide confetti completely (removes all particles)
    _confettiController.stop();
    setState(() => _showConfetti = false);
    
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
    // Stop and hide confetti completely
    _confettiController.stop();
    setState(() => _showConfetti = false);
    
    // Play button sound
    _audioService.playButton();
    
    // Restart
    _gameCubit.restartLevel();
  }

  void _showPowerUpTutorial() {
    final playerCubit = context.read<PlayerCubit>();
    final hasPowerUps = playerCubit.state.player.powerUpInventory.values.any((count) => count > 0);
    
    // Only show if user has at least one power-up
    if (!hasPowerUps) return;
    
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      showDialog(
        context: context,
        barrierDismissible: true,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Text('⚡', style: TextStyle(fontSize: 32)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Power-ups Ready!',
                  style: AppTextStyles.headline3.copyWith(fontSize: 20),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tap any power-up icon at the bottom to use it instantly!',
                style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Just one tap to activate - no extra steps!',
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Got it!'),
            ),
          ],
        ),
      );
    });
  }

  /* Unused method - commented out
  void _showPowerUpsDialog() {
    _gameCubit.pauseGame();
    _audioService.playButton();
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, playerState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.surface,
                    AppColors.surfaceLight,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withAlpha(100), width: 2),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('⚡ Power-ups', style: AppTextStyles.headline3),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            Navigator.pop(dialogContext);
                            _gameCubit.resumeGame();
                          },
                        ),
                      ],
                    ),
                  const SizedBox(height: 8),
                  
                  // Currency Display
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Row(
                          children: [
                            const Text('🪙', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 6),
                            Text(
                              '${playerState.player.coins}',
                              style: AppTextStyles.headline3.copyWith(
                                color: AppColors.coinColor,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text('💎', style: TextStyle(fontSize: 20)),
                            const SizedBox(width: 6),
                            Text(
                              '${playerState.player.gems}',
                              style: AppTextStyles.headline3.copyWith(
                                color: AppColors.gemColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Info text
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Use power-ups during the game to get helpful boosts!',
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Power-ups List
                  LimitedBox(
                    maxHeight: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: PowerUpConfigs.all.length,
                      itemBuilder: (context, index) {
                        final powerUp = PowerUpConfigs.all[index];
                        final inventory = playerState.player.powerUpInventory[powerUp.id] ?? 0;
                        
                        return _PowerUpItem(
                          powerUp: powerUp,
                          inventory: inventory,
                          onUse: inventory > 0
                              ? () {
                                  Navigator.pop(dialogContext);
                                  _usePowerUp(powerUp);
                                }
                              : null,
                          onBuy: () {
                            Navigator.pop(dialogContext);
                            Navigator.pushNamed(context, '/shop');
                          },
                        );
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Shop button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                        Navigator.pushNamed(context, '/shop');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Go to Shop'),
                    ),
                  ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ).then((_) {
      // Resume game when dialog is dismissed
      if (_gameCubit.state.isPaused) {
        _gameCubit.resumeGame();
      }
    });
  } */

  /* Related to commented out _showPowerUpsDialog - commenting out
  void _usePowerUp(PowerUpConfig powerUp) {
    final playerCubit = context.read<PlayerCubit>();
    final inventory = playerCubit.state.player.powerUpInventory[powerUp.id] ?? 0;
    
    if (inventory <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough power-ups!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    
    // Use the power-up
    playerCubit.usePowerUp(powerUp.id);
    _audioService.playPowerUp();
    
    // Apply power-up effect
    String? feedbackMessage;
    Color feedbackColor = AppColors.success;
    
    switch (powerUp.id) {
      case 'peek':
        _gameCubit.activatePeek();
        feedbackMessage = '${powerUp.icon} Peek! All cards revealed for 3 seconds!';
        break;
      case 'freeze':
        _gameCubit.activateFreeze();
        feedbackMessage = '${powerUp.icon} Freeze! Timer paused for 10 seconds!';
        break;
      case 'hint':
        _gameCubit.activateHint();
        feedbackMessage = '${powerUp.icon} Hint! A matching pair is highlighted!';
        break;
      case 'undo':
        // Check if undo is available
        if (!_gameCubit.state.canUndo) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('↩️ Can only undo right after a mismatch!'),
              backgroundColor: AppColors.warning,
              duration: Duration(seconds: 2),
            ),
          );
          // Refund the power-up since it couldn't be used
          playerCubit.addPowerUp(powerUp.id, 1);
          return;
        }
        _gameCubit.activateUndo();
        feedbackMessage = '${powerUp.icon} Undo! Last mismatch reversed!';
        break;
      case 'magnet':
        _gameCubit.activateMagnet();
        feedbackMessage = '${powerUp.icon} Magnet! Auto-matching a pair!';
        break;
      case 'double_coins':
        if (_gameCubit.state.isDoubleCoinsActive) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('💰 Double Coins is already active!'),
              backgroundColor: AppColors.warning,
              duration: Duration(seconds: 2),
            ),
          );
          // Refund the power-up since it couldn't be used
          playerCubit.addPowerUp(powerUp.id, 1);
          return;
        }
        _gameCubit.activateDoubleCoins();
        feedbackMessage = '${powerUp.icon} Double Coins! Earn 2x coins!';
        feedbackColor = Colors.amber;
        break;
      case 'shield':
        _gameCubit.activateShield();
        final shieldCount = _gameCubit.state.shieldCount;
        feedbackMessage = '${powerUp.icon} Shield! Protected for $shieldCount mistakes!';
        feedbackColor = Colors.blue;
        break;
    }
    
    // Show feedback message
    if (feedbackMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(feedbackMessage),
          backgroundColor: feedbackColor,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  } */

  void _showPauseDialog() {
    _gameCubit.pauseGame();
    _audioService.playButton();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface,
                AppColors.surfaceLight,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primary.withAlpha(100), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withAlpha(50),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pause Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.pause_circle_filled,
                  size: 48,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(height: 16),
              
              // Title
              Text(
                'Game Paused',
                style: AppTextStyles.headline2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Level info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Level $_currentLevel',
                  style: AppTextStyles.body1.copyWith(color: AppColors.accent),
                ),
              ),
              const SizedBox(height: 24),
              
              // Resume Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _gameCubit.resumeGame();
                    _audioService.playButton();
                  },
                  icon: const Icon(Icons.play_arrow_rounded, size: 28),
                  label: const Text('Resume', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Restart Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _restartLevel();
                  },
                  icon: const Icon(Icons.refresh_rounded, size: 24),
                  label: const Text('Restart Level', style: TextStyle(fontSize: 16)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.accent,
                    side: BorderSide(color: AppColors.accent.withAlpha(150)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Home Button
              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.home_rounded, size: 24, color: AppColors.textSecondary),
                  label: const Text(
                    'Exit to Home',
                    style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ).animate().scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 200.ms,
          curve: Curves.easeOutBack,
        ),
      ),
    );
  }

  void _showResultDialog() {
    final result = _gameCubit.getResult();
    final playerCubit = context.read<PlayerCubit>();
    playerCubit.updateLevelProgress(result);
    
    // Trigger interstitial ad (shows based on frequency and cooldown)
    AdService.instance.onLevelComplete();
    
    // Play success sound and show confetti
    _audioService.playSuccess();
    setState(() => _showConfetti = true);
    _confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => ResultDialog(
        result: result,
        onNextLevel: () {
          // Stop and hide confetti immediately (removes all particles)
          _confettiController.stop();
          setState(() => _showConfetti = false);
          Navigator.pop(context);
          // Show unlock notifications before starting next level
          _showUnlockNotifications(playerCubit, () => _startNextLevel());
        },
        onReplay: () {
          // Stop and hide confetti immediately
          _confettiController.stop();
          setState(() => _showConfetti = false);
          Navigator.pop(context);
          _showUnlockNotifications(playerCubit, () => _restartLevel());
        },
        onHome: () {
          // Stop and hide confetti immediately
          _confettiController.stop();
          setState(() => _showConfetti = false);
          Navigator.pop(context);
          _showUnlockNotifications(playerCubit, () => Navigator.pop(context));
        },
      ),
    ).then((_) {
      // Ensure confetti is stopped and hidden even if dialog is dismissed unexpectedly
      if (_confettiController.state == ConfettiControllerState.playing) {
        _confettiController.stop();
      }
      if (_showConfetti && mounted) {
        setState(() => _showConfetti = false);
      }
    });
  }
  
  void _showUnlockNotifications(PlayerCubit playerCubit, VoidCallback onComplete) {
    final unlockedAchievements = playerCubit.lastUnlockedAchievements;
    final unlockedThemeAvailability = playerCubit.lastUnlockedThemeAvailability;
    
    // If no unlocks, proceed immediately
    if (unlockedAchievements.isEmpty && unlockedThemeAvailability.isEmpty) {
      onComplete();
      return;
    }
    
    // Show achievement unlock popup first
    if (unlockedAchievements.isNotEmpty) {
      _showAchievementUnlockDialog(unlockedAchievements, () {
        // Then show theme availability if any
        if (unlockedThemeAvailability.isNotEmpty) {
          _showThemeUnlockAvailableDialog(unlockedThemeAvailability, onComplete);
        } else {
          onComplete();
        }
      });
    } else if (unlockedThemeAvailability.isNotEmpty) {
      _showThemeUnlockAvailableDialog(unlockedThemeAvailability, onComplete);
    }
  }
  
  void _showAchievementUnlockDialog(List<String> achievementIds, VoidCallback onDismiss) {
    final achievements = achievementIds
        .map((id) => Achievements.getById(id))
        .where((a) => a != null)
        .cast<Achievement>()
        .toList();
    
    if (achievements.isEmpty) {
      onDismiss();
      return;
    }
    
    _audioService.playAchievement();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 48))
                .animate()
                .scale(duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 8),
            Text(
              achievements.length == 1 ? 'Achievement Unlocked!' : 'Achievements Unlocked!',
              style: AppTextStyles.headline3.copyWith(color: AppColors.accent),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...achievements.asMap().entries.map((entry) {
              final index = entry.key;
              final achievement = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.success.withAlpha(40),
                      AppColors.success.withAlpha(20),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    Text(achievement.icon, style: const TextStyle(fontSize: 32)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            achievement.title,
                            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            achievement.description,
                            style: AppTextStyles.caption,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: achievement.rewards.map((r) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                r.displayText,
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: Duration(milliseconds: 100 * index))
                  .fadeIn()
                  .slideX(begin: 0.2);
            }),
            const SizedBox(height: 8),
            Text(
              'Go to Achievements to claim rewards!',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDismiss();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }
  
  void _showThemeUnlockAvailableDialog(List<String> themeIds, VoidCallback onDismiss) {
    final themes = themeIds
        .map((id) => LevelGeneratorService.getThemeById(id))
        .toList();
    
    _audioService.playSuccess();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Column(
          children: [
            const Text('🎨', style: TextStyle(fontSize: 48))
                .animate()
                .scale(duration: 500.ms, curve: Curves.elasticOut)
                .then()
                .shake(duration: 400.ms),
            const SizedBox(height: 8),
            Text(
              themes.length == 1 ? 'New Theme Available!' : 'New Themes Available!',
              style: AppTextStyles.headline3.copyWith(color: AppColors.primary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You\'ve unlocked access to ${themes.length == 1 ? 'a new theme' : 'new themes'}!',
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ...themes.asMap().entries.map((entry) {
              final index = entry.key;
              final theme = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withAlpha(40),
                      AppColors.secondary.withAlpha(30),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withAlpha(60)),
                ),
                child: Row(
                  children: [
                    Text(theme.icon, style: const TextStyle(fontSize: 36)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            theme.name,
                            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            theme.symbols.take(6).join(' '),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${theme.cost} 💰 to unlock',
                            style: AppTextStyles.caption.copyWith(color: AppColors.coinColor),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: Duration(milliseconds: 150 * index))
                  .fadeIn()
                  .scale(begin: const Offset(0.9, 0.9));
            }),
            const SizedBox(height: 8),
            Text(
              'Visit the home screen to unlock!',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onDismiss();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showTimeoutDialog() {
    _audioService.playMismatch();
    
    final bool adAvailable = AdService.instance.isRewardedAdReady();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('⏰ Time\'s Up!', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'You ran out of time!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            if (adAvailable) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.accent.withAlpha(30),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.accent.withAlpha(100)),
                ),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('📺', style: TextStyle(fontSize: 24)),
                        SizedBox(width: 8),
                        Text(
                          'Watch ad for +30s',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Continue playing!',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: const Text('Home'),
              ),
              if (adAvailable)
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context); // Close dialog first
                    
                    final rewarded = await AdService.instance.showRewardedAd(placement: 'extra_time');
                    
                    if (rewarded && mounted) {
                      // Add 30 seconds to timer
                      _gameCubit.addExtraTime(30);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Text('⏰', style: TextStyle(fontSize: 22)),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  '+30 seconds added! Keep playing!',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: AppColors.success,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else if (mounted) {
                      // Ad failed, show timeout dialog again
                      _showTimeoutDialog();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  icon: const Icon(Icons.play_circle_outline, size: 18),
                  label: const Text('+30s'),
                ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _restartLevel();
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: const Text('Retry'),
              ),
            ],
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
                          BlocBuilder<GameCubit, GameState>(
                            buildWhen: (prev, curr) => prev.levelConfig != curr.levelConfig,
                            builder: (context, gameState) {
                              return _GameHeader(
                                level: _currentLevel,
                                specialType: gameState.levelConfig?.specialType,
                                specialEmoji: gameState.levelConfig?.specialLevelEmoji,
                                onPause: _showPauseDialog,
                                onHome: () => Navigator.pop(context),
                              );
                            },
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

                                return Column(
                                  children: [
                                    // Preview timer - shows at top of game board area
                                    if (state.phase == GamePhase.preview)
                                      _PreviewOverlay(
                                        remainingTime: state.previewTimeRemaining,
                                        onSkip: () => _gameCubit.skipPreview(),
                                      ),
                                    
                                    // Game Board - takes remaining space
                                    Expanded(
                                      child: Center(
                                        child: GameBoard(
                                          cards: state.cards,
                                          columns: state.levelConfig?.columns ?? 4,
                                          rows: state.levelConfig?.rows ?? 4,
                                          onCardTap: (index) => _gameCubit.flipCard(index),
                                          interactive: state.phase == GamePhase.playing,
                                        ),
                                      ),
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

                  // Confetti - only shown when _showConfetti is true
                  // Removing the widget clears all particles instantly
                  if (_showConfetti)
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
  final SpecialLevelType? specialType;
  final String? specialEmoji;
  final VoidCallback onPause;
  final VoidCallback onHome;

  const _GameHeader({
    required this.level,
    this.specialType,
    this.specialEmoji,
    required this.onPause,
    required this.onHome,
  });

  Color _getSpecialColor() {
    if (specialType == null) return AppColors.primary;
    switch (specialType!) {
      case SpecialLevelType.bossLevel:
        return const Color(0xFFFF5722);
      case SpecialLevelType.bonusRound:
        return const Color(0xFF4CAF50);
      case SpecialLevelType.speedChallenge:
        return const Color(0xFFFFEB3B);
      case SpecialLevelType.memoryMaster:
        return const Color(0xFF9C27B0);
      case SpecialLevelType.mysteryLevel:
        return const Color(0xFF607D8B);
      case SpecialLevelType.dailyChallenge:
        return const Color(0xFF2196F3);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSpecial = specialType != null;
    final specialColor = _getSpecialColor();
    
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
                  // Special level indicator
                  if (isSpecial) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [specialColor, specialColor.withAlpha(180)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: specialColor.withAlpha(100),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (specialEmoji != null)
                            Text(specialEmoji!, style: const TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            'Level $level',
                            style: AppTextStyles.body2.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else
                    Text('Level $level', style: AppTextStyles.headline3),
                  if (state.isFreezeActive)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
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
                icon: const Icon(
                  Icons.pause_circle_outline,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: state.isPaused ? null : onPause,
                tooltip: 'Pause',
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
        // Get player's undo inventory count
        final playerState = context.watch<PlayerCubit>().state;
        final undoInventory = playerState.player.powerUpInventory['undo'] ?? 0;
        
        // Only show undo ready if player has undo power-ups AND can use them
        final showUndoReady = state.canUndo && undoInventory > 0;
        
        // Check if any power-ups are active
        final hasActiveEffects = state.isFreezeActive || 
            state.isDoubleCoinsActive || 
            state.shieldCount > 0 ||
            showUndoReady;
        
        return Column(
          children: [
            // Active power-up effects bar
            if (hasActiveEffects)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withAlpha(50),
                      AppColors.primary.withAlpha(50),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.accent.withAlpha(100)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (state.isFreezeActive) ...[
                      const Text('❄️', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '${state.freezeTimeRemaining?.inSeconds ?? 0}s',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.lightBlueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (state.isDoubleCoinsActive) ...[
                      const Text('💰', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '2x',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (state.shieldCount > 0) ...[
                      const Text('🛡️', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        'x${state.shieldCount}',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (showUndoReady) ...[
                      const Text('↩️', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        'Ready',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.orangeAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            
            // Main stats row
            Container(
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
            ),
          ],
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
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withAlpha(240),
            AppColors.primary.withAlpha(240),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withAlpha(150),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: Colors.white.withAlpha(100),
          width: 2,
        ),
      ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title with pulsing effect
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '👀',
                  style: TextStyle(fontSize: 24),
                ).animate(onPlay: (c) => c.repeat()).scale(
                  duration: 1.seconds,
                  begin: const Offset(1.0, 1.0),
                  end: const Offset(1.2, 1.2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Memorize the Cards!',
                  style: AppTextStyles.headline2.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withAlpha(100),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Countdown timer with circular progress
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Countdown circle
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '$seconds',
                      style: AppTextStyles.headline1.copyWith(
                        fontSize: 32,
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate(key: ValueKey(seconds))
                        .scale(duration: 200.ms, curve: Curves.easeOut)
                        .then()
                        .shake(duration: 100.ms),
                  ),
                ),
                const SizedBox(width: 20),
                // Skip button
                ElevatedButton.icon(
                  onPressed: onSkip,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.skip_next, size: 18),
                  label: Text(
                    'Skip & Start',
                    style: AppTextStyles.body1.copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ).animate().fadeIn(duration: 300.ms).scale(
        begin: const Offset(0.95, 0.95),
        duration: 300.ms,
        curve: Curves.easeOut,
      );
  }
}

/* Related to commented out _showPowerUpsDialog - commenting out
class _PowerUpItem extends StatelessWidget {
  final PowerUpConfig powerUp;
  final int inventory;
  final VoidCallback? onUse;
  final VoidCallback onBuy;

  const _PowerUpItem({
    required this.powerUp,
    required this.inventory,
    this.onUse,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.surface.withAlpha(180),
            AppColors.surfaceLight.withAlpha(100),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: inventory > 0 ? AppColors.success.withAlpha(100) : AppColors.primary.withAlpha(50),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: Text(powerUp.icon, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 12),
          
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  powerUp.name,
                  style: AppTextStyles.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  powerUp.description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (powerUp.coinCost > 0) ...[
                      const Text('💰', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        '${powerUp.coinCost}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.coinColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    if (powerUp.coinCost > 0 && powerUp.gemCost > 0)
                      const Text(' / ', style: TextStyle(color: AppColors.textSecondary)),
                    if (powerUp.gemCost > 0) ...[
                      const Text('💎', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text(
                        '${powerUp.gemCost}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.gemColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          // Inventory / Actions
          Column(
            children: [
              // Inventory count
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: inventory > 0 
                      ? AppColors.success.withAlpha(80)
                      : AppColors.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'x$inventory',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: inventory > 0 ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              
              // Use or Buy button
              ElevatedButton(
                onPressed: onUse ?? onBuy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: inventory > 0 ? AppColors.success : AppColors.primary,
                  minimumSize: const Size(70, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                child: Text(
                  inventory > 0 ? 'Use' : 'Buy',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
} */
