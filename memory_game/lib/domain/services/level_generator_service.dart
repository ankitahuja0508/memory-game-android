import 'dart:math';
import '../../data/models/models.dart';
import '../../core/constants/app_constants.dart';

class LevelGeneratorService {
  final Random _random = Random();

  static const List<GameCardTheme> themes = [
    GameCardTheme(id: 'animals', name: 'Animals', icon: '🐼', symbols: CardSymbols.animals),
    GameCardTheme(id: 'space', name: 'Space', icon: '🚀', symbols: CardSymbols.space, unlocksAtLevel: 10, cost: 100),
    GameCardTheme(id: 'food', name: 'Food', icon: '🍕', symbols: CardSymbols.food, unlocksAtLevel: 20, cost: 200),
    GameCardTheme(id: 'nature', name: 'Nature', icon: '🌸', symbols: CardSymbols.nature, unlocksAtLevel: 30, cost: 300),
    GameCardTheme(id: 'sports', name: 'Sports', icon: '⚽', symbols: CardSymbols.sports, unlocksAtLevel: 40, cost: 400),
    GameCardTheme(id: 'travel', name: 'Travel', icon: '✈️', symbols: CardSymbols.travel, unlocksAtLevel: 50, cost: 500),
    GameCardTheme(id: 'emotions', name: 'Emotions', icon: '😀', symbols: CardSymbols.emotions, unlocksAtLevel: 60, cost: 600),
    GameCardTheme(id: 'music', name: 'Music', icon: '🎵', symbols: CardSymbols.music, unlocksAtLevel: 70, cost: 700),
  ];

  static GameCardTheme getThemeById(String id) {
    return themes.firstWhere((t) => t.id == id, orElse: () => themes.first);
  }

  LevelConfig generateLevel(int level, {String? themeId}) {
    // Calculate pairs based on level (2-20 pairs range)
    final pairs = _calculatePairs(level);
    
    // Calculate grid dimensions
    final (columns, rows) = _calculateGrid(pairs);
    
    // Calculate time limit
    final timeLimit = _calculateTimeLimit(level, pairs);
    
    // Determine difficulty
    final difficulty = _getDifficulty(level);
    
    // Get theme
    final theme = themeId != null ? getThemeById(themeId) : _getThemeForLevel(level);
    
    // Calculate star thresholds
    final starThresholds = _calculateStarThresholds(pairs, timeLimit);

    return LevelConfig(
      level: level,
      pairs: pairs,
      columns: columns,
      rows: rows,
      timeLimit: timeLimit,
      theme: theme,
      difficulty: difficulty,
      starThresholds: starThresholds,
      showPreview: true, // Always show preview
    );
  }

  int _calculatePairs(int level) {
    // Start with 2 pairs, increase gradually
    // Levels 1-5: 2-3 pairs
    // Levels 6-15: 4-6 pairs
    // Levels 16-30: 6-8 pairs
    // Levels 31-50: 8-10 pairs
    // Levels 51+: 10-15 pairs (max 20)
    
    if (level <= 5) return 2 + (level - 1) ~/ 2;
    if (level <= 15) return 3 + (level - 5) ~/ 2;
    if (level <= 30) return 6 + (level - 15) ~/ 4;
    if (level <= 50) return 8 + (level - 30) ~/ 5;
    return min(10 + (level - 50) ~/ 10, 20);
  }

  (int, int) _calculateGrid(int pairs) {
    final totalCards = pairs * 2;
    
    // Find best grid dimensions
    if (totalCards <= 4) return (2, 2);
    if (totalCards <= 6) return (3, 2);
    if (totalCards <= 8) return (4, 2);
    if (totalCards <= 12) return (4, 3);
    if (totalCards <= 16) return (4, 4);
    if (totalCards <= 20) return (5, 4);
    if (totalCards <= 24) return (6, 4);
    if (totalCards <= 30) return (6, 5);
    if (totalCards <= 36) return (6, 6);
    return (7, 6);
  }

  Duration _calculateTimeLimit(int level, int pairs) {
    // Base time: 10 seconds per pair, but decreases with level
    final baseTimePerPair = max(6, 15 - (level ~/ 20));
    final totalSeconds = pairs * baseTimePerPair + 10; // +10 buffer
    return Duration(seconds: totalSeconds);
  }

  DifficultyTier _getDifficulty(int level) {
    if (level <= 10) return DifficultyTier.beginner;
    if (level <= 25) return DifficultyTier.easy;
    if (level <= 50) return DifficultyTier.medium;
    if (level <= 100) return DifficultyTier.hard;
    return DifficultyTier.expert;
  }

  GameCardTheme _getThemeForLevel(int level) {
    // Pick a random unlocked theme
    final unlocked = themes.where((t) => t.unlocksAtLevel <= level).toList();
    if (unlocked.isEmpty) return themes.first;
    return unlocked[_random.nextInt(unlocked.length)];
  }

  StarThresholds _calculateStarThresholds(int pairs, Duration timeLimit) {
    final optimalMoves = pairs;
    return StarThresholds(
      oneStar: (optimalMoves * 3).ceil(),
      twoStar: (optimalMoves * 2).ceil(),
      threeStar: (optimalMoves * 1.3).ceil(),
      timeForThree: Duration(seconds: (timeLimit.inSeconds * 0.6).round()),
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
}
