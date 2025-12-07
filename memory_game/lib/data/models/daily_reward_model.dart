import 'package:equatable/equatable.dart';
import 'achievement_model.dart';

class DailyReward extends Equatable {
  final int day;
  final List<Reward> rewards;
  final bool isSpecial;

  const DailyReward({required this.day, required this.rewards, this.isSpecial = false});

  @override
  List<Object?> get props => [day, rewards, isSpecial];
}

class DailyRewards {
  DailyRewards._();

  static const List<DailyReward> weekCycle = [
    DailyReward(day: 1, rewards: [Reward.coins(100)]),
    DailyReward(day: 2, rewards: [Reward.coins(150)]),
    DailyReward(day: 3, rewards: [Reward.coins(200), Reward.powerUp('peek', 1)], isSpecial: true),
    DailyReward(day: 4, rewards: [Reward.coins(250)]),
    DailyReward(day: 5, rewards: [Reward.coins(300), Reward.powerUp('freeze', 1), Reward.powerUp('hint', 1)], isSpecial: true),
    DailyReward(day: 6, rewards: [Reward.coins(400), Reward.gems(5)]),
    DailyReward(day: 7, rewards: [Reward.coins(500), Reward.gems(15), Reward.powerUp('magnet', 1)], isSpecial: true),
  ];

  static DailyReward getRewardForDay(int day) {
    final cycleDay = ((day - 1) % 7) + 1;
    return weekCycle.firstWhere((r) => r.day == cycleDay);
  }
}

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

  DailyRewardStatus copyWith({
    int? currentStreak,
    int? currentDay,
    DateTime? lastClaimDate,
    bool? canClaimToday,
  }) => DailyRewardStatus(
    currentStreak: currentStreak ?? this.currentStreak,
    currentDay: currentDay ?? this.currentDay,
    lastClaimDate: lastClaimDate ?? this.lastClaimDate,
    canClaimToday: canClaimToday ?? this.canClaimToday,
  );

  Map<String, dynamic> toJson() => {
    'currentStreak': currentStreak,
    'currentDay': currentDay,
    'lastClaimDate': lastClaimDate?.toIso8601String(),
    'canClaimToday': canClaimToday,
  };

  factory DailyRewardStatus.fromJson(Map<String, dynamic> json) => DailyRewardStatus(
    currentStreak: json['currentStreak'] as int? ?? 0,
    currentDay: json['currentDay'] as int? ?? 1,
    lastClaimDate: json['lastClaimDate'] != null ? DateTime.parse(json['lastClaimDate'] as String) : null,
    canClaimToday: json['canClaimToday'] as bool? ?? true,
  );

  @override
  List<Object?> get props => [currentStreak, currentDay, lastClaimDate, canClaimToday];
}
