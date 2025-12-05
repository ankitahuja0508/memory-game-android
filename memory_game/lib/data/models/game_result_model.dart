import 'package:equatable/equatable.dart';
import 'achievement_model.dart';

/// Result of a completed game level
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
  final List<Reward> bonusRewards;
  final bool isNewBestTime;
  final bool isNewBestMoves;
  final List<String> unlockedAchievements;

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
    this.bonusRewards = const [],
    this.isNewBestTime = false,
    this.isNewBestMoves = false,
    this.unlockedAchievements = const [],
  });

  int get totalCoins => coinsEarned + bonusCoins;

  double get efficiency => optimalMoves / moves;

  String get formattedTime {
    final minutes = timeTaken.inMinutes;
    final seconds = timeTaken.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  List<Object?> get props => [
        level,
        stars,
        moves,
        timeTaken,
        matches,
        mistakes,
        longestStreak,
        isPerfect,
        coinsEarned,
        xpEarned,
      ];
}

/// Calculates game results
class GameResultCalculator {
  /// Calculate stars based on performance
  static int calculateStars({
    required int moves,
    required int optimalMoves,
    required Duration timeTaken,
    required Duration parTime,
    required int mistakes,
  }) {
    int stars = 1; // Complete = 1 star

    final moveRatio = moves / optimalMoves;
    final timeBonus = timeTaken <= parTime;

    // Star 2: Under move threshold OR under time
    if (moveRatio <= 1.5 || timeBonus) {
      stars = 2;
    }

    // Star 3: Excellent performance
    if (moveRatio <= 1.2 && mistakes <= 2) {
      stars = 3;
    }

    // Perfect game always gets 3 stars
    if (mistakes == 0) {
      stars = 3;
    }

    return stars;
  }

  /// Calculate coins earned
  static int calculateCoins({
    required int level,
    required int stars,
    required bool isPerfect,
    required Duration timeTaken,
    required Duration parTime,
    required int streak,
  }) {
    int coins = 10 + (level ~/ 5); // Base coins scale with level

    // Star bonus
    coins += stars * 5;

    // Perfect game bonus
    if (isPerfect) {
      coins += 50;
    }

    // Speed bonus
    if (timeTaken < parTime) {
      coins += 15;
    }

    // Streak bonus
    coins += (streak * 2);

    return coins;
  }

  /// Calculate XP earned
  static int calculateXP({
    required int stars,
    required bool isPerfect,
    required List<String> newAchievements,
  }) {
    int xp = 20; // Base XP

    // Star bonus
    xp += stars * 10;

    // Perfect game bonus
    if (isPerfect) {
      xp += 50;
    }

    // Achievement bonus
    xp += newAchievements.length * 25;

    return xp;
  }
}
