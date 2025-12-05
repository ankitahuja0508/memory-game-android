import 'package:equatable/equatable.dart';

/// Achievement category
enum AchievementCategory {
  beginner,
  skill,
  collection,
  milestone,
  special,
}

/// Reward type for achievements
enum RewardType {
  coins,
  gems,
  powerUp,
  theme,
  cardBack,
}

/// Reward data
class Reward extends Equatable {
  final RewardType type;
  final int amount;
  final String? itemId;

  const Reward({
    required this.type,
    this.amount = 0,
    this.itemId,
  });

  const Reward.coins(int coins)
      : type = RewardType.coins,
        amount = coins,
        itemId = null;

  const Reward.gems(int gems)
      : type = RewardType.gems,
        amount = gems,
        itemId = null;

  const Reward.powerUp(String id, [int count = 1])
      : type = RewardType.powerUp,
        amount = count,
        itemId = id;

  const Reward.theme(String id)
      : type = RewardType.theme,
        amount = 1,
        itemId = id;

  String get displayText {
    switch (type) {
      case RewardType.coins:
        return '+$amount 💰';
      case RewardType.gems:
        return '+$amount 💎';
      case RewardType.powerUp:
        return '+$amount $itemId';
      case RewardType.theme:
        return 'Theme: $itemId';
      case RewardType.cardBack:
        return 'Card Back: $itemId';
    }
  }

  @override
  List<Object?> get props => [type, amount, itemId];

  Map<String, dynamic> toJson() {
    return {
      'type': type.index,
      'amount': amount,
      'itemId': itemId,
    };
  }

  factory Reward.fromJson(Map<String, dynamic> json) {
    return Reward(
      type: RewardType.values[json['type'] as int],
      amount: json['amount'] as int? ?? 0,
      itemId: json['itemId'] as String?,
    );
  }
}

/// Achievement definition
class Achievement extends Equatable {
  final String id;
  final String title;
  final String description;
  final String icon;
  final AchievementCategory category;
  final List<Reward> rewards;
  final int targetValue;
  final bool isSecret;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
    required this.rewards,
    this.targetValue = 1,
    this.isSecret = false,
  });

  @override
  List<Object?> get props => [id, title, category, targetValue];
}

/// Player's achievement progress
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

  double get progressPercent {
    return currentValue.toDouble();
  }

  AchievementProgress copyWith({
    String? achievementId,
    int? currentValue,
    bool? isCompleted,
    bool? isRewardClaimed,
    DateTime? completedAt,
  }) {
    return AchievementProgress(
      achievementId: achievementId ?? this.achievementId,
      currentValue: currentValue ?? this.currentValue,
      isCompleted: isCompleted ?? this.isCompleted,
      isRewardClaimed: isRewardClaimed ?? this.isRewardClaimed,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'achievementId': achievementId,
      'currentValue': currentValue,
      'isCompleted': isCompleted,
      'isRewardClaimed': isRewardClaimed,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory AchievementProgress.fromJson(Map<String, dynamic> json) {
    return AchievementProgress(
      achievementId: json['achievementId'] as String,
      currentValue: json['currentValue'] as int? ?? 0,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isRewardClaimed: json['isRewardClaimed'] as bool? ?? false,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
        achievementId,
        currentValue,
        isCompleted,
        isRewardClaimed,
        completedAt,
      ];
}

/// Predefined achievements
class Achievements {
  Achievements._();

  static const List<Achievement> all = [
    // Beginner achievements
    Achievement(
      id: 'first_match',
      title: 'First Match!',
      description: 'Match your first pair of cards',
      icon: '🎉',
      category: AchievementCategory.beginner,
      rewards: [Reward.coins(10)],
    ),
    Achievement(
      id: 'first_level',
      title: 'Getting Started',
      description: 'Complete your first level',
      icon: '🌟',
      category: AchievementCategory.beginner,
      rewards: [Reward.coins(25)],
    ),
    Achievement(
      id: 'level_10',
      title: 'On A Roll',
      description: 'Complete 10 levels',
      icon: '🔥',
      category: AchievementCategory.beginner,
      rewards: [Reward.coins(100)],
      targetValue: 10,
    ),

    // Skill achievements
    Achievement(
      id: 'perfect_game',
      title: 'Perfect Memory',
      description: 'Complete a level with no mistakes',
      icon: '🧠',
      category: AchievementCategory.skill,
      rewards: [Reward.gems(5)],
    ),
    Achievement(
      id: 'speed_demon',
      title: 'Speed Demon',
      description: 'Complete a level in under 15 seconds',
      icon: '⚡',
      category: AchievementCategory.skill,
      rewards: [Reward.coins(200)],
    ),
    Achievement(
      id: 'streak_5',
      title: 'Hot Streak',
      description: 'Match 5 pairs in a row',
      icon: '🔥',
      category: AchievementCategory.skill,
      rewards: [Reward.coins(50)],
      targetValue: 5,
    ),
    Achievement(
      id: 'streak_10',
      title: 'On Fire!',
      description: 'Match 10 pairs in a row',
      icon: '💫',
      category: AchievementCategory.skill,
      rewards: [Reward.gems(10)],
      targetValue: 10,
    ),
    Achievement(
      id: 'three_stars_10',
      title: 'Star Collector',
      description: 'Earn 3 stars on 10 levels',
      icon: '⭐',
      category: AchievementCategory.skill,
      rewards: [Reward.coins(150)],
      targetValue: 10,
    ),

    // Milestone achievements
    Achievement(
      id: 'level_25',
      title: 'Quarter Century',
      description: 'Complete 25 levels',
      icon: '🏅',
      category: AchievementCategory.milestone,
      rewards: [Reward.gems(15)],
      targetValue: 25,
    ),
    Achievement(
      id: 'level_50',
      title: 'Half Century',
      description: 'Complete 50 levels',
      icon: '🎖️',
      category: AchievementCategory.milestone,
      rewards: [Reward.gems(25)],
      targetValue: 50,
    ),
    Achievement(
      id: 'level_100',
      title: 'Centurion',
      description: 'Complete 100 levels',
      icon: '🏆',
      category: AchievementCategory.milestone,
      rewards: [Reward.gems(50), Reward.theme('golden')],
      targetValue: 100,
    ),
    Achievement(
      id: 'total_stars_100',
      title: 'Stellar',
      description: 'Earn 100 total stars',
      icon: '🌠',
      category: AchievementCategory.milestone,
      rewards: [Reward.coins(500)],
      targetValue: 100,
    ),
    Achievement(
      id: 'matches_500',
      title: 'Match Master',
      description: 'Match 500 pairs total',
      icon: '🎯',
      category: AchievementCategory.milestone,
      rewards: [Reward.gems(20)],
      targetValue: 500,
    ),

    // Collection achievements
    Achievement(
      id: 'unlock_3_themes',
      title: 'Theme Enthusiast',
      description: 'Unlock 3 different themes',
      icon: '🎨',
      category: AchievementCategory.collection,
      rewards: [Reward.coins(100)],
      targetValue: 3,
    ),
    Achievement(
      id: 'all_powerups',
      title: 'Power Player',
      description: 'Use each power-up at least once',
      icon: '⚡',
      category: AchievementCategory.collection,
      rewards: [Reward.gems(15)],
      targetValue: 5,
    ),

    // Daily achievements
    Achievement(
      id: 'daily_streak_7',
      title: 'Weekly Warrior',
      description: 'Login 7 days in a row',
      icon: '📅',
      category: AchievementCategory.special,
      rewards: [Reward.gems(20)],
      targetValue: 7,
    ),
    Achievement(
      id: 'daily_streak_30',
      title: 'Monthly Master',
      description: 'Login 30 days in a row',
      icon: '🗓️',
      category: AchievementCategory.special,
      rewards: [Reward.gems(100), Reward.theme('exclusive')],
      targetValue: 30,
    ),

    // Special achievements
    Achievement(
      id: 'perfect_10',
      title: 'Perfectionist',
      description: 'Complete 10 levels with no mistakes',
      icon: '💎',
      category: AchievementCategory.special,
      rewards: [Reward.gems(30)],
      targetValue: 10,
    ),
  ];

  static Achievement? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }
}
