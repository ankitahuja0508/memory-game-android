import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/models.dart';
import '../../domain/services/services.dart';
import 'game_state.dart';

/// Cubit for managing game state
class GameCubit extends Cubit<GameState> {
  final LevelGeneratorService _levelGenerator;
  final AudioService _audioService;
  final HapticService _hapticService;

  Timer? _gameTimer;
  Timer? _freezeTimer;
  Timer? _peekTimer;
  Timer? _mismatchTimer;

  GameCubit({
    required LevelGeneratorService levelGenerator,
    required AudioService audioService,
    required HapticService hapticService,
  })  : _levelGenerator = levelGenerator,
        _audioService = audioService,
        _hapticService = hapticService,
        super(const GameState());

  /// Start a new game
  void startGame(int level, {String? themeId}) {
    _cancelAllTimers();

    final config = _levelGenerator.generateLevel(level, themeId: themeId);
    final cards = _levelGenerator.generateCards(config);

    emit(GameState(
      status: GameStatus.ready,
      levelConfig: config,
      cards: cards,
    ));

    // Small delay before starting
    Future.delayed(const Duration(milliseconds: 500), () {
      if (state.status == GameStatus.ready) {
        emit(state.copyWith(status: GameStatus.playing));
        _startGameTimer();
      }
    });
  }

  /// Flip a card
  void flipCard(int index) {
    if (state.status != GameStatus.playing) return;
    if (index < 0 || index >= state.cards.length) return;

    final card = state.cards[index];

    // Can't flip matched or already face-up cards
    if (card.isMatched || card.isFaceUp) return;

    // Already have two cards flipped, waiting for comparison
    if (state.firstFlippedIndex != null && state.secondFlippedIndex != null) {
      return;
    }

    _audioService.playFlip();
    _hapticService.mediumImpact();

    final updatedCards = List<CardModel>.from(state.cards);
    updatedCards[index] = card.copyWith(state: CardState.faceUp, isNew: false);

    // Clear hint if this card was hinted
    List<int> hintedIndices = List.from(state.hintedCardIndices);
    hintedIndices.remove(index);

    if (state.firstFlippedIndex == null) {
      // First card of pair
      emit(state.copyWith(
        cards: updatedCards,
        firstFlippedIndex: index,
        hintedCardIndices: hintedIndices,
      ));
    } else {
      // Second card of pair
      emit(state.copyWith(
        cards: updatedCards,
        secondFlippedIndex: index,
        moves: state.moves + 1,
        hintedCardIndices: hintedIndices,
      ));

      // Check for match
      _checkMatch(state.firstFlippedIndex!, index);
    }
  }

  /// Check if two flipped cards match
  void _checkMatch(int first, int second) {
    final firstCard = state.cards[first];
    final secondCard = state.cards[second];

    if (firstCard.pairId == secondCard.pairId) {
      // Match!
      _handleMatch(first, second);
    } else {
      // No match
      _handleMismatch(first, second);
    }
  }

  /// Handle a successful match
  void _handleMatch(int first, int second) {
    _audioService.playMatch();
    _hapticService.successVibration();

    final updatedCards = List<CardModel>.from(state.cards);
    updatedCards[first] = updatedCards[first].copyWith(state: CardState.matched);
    updatedCards[second] = updatedCards[second].copyWith(state: CardState.matched);

    final newStreak = state.currentStreak + 1;
    final longestStreak = newStreak > state.longestStreak ? newStreak : state.longestStreak;

    // Calculate streak bonus
    final streakBonus = newStreak * 5;
    final coinBonus = state.isDoubleCoinsActive ? streakBonus * 2 : streakBonus;

    emit(state.copyWith(
      cards: updatedCards,
      matches: state.matches + 1,
      currentStreak: newStreak,
      longestStreak: longestStreak,
      coinsEarned: state.coinsEarned + coinBonus,
      clearFirstFlipped: true,
      clearSecondFlipped: true,
      canUndo: false,
      clearLastMismatch: true,
    ));

    // Check if game is complete
    if (state.allMatched) {
      _completeGame();
    }
  }

  /// Handle a mismatch
  void _handleMismatch(int first, int second) {
    // Use shield if available
    if (state.hasShield) {
      emit(state.copyWith(
        hasShield: false,
        clearFirstFlipped: true,
        clearSecondFlipped: true,
      ));
      // Flip cards back immediately
      _flipCardsBack(first, second);
      return;
    }

    _audioService.playMismatch();
    _hapticService.errorVibration();

    emit(state.copyWith(
      mistakes: state.mistakes + 1,
      currentStreak: 0,
      canUndo: true,
      lastMismatchFirst: first,
      lastMismatchSecond: second,
    ));

    // Flip cards back after delay
    _mismatchTimer?.cancel();
    _mismatchTimer = Timer(const Duration(milliseconds: 1000), () {
      _flipCardsBack(first, second);
    });
  }

  /// Flip cards back to face down
  void _flipCardsBack(int first, int second) {
    if (state.status != GameStatus.playing) return;

    final updatedCards = List<CardModel>.from(state.cards);

    if (first < updatedCards.length && !updatedCards[first].isMatched) {
      updatedCards[first] = updatedCards[first].copyWith(state: CardState.faceDown);
    }
    if (second < updatedCards.length && !updatedCards[second].isMatched) {
      updatedCards[second] = updatedCards[second].copyWith(state: CardState.faceDown);
    }

    emit(state.copyWith(
      cards: updatedCards,
      clearFirstFlipped: true,
      clearSecondFlipped: true,
    ));
  }

  /// Complete the game
  void _completeGame() {
    _cancelAllTimers();

    _audioService.playLevelComplete();
    _hapticService.celebrationVibration();

    final config = state.levelConfig!;
    final stars = GameResultCalculator.calculateStars(
      moves: state.moves,
      optimalMoves: config.pairs,
      timeTaken: state.timeElapsed,
      parTime: config.starThresholds.timeForThree,
      mistakes: state.mistakes,
    );

    final baseCoins = GameResultCalculator.calculateCoins(
      level: config.level,
      stars: stars,
      isPerfect: state.isPerfectGame,
      timeTaken: state.timeElapsed,
      parTime: config.starThresholds.timeForThree,
      streak: state.longestStreak,
    );

    final totalCoins = state.isDoubleCoinsActive ? baseCoins * 2 : baseCoins;
    final xp = GameResultCalculator.calculateXP(
      stars: stars,
      isPerfect: state.isPerfectGame,
      newAchievements: [],
    );

    final result = GameResult(
      level: config.level,
      stars: stars,
      moves: state.moves,
      optimalMoves: config.pairs,
      timeTaken: state.timeElapsed,
      timeLimit: config.timeLimit,
      matches: state.matches,
      mistakes: state.mistakes,
      longestStreak: state.longestStreak,
      isPerfect: state.isPerfectGame,
      coinsEarned: totalCoins,
      xpEarned: xp,
      bonusCoins: state.coinsEarned,
    );

    emit(state.copyWith(
      status: GameStatus.completed,
      result: result,
    ));
  }

  /// Time out - game over
  void _gameTimeOut() {
    _cancelAllTimers();

    _audioService.playSound(SoundEffect.gameOver);
    _hapticService.errorVibration();

    emit(state.copyWith(status: GameStatus.timeOut));
  }

  /// Start game timer
  void _startGameTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.status != GameStatus.playing) {
        timer.cancel();
        return;
      }

      // Don't count time if frozen
      if (state.isTimeFrozen) {
        final newFreezeTime = state.freezeTimeRemaining! - const Duration(seconds: 1);
        if (newFreezeTime.inSeconds <= 0) {
          emit(state.copyWith(clearFreeze: true));
        } else {
          emit(state.copyWith(freezeTimeRemaining: newFreezeTime));
        }
        return;
      }

      final newTime = state.timeElapsed + const Duration(seconds: 1);

      if (newTime >= state.levelConfig!.timeLimit) {
        _gameTimeOut();
      } else {
        emit(state.copyWith(timeElapsed: newTime));
      }
    });
  }

  /// Pause game
  void pauseGame() {
    if (state.status != GameStatus.playing) return;
    _gameTimer?.cancel();
    emit(state.copyWith(status: GameStatus.paused));
  }

  /// Resume game
  void resumeGame() {
    if (state.status != GameStatus.paused) return;
    emit(state.copyWith(status: GameStatus.playing));
    _startGameTimer();
  }

  /// Use peek power-up
  void usePeek() {
    if (state.status != GameStatus.playing || state.isPeekActive) return;

    _audioService.playPowerUp();
    _hapticService.mediumImpact();

    // Reveal all cards
    final updatedCards = state.cards.map((card) {
      if (!card.isMatched) {
        return card.copyWith(state: CardState.faceUp);
      }
      return card;
    }).toList();

    emit(state.copyWith(
      cards: updatedCards,
      isPeekActive: true,
      peekTimeRemaining: const Duration(seconds: 3),
      clearFirstFlipped: true,
      clearSecondFlipped: true,
    ));

    // Hide cards after 3 seconds
    _peekTimer?.cancel();
    _peekTimer = Timer(const Duration(seconds: 3), () {
      _endPeek();
    });
  }

  void _endPeek() {
    if (!state.isPeekActive) return;

    final updatedCards = state.cards.map((card) {
      if (!card.isMatched) {
        return card.copyWith(state: CardState.faceDown);
      }
      return card;
    }).toList();

    emit(state.copyWith(
      cards: updatedCards,
      isPeekActive: false,
      clearPeek: true,
    ));
  }

  /// Use freeze power-up
  void useFreeze() {
    if (state.status != GameStatus.playing || state.isTimeFrozen) return;

    _audioService.playPowerUp();
    _hapticService.mediumImpact();

    emit(state.copyWith(
      freezeTimeRemaining: const Duration(seconds: 10),
    ));
  }

  /// Use hint power-up
  void useHint() {
    if (state.status != GameStatus.playing) return;

    // Find an unmatched pair
    final unmatchedCards = <int, CardModel>{};
    for (int i = 0; i < state.cards.length; i++) {
      if (!state.cards[i].isMatched && !state.cards[i].isFaceUp) {
        unmatchedCards[i] = state.cards[i];
      }
    }

    if (unmatchedCards.isEmpty) return;

    // Find a pair
    int? hintFirst;
    int? hintSecond;

    for (final entry1 in unmatchedCards.entries) {
      for (final entry2 in unmatchedCards.entries) {
        if (entry1.key != entry2.key &&
            entry1.value.pairId == entry2.value.pairId) {
          hintFirst = entry1.key;
          hintSecond = entry2.key;
          break;
        }
      }
      if (hintFirst != null) break;
    }

    if (hintFirst == null || hintSecond == null) return;

    _audioService.playPowerUp();
    _hapticService.lightImpact();

    // Mark cards as hinted
    final updatedCards = List<CardModel>.from(state.cards);
    updatedCards[hintFirst] = updatedCards[hintFirst].copyWith(state: CardState.hinted);
    updatedCards[hintSecond] = updatedCards[hintSecond].copyWith(state: CardState.hinted);

    emit(state.copyWith(
      cards: updatedCards,
      hintedCardIndices: [hintFirst, hintSecond],
    ));
  }

  /// Use undo power-up
  void useUndo() {
    if (!state.canUndo || state.lastMismatchFirst == null || state.lastMismatchSecond == null) {
      return;
    }

    _audioService.playPowerUp();
    _hapticService.lightImpact();

    // Revert the last mismatch
    emit(state.copyWith(
      mistakes: state.mistakes - 1,
      moves: state.moves - 1,
      canUndo: false,
      clearLastMismatch: true,
    ));
  }

  /// Use magnet power-up (auto-match one pair)
  void useMagnet() {
    if (state.status != GameStatus.playing) return;

    // Find an unmatched pair
    final unmatchedCards = <int, CardModel>{};
    for (int i = 0; i < state.cards.length; i++) {
      if (!state.cards[i].isMatched) {
        unmatchedCards[i] = state.cards[i];
      }
    }

    // Find a pair
    int? first;
    int? second;

    for (final entry1 in unmatchedCards.entries) {
      for (final entry2 in unmatchedCards.entries) {
        if (entry1.key != entry2.key &&
            entry1.value.pairId == entry2.value.pairId) {
          first = entry1.key;
          second = entry2.key;
          break;
        }
      }
      if (first != null) break;
    }

    if (first == null || second == null) return;

    _audioService.playPowerUp();
    _hapticService.successVibration();

    // Match the pair
    final updatedCards = List<CardModel>.from(state.cards);
    updatedCards[first] = updatedCards[first].copyWith(state: CardState.matched);
    updatedCards[second] = updatedCards[second].copyWith(state: CardState.matched);

    emit(state.copyWith(
      cards: updatedCards,
      matches: state.matches + 1,
    ));

    // Check if game is complete
    if (state.matches + 1 >= state.totalPairs) {
      _completeGame();
    }
  }

  /// Activate double coins
  void activateDoubleCoins() {
    emit(state.copyWith(isDoubleCoinsActive: true));
  }

  /// Activate shield
  void activateShield() {
    emit(state.copyWith(hasShield: true));
  }

  /// Reset game
  void resetGame() {
    _cancelAllTimers();
    emit(const GameState());
  }

  void _cancelAllTimers() {
    _gameTimer?.cancel();
    _freezeTimer?.cancel();
    _peekTimer?.cancel();
    _mismatchTimer?.cancel();
  }

  @override
  Future<void> close() {
    _cancelAllTimers();
    return super.close();
  }
}
