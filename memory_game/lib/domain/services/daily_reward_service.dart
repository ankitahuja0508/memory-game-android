import '../../data/models/models.dart';

/// Service for managing daily rewards
class DailyRewardService {
  DailyRewardStatus _status = const DailyRewardStatus();

  DailyRewardStatus get status => _status;

  /// Initialize with saved status
  void init(DailyRewardStatus savedStatus) {
    _status = savedStatus;
    _checkAndUpdateStreak();
  }

  /// Check if streak should be reset or if reward is claimable
  void _checkAndUpdateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_status.lastClaimDate == null) {
      // First time player
      _status = const DailyRewardStatus(
        currentStreak: 0,
        currentDay: 1,
        canClaimToday: true,
      );
      return;
    }

    final lastClaim = _status.lastClaimDate!;
    final lastClaimDay = DateTime(lastClaim.year, lastClaim.month, lastClaim.day);
    final difference = today.difference(lastClaimDay).inDays;

    if (difference == 0) {
      // Already claimed today
      _status = _status.copyWith(canClaimToday: false);
    } else if (difference == 1) {
      // Consecutive day - can claim
      _status = _status.copyWith(canClaimToday: true);
    } else {
      // Streak broken - reset
      _status = DailyRewardStatus(
        currentStreak: 0,
        currentDay: 1,
        canClaimToday: true,
        lastClaimDate: _status.lastClaimDate,
      );
    }
  }

  /// Claim daily reward
  DailyReward? claimReward() {
    if (!_status.canClaimToday) return null;

    final reward = DailyRewards.getRewardForDay(_status.currentDay);
    final now = DateTime.now();

    // Update status
    final newDay = (_status.currentDay % 7) + 1;
    _status = DailyRewardStatus(
      currentStreak: _status.currentStreak + 1,
      currentDay: newDay,
      lastClaimDate: now,
      canClaimToday: false,
    );

    return reward;
  }

  /// Get current day's reward (without claiming)
  DailyReward getTodayReward() {
    return DailyRewards.getRewardForDay(_status.currentDay);
  }

  /// Get all 7 days with claim status
  List<DailyRewardDay> getWeekRewards() {
    final rewards = <DailyRewardDay>[];
    final currentCycleDay = _status.currentDay;

    for (int i = 1; i <= 7; i++) {
      final reward = DailyRewards.getRewardForDay(i);
      DailyRewardDayStatus status;

      if (i < currentCycleDay) {
        status = DailyRewardDayStatus.claimed;
      } else if (i == currentCycleDay && _status.canClaimToday) {
        status = DailyRewardDayStatus.available;
      } else if (i == currentCycleDay && !_status.canClaimToday) {
        status = DailyRewardDayStatus.claimed;
      } else {
        status = DailyRewardDayStatus.locked;
      }

      rewards.add(DailyRewardDay(
        day: i,
        reward: reward,
        status: status,
      ));
    }

    return rewards;
  }

  /// Check if any reward is claimable
  bool get canClaim => _status.canClaimToday;

  /// Get current streak
  int get currentStreak => _status.currentStreak;
}

/// Status for a day in the reward cycle
enum DailyRewardDayStatus {
  claimed,
  available,
  locked,
}

/// Day info for UI
class DailyRewardDay {
  final int day;
  final DailyReward reward;
  final DailyRewardDayStatus status;

  const DailyRewardDay({
    required this.day,
    required this.reward,
    required this.status,
  });
}
