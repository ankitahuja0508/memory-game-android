import 'package:equatable/equatable.dart';
import '../../data/models/models.dart';

class PlayerState extends Equatable {
  final PlayerModel player;
  final SettingsModel settings;
  final Map<int, LevelProgress> levelProgress;
  final Map<String, AchievementProgress> achievementProgress;
  final DailyRewardStatus dailyRewardStatus;
  final bool isLoading;

  const PlayerState({
    required this.player,
    this.settings = const SettingsModel(),
    this.levelProgress = const {},
    this.achievementProgress = const {},
    this.dailyRewardStatus = const DailyRewardStatus(),
    this.isLoading = true,
  });

  int get highestUnlockedLevel {
    if (levelProgress.isEmpty) return 1;
    final completed = levelProgress.values.where((p) => p.completed).map((p) => p.level).toList();
    if (completed.isEmpty) return 1;
    return completed.reduce((a, b) => a > b ? a : b) + 1;
  }

  int get totalStars {
    return levelProgress.values.fold(0, (sum, p) => sum + p.stars);
  }

  int get completedLevels {
    return levelProgress.values.where((p) => p.completed).length;
  }

  /// Count of achievements that are completed but rewards not claimed
  int get unclaimedAchievementCount {
    return achievementProgress.values
        .where((p) => p.isCompleted && !p.isRewardClaimed)
        .length;
  }

  /// Whether daily reward is available to claim
  bool get hasDailyRewardAvailable {
    return dailyRewardStatus.canClaimToday;
  }

  /// Check if a theme can be unlocked at current level
  bool canUnlockTheme(String themeId, int requiredLevel) {
    final isUnlocked = player.unlockedThemes.contains(themeId);
    return !isUnlocked && highestUnlockedLevel >= requiredLevel;
  }

  PlayerState copyWith({
    PlayerModel? player,
    SettingsModel? settings,
    Map<int, LevelProgress>? levelProgress,
    Map<String, AchievementProgress>? achievementProgress,
    DailyRewardStatus? dailyRewardStatus,
    bool? isLoading,
  }) {
    return PlayerState(
      player: player ?? this.player,
      settings: settings ?? this.settings,
      levelProgress: levelProgress ?? this.levelProgress,
      achievementProgress: achievementProgress ?? this.achievementProgress,
      dailyRewardStatus: dailyRewardStatus ?? this.dailyRewardStatus,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [player, settings, levelProgress, achievementProgress, dailyRewardStatus, isLoading];
}
