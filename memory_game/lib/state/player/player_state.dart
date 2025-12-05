import 'package:equatable/equatable.dart';
import '../../data/models/models.dart';

/// State for player data
class PlayerState extends Equatable {
  final PlayerModel player;
  final Map<int, LevelProgress> levelProgress;
  final SettingsModel settings;
  final DailyRewardStatus dailyRewardStatus;
  final Map<String, AchievementProgress> achievementProgress;
  final bool isLoading;
  final String? error;

  const PlayerState({
    required this.player,
    this.levelProgress = const {},
    this.settings = const SettingsModel(),
    this.dailyRewardStatus = const DailyRewardStatus(),
    this.achievementProgress = const {},
    this.isLoading = false,
    this.error,
  });

  /// Get highest unlocked level
  int get highestUnlockedLevel {
    if (levelProgress.isEmpty) return 1;
    final completed = levelProgress.entries
        .where((e) => e.value.completed)
        .map((e) => e.key)
        .toList();
    if (completed.isEmpty) return 1;
    return completed.reduce((a, b) => a > b ? a : b) + 1;
  }

  /// Get total stars earned
  int get totalStars {
    return levelProgress.values.fold(0, (sum, p) => sum + p.stars);
  }

  /// Get completed levels count
  int get completedLevelsCount {
    return levelProgress.values.where((p) => p.completed).length;
  }

  /// Check if a level is unlocked
  bool isLevelUnlocked(int level) {
    if (level == 1) return true;
    final previousProgress = levelProgress[level - 1];
    return previousProgress?.completed ?? false;
  }

  /// Get progress for a level
  LevelProgress? getLevelProgress(int level) => levelProgress[level];

  PlayerState copyWith({
    PlayerModel? player,
    Map<int, LevelProgress>? levelProgress,
    SettingsModel? settings,
    DailyRewardStatus? dailyRewardStatus,
    Map<String, AchievementProgress>? achievementProgress,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PlayerState(
      player: player ?? this.player,
      levelProgress: levelProgress ?? this.levelProgress,
      settings: settings ?? this.settings,
      dailyRewardStatus: dailyRewardStatus ?? this.dailyRewardStatus,
      achievementProgress: achievementProgress ?? this.achievementProgress,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  List<Object?> get props => [
        player,
        levelProgress,
        settings,
        dailyRewardStatus,
        achievementProgress,
        isLoading,
        error,
      ];
}
