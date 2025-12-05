import 'dart:math';
import '../../data/models/models.dart';
import '../../core/constants/app_constants.dart';

/// Service for generating level configurations and cards
class LevelGeneratorService {
  final Random _random = Random();

  /// All available themes
  static const List<GameCardTheme> allThemes = [
    GameCardTheme(
      id: 'animals',
      name: 'Animals',
      icon: '🐾',
      symbols: CardSymbols.animals,
      unlocksAtLevel: 1,
      cost: 0,
    ),
    GameCardTheme(
      id: 'space',
      name: 'Space',
      icon: '🚀',
      symbols: CardSymbols.space,
      unlocksAtLevel: 15,
      cost: 500,
    ),
    GameCardTheme(
      id: 'food',
      name: 'Food',
      icon: '🍕',
      symbols: CardSymbols.food,
      unlocksAtLevel: 30,
      cost: 750,
    ),
    GameCardTheme(
      id: 'nature',
      name: 'Nature',
      icon: '🌸',
      symbols: CardSymbols.nature,
      unlocksAtLevel: 45,
      cost: 1000,
    ),
    GameCardTheme(
      id: 'sports',
      name: 'Sports',
      icon: '⚽',
      symbols: CardSymbols.sports,
      unlocksAtLevel: 60,
      cost: 1250,
    ),
    GameCardTheme(
      id: 'travel',
      name: 'Travel',
      icon: '✈️',
      symbols: CardSymbols.travel,
      unlocksAtLevel: 75,
      cost: 1500,
    ),
    GameCardTheme(
      id: 'emotions',
      name: 'Emotions',
      icon: '😀',
      symbols: CardSymbols.emotions,
      unlocksAtLevel: 90,
      cost: 1750,
    ),
    GameCardTheme(
      id: 'music',
      name: 'Music',
      icon: '🎵',
      symbols: CardSymbols.music,
      unlocksAtLevel: 100,
      cost: 2000,
    ),
  ];

  /// Get theme by ID
  GameCardTheme getThemeById(String id) {
    return allThemes.firstWhere(
      (t) => t.id == id,
      orElse: () => allThemes.first,
    );
  }

  /// Get unlocked themes for a player level
  List<GameCardTheme> getUnlockedThemes(int playerLevel) {
    return allThemes.where((t) => t.unlocksAtLevel <= playerLevel).toList();
  }

  /// Generate level configuration
  LevelConfig generateLevel(int levelNumber, {String? themeId}) {
    final pairs = _calculatePairs(levelNumber);
    final grid = _calculateGrid(pairs);
    final timeLimit = _calculateTimeLimit(levelNumber, pairs);
    final theme = themeId != null ? getThemeById(themeId) : _getThemeForLevel(levelNumber);
    final difficulty = _getDifficultyTier(levelNumber);
    final specialType = _getSpecialLevelType(levelNumber);
    final starThresholds = _calculateStarThresholds(pairs);

    return LevelConfig(
      level: levelNumber,
      pairs: pairs,
      columns: grid.columns,
      rows: grid.rows,
      timeLimit: timeLimit,
      theme: theme,
      difficulty: difficulty,
      specialType: specialType,
      starThresholds: starThresholds,
    );
  }

  /// Generate cards for a level
  List<CardModel> generateCards(LevelConfig config) {
    final symbols = List<String>.from(config.theme.symbols)..shuffle(_random);
    final selectedSymbols = symbols.take(config.pairs).toList();
    final cards = <CardModel>[];

    for (int i = 0; i < config.pairs; i++) {
      // Add pair of cards with same symbol
      cards.add(CardModel(
        id: '${config.level}_${i}_a',
        symbol: selectedSymbols[i],
        pairId: i,
        state: CardState.faceDown,
      ));
      cards.add(CardModel(
        id: '${config.level}_${i}_b',
        symbol: selectedSymbols[i],
        pairId: i,
        state: CardState.faceDown,
      ));
    }

    // Shuffle cards
    cards.shuffle(_random);

    return cards;
  }

  /// Calculate number of pairs based on level
  int _calculatePairs(int level) {
    if (level <= 5) {
      return 3 + (level ~/ 2); // 3-5 pairs
    } else if (level <= 15) {
      return 5 + ((level - 5) ~/ 2); // 5-10 pairs
    } else if (level <= 30) {
      return 10 + ((level - 15) ~/ 3); // 10-15 pairs
    } else if (level <= 60) {
      return 15 + ((level - 30) ~/ 6); // 15-20 pairs
    } else {
      // Cap at 20 pairs for playability
      return min(20, 18 + ((level - 60) ~/ 20));
    }
  }

  /// Calculate optimal grid dimensions
  _GridSize _calculateGrid(int pairs) {
    final totalCards = pairs * 2;

    // Try to find a nice rectangular grid
    final possibleGrids = <_GridSize>[];

    for (int cols = 2; cols <= 8; cols++) {
      if (totalCards % cols == 0) {
        final rows = totalCards ~/ cols;
        if (rows >= 2 && rows <= 8) {
          possibleGrids.add(_GridSize(columns: cols, rows: rows));
        }
      }
    }

    if (possibleGrids.isEmpty) {
      // Fallback: find closest grid that works
      for (int cols = 2; cols <= 8; cols++) {
        final rows = (totalCards / cols).ceil();
        if (rows <= 8) {
          return _GridSize(columns: cols, rows: rows);
        }
      }
      return _GridSize(columns: 4, rows: (totalCards / 4).ceil());
    }

    // Prefer more square-like grids (columns ≈ rows)
    possibleGrids.sort((a, b) {
      final diffA = (a.columns - a.rows).abs();
      final diffB = (b.columns - b.rows).abs();
      return diffA.compareTo(diffB);
    });

    return possibleGrids.first;
  }

  /// Calculate time limit based on level and pairs
  Duration _calculateTimeLimit(int level, int pairs) {
    // Base time: 4 seconds per pair
    int baseSeconds = pairs * 4;

    // Adjust for difficulty
    if (level <= 10) {
      baseSeconds = (baseSeconds * 1.5).round(); // More generous for beginners
    } else if (level <= 30) {
      baseSeconds = (baseSeconds * 1.3).round();
    } else if (level <= 60) {
      baseSeconds = (baseSeconds * 1.1).round();
    }
    // Harder levels keep base time

    // Minimum 30 seconds, maximum 180 seconds
    return Duration(seconds: baseSeconds.clamp(30, 180));
  }

  /// Get theme for level (cycles through unlocked themes)
  GameCardTheme _getThemeForLevel(int level) {
    final unlockedThemes = getUnlockedThemes(level);
    if (unlockedThemes.isEmpty) return allThemes.first;

    // Cycle through themes based on level
    final index = (level - 1) % unlockedThemes.length;
    return unlockedThemes[index];
  }

  /// Get difficulty tier
  DifficultyTier _getDifficultyTier(int level) {
    if (level <= 10) return DifficultyTier.beginner;
    if (level <= 30) return DifficultyTier.easy;
    if (level <= 60) return DifficultyTier.medium;
    if (level <= 100) return DifficultyTier.hard;
    return DifficultyTier.expert;
  }

  /// Get special level type (every 10 levels)
  SpecialLevelType _getSpecialLevelType(int level) {
    if (level % 50 == 0) return SpecialLevelType.bossLevel;
    if (level % 25 == 0) return SpecialLevelType.memoryMaster;
    if (level % 10 == 0) return SpecialLevelType.bonusRound;
    if (level % 15 == 0) return SpecialLevelType.speedChallenge;
    return SpecialLevelType.normal;
  }

  /// Calculate star thresholds
  StarThresholds _calculateStarThresholds(int pairs) {
    final optimal = pairs; // Perfect memory = pairs moves

    return StarThresholds(
      threeStar: (optimal * 1.2).round(),
      twoStar: (optimal * 1.5).round(),
      oneStar: (optimal * 2.0).round(),
      timeForThree: Duration(seconds: pairs * 3),
    );
  }

  /// Get par time for bonus calculation
  Duration getParTime(int pairs, int level) {
    final baseSeconds = pairs * 3;
    return Duration(seconds: baseSeconds);
  }
}

class _GridSize {
  final int columns;
  final int rows;

  _GridSize({required this.columns, required this.rows});
}
