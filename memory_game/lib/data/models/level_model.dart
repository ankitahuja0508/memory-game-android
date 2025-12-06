import 'package:equatable/equatable.dart';

enum DifficultyTier { beginner, easy, medium, hard, expert }

enum SpecialLevelType { 
  bonusRound,      // Extra time, relaxed - 2x coins
  bossLevel,       // Large grid, special rewards - 3x coins
  speedChallenge,  // Half time, fewer pairs - 2.5x coins
  memoryMaster,    // Brief preview, then hidden - 2x coins
  mysteryLevel,    // Unknown card positions
  dailyChallenge,  // Unique daily configuration
}

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
  final SpecialLevelType? specialType; // null = normal level
  final DifficultyTier difficulty;
  final StarThresholds starThresholds;
  final bool showPreview;
  final double coinMultiplier;
  final int previewDuration; // in milliseconds

  const LevelConfig({
    required this.level,
    required this.pairs,
    required this.columns,
    required this.rows,
    required this.timeLimit,
    required this.theme,
    this.specialType,
    required this.difficulty,
    required this.starThresholds,
    this.showPreview = true,
    this.coinMultiplier = 1.0,
    this.previewDuration = 3000,
  });

  int get totalCards => pairs * 2;
  
  bool get isSpecialLevel => specialType != null;
  
  String get difficultyName {
    switch (difficulty) {
      case DifficultyTier.beginner:
        return 'Beginner';
      case DifficultyTier.easy:
        return 'Easy';
      case DifficultyTier.medium:
        return 'Medium';
      case DifficultyTier.hard:
        return 'Hard';
      case DifficultyTier.expert:
        return 'Expert';
    }
  }
  
  String get specialLevelEmoji {
    if (specialType == null) return '';
    switch (specialType!) {
      case SpecialLevelType.bossLevel:
        return '🔥';
      case SpecialLevelType.bonusRound:
        return '🎁';
      case SpecialLevelType.speedChallenge:
        return '⚡';
      case SpecialLevelType.memoryMaster:
        return '🧠';
      case SpecialLevelType.mysteryLevel:
        return '❓';
      case SpecialLevelType.dailyChallenge:
        return '📅';
    }
  }

  @override
  List<Object?> get props => [level, pairs, columns, rows, timeLimit, theme, difficulty, specialType];
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
