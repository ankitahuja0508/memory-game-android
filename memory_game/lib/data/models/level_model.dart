import 'package:equatable/equatable.dart';

enum DifficultyTier { beginner, easy, medium, hard, expert }
enum SpecialLevelType { normal, bonusRound, bossLevel, speedChallenge, memoryMaster }

/// Theme for card set
class GameCardTheme extends Equatable {
  final String id;
  final String name;
  final String icon;
  final List<String> symbols;
  final int unlocksAtLevel;
  final int cost;

  const GameCardTheme({
    required this.id,
    required this.name,
    required this.icon,
    required this.symbols,
    this.unlocksAtLevel = 1,
    this.cost = 0,
  });

  @override
  List<Object?> get props => [id, name, symbols, unlocksAtLevel];
}

/// Configuration for a game level
class LevelConfig extends Equatable {
  final int level;
  final int pairs;
  final int columns;
  final int rows;
  final Duration timeLimit;
  final GameCardTheme theme;
  final SpecialLevelType specialType;
  final DifficultyTier difficulty;
  final StarThresholds starThresholds;
  final bool showPreview; // Whether to show cards at start

  const LevelConfig({
    required this.level,
    required this.pairs,
    required this.columns,
    required this.rows,
    required this.timeLimit,
    required this.theme,
    this.specialType = SpecialLevelType.normal,
    required this.difficulty,
    required this.starThresholds,
    this.showPreview = true, // Default to showing preview
  });

  int get totalCards => pairs * 2;

  @override
  List<Object?> get props => [level, pairs, columns, rows, timeLimit, theme, difficulty];
}

class StarThresholds extends Equatable {
  final int oneStar;
  final int twoStar;
  final int threeStar;
  final Duration timeForThree;

  const StarThresholds({
    required this.oneStar,
    required this.twoStar,
    required this.threeStar,
    required this.timeForThree,
  });

  @override
  List<Object?> get props => [oneStar, twoStar, threeStar, timeForThree];
}

class LevelProgress extends Equatable {
  final int level;
  final int stars;
  final int bestMoves;
  final Duration bestTime;
  final bool completed;
  final int attempts;

  const LevelProgress({
    required this.level,
    this.stars = 0,
    this.bestMoves = 0,
    this.bestTime = Duration.zero,
    this.completed = false,
    this.attempts = 0,
  });

  LevelProgress copyWith({
    int? level,
    int? stars,
    int? bestMoves,
    Duration? bestTime,
    bool? completed,
    int? attempts,
  }) {
    return LevelProgress(
      level: level ?? this.level,
      stars: stars ?? this.stars,
      bestMoves: bestMoves ?? this.bestMoves,
      bestTime: bestTime ?? this.bestTime,
      completed: completed ?? this.completed,
      attempts: attempts ?? this.attempts,
    );
  }

  Map<String, dynamic> toJson() => {
    'level': level,
    'stars': stars,
    'bestMoves': bestMoves,
    'bestTime': bestTime.inMilliseconds,
    'completed': completed,
    'attempts': attempts,
  };

  factory LevelProgress.fromJson(Map<String, dynamic> json) => LevelProgress(
    level: json['level'] as int,
    stars: json['stars'] as int? ?? 0,
    bestMoves: json['bestMoves'] as int? ?? 0,
    bestTime: Duration(milliseconds: json['bestTime'] as int? ?? 0),
    completed: json['completed'] as bool? ?? false,
    attempts: json['attempts'] as int? ?? 0,
  );

  @override
  List<Object?> get props => [level, stars, bestMoves, bestTime, completed, attempts];
}
