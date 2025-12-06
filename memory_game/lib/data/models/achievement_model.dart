import 'package:equatable/equatable.dart';

enum AchievementCategory { beginner, skill, milestone, special }
enum RewardType { coins, gems, powerUp, theme }

class Reward extends Equatable {
  final RewardType type;
  final int amount;
  final String? itemId;

  const Reward({required this.type, this.amount = 0, this.itemId});

  const Reward.coins(int coins) : type = RewardType.coins, amount = coins, itemId = null;
  const Reward.gems(int gems) : type = RewardType.gems, amount = gems, itemId = null;
  const Reward.powerUp(String id, [int count = 1]) : type = RewardType.powerUp, amount = count, itemId = id;
  const Reward.theme(String id) : type = RewardType.theme, amount = 1, itemId = id;

  String get displayText {
    switch (type) {
      case RewardType.coins: return '+$amount 💰';
      case RewardType.gems: return '+$amount 💎';
      case RewardType.powerUp: return '+$amount $itemId';
      case RewardType.theme: return 'Theme: $itemId';
    }
  }

  @override
  List<Object?> get props => [type, amount, itemId];
}

class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementCategory category;
  final List<Reward> rewards;
  final int targetValue;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.rewards,
    this.targetValue = 1,
  });

  @override
  List<Object?> get props => [id, title, category, targetValue];
}

class AchievementProgress extends Equatable {
  final String achievementId;
  final int currentValue;
  final bool isCompleted;
  final bool isRewardClaimed;
  final DateTime? completedAt;

  const AchievementProgress({
    required this.achievementId,
    this.currentValue = 0,
    this.isCompleted = false,
    this.isRewardClaimed = false,
    this.completedAt,
  });

  AchievementProgress copyWith({
    String? achievementId,
    int? currentValue,
    bool? isCompleted,
    bool? isRewardClaimed,
    DateTime? completedAt,
  }) => AchievementProgress(
    achievementId: achievementId ?? this.achievementId,
    currentValue: currentValue ?? this.currentValue,
    isCompleted: isCompleted ?? this.isCompleted,
    isRewardClaimed: isRewardClaimed ?? this.isRewardClaimed,
    completedAt: completedAt ?? this.completedAt,
  );

  Map<String, dynamic> toJson() => {
    'achievementId': achievementId,
    'currentValue': currentValue,
    'isCompleted': isCompleted,
    'isRewardClaimed': isRewardClaimed,
    'completedAt': completedAt?.toIso8601String(),
  };

  factory AchievementProgress.fromJson(Map<String, dynamic> json) => AchievementProgress(
    achievementId: json['achievementId'] as String,
    currentValue: json['currentValue'] as int? ?? 0,
    isCompleted: json['isCompleted'] as bool? ?? false,
    isRewardClaimed: json['isRewardClaimed'] as bool? ?? false,
    completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
  );

  @override
  List<Object?> get props => [achievementId, currentValue, isCompleted, isRewardClaimed];
}

class Achievements {
  Achievements._();

  static const List<Achievement> all = [
    Achievement(id: 'first_match', title: 'First Match!', description: 'Match your first pair', icon: '🎉', category: AchievementCategory.beginner, rewards: [Reward.coins(10)]),
    Achievement(id: 'first_level', title: 'Getting Started', description: 'Complete your first level', icon: '🌟', category: AchievementCategory.beginner, rewards: [Reward.coins(25)]),
    Achievement(id: 'level_10', title: 'On A Roll', description: 'Complete 10 levels', icon: '🔥', category: AchievementCategory.beginner, rewards: [Reward.coins(100)], targetValue: 10),
    Achievement(id: 'perfect_game', title: 'Perfect Memory', description: 'Complete a level with no mistakes', icon: '🧠', category: AchievementCategory.skill, rewards: [Reward.gems(5)]),
    Achievement(id: 'streak_5', title: 'Hot Streak', description: 'Match 5 pairs in a row', icon: '🔥', category: AchievementCategory.skill, rewards: [Reward.coins(50)], targetValue: 5),
    Achievement(id: 'level_25', title: 'Quarter Century', description: 'Complete 25 levels', icon: '🏅', category: AchievementCategory.milestone, rewards: [Reward.gems(15)], targetValue: 25),
    Achievement(id: 'level_50', title: 'Half Century', description: 'Complete 50 levels', icon: '🎖️', category: AchievementCategory.milestone, rewards: [Reward.gems(25)], targetValue: 50),
    Achievement(id: 'level_100', title: 'Centurion', description: 'Complete 100 levels', icon: '🏆', category: AchievementCategory.milestone, rewards: [Reward.gems(50)], targetValue: 100),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
