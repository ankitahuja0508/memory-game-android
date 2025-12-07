import 'package:equatable/equatable.dart';
import '../../data/models/models.dart';

enum GamePhase {
  loading,
  preview,    // NEW: Cards revealed for memorization
  playing,
  paused,
  completed,
  timeout,
}

class GameState extends Equatable {
  final GamePhase phase;
  final int level;
  final List<CardModel> cards;
  final List<int> selectedIndices;
  final int moves;
  final int matches;
  final int mistakes;
  final int currentStreak;
  final int longestStreak;
  final Duration elapsedTime;
  final Duration? timeLimit;
  final Duration previewTimeRemaining; // NEW: For preview countdown
  final bool isPeekActive;
  final bool isFreezeActive;
  final bool isHintActive;
  final Duration? freezeTimeRemaining;
  final LevelConfig? levelConfig;

  const GameState({
    this.phase = GamePhase.loading,
    this.level = 1,
    this.cards = const [],
    this.selectedIndices = const [],
    this.moves = 0,
    this.matches = 0,
    this.mistakes = 0,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.elapsedTime = Duration.zero,
    this.timeLimit,
    this.previewTimeRemaining = Duration.zero,
    this.isPeekActive = false,
    this.isFreezeActive = false,
    this.isHintActive = false,
    this.freezeTimeRemaining,
    this.levelConfig,
  });

  /// Returns true if any power-up is active that should pause the timer
  bool get isTimerPaused => isPeekActive || isFreezeActive || isHintActive;

  bool get isPlaying => phase == GamePhase.playing;
  bool get isPaused => phase == GamePhase.paused;
  bool get isCompleted => phase == GamePhase.completed;
  bool get isTimedOut => phase == GamePhase.timeout;
  bool get isPreview => phase == GamePhase.preview;
  bool get canInteract => phase == GamePhase.playing && selectedIndices.length < 2;

  int get totalPairs => cards.length ~/ 2;
  int get remainingPairs => totalPairs - matches;
  bool get allMatched => matches >= totalPairs && totalPairs > 0;
  bool get isPerfect => mistakes == 0 && allMatched;

  Duration get remainingTime {
    if (timeLimit == null) return Duration.zero;
    final remaining = timeLimit! - elapsedTime;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  GameState copyWith({
    GamePhase? phase,
    int? level,
    List<CardModel>? cards,
    List<int>? selectedIndices,
    int? moves,
    int? matches,
    int? mistakes,
    int? currentStreak,
    int? longestStreak,
    Duration? elapsedTime,
    Duration? timeLimit,
    Duration? previewTimeRemaining,
    bool? isPeekActive,
    bool? isFreezeActive,
    bool? isHintActive,
    Duration? freezeTimeRemaining,
    LevelConfig? levelConfig,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      level: level ?? this.level,
      cards: cards ?? this.cards,
      selectedIndices: selectedIndices ?? this.selectedIndices,
      moves: moves ?? this.moves,
      matches: matches ?? this.matches,
      mistakes: mistakes ?? this.mistakes,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      elapsedTime: elapsedTime ?? this.elapsedTime,
      timeLimit: timeLimit ?? this.timeLimit,
      previewTimeRemaining: previewTimeRemaining ?? this.previewTimeRemaining,
      isPeekActive: isPeekActive ?? this.isPeekActive,
      isFreezeActive: isFreezeActive ?? this.isFreezeActive,
      isHintActive: isHintActive ?? this.isHintActive,
      freezeTimeRemaining: freezeTimeRemaining ?? this.freezeTimeRemaining,
      levelConfig: levelConfig ?? this.levelConfig,
    );
  }

  @override
  List<Object?> get props => [
    phase, level, cards, selectedIndices, moves, matches, mistakes,
    currentStreak, longestStreak, elapsedTime, timeLimit, previewTimeRemaining,
    isPeekActive, isFreezeActive, isHintActive, freezeTimeRemaining, levelConfig,
  ];
}
