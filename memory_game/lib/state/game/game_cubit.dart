import 'dart:async';
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

      if (!state.isFreezeActive) {
        final newElapsed = state.elapsedTime + const Duration(seconds: 1);
        
        if (state.timeLimit != null && newElapsed >= state.timeLimit!) {
          timer.cancel();
          emit(state.copyWith(phase: GamePhase.timeout, elapsedTime: newElapsed));
          return;
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

    final newCards = List<CardModel>.from(state.cards);
    newCards[index] = card.copyWith(state: CardState.faceUp);

    final newSelected = [...state.selectedIndices, index];

    emit(state.copyWith(
      cards: newCards,
      selectedIndices: newSelected,
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

    emit(state.copyWith(
      cards: newCards,
      selectedIndices: [],
      moves: state.moves + 1,
      mistakes: state.mistakes + 1,
      currentStreak: 0,
    ));
  }

  void _completeGame() {
    _stopAllTimers();
    _audioService.playSuccess();
    _hapticService.heavy();
    emit(state.copyWith(phase: GamePhase.completed));
  }

  // Power-ups
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

    emit(state.copyWith(cards: peekCards, isPeekActive: true));

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

    emit(state.copyWith(cards: newCards));

    // Remove hint after 3 seconds (gives user time to tap both cards)
    Timer(const Duration(seconds: 3), () {
      final resetCards = state.cards.map((c) {
        if (c.state == CardState.hinted) {
          return c.copyWith(state: CardState.faceDown);
        }
        return c;
      }).toList();
      emit(state.copyWith(cards: resetCards));
    });
  }

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

    emit(state.copyWith(cards: revealCards));

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
    final coins = (baseCoins * coinMultiplier).round();

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
