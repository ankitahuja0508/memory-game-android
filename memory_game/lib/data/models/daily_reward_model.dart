import 'package:equatable/equatable.dart';
import 'achievement_model.dart';

/// Daily reward configuration
class DailyReward extends Equatable {
  final int day;
  final List<Reward> rewards;
  final bool isSpecial;

  const DailyReward({
    required this.day,
    required this.rewards,
    this.isSpecial = false,
  });

  @override
  List<Object?> get props => [day, rewards, isSpecial];
}

/// 7-day reward cycle
class DailyRewards {
  DailyRewards._();

  static const List<DailyReward> weekCycle = [
    DailyReward(
      day: 1,
      rewards: [Reward.coins(50)],
    ),
    DailyReward(
      day: 2,
      rewards: [Reward.coins(75)],
    ),
    DailyReward(
      day: 3,
      rewards: [Reward.coins(100), Reward.powerUp('peek', 1)],
      isSpecial: true,
    ),
    DailyReward(
      day: 4,
      rewards: [Reward.coins(125)],
    ),
    DailyReward(
      day: 5,
      rewards: [Reward.coins(150), Reward.powerUp('freeze', 1)],
      isSpecial: true,
    ),
    DailyReward(
      day: 6,
      rewards: [Reward.coins(200)],
    ),
    DailyReward(
      day: 7,
      rewards: [Reward.coins(300), Reward.gems(10)],
      isSpecial: true,
    ),
  ];

  static DailyReward getRewardForDay(int day) {
    // Cycle through the week (1-7)
    final cycleDay = ((day - 1) % 7) + 1;
    return weekCycle.firstWhere((r) => r.day == cycleDay);
  }

  static int getTotalCoinsForStreak(int streak) {
    int total = 0;
    for (int i = 1; i <= streak && i <= 7; i++) {
      final reward = getRewardForDay(i);
      for (final r in reward.rewards) {
        if (r.type == RewardType.coins) {
          total += r.amount;
        }
      }
    }
    return total;
  }
}

/// Player's daily reward status
class DailyRewardStatus extends Equatable {
  final int currentStreak;
  final int currentDay;
  final DateTime? lastClaimDate;
  final bool canClaimToday;

  const DailyRewardStatus({
    this.currentStreak = 0,
    this.currentDay = 1,
    this.lastClaimDate,
    this.canClaimToday = true,
  });

  DailyReward get todayReward => DailyRewards.getRewardForDay(currentDay);

  DailyRewardStatus copyWith({
    int? currentStreak,
    int? currentDay,
    DateTime? lastClaimDate,
    bool? canClaimToday,
  }) {
    return DailyRewardStatus(
      currentStreak: currentStreak ?? this.currentStreak,
      currentDay: currentDay ?? this.currentDay,
      lastClaimDate: lastClaimDate ?? this.lastClaimDate,
      canClaimToday: canClaimToday ?? this.canClaimToday,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentStreak': currentStreak,
      'currentDay': currentDay,
      'lastClaimDate': lastClaimDate?.toIso8601String(),
      'canClaimToday': canClaimToday,
    };
  }

  factory DailyRewardStatus.fromJson(Map<String, dynamic> json) {
    return DailyRewardStatus(
      currentStreak: json['currentStreak'] as int? ?? 0,
      currentDay: json['currentDay'] as int? ?? 1,
      lastClaimDate: json['lastClaimDate'] != null
          ? DateTime.parse(json['lastClaimDate'] as String)
          : null,
      canClaimToday: json['canClaimToday'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [currentStreak, currentDay, lastClaimDate, canClaimToday];
}
