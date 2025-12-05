import '../../data/models/models.dart';

/// Service for tracking and unlocking achievements
class AchievementService {
  Map<String, AchievementProgress> _progress = {};

  Map<String, AchievementProgress> get progress => _progress;

  /// Initialize with saved progress
  void init(Map<String, AchievementProgress> savedProgress) {
    _progress = Map.from(savedProgress);

    // Ensure all achievements have progress entries
    for (final achievement in Achievements.all) {
      if (!_progress.containsKey(achievement.id)) {
        _progress[achievement.id] = AchievementProgress(
          achievementId: achievement.id,
        );
      }
    }
  }

  /// Check and update achievements based on game event
  List<Achievement> checkAchievements({
    int? levelsCompleted,
    int? totalStars,
    int? currentStreak,
    int? totalMatches,
    int? perfectGames,
    int? dailyStreak,
    int? themesUnlocked,
    int? powerUpsUsed,
    bool? isPerfectGame,
    Duration? levelTime,
  }) {
    final newlyUnlocked = <Achievement>[];

    for (final achievement in Achievements.all) {
      final currentProgress = _progress[achievement.id];
      if (currentProgress == null || currentProgress.isCompleted) continue;

      int newValue = currentProgress.currentValue;
      bool shouldComplete = false;

      switch (achievement.id) {
        // Beginner achievements
        case 'first_match':
          if ((totalMatches ?? 0) >= 1) shouldComplete = true;
          break;
        case 'first_level':
          if ((levelsCompleted ?? 0) >= 1) shouldComplete = true;
          break;
        case 'level_10':
          newValue = levelsCompleted ?? 0;
          if (newValue >= 10) shouldComplete = true;
          break;

        // Skill achievements
        case 'perfect_game':
          if (isPerfectGame == true) shouldComplete = true;
          break;
        case 'speed_demon':
          if (levelTime != null && levelTime.inSeconds < 15) shouldComplete = true;
          break;
        case 'streak_5':
          newValue = currentStreak ?? 0;
          if (newValue >= 5) shouldComplete = true;
          break;
        case 'streak_10':
          newValue = currentStreak ?? 0;
          if (newValue >= 10) shouldComplete = true;
          break;
        case 'three_stars_10':
          // Track separately
          break;

        // Milestone achievements
        case 'level_25':
          newValue = levelsCompleted ?? 0;
          if (newValue >= 25) shouldComplete = true;
          break;
        case 'level_50':
          newValue = levelsCompleted ?? 0;
          if (newValue >= 50) shouldComplete = true;
          break;
        case 'level_100':
          newValue = levelsCompleted ?? 0;
          if (newValue >= 100) shouldComplete = true;
          break;
        case 'total_stars_100':
          newValue = totalStars ?? 0;
          if (newValue >= 100) shouldComplete = true;
          break;
        case 'matches_500':
          newValue = totalMatches ?? 0;
          if (newValue >= 500) shouldComplete = true;
          break;

        // Collection achievements
        case 'unlock_3_themes':
          newValue = themesUnlocked ?? 0;
          if (newValue >= 3) shouldComplete = true;
          break;

        // Special achievements
        case 'daily_streak_7':
          newValue = dailyStreak ?? 0;
          if (newValue >= 7) shouldComplete = true;
          break;
        case 'daily_streak_30':
          newValue = dailyStreak ?? 0;
          if (newValue >= 30) shouldComplete = true;
          break;
        case 'perfect_10':
          newValue = perfectGames ?? 0;
          if (newValue >= 10) shouldComplete = true;
          break;
      }

      // Update progress
      if (shouldComplete && !currentProgress.isCompleted) {
        _progress[achievement.id] = currentProgress.copyWith(
          currentValue: achievement.targetValue,
          isCompleted: true,
          completedAt: DateTime.now(),
        );
        newlyUnlocked.add(achievement);
      } else if (newValue > currentProgress.currentValue) {
        _progress[achievement.id] = currentProgress.copyWith(
          currentValue: newValue,
        );
      }
    }

    return newlyUnlocked;
  }

  /// Mark achievement reward as claimed
  void claimReward(String achievementId) {
    final current = _progress[achievementId];
    if (current != null && current.isCompleted && !current.isRewardClaimed) {
      _progress[achievementId] = current.copyWith(isRewardClaimed: true);
    }
  }

  /// Get unclaimed completed achievements
  List<Achievement> getUnclaimedAchievements() {
    return Achievements.all.where((a) {
      final progress = _progress[a.id];
      return progress != null && progress.isCompleted && !progress.isRewardClaimed;
    }).toList();
  }

  /// Get achievement progress percentage
  double getProgressPercentage(String achievementId) {
    final achievement = Achievements.getById(achievementId);
    final progress = _progress[achievementId];
    if (achievement == null || progress == null) return 0;
    return (progress.currentValue / achievement.targetValue).clamp(0.0, 1.0);
  }

  /// Get total completed count
  int get completedCount {
    return _progress.values.where((p) => p.isCompleted).length;
  }

  /// Get total achievement count
  int get totalCount => Achievements.all.length;
}
