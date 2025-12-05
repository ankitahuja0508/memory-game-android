import 'package:equatable/equatable.dart';

/// Difficulty tier for levels
enum DifficultyTier {
  beginner,  // 1-10
  easy,      // 11-30
  medium,    // 31-60
  hard,      // 61-100
  expert,    // 101+
}

/// Special level types
enum SpecialLevelType {
  normal,
  bonusRound,
  bossLevel,
  speedChallenge,
  memoryMaster,
}

/// Theme for card set - renamed to avoid conflict with Flutter's CardTheme
class GameCardTheme extends Equatable {
  final String id;
  final String name;
  final String icon;
  final List<String> symbols;
  final int unlocksAtLevel;
  final int cost;
  final bool isPremium;

  const GameCardTheme({
    required this.id,
    required this.name,
    required this.icon,
    required this.symbols,
    this.unlocksAtLevel = 1,
    this.cost = 0,
    this.isPremium = false,
  });

  @override
  List<Object?> get props => [id, name, symbols, unlocksAtLevel];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'symbols': symbols,
      'unlocksAtLevel': unlocksAtLevel,
      'cost': cost,
      'isPremium': isPremium,
    };
  }

  factory GameCardTheme.fromJson(Map<String, dynamic> json) {
    return GameCardTheme(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: json['icon'] as String,
      symbols: List<String>.from(json['symbols'] as List),
      unlocksAtLevel: json['unlocksAtLevel'] as int? ?? 1,
      cost: json['cost'] as int? ?? 0,
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }
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
  });

  int get totalCards => pairs * 2;

  @override
  List<Object?> get props => [
        level,
        pairs,
        columns,
        rows,
        timeLimit,
        theme,
        specialType,
        difficulty,
      ];
}

/// Thresholds for earning stars
class StarThresholds extends Equatable {
  final int oneStar;   // Max moves for 1 star
  final int twoStar;   // Max moves for 2 stars
  final int threeStar; // Max moves for 3 stars
  final Duration timeForThree; // Time limit for 3 stars

  const StarThresholds({
    required this.oneStar,
    required this.twoStar,
    required this.threeStar,
    required this.timeForThree,
  });

  @override
  List<Object?> get props => [oneStar, twoStar, threeStar, timeForThree];
}

/// Player's progress on a specific level
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

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'stars': stars,
      'bestMoves': bestMoves,
      'bestTime': bestTime.inMilliseconds,
      'completed': completed,
      'attempts': attempts,
    };
  }

  factory LevelProgress.fromJson(Map<String, dynamic> json) {
    return LevelProgress(
      level: json['level'] as int,
      stars: json['stars'] as int? ?? 0,
      bestMoves: json['bestMoves'] as int? ?? 0,
      bestTime: Duration(milliseconds: json['bestTime'] as int? ?? 0),
      completed: json['completed'] as bool? ?? false,
      attempts: json['attempts'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [level, stars, bestMoves, bestTime, completed, attempts];
}
