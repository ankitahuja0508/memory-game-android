import 'package:equatable/equatable.dart';
import '../../data/models/models.dart';

/// Game status
enum GameStatus {
  initial,
  ready,
  playing,
  paused,
  completed,
  timeOut,
}

/// State for the game screen
class GameState extends Equatable {
  final GameStatus status;
  final LevelConfig? levelConfig;
  final List<CardModel> cards;
  final int? firstFlippedIndex;
  final int? secondFlippedIndex;
  final int moves;
  final int matches;
  final int mistakes;
  final int currentStreak;
  final int longestStreak;
  final Duration timeElapsed;
  final Duration? freezeTimeRemaining;
  final bool isPeekActive;
  final Duration? peekTimeRemaining;
  final List<int> hintedCardIndices;
  final int coinsEarned;
  final bool isDoubleCoinsActive;
  final bool hasShield;
  final bool canUndo;
  final int? lastMismatchFirst;
  final int? lastMismatchSecond;
  final GameResult? result;

  const GameState({
    this.status = GameStatus.initial,
    this.levelConfig,
    this.cards = const [],
    this.firstFlippedIndex,
    this.secondFlippedIndex,
    this.moves = 0,
    this.matches = 0,
    this.mistakes = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.timeElapsed = Duration.zero,
    this.freezeTimeRemaining,
    this.isPeekActive = false,
    this.peekTimeRemaining,
    this.hintedCardIndices = const [],
    this.coinsEarned = 0,
    this.isDoubleCoinsActive = false,
    this.hasShield = false,
    this.canUndo = false,
    this.lastMismatchFirst,
    this.lastMismatchSecond,
    this.result,
  });

  bool get isPlaying => status == GameStatus.playing;
  bool get isPaused => status == GameStatus.paused;
  bool get isCompleted => status == GameStatus.completed;
  bool get isTimeFrozen => freezeTimeRemaining != null && freezeTimeRemaining!.inSeconds > 0;

  int get totalPairs => levelConfig?.pairs ?? 0;
  int get remainingPairs => totalPairs - matches;
  bool get allMatched => matches >= totalPairs;

  Duration get remainingTime {
    if (levelConfig == null) return Duration.zero;
    final remaining = levelConfig!.timeLimit - timeElapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  double get timeProgress {
    if (levelConfig == null) return 0;
    return (timeElapsed.inMilliseconds / levelConfig!.timeLimit.inMilliseconds).clamp(0.0, 1.0);
  }

  bool get isPerfectGame => mistakes == 0;

  GameState copyWith({
    GameStatus? status,
    LevelConfig? levelConfig,
    List<CardModel>? cards,
    int? firstFlippedIndex,
    int? secondFlippedIndex,
    int? moves,
    int? matches,
    int? mistakes,
    int? currentStreak,
    int? longestStreak,
    Duration? timeElapsed,
    Duration? freezeTimeRemaining,
    bool? isPeekActive,
    Duration? peekTimeRemaining,
    List<int>? hintedCardIndices,
    int? coinsEarned,
    bool? isDoubleCoinsActive,
    bool? hasShield,
    bool? canUndo,
    int? lastMismatchFirst,
    int? lastMismatchSecond,
    GameResult? result,
    bool clearFirstFlipped = false,
    bool clearSecondFlipped = false,
    bool clearFreeze = false,
    bool clearPeek = false,
    bool clearHints = false,
    bool clearLastMismatch = false,
  }) {
    return GameState(
      status: status ?? this.status,
      levelConfig: levelConfig ?? this.levelConfig,
      cards: cards ?? this.cards,
      firstFlippedIndex: clearFirstFlipped ? null : (firstFlippedIndex ?? this.firstFlippedIndex),
      secondFlippedIndex: clearSecondFlipped ? null : (secondFlippedIndex ?? this.secondFlippedIndex),
      moves: moves ?? this.moves,
      matches: matches ?? this.matches,
      mistakes: mistakes ?? this.mistakes,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      freezeTimeRemaining: clearFreeze ? null : (freezeTimeRemaining ?? this.freezeTimeRemaining),
      isPeekActive: isPeekActive ?? this.isPeekActive,
      peekTimeRemaining: clearPeek ? null : (peekTimeRemaining ?? this.peekTimeRemaining),
      hintedCardIndices: clearHints ? const [] : (hintedCardIndices ?? this.hintedCardIndices),
      coinsEarned: coinsEarned ?? this.coinsEarned,
      isDoubleCoinsActive: isDoubleCoinsActive ?? this.isDoubleCoinsActive,
      hasShield: hasShield ?? this.hasShield,
      canUndo: canUndo ?? this.canUndo,
      lastMismatchFirst: clearLastMismatch ? null : (lastMismatchFirst ?? this.lastMismatchFirst),
      lastMismatchSecond: clearLastMismatch ? null : (lastMismatchSecond ?? this.lastMismatchSecond),
      result: result ?? this.result,
    );
  }

  @override
  List<Object?> get props => [
        status,
        levelConfig,
        cards,
        firstFlippedIndex,
        secondFlippedIndex,
        moves,
        matches,
        mistakes,
        currentStreak,
        longestStreak,
        timeElapsed,
        freezeTimeRemaining,
        isPeekActive,
        peekTimeRemaining,
        hintedCardIndices,
        coinsEarned,
        isDoubleCoinsActive,
        hasShield,
        canUndo,
        lastMismatchFirst,
        lastMismatchSecond,
        result,
      ];
}
