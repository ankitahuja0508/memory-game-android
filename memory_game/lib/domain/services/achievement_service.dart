import '../../data/models/models.dart';

class AchievementService {
  Map<String, AchievementProgress> _progress = {};

  void loadProgress(Map<String, AchievementProgress> progress) {
    _progress = Map.from(progress);
  }

  Map<String, AchievementProgress> get progress => _progress;

  List<String> checkAndUnlock({
    int? matchesMade,
    int? levelsCompleted,
    int? currentStreak,
    bool? perfectGame,
  }) {
    final newlyUnlocked = <String>[];

    for (final achievement in Achievements.all) {
      final current = _progress[achievement.id] ?? AchievementProgress(achievementId: achievement.id);
      if (current.isCompleted) continue;

      int newValue = current.currentValue;
      bool completed = false;

      switch (achievement.id) {
        case 'first_match':
          if (matchesMade != null && matchesMade >= 1) {
            completed = true;
          }
          break;
        case 'first_level':
          if (levelsCompleted != null && levelsCompleted >= 1) {
            completed = true;
          }
          break;
        case 'level_10':
        case 'level_25':
        case 'level_50':
        case 'level_100':
          if (levelsCompleted != null) {
            newValue = levelsCompleted;
            if (newValue >= achievement.targetValue) completed = true;
          }
          break;
        case 'perfect_game':
          if (perfectGame == true) {
            completed = true;
          }
          break;
        case 'streak_5':
          if (currentStreak != null && currentStreak >= achievement.targetValue) {
            completed = true;
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
