import 'package:equatable/equatable.dart';
import '../../core/constants/app_constants.dart';

/// Player profile and progress data
class PlayerModel extends Equatable {
  final String id;
  final String name;
  final int coins;
  final int gems;
  final int xp;
  final int playerLevel;
  final int currentGameLevel;
  final int totalStars;
  final int totalGamesPlayed;
  final int perfectGames;
  final int longestStreak;
  final int currentDailyStreak;
  final DateTime? lastPlayedDate;
  final DateTime? lastDailyRewardClaim;
  final int dailyRewardDay;
  final List<String> unlockedThemes;
  final String equippedTheme;
  final Map<String, int> powerUpInventory;
  final int hintsRemaining;

  const PlayerModel({
    required this.id,
    this.name = 'Player',
    this.coins = AppConstants.startingCoins,
    this.gems = AppConstants.startingGems,
    this.xp = 0,
    this.playerLevel = 1,
    this.currentGameLevel = 1,
    this.totalStars = 0,
    this.totalGamesPlayed = 0,
    this.perfectGames = 0,
    this.longestStreak = 0,
    this.currentDailyStreak = 0,
    this.lastPlayedDate,
    this.lastDailyRewardClaim,
    this.dailyRewardDay = 0,
    this.unlockedThemes = const ['animals'],
    this.equippedTheme = 'animals',
    this.powerUpInventory = const {},
    this.hintsRemaining = 3,
  });

  int get xpForNextLevel => (100 * (1.15 * playerLevel)).round();
  double get levelProgress => xp / xpForNextLevel;

  bool canAffordCoins(int amount) => coins >= amount;
  bool canAffordGems(int amount) => gems >= amount;

  int getPowerUpCount(String powerUpId) => powerUpInventory[powerUpId] ?? 0;

  PlayerModel copyWith({
    String? id,
    String? name,
    int? coins,
    int? gems,
    int? xp,
    int? playerLevel,
    int? currentGameLevel,
    int? totalStars,
    int? totalGamesPlayed,
    int? perfectGames,
    int? longestStreak,
    int? currentDailyStreak,
    DateTime? lastPlayedDate,
    DateTime? lastDailyRewardClaim,
    int? dailyRewardDay,
    List<String>? unlockedThemes,
    String? equippedTheme,
    Map<String, int>? powerUpInventory,
    int? hintsRemaining,
  }) {
    return PlayerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      coins: coins ?? this.coins,
      gems: gems ?? this.gems,
      xp: xp ?? this.xp,
      playerLevel: playerLevel ?? this.playerLevel,
      currentGameLevel: currentGameLevel ?? this.currentGameLevel,
      totalStars: totalStars ?? this.totalStars,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      perfectGames: perfectGames ?? this.perfectGames,
      longestStreak: longestStreak ?? this.longestStreak,
      currentDailyStreak: currentDailyStreak ?? this.currentDailyStreak,
      lastPlayedDate: lastPlayedDate ?? this.lastPlayedDate,
      lastDailyRewardClaim: lastDailyRewardClaim ?? this.lastDailyRewardClaim,
      dailyRewardDay: dailyRewardDay ?? this.dailyRewardDay,
      unlockedThemes: unlockedThemes ?? this.unlockedThemes,
      equippedTheme: equippedTheme ?? this.equippedTheme,
      powerUpInventory: powerUpInventory ?? this.powerUpInventory,
      hintsRemaining: hintsRemaining ?? this.hintsRemaining,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'coins': coins,
    'gems': gems,
    'xp': xp,
    'playerLevel': playerLevel,
    'currentGameLevel': currentGameLevel,
    'totalStars': totalStars,
    'totalGamesPlayed': totalGamesPlayed,
    'perfectGames': perfectGames,
    'longestStreak': longestStreak,
    'currentDailyStreak': currentDailyStreak,
    'lastPlayedDate': lastPlayedDate?.toIso8601String(),
    'lastDailyRewardClaim': lastDailyRewardClaim?.toIso8601String(),
    'dailyRewardDay': dailyRewardDay,
    'unlockedThemes': unlockedThemes,
    'equippedTheme': equippedTheme,
    'powerUpInventory': powerUpInventory,
    'hintsRemaining': hintsRemaining,
  };

  factory PlayerModel.fromJson(Map<String, dynamic> json) => PlayerModel(
    id: json['id'] as String,
    name: json['name'] as String? ?? 'Player',
    coins: json['coins'] as int? ?? AppConstants.startingCoins,
    gems: json['gems'] as int? ?? AppConstants.startingGems,
    xp: json['xp'] as int? ?? 0,
    playerLevel: json['playerLevel'] as int? ?? 1,
    currentGameLevel: json['currentGameLevel'] as int? ?? 1,
    totalStars: json['totalStars'] as int? ?? 0,
    totalGamesPlayed: json['totalGamesPlayed'] as int? ?? 0,
    perfectGames: json['perfectGames'] as int? ?? 0,
    longestStreak: json['longestStreak'] as int? ?? 0,
    currentDailyStreak: json['currentDailyStreak'] as int? ?? 0,
    lastPlayedDate: json['lastPlayedDate'] != null
        ? DateTime.parse(json['lastPlayedDate'] as String)
        : null,
    lastDailyRewardClaim: json['lastDailyRewardClaim'] != null
        ? DateTime.parse(json['lastDailyRewardClaim'] as String)
        : null,
    dailyRewardDay: json['dailyRewardDay'] as int? ?? 0,
    unlockedThemes: json['unlockedThemes'] != null
        ? List<String>.from(json['unlockedThemes'] as List)
        : const ['animals'],
    equippedTheme: json['equippedTheme'] as String? ?? 'animals',
    powerUpInventory: json['powerUpInventory'] != null
        ? Map<String, int>.from(json['powerUpInventory'] as Map)
        : const {},
    hintsRemaining: json['hintsRemaining'] as int? ?? 3,
  );

  factory PlayerModel.newPlayer() {
    return PlayerModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      lastPlayedDate: DateTime.now(),
      // Give starting power-ups!
      powerUpInventory: const {
        'peek': AppConstants.startingPeekPowerUps,
        'freeze': AppConstants.startingFreezePowerUps,
        'hint': AppConstants.startingHintPowerUps,
        'magnet': AppConstants.startingMagnetPowerUps,
      },
    );
  }

  @override
  List<Object?> get props => [
    id, name, coins, gems, xp, playerLevel, currentGameLevel,
    totalStars, totalGamesPlayed, perfectGames, longestStreak,
    currentDailyStreak, unlockedThemes, equippedTheme, powerUpInventory,
  ];
}
