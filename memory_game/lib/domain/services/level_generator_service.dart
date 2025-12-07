import 'dart:math';
import '../../core/constants/app_constants.dart';
import '../../data/models/models.dart';

class LevelGeneratorService {
  final Random _random = Random();

  static const List<GameCardTheme> themes = [
    GameCardTheme(id: 'animals', name: 'Animals', icon: '🐼', symbols: CardSymbols.animals), // Free starter theme
    GameCardTheme(id: 'space', name: 'Space', icon: '🚀', symbols: CardSymbols.space, unlocksAtLevel: 8, cost: 300),
    GameCardTheme(id: 'food', name: 'Food', icon: '🍕', symbols: CardSymbols.food, unlocksAtLevel: 15, cost: 450),
    GameCardTheme(id: 'nature', name: 'Nature', icon: '🌸', symbols: CardSymbols.nature, unlocksAtLevel: 25, cost: 600),
    GameCardTheme(id: 'sports', name: 'Sports', icon: '⚽', symbols: CardSymbols.sports, unlocksAtLevel: 35, cost: 800),
    GameCardTheme(id: 'travel', name: 'Travel', icon: '✈️', symbols: CardSymbols.travel, unlocksAtLevel: 45, cost: 1000),
    GameCardTheme(id: 'emotions', name: 'Emotions', icon: '😀', symbols: CardSymbols.emotions, unlocksAtLevel: 55, cost: 1200),
    GameCardTheme(id: 'music', name: 'Music', icon: '🎵', symbols: CardSymbols.music, unlocksAtLevel: 70, cost: 1500),
  ];

  static GameCardTheme getThemeById(String id) {
    return themes.firstWhere((t) => t.id == id, orElse: () => themes.first);
  }

  /// Get special level type based on level number
  SpecialLevelType? _getSpecialLevelType(int level) {
    // Boss levels every 10 levels (10, 20, 30...)
    if (level % 10 == 0) return SpecialLevelType.bossLevel;
    // Bonus rounds every 5 levels (5, 15, 25...)
    if (level % 10 == 5) return SpecialLevelType.bonusRound;
    // Speed challenge at levels 7, 17, 27...
    if (level % 10 == 7) return SpecialLevelType.speedChallenge;
    // Memory master at levels 3, 13, 23...
    if (level % 10 == 3 && level >= 3) return SpecialLevelType.memoryMaster;
    return null;
  }

  LevelConfig generateLevel(int level, {String? themeId}) {
    final specialType = _getSpecialLevelType(level);
    
    // Calculate pairs based on level with faster progression
    int pairs = _calculatePairs(level, specialType);
    
    // Calculate grid dimensions
    final (columns, rows) = _calculateGrid(pairs);
    
    // Calculate time limit (special levels may have modified time)
    Duration timeLimit = _calculateTimeLimit(level, pairs, specialType);
    
    // Determine difficulty
    final difficulty = _getDifficulty(level);
    
    // Get theme
    final theme = themeId != null ? getThemeById(themeId) : _getThemeForLevel(level);
    
    // Calculate star thresholds
    final starThresholds = _calculateStarThresholds(pairs, timeLimit, specialType);
    
    // Preview duration based on level and special type
    final previewDuration = _getPreviewDuration(level, pairs, specialType);

    return LevelConfig(
      level: level,
      pairs: pairs,
      columns: columns,
      rows: rows,
      timeLimit: timeLimit,
      theme: theme,
      difficulty: difficulty,
      starThresholds: starThresholds,
      showPreview: true,
      specialType: specialType,
      coinMultiplier: _getCoinMultiplier(specialType),
      previewDuration: previewDuration,
    );
  }

  int _calculatePairs(int level, SpecialLevelType? specialType) {
    // Base pairs calculation - faster progression
    int basePairs;
    
    if (level == 1) {
      basePairs = 3; // Start with 3 pairs (6 cards, 3x2 grid)
    } else if (level == 2) {
      basePairs = 4; // 8 cards (4x2)
    } else if (level <= 4) {
      basePairs = 5; // 10 cards (5x2)
    } else if (level <= 7) {
      basePairs = 6; // 12 cards (4x3)
    } else if (level <= 10) {
      basePairs = 7 + (level - 8); // 14-16 cards
    } else if (level <= 15) {
      basePairs = 9 + (level - 10) ~/ 2; // 18-22 cards
    } else if (level <= 25) {
      basePairs = 12 + (level - 15) ~/ 3; // 24-30 cards
    } else if (level <= 40) {
      basePairs = 15 + (level - 25) ~/ 4; // 30-38 cards
    } else if (level <= 60) {
      basePairs = 18 + (level - 40) ~/ 5; // 36-44 cards
    } else {
      basePairs = min(20 + (level - 60) ~/ 10, 24); // Max 48 cards
    }
    
    // Modify based on special level type
    if (specialType != null) {
      switch (specialType) {
        case SpecialLevelType.bossLevel:
          basePairs = (basePairs * 1.3).ceil(); // Boss has more pairs
          break;
        case SpecialLevelType.bonusRound:
          basePairs = max(basePairs - 1, 3); // Bonus is slightly easier
          break;
        case SpecialLevelType.speedChallenge:
          basePairs = max(basePairs - 2, 4); // Speed has fewer pairs
          break;
        case SpecialLevelType.memoryMaster:
          basePairs = basePairs; // Same pairs, but harder rules
          break;
        case SpecialLevelType.mysteryLevel:
        case SpecialLevelType.dailyChallenge:
          break;
      }
    }
    
    return min(basePairs, 24); // Max 24 pairs (48 cards)
  }

  (int, int) _calculateGrid(int pairs) {
    final totalCards = pairs * 2;
    
    // Optimized grid layouts for visual appeal
    if (totalCards <= 6) return (3, 2);
    if (totalCards <= 8) return (4, 2);
    if (totalCards <= 10) return (5, 2);
    if (totalCards <= 12) return (4, 3);
    if (totalCards <= 14) return (7, 2);
    if (totalCards <= 16) return (4, 4);
    if (totalCards <= 18) return (6, 3);
    if (totalCards <= 20) return (5, 4);
    if (totalCards <= 24) return (6, 4);
    if (totalCards <= 28) return (7, 4);
    if (totalCards <= 30) return (6, 5);
    if (totalCards <= 35) return (7, 5);
    if (totalCards <= 36) return (6, 6);
    if (totalCards <= 40) return (8, 5);
    if (totalCards <= 42) return (7, 6);
    if (totalCards <= 48) return (8, 6);
    return (8, 6); // Max grid
  }

  Duration _calculateTimeLimit(int level, int pairs, SpecialLevelType? specialType) {
    // Base time calculation - more generous early, tighter later
    int secondsPerPair;
    
    if (level <= 5) {
      secondsPerPair = 12; // Very generous early
    } else if (level <= 15) {
      secondsPerPair = 10;
    } else if (level <= 30) {
      secondsPerPair = 8;
    } else if (level <= 50) {
      secondsPerPair = 7;
    } else {
      secondsPerPair = 6;
    }
    
    int totalSeconds = pairs * secondsPerPair + 5; // +5 buffer
    
    // Modify based on special level type
    if (specialType != null) {
      switch (specialType) {
        case SpecialLevelType.bossLevel:
          totalSeconds = (totalSeconds * 1.2).round(); // Boss gets more time
          break;
        case SpecialLevelType.bonusRound:
          totalSeconds = (totalSeconds * 1.5).round(); // Bonus is relaxed
          break;
        case SpecialLevelType.speedChallenge:
          totalSeconds = (totalSeconds * 0.5).round(); // Speed is half time!
          break;
        case SpecialLevelType.memoryMaster:
          totalSeconds = (totalSeconds * 0.8).round(); // Memory master is tight
          break;
        case SpecialLevelType.mysteryLevel:
        case SpecialLevelType.dailyChallenge:
          break;
      }
    }
    
    return Duration(seconds: max(totalSeconds, 15)); // Minimum 15 seconds
  }

  int _getPreviewDuration(int level, int pairs, SpecialLevelType? specialType) {
    // Memory Master: Brief preview then cards hide
    if (specialType == SpecialLevelType.memoryMaster) {
      return 2000 + (pairs * 150); // 2s base + 150ms per pair
    }
    
    // Speed challenge: Shorter preview
    if (specialType == SpecialLevelType.speedChallenge) {
      return 2000;
    }
    
    // Normal levels: Scale with pairs
    if (level <= 5) {
      return 3500; // Longer for beginners
    } else if (level <= 15) {
      return 3000;
    } else if (level <= 30) {
      return 2500 + (pairs * 50);
    } else {
      return 2000 + (pairs * 40);
    }
  }

  double _getCoinMultiplier(SpecialLevelType? specialType) {
    if (specialType == null) return 1.0;
    
    switch (specialType) {
      case SpecialLevelType.bossLevel:
        return 3.0; // Triple coins!
      case SpecialLevelType.bonusRound:
        return 2.0; // Double coins
      case SpecialLevelType.speedChallenge:
        return 2.5; // High risk, high reward
      case SpecialLevelType.memoryMaster:
        return 2.0;
      case SpecialLevelType.mysteryLevel:
        return 1.5;
      case SpecialLevelType.dailyChallenge:
        return 2.0;
    }
  }

  DifficultyTier _getDifficulty(int level) {
    if (level <= 5) return DifficultyTier.beginner;
    if (level <= 15) return DifficultyTier.easy;
    if (level <= 30) return DifficultyTier.medium;
    if (level <= 50) return DifficultyTier.hard;
    return DifficultyTier.expert;
  }

  GameCardTheme _getThemeForLevel(int level) {
    // Pick a random unlocked theme
    final unlocked = themes.where((t) => t.unlocksAtLevel <= level).toList();
    if (unlocked.isEmpty) return themes.first;
    return unlocked[_random.nextInt(unlocked.length)];
  }

  StarThresholds _calculateStarThresholds(int pairs, Duration timeLimit, SpecialLevelType? specialType) {
    final optimalMoves = pairs;
    
    // Adjust thresholds based on special type
    double threeStarMultiplier = 1.3;
    double twoStarMultiplier = 2.0;
    double oneStarMultiplier = 3.0;
    double timeThreshold = 0.6;
    
    if (specialType == SpecialLevelType.memoryMaster) {
      // Harder to get stars in memory master
      threeStarMultiplier = 1.2;
      twoStarMultiplier = 1.5;
      oneStarMultiplier = 2.0;
    } else if (specialType == SpecialLevelType.bonusRound) {
      // Easier to get stars in bonus
      threeStarMultiplier = 1.5;
      twoStarMultiplier = 2.5;
      oneStarMultiplier = 4.0;
      timeThreshold = 0.7;
    }
    
    return StarThresholds(
      oneStar: (optimalMoves * oneStarMultiplier).ceil(),
      twoStar: (optimalMoves * twoStarMultiplier).ceil(),
      threeStar: (optimalMoves * threeStarMultiplier).ceil(),
      timeForThree: Duration(seconds: (timeLimit.inSeconds * timeThreshold).round()),
    );
  }

  List<CardModel> generateCards(LevelConfig config) {
    final symbols = List<String>.from(config.theme.symbols);
    symbols.shuffle(_random);
    final selectedSymbols = symbols.take(config.pairs).toList();

    final cards = <CardModel>[];
    for (var i = 0; i < config.pairs; i++) {
      final symbol = selectedSymbols[i];
      // Create pair
      cards.add(CardModel(id: '${i}_a', symbol: symbol, pairId: i));
      cards.add(CardModel(id: '${i}_b', symbol: symbol, pairId: i));
    }

    cards.shuffle(_random);
    return cards;
  }
  
  /// Get a description of what makes this level special
  static String? getSpecialLevelDescription(SpecialLevelType? type) {
    if (type == null) return null;
    
    switch (type) {
      case SpecialLevelType.bossLevel:
        return '🔥 BOSS LEVEL - More pairs, 3x coins!';
      case SpecialLevelType.bonusRound:
        return '🎁 BONUS ROUND - Extra time, 2x coins!';
      case SpecialLevelType.speedChallenge:
        return '⚡ SPEED CHALLENGE - Half time, 2.5x coins!';
      case SpecialLevelType.memoryMaster:
        return '🧠 MEMORY MASTER - Brief preview, 2x coins!';
      case SpecialLevelType.mysteryLevel:
        return '❓ MYSTERY LEVEL';
      case SpecialLevelType.dailyChallenge:
        return '📅 DAILY CHALLENGE';
    }
  }
}
