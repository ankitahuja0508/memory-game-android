import '../../data/models/models.dart';

class AchievementService {
  Map<String, AchievementProgress> _progress = {};

  void loadProgress(Map<String, AchievementProgress> progress) {
    _progress = Map.from(progress);
  }

  /// Returns a copy of the progress map to ensure Bloc detects state changes
  Map<String, AchievementProgress> get progress => Map.from(_progress);

  List<String> checkAndUnlock({
    int? matchesMade,
    int? levelsCompleted,
    int? currentStreak,
    bool? perfectGame,
    int? perfectGamesCount,
    int? totalStars,
    int? themesUnlocked,
    int? dailyStreak,
    int? totalCoinsEarned,
    int? powerUpsUsed,
    int? threeStarLevels,
    int? totalMatches,
    int? bossLevelsCompleted,
    int? fastestLevelSeconds,
  }) {
    final newlyUnlocked = <String>[];

    for (final achievement in Achievements.all) {
      final current = _progress[achievement.id] ?? AchievementProgress(achievementId: achievement.id);
      if (current.isCompleted) continue;

      int newValue = current.currentValue;
      bool completed = false;

      switch (achievement.id) {
        // Beginner achievements
        case 'first_match':
          if (matchesMade != null && matchesMade >= 1) completed = true;
          break;
        case 'first_level':
          if (levelsCompleted != null && levelsCompleted >= 1) completed = true;
          break;
        case 'level_5':
        case 'level_10':
        case 'level_25':
        case 'level_50':
        case 'level_75':
        case 'level_100':
        case 'level_150':
        case 'level_200':
          if (levelsCompleted != null) {
            newValue = levelsCompleted;
            if (newValue >= achievement.targetValue) completed = true;
          }
          break;
          
        // Skill achievements
        case 'perfect_game':
          if (perfectGame == true) completed = true;
          break;
        case 'perfect_5':
        case 'perfect_10':
          if (perfectGamesCount != null) {
            newValue = perfectGamesCount;
            if (newValue >= achievement.targetValue) completed = true;
          }
          break;
        case 'streak_5':
        case 'streak_10':
        case 'streak_15':
          if (currentStreak != null) {
            newValue = currentStreak;
            if (newValue >= achievement.targetValue) completed = true;
          }
          break;
        case 'speed_demon':
          if (fastestLevelSeconds != null && fastestLevelSeconds <= 15) completed = true;
          break;
        case 'lightning_fast':
          if (fastestLevelSeconds != null && fastestLevelSeconds <= 10) completed = true;
          break;
        case 'boss_slayer':
          if (bossLevelsCompleted != null && bossLevelsCompleted >= 1) completed = true;
          break;
        case 'boss_master':
          if (bossLevelsCompleted != null) {
            newValue = bossLevelsCompleted;
            if (newValue >= achievement.targetValue) completed = true;
          }
          break;
          
        // Milestone achievements
        case 'stars_50':
        case 'stars_100':
        case 'stars_250':
        case 'stars_500':
          if (totalStars != null) {
            newValue = totalStars;
            if (newValue >= achievement.targetValue) completed = true;
          }
          break;
          
        // Special achievements
        case 'theme_collector_2':
        case 'theme_collector_4':
        case 'theme_collector_all':
          if (themesUnlocked != null) {
            newValue = themesUnlocked;
            if (newValue >= achievement.targetValue) completed = true;
          }
          break;
        case 'daily_streak_3':
        case 'daily_streak_7':
        case 'daily_streak_14':
        case 'daily_streak_30':
          if (dailyStreak != null) {
            newValue = dailyStreak;
            if (newValue >= achievement.targetValue) completed = true;
          }
          break;
        case 'coins_1000':
        case 'coins_5000':
        case 'coins_10000':
          if (totalCoinsEarned != null) {
            newValue = totalCoinsEarned;
            if (newValue >= achievement.targetValue) completed = true;
          }
          break;
        case 'powerup_5':
        case 'powerup_25':
        case 'powerup_50':
          if (powerUpsUsed != null) {
            newValue = powerUpsUsed;
            if (newValue >= achievement.targetValue) completed = true;
          }
          break;
        case 'three_star_10':
        case 'three_star_25':
        case 'three_star_50':
          if (threeStarLevels != null) {
            newValue = threeStarLevels;
            if (newValue >= achievement.targetValue) completed = true;
          }
          break;
        case 'matches_100':
        case 'matches_500':
        case 'matches_1000':
          if (totalMatches != null) {
            newValue = totalMatches;
            if (newValue >= achievement.targetValue) completed = true;
          }
          break;
      }

      if (completed || newValue > current.currentValue) {
        _progress[achievement.id] = current.copyWith(
          currentValue: newValue,
          isCompleted: completed,
          completedAt: completed ? DateTime.now() : null,
        );
        if (completed) newlyUnlocked.add(achievement.id);
      }
    }

    return newlyUnlocked;
  }

  void claimReward(String achievementId) {
    final current = _progress[achievementId];
    if (current != null && current.isCompleted && !current.isRewardClaimed) {
      _progress[achievementId] = current.copyWith(isRewardClaimed: true);
    }
  }
}
