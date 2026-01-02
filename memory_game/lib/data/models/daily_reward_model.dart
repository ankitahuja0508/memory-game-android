import 'package:equatable/equatable.dart';
import 'achievement_model.dart';

class DailyReward extends Equatable {
  final int day;
  final List<Reward> rewards;
  final bool isSpecial;
  final bool isMilestone;

  const DailyReward({
    required this.day, 
    required this.rewards, 
    this.isSpecial = false,
    this.isMilestone = false,
  });

  @override
  List<Object?> get props => [day, rewards, isSpecial, isMilestone];
}

class DailyRewards {
  DailyRewards._();

  /// Extended daily rewards - goes beyond 7 days with increasing rewards
  /// Week 1: Base rewards
  /// Week 2+: Better rewards with milestone bonuses
  static DailyReward getRewardForDay(int day) {
    // Special milestone days
    if (day == 7) {
      return DailyReward(
        day: day,
        rewards: const [
          Reward.coins(500),
          Reward.gems(15),
          Reward.powerUp('magnet', 1),
        ],
        isSpecial: true,
        isMilestone: true,
      );
    } else if (day == 14) {
      return DailyReward(
        day: day,
        rewards: const [
          Reward.coins(1000),
          Reward.gems(25),
          Reward.powerUp('shield', 2),
          Reward.powerUp('double_coins', 1),
        ],
        isSpecial: true,
        isMilestone: true,
      );
    } else if (day == 21) {
      return DailyReward(
        day: day,
        rewards: const [
          Reward.coins(1500),
          Reward.gems(40),
          Reward.powerUp('magnet', 2),
          Reward.powerUp('freeze', 2),
        ],
        isSpecial: true,
        isMilestone: true,
      );
    } else if (day == 30) {
      return DailyReward(
        day: day,
        rewards: const [
          Reward.coins(2500),
          Reward.gems(75),
          Reward.powerUp('peek', 3),
          Reward.powerUp('hint', 3),
          Reward.powerUp('undo', 2),
        ],
        isSpecial: true,
        isMilestone: true,
      );
    } else if (day % 30 == 0) {
      // Monthly milestone (beyond day 30)
      final month = day ~/ 30;
      return DailyReward(
        day: day,
        rewards: [
          Reward.coins(2500 + (month * 500)),
          Reward.gems(75 + (month * 15)),
          const Reward.powerUp('magnet', 2),
          const Reward.powerUp('shield', 2),
        ],
        isSpecial: true,
        isMilestone: true,
      );
    }
    
    // Regular days based on cycle position
    final cycleDay = ((day - 1) % 7) + 1;
    final weekMultiplier = ((day - 1) ~/ 7) + 1;
    final bonusCoins = (weekMultiplier - 1) * 50; // +50 coins per week
    final bonusGems = (weekMultiplier - 1) ~/ 2; // +1 gem every 2 weeks
    
    switch (cycleDay) {
      case 1:
        return DailyReward(
          day: day,
          rewards: [Reward.coins(100 + bonusCoins)],
        );
      case 2:
        return DailyReward(
          day: day,
          rewards: [Reward.coins(150 + bonusCoins)],
        );
      case 3:
        return DailyReward(
          day: day,
          rewards: [
            Reward.coins(200 + bonusCoins),
            const Reward.powerUp('peek', 1),
          ],
          isSpecial: true,
        );
      case 4:
        return DailyReward(
          day: day,
          rewards: [Reward.coins(250 + bonusCoins)],
        );
      case 5:
        return DailyReward(
          day: day,
          rewards: [
            Reward.coins(300 + bonusCoins),
            const Reward.powerUp('freeze', 1),
            const Reward.powerUp('hint', 1),
          ],
          isSpecial: true,
        );
      case 6:
        return DailyReward(
          day: day,
          rewards: [
            Reward.coins(400 + bonusCoins),
            Reward.gems(5 + bonusGems),
          ],
        );
      case 7:
      default:
        return DailyReward(
          day: day,
          rewards: [
            Reward.coins(500 + bonusCoins),
            Reward.gems(15 + bonusGems),
            const Reward.powerUp('magnet', 1),
          ],
          isSpecial: true,
        );
    }
  }

  /// Get rewards for display in the week view (current week based on streak)
  static List<DailyReward> getWeekRewards(int currentStreak) {
    final startDay = currentStreak > 0 
        ? ((currentStreak - 1) ~/ 7) * 7 + 1 
        : 1;
    
    return List.generate(7, (index) => getRewardForDay(startDay + index));
  }
}

class DailyRewardStatus extends Equatable {
  final int currentStreak;
  final DateTime? lastClaimDate;
  final bool canClaimToday;

  const DailyRewardStatus({
    this.currentStreak = 0,
    this.lastClaimDate,
    this.canClaimToday = true,
  });

  /// The day number user is currently on (streak + 1 if can claim, or streak if claimed today)
  int get currentDay => canClaimToday ? currentStreak + 1 : currentStreak;

  DailyRewardStatus copyWith({
    int? currentStreak,
    DateTime? lastClaimDate,
    bool? canClaimToday,
  }) => DailyRewardStatus(
    currentStreak: currentStreak ?? this.currentStreak,
    lastClaimDate: lastClaimDate ?? this.lastClaimDate,
    canClaimToday: canClaimToday ?? this.canClaimToday,
  );

  Map<String, dynamic> toJson() => {
    'currentStreak': currentStreak,
    'lastClaimDate': lastClaimDate?.toIso8601String(),
    'canClaimToday': canClaimToday,
  };

  factory DailyRewardStatus.fromJson(Map<String, dynamic> json) => DailyRewardStatus(
    currentStreak: json['currentStreak'] as int? ?? 0,
    lastClaimDate: json['lastClaimDate'] != null ? DateTime.parse(json['lastClaimDate'] as String) : null,
    canClaimToday: json['canClaimToday'] as bool? ?? true,
  );

  @override
  List<Object?> get props => [currentStreak, lastClaimDate, canClaimToday];
}
