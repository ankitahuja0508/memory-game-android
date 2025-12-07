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
    // Beginner Achievements
    Achievement(id: 'first_match', title: 'First Match!', description: 'Match your first pair', icon: '🎉', category: AchievementCategory.beginner, rewards: [Reward.coins(25)]),
    Achievement(id: 'first_level', title: 'Getting Started', description: 'Complete your first level', icon: '🌟', category: AchievementCategory.beginner, rewards: [Reward.coins(50)]),
    Achievement(id: 'level_5', title: 'Warming Up', description: 'Complete 5 levels', icon: '🎯', category: AchievementCategory.beginner, rewards: [Reward.coins(75)], targetValue: 5),
    Achievement(id: 'level_10', title: 'On A Roll', description: 'Complete 10 levels', icon: '🔥', category: AchievementCategory.beginner, rewards: [Reward.coins(150)], targetValue: 10),
    
    // Skill Achievements
    Achievement(id: 'perfect_game', title: 'Perfect Memory', description: 'Complete a level with no mistakes', icon: '🧠', category: AchievementCategory.skill, rewards: [Reward.gems(5)]),
    Achievement(id: 'perfect_5', title: 'Memory Master', description: 'Complete 5 perfect games', icon: '🎓', category: AchievementCategory.skill, rewards: [Reward.gems(15)], targetValue: 5),
    Achievement(id: 'perfect_10', title: 'Flawless Mind', description: 'Complete 10 perfect games', icon: '💎', category: AchievementCategory.skill, rewards: [Reward.gems(30)], targetValue: 10),
    Achievement(id: 'streak_5', title: 'Hot Streak', description: 'Match 5 pairs in a row', icon: '🔥', category: AchievementCategory.skill, rewards: [Reward.coins(100)], targetValue: 5),
    Achievement(id: 'streak_10', title: 'On Fire!', description: 'Match 10 pairs in a row', icon: '💥', category: AchievementCategory.skill, rewards: [Reward.gems(10)], targetValue: 10),
    Achievement(id: 'streak_15', title: 'Unstoppable', description: 'Match 15 pairs in a row', icon: '⚡', category: AchievementCategory.skill, rewards: [Reward.gems(25)], targetValue: 15),
    Achievement(id: 'speed_demon', title: 'Speed Demon', description: 'Complete a level in under 15 seconds', icon: '⏱️', category: AchievementCategory.skill, rewards: [Reward.coins(200)]),
    Achievement(id: 'lightning_fast', title: 'Lightning Fast', description: 'Complete a level in under 10 seconds', icon: '⚡', category: AchievementCategory.skill, rewards: [Reward.gems(15)]),
    Achievement(id: 'boss_slayer', title: 'Boss Slayer', description: 'Complete a boss level', icon: '👹', category: AchievementCategory.skill, rewards: [Reward.coins(300)]),
    Achievement(id: 'boss_master', title: 'Boss Master', description: 'Complete 5 boss levels', icon: '🐉', category: AchievementCategory.skill, rewards: [Reward.gems(20)], targetValue: 5),
    
    // Milestone Achievements
    Achievement(id: 'level_25', title: 'Quarter Century', description: 'Complete 25 levels', icon: '🏅', category: AchievementCategory.milestone, rewards: [Reward.gems(20)], targetValue: 25),
    Achievement(id: 'level_50', title: 'Half Century', description: 'Complete 50 levels', icon: '🎖️', category: AchievementCategory.milestone, rewards: [Reward.gems(35)], targetValue: 50),
    Achievement(id: 'level_75', title: 'Diamond Player', description: 'Complete 75 levels', icon: '💎', category: AchievementCategory.milestone, rewards: [Reward.gems(45)], targetValue: 75),
    Achievement(id: 'level_100', title: 'Centurion', description: 'Complete 100 levels', icon: '🏆', category: AchievementCategory.milestone, rewards: [Reward.gems(60)], targetValue: 100),
    Achievement(id: 'level_150', title: 'Memory Legend', description: 'Complete 150 levels', icon: '👑', category: AchievementCategory.milestone, rewards: [Reward.gems(80)], targetValue: 150),
    Achievement(id: 'level_200', title: 'Grand Master', description: 'Complete 200 levels', icon: '🌟', category: AchievementCategory.milestone, rewards: [Reward.gems(100)], targetValue: 200),
    Achievement(id: 'stars_50', title: 'Star Collector', description: 'Earn 50 total stars', icon: '⭐', category: AchievementCategory.milestone, rewards: [Reward.coins(200)], targetValue: 50),
    Achievement(id: 'stars_100', title: 'Star Hunter', description: 'Earn 100 total stars', icon: '🌟', category: AchievementCategory.milestone, rewards: [Reward.gems(15)], targetValue: 100),
    Achievement(id: 'stars_250', title: 'Stargazer', description: 'Earn 250 total stars', icon: '✨', category: AchievementCategory.milestone, rewards: [Reward.gems(40)], targetValue: 250),
    Achievement(id: 'stars_500', title: 'Constellation', description: 'Earn 500 total stars', icon: '🌌', category: AchievementCategory.milestone, rewards: [Reward.gems(75)], targetValue: 500),
    
    // Special Achievements
    Achievement(id: 'theme_collector_2', title: 'Theme Explorer', description: 'Unlock 2 themes', icon: '🎨', category: AchievementCategory.special, rewards: [Reward.coins(150)], targetValue: 2),
    Achievement(id: 'theme_collector_4', title: 'Theme Hunter', description: 'Unlock 4 themes', icon: '🖼️', category: AchievementCategory.special, rewards: [Reward.gems(20)], targetValue: 4),
    Achievement(id: 'theme_collector_all', title: 'Theme Master', description: 'Unlock all themes', icon: '🏛️', category: AchievementCategory.special, rewards: [Reward.gems(50)], targetValue: 8),
    Achievement(id: 'daily_streak_3', title: 'Daily Player', description: 'Login 3 days in a row', icon: '📅', category: AchievementCategory.special, rewards: [Reward.coins(150)], targetValue: 3),
    Achievement(id: 'daily_streak_7', title: 'Weekly Warrior', description: 'Login 7 days in a row', icon: '📆', category: AchievementCategory.special, rewards: [Reward.gems(25)], targetValue: 7),
    Achievement(id: 'daily_streak_14', title: 'Dedicated Player', description: 'Login 14 days in a row', icon: '🗓️', category: AchievementCategory.special, rewards: [Reward.gems(50)], targetValue: 14),
    Achievement(id: 'daily_streak_30', title: 'Memory Addict', description: 'Login 30 days in a row', icon: '🎊', category: AchievementCategory.special, rewards: [Reward.gems(100)], targetValue: 30),
    Achievement(id: 'coins_1000', title: 'Coin Hoarder', description: 'Earn 1,000 total coins', icon: '💰', category: AchievementCategory.special, rewards: [Reward.gems(10)], targetValue: 1000),
    Achievement(id: 'coins_5000', title: 'Wealthy Player', description: 'Earn 5,000 total coins', icon: '💵', category: AchievementCategory.special, rewards: [Reward.gems(30)], targetValue: 5000),
    Achievement(id: 'coins_10000', title: 'Coin Tycoon', description: 'Earn 10,000 total coins', icon: '💎', category: AchievementCategory.special, rewards: [Reward.gems(50)], targetValue: 10000),
    Achievement(id: 'powerup_5', title: 'Power User', description: 'Use 5 power-ups', icon: '⚡', category: AchievementCategory.special, rewards: [Reward.coins(100)], targetValue: 5),
    Achievement(id: 'powerup_25', title: 'Power Addict', description: 'Use 25 power-ups', icon: '🔋', category: AchievementCategory.special, rewards: [Reward.gems(15)], targetValue: 25),
    Achievement(id: 'powerup_50', title: 'Power Master', description: 'Use 50 power-ups', icon: '🚀', category: AchievementCategory.special, rewards: [Reward.gems(35)], targetValue: 50),
    Achievement(id: 'three_star_10', title: '3-Star Beginner', description: 'Get 3 stars on 10 levels', icon: '⭐', category: AchievementCategory.special, rewards: [Reward.coins(250)], targetValue: 10),
    Achievement(id: 'three_star_25', title: '3-Star Expert', description: 'Get 3 stars on 25 levels', icon: '🌟', category: AchievementCategory.special, rewards: [Reward.gems(25)], targetValue: 25),
    Achievement(id: 'three_star_50', title: '3-Star Master', description: 'Get 3 stars on 50 levels', icon: '✨', category: AchievementCategory.special, rewards: [Reward.gems(50)], targetValue: 50),
    Achievement(id: 'matches_100', title: 'Match Maker', description: 'Make 100 matches', icon: '🎴', category: AchievementCategory.special, rewards: [Reward.coins(100)], targetValue: 100),
    Achievement(id: 'matches_500', title: 'Match Expert', description: 'Make 500 matches', icon: '🃏', category: AchievementCategory.special, rewards: [Reward.gems(15)], targetValue: 500),
    Achievement(id: 'matches_1000', title: 'Match Legend', description: 'Make 1,000 matches', icon: '🏆', category: AchievementCategory.special, rewards: [Reward.gems(40)], targetValue: 1000),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
