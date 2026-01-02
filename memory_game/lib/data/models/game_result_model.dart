import 'package:equatable/equatable.dart';
import 'level_model.dart';

class GameResult extends Equatable {
  final int level;
  final int stars;
  final int moves;
  final int optimalMoves;
  final Duration timeTaken;
  final Duration timeLimit;
  final int matches;
  final int mistakes;
  final int longestStreak;
  final bool isPerfect;
  final int coinsEarned;
  final int xpEarned;
  final int bonusCoins;
  final SpecialLevelType? specialLevelType;

  const GameResult({
    required this.level,
    required this.stars,
    required this.moves,
    required this.optimalMoves,
    required this.timeTaken,
    required this.timeLimit,
    required this.matches,
    this.mistakes = 0,
    this.longestStreak = 0,
    this.isPerfect = false,
    this.coinsEarned = 0,
    this.xpEarned = 0,
    this.bonusCoins = 0,
    this.specialLevelType,
  });

  int get totalCoins => coinsEarned + bonusCoins;
  
  bool get isSpecialLevel => specialLevelType != null;
  
  String? get specialLevelBonus {
    if (specialLevelType == null) return null;
    switch (specialLevelType!) {
      case SpecialLevelType.bossLevel:
        return '🔥 Boss Level - 3x Coins!';
      case SpecialLevelType.bonusRound:
        return '🎁 Bonus Round - 2x Coins!';
      case SpecialLevelType.speedChallenge:
        return '⚡ Speed Challenge - 2.5x Coins!';
      case SpecialLevelType.memoryMaster:
        return '🧠 Memory Master - 2x Coins!';
      case SpecialLevelType.mysteryLevel:
        return '❓ Mystery Level';
      case SpecialLevelType.dailyChallenge:
        return '📅 Daily Challenge - 2x Coins!';
    }
  }

  String get formattedTime {
    final minutes = timeTaken.inMinutes;
    final seconds = timeTaken.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [level, stars, moves, timeTaken, matches, mistakes, isPerfect, coinsEarned, specialLevelType];
}

class GameResultCalculator {
  static int calculateStars({
    required int moves,
    required int optimalMoves,
    required Duration timeTaken,
    required Duration parTime,
    required int mistakes,
  }) {
    int stars = 1;
    final moveRatio = moves / optimalMoves;
    final timeBonus = timeTaken <= parTime;

    if (moveRatio <= 1.5 || timeBonus) stars = 2;
    if (moveRatio <= 1.2 && mistakes <= 2) stars = 3;
    if (mistakes == 0) stars = 3;

    return stars;
  }

  static int calculateCoins({
    required int level,
    required int stars,
    required bool isPerfect,
    required Duration timeTaken,
    required Duration parTime,
    required int streak,
  }) {
    int coins = 10 + (level ~/ 5);
    coins += stars * 5;
    if (isPerfect) coins += 50;
    if (timeTaken < parTime) coins += 15;
    coins += (streak * 2);
    return coins;
  }

  static int calculateXP({
    required int stars,
    required bool isPerfect,
    required List<String> newAchievements,
  }) {
    int xp = 20;
    xp += stars * 10;
    if (isPerfect) xp += 50;
    xp += newAchievements.length * 25;
    return xp;
  }
}
