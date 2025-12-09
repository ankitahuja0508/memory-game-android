import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/models.dart';
import '../../domain/services/services.dart';
import 'game_state.dart';

class GameCubit extends Cubit<GameState> {
  final LevelGeneratorService _levelGenerator;
  final AudioService _audioService;
  final HapticService _hapticService;

  Timer? _gameTimer;
  Timer? _previewTimer;
  Timer? _freezeTimer;
  Timer? _matchDelayTimer;

  GameCubit({
    required LevelGeneratorService levelGenerator,
    required AudioService audioService,
    required HapticService hapticService,
  })  : _levelGenerator = levelGenerator,
        _audioService = audioService,
        _hapticService = hapticService,
        super(const GameState());

  void startLevel(int level, {String? themeId, bool showPreview = true}) {
    _stopAllTimers();

    final config = _levelGenerator.generateLevel(level, themeId: themeId);
    final cards = _levelGenerator.generateCards(config);

    // Start with preview phase - all cards visible
    final previewCards = cards.map((c) => c.copyWith(state: CardState.preview)).toList();

    // Use preview duration from level config
    final previewDuration = Duration(milliseconds: config.previewDuration);

    emit(GameState(
      phase: showPreview && config.showPreview ? GamePhase.preview : GamePhase.playing,
      level: level,
      cards: showPreview && config.showPreview ? previewCards : cards,
      timeLimit: config.timeLimit,
      levelConfig: config,
      previewTimeRemaining: previewDuration,
    ));

    if (showPreview && config.showPreview) {
      _startPreviewPhase();
    } else {
      _startGameTimer();
    }
  }

  void _startPreviewPhase() {
    const tickDuration = Duration(milliseconds: 100);
    int lastSecond = -1;
    
    _previewTimer = Timer.periodic(tickDuration, (timer) {
      if (state.phase != GamePhase.preview) {
        timer.cancel();
        return;
      }

      final newRemaining = state.previewTimeRemaining - tickDuration;
      
      if (newRemaining <= Duration.zero) {
        timer.cancel();
        _endPreviewPhase();
      } else {
        // Play countdown sound for last 3 seconds
        final currentSecond = newRemaining.inSeconds;
        if (currentSecond != lastSecond && currentSecond <= 3 && currentSecond > 0) {
          _audioService.playCountdown();
          _hapticService.light();
          lastSecond = currentSecond;
        }
        emit(state.copyWith(previewTimeRemaining: newRemaining));
      }
    });
  }

  void _endPreviewPhase() {
    // Hide all cards
    final hiddenCards = state.cards.map((c) => c.copyWith(state: CardState.faceDown)).toList();
    
    emit(state.copyWith(
      phase: GamePhase.playing,
      cards: hiddenCards,
      previewTimeRemaining: Duration.zero,
    ));

    _startGameTimer();
  }

  void skipPreview() {
    _previewTimer?.cancel();
    _endPreviewPhase();
  }

  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.phase != GamePhase.playing) {
        timer.cancel();
        return;
      }

      // Pause timer when any power-up is active (peek, freeze, hint)
      if (!state.isTimerPaused) {
        final newElapsed = state.elapsedTime + const Duration(seconds: 1);
        
        if (state.timeLimit != null && newElapsed >= state.timeLimit!) {
          timer.cancel();
          emit(state.copyWith(phase: GamePhase.timeout, elapsedTime: newElapsed));
          return;
        }

        // Play warning sound when time is low
        if (state.timeLimit != null) {
          final remaining = state.timeLimit! - newElapsed;
          if (remaining.inSeconds == 10 || remaining.inSeconds == 5) {
            _audioService.playTimerWarning();
            _hapticService.light();
          } else if (remaining.inSeconds <= 3 && remaining.inSeconds > 0) {
            _audioService.playCountdown();
            _hapticService.medium();
          }
        }

        emit(state.copyWith(elapsedTime: newElapsed));
      }
    });
  }

  void flipCard(int index) {
    if (!state.canInteract) return;
    if (index < 0 || index >= state.cards.length) return;

    final card = state.cards[index];
    if (!card.canBeFlipped) return;

    _audioService.playFlip();
    _hapticService.light();

    // Clear canUndo when user makes a new move
    final newCards = List<CardModel>.from(state.cards);
    newCards[index] = card.copyWith(state: CardState.faceUp);

    final newSelected = [...state.selectedIndices, index];

    emit(state.copyWith(
      cards: newCards,
      selectedIndices: newSelected,
      canUndo: false, // Any new move cancels undo ability
    ));

    if (newSelected.length == 2) {
      _checkMatch();
    }
  }

  void _checkMatch() {
    if (state.selectedIndices.length != 2) return;

    final idx1 = state.selectedIndices[0];
    final idx2 = state.selectedIndices[1];
    final card1 = state.cards[idx1];
    final card2 = state.cards[idx2];

    final isMatch = card1.pairId == card2.pairId;

    _matchDelayTimer?.cancel();
    _matchDelayTimer = Timer(const Duration(milliseconds: 600), () {
      if (isMatch) {
        _handleMatch(idx1, idx2);
      } else {
        _handleMismatch(idx1, idx2);
      }
    });
  }

  void _handleMatch(int idx1, int idx2) {
    _audioService.playMatch();
    _hapticService.success();

    final newCards = List<CardModel>.from(state.cards);
    newCards[idx1] = newCards[idx1].copyWith(state: CardState.matched);
    newCards[idx2] = newCards[idx2].copyWith(state: CardState.matched);

    final newMatches = state.matches + 1;
    final newStreak = state.currentStreak + 1;
    final newLongest = newStreak > state.longestStreak ? newStreak : state.longestStreak;

    emit(state.copyWith(
      cards: newCards,
      selectedIndices: [],
      moves: state.moves + 1,
      matches: newMatches,
      currentStreak: newStreak,
      longestStreak: newLongest,
      canUndo: false, // Can't undo a match
      lastMismatchIndices: null,
    ));

    // Check if game complete
    if (newMatches >= state.totalPairs) {
      _completeGame();
    }
  }

  void _handleMismatch(int idx1, int idx2) {
    _audioService.playMismatch();
    _hapticService.error();

    final newCards = List<CardModel>.from(state.cards);
    newCards[idx1] = newCards[idx1].copyWith(state: CardState.faceDown);
    newCards[idx2] = newCards[idx2].copyWith(state: CardState.faceDown);

    // Check if shield is active
    if (state.hasShieldProtection) {
      // Shield absorbs the mistake
      debugPrint('🛡️ Shield protected from mistake! Remaining: ${state.shieldCount - 1}');
      emit(state.copyWith(
        cards: newCards,
        selectedIndices: [],
        moves: state.moves + 1,
        // Don't increment mistakes - shield absorbed it
        currentStreak: 0, // Still breaks streak
        shieldCount: state.shieldCount - 1, // Use one shield charge
        canUndo: false, // No undo needed - shield absorbed the mistake
        lastMismatchIndices: [], // Clear last mismatch since shield absorbed it
      ));
    } else {
      // Normal mismatch
      emit(state.copyWith(
        cards: newCards,
        selectedIndices: [],
        moves: state.moves + 1,
        mistakes: state.mistakes + 1,
        currentStreak: 0,
        canUndo: true, // Enable undo after mismatch
        lastMismatchIndices: [idx1, idx2],
      ));
    }
  }

  void _completeGame() {
    _stopAllTimers();
    _hapticService.heavy();
    emit(state.copyWith(phase: GamePhase.completed));
    // Note: Success sound is played in game_screen.dart when showing the result dialog
  }

  // ============================================
  // POWER-UPS
  // ============================================

  /// PEEK: Show all cards for 3 seconds
  void activatePeek() {
    if (state.phase != GamePhase.playing) return;
    
    _audioService.playPowerUp();
    _hapticService.medium();

    final peekCards = state.cards.map((c) {
      if (c.state == CardState.faceDown) {
        return c.copyWith(state: CardState.faceUp);
      }
      return c;
    }).toList();

    emit(state.copyWith(cards: peekCards, isPeekActive: true, canUndo: false));

    Timer(const Duration(seconds: 3), () {
      if (!state.isPeekActive) return;
      
      final hiddenCards = state.cards.map((c) {
        if (c.state == CardState.faceUp && c.state != CardState.matched) {
          return c.copyWith(state: CardState.faceDown);
        }
        return c;
      }).toList();

      emit(state.copyWith(cards: hiddenCards, isPeekActive: false));
    });
  }

  /// FREEZE: Pause timer for 10 seconds
  void activateFreeze() {
    if (state.phase != GamePhase.playing || state.isFreezeActive) return;

    _audioService.playPowerUp();
    _hapticService.medium();

    emit(state.copyWith(
      isFreezeActive: true,
      freezeTimeRemaining: const Duration(seconds: 10),
    ));

    _freezeTimer?.cancel();
    _freezeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!state.isFreezeActive) {
        timer.cancel();
        return;
      }

      final remaining = state.freezeTimeRemaining! - const Duration(seconds: 1);
      if (remaining <= Duration.zero) {
        timer.cancel();
        emit(state.copyWith(isFreezeActive: false, freezeTimeRemaining: null));
      } else {
        emit(state.copyWith(freezeTimeRemaining: remaining));
      }
    });
  }

  /// HINT: Highlight one matching pair for 3 seconds
  void activateHint() {
    if (state.phase != GamePhase.playing) return;

    _audioService.playPowerUp();
    _hapticService.medium();

    // Find an unmatched pair (not already flipped or matched)
    final unmatchedCards = <int, List<int>>{};
    for (var i = 0; i < state.cards.length; i++) {
      final card = state.cards[i];
      if (card.state == CardState.faceDown) {
        unmatchedCards.putIfAbsent(card.pairId, () => []).add(i);
      }
    }

    // Filter to only pairs where both cards are available
    unmatchedCards.removeWhere((key, value) => value.length < 2);

    if (unmatchedCards.isEmpty) return;

    // Get first complete pair
    final pairIndices = unmatchedCards.values.first;

    final newCards = List<CardModel>.from(state.cards);
    newCards[pairIndices[0]] = newCards[pairIndices[0]].copyWith(state: CardState.hinted);
    newCards[pairIndices[1]] = newCards[pairIndices[1]].copyWith(state: CardState.hinted);

    // Set hint active (pauses timer)
    emit(state.copyWith(cards: newCards, isHintActive: true, canUndo: false));

    // Remove hint after 3 seconds (gives user time to tap both cards)
    Timer(const Duration(seconds: 3), () {
      if (!state.isHintActive) return; // Already deactivated
      
      final resetCards = state.cards.map((c) {
        if (c.state == CardState.hinted) {
          return c.copyWith(state: CardState.faceDown);
        }
        return c;
      }).toList();
      emit(state.copyWith(cards: resetCards, isHintActive: false));
    });
  }

  /// MAGNET: Auto-match one pair instantly
  void activateMagnet() {
    if (state.phase != GamePhase.playing) return;

    _audioService.playPowerUp();
    _hapticService.medium();

    // Find and auto-match one pair
    final unmatchedCards = <int, List<int>>{};
    for (var i = 0; i < state.cards.length; i++) {
      final card = state.cards[i];
      if (card.state != CardState.matched && card.state != CardState.faceUp) {
        unmatchedCards.putIfAbsent(card.pairId, () => []).add(i);
      }
    }

    if (unmatchedCards.isEmpty) return;

    final pairIndices = unmatchedCards.values.first;
    if (pairIndices.length < 2) return;

    final idx1 = pairIndices[0];
    final idx2 = pairIndices[1];

    // First, reveal the cards
    final revealCards = List<CardModel>.from(state.cards);
    revealCards[idx1] = revealCards[idx1].copyWith(state: CardState.hinted);
    revealCards[idx2] = revealCards[idx2].copyWith(state: CardState.hinted);

    emit(state.copyWith(cards: revealCards, canUndo: false));

    // After a brief delay, match them
    Timer(const Duration(milliseconds: 600), () {
      _audioService.playMatch();
      _hapticService.success();

      final matchCards = List<CardModel>.from(state.cards);
      // Find the cards again in case state changed
      for (var i = 0; i < matchCards.length; i++) {
        if (i == idx1 || i == idx2) {
          matchCards[i] = matchCards[i].copyWith(state: CardState.matched);
        }
      }

      final newMatches = state.matches + 1;

      emit(state.copyWith(
        cards: matchCards,
        matches: newMatches,
      ));

      if (newMatches >= state.totalPairs) {
        _completeGame();
      }
    });
  }

  /// UNDO: Undo the last wrong match (reduces moves and mistakes by 1)
  void activateUndo() {
    if (state.phase != GamePhase.playing) return;
    if (!state.canUndo || state.lastMismatchIndices == null) {
      debugPrint('↩️ Cannot undo - no recent mismatch');
      return;
    }

    _audioService.playPowerUp();
    _hapticService.medium();

    debugPrint('↩️ Undo activated! Reversing last mismatch');
    debugPrint('   Current moves: ${state.moves}');
    debugPrint('   Current mistakes: ${state.mistakes}');

    // Reduce moves by 1 (the mismatch move is undone)
    // Reduce mistakes by 1 (only if shield didn't absorb it)
    final newMoves = state.moves > 0 ? state.moves - 1 : 0;
    final newMistakes = state.mistakes > 0 ? state.mistakes - 1 : state.mistakes;

    debugPrint('   New moves: $newMoves');
    debugPrint('   New mistakes: $newMistakes');

    emit(state.copyWith(
      moves: newMoves,
      mistakes: newMistakes,
      canUndo: false, // Can only undo once
      lastMismatchIndices: null,
    ));
    
    debugPrint('✅ Undo complete! Moves: ${state.moves}, Mistakes: ${state.mistakes}');
  }

  /// DOUBLE COINS: Double the coin reward at end of level
  void activateDoubleCoins() {
    if (state.phase != GamePhase.playing) return;
    if (state.isDoubleCoinsActive) return; // Already active

    _audioService.playPowerUp();
    _hapticService.medium();

    debugPrint('💰 Double Coins activated! Coins will be doubled at level end');

    emit(state.copyWith(isDoubleCoinsActive: true, canUndo: false));
  }

  /// SHIELD: Protect from the next 3 mistakes (mistakes won't count)
  void activateShield() {
    if (state.phase != GamePhase.playing) return;

    _audioService.playPowerUp();
    _hapticService.medium();

    // Add 3 shield charges
    final newShieldCount = state.shieldCount + 3;
    debugPrint('🛡️ Shield activated! Protection for $newShieldCount mistakes');

    emit(state.copyWith(shieldCount: newShieldCount, canUndo: false));
  }

  // ============================================
  // GAME CONTROLS
  // ============================================

  void pauseGame() {
    if (state.phase != GamePhase.playing) return;
    _gameTimer?.cancel();
    emit(state.copyWith(phase: GamePhase.paused));
  }

  void resumeGame() {
    if (state.phase != GamePhase.paused) return;
    emit(state.copyWith(phase: GamePhase.playing));
    _startGameTimer();
  }

  void restartLevel() {
    startLevel(state.level, themeId: state.levelConfig?.theme.id);
  }

  /// Add extra time (for rewarded ad)
  void addExtraTime(int seconds) {
    if (state.phase != GamePhase.timeout) return;
    
    // Resume game with extra time by going back to playing phase
    emit(state.copyWith(phase: GamePhase.playing));
    
    // Restart the timer
    _startGameTimer();
  }

  GameResult getResult() {
    final config = state.levelConfig;
    final optimalMoves = state.totalPairs;
    
    final stars = GameResultCalculator.calculateStars(
      moves: state.moves,
      optimalMoves: optimalMoves,
      timeTaken: state.elapsedTime,
      parTime: config?.starThresholds.timeForThree ?? Duration.zero,
      mistakes: state.mistakes,
    );

    final baseCoins = GameResultCalculator.calculateCoins(
      level: state.level,
      stars: stars,
      isPerfect: state.isPerfect,
      timeTaken: state.elapsedTime,
      parTime: config?.starThresholds.timeForThree ?? Duration.zero,
      streak: state.longestStreak,
    );
    
    // Apply coin multiplier from level config (special levels give bonus coins)
    final coinMultiplier = config?.coinMultiplier ?? 1.0;
    var coins = (baseCoins * coinMultiplier).round();
    
    // Apply Double Coins power-up
    if (state.isDoubleCoinsActive) {
      coins *= 2;
      debugPrint('💰 Double Coins applied! $baseCoins → $coins');
    }

    return GameResult(
      level: state.level,
      stars: stars,
      moves: state.moves,
      optimalMoves: optimalMoves,
      timeTaken: state.elapsedTime,
      timeLimit: config?.timeLimit ?? Duration.zero,
      matches: state.matches,
      mistakes: state.mistakes,
      longestStreak: state.longestStreak,
      isPerfect: state.isPerfect,
      coinsEarned: coins,
      xpEarned: GameResultCalculator.calculateXP(
        stars: stars,
        isPerfect: state.isPerfect,
        newAchievements: [],
      ),
      specialLevelType: config?.specialType,
    );
  }

  void _stopAllTimers() {
    _gameTimer?.cancel();
    _previewTimer?.cancel();
    _freezeTimer?.cancel();
    _matchDelayTimer?.cancel();
  }

  @override
  Future<void> close() {
    _stopAllTimers();
    return super.close();
  }
}
