import '../../data/models/models.dart';

class DailyRewardService {
  DailyRewardStatus _status = const DailyRewardStatus();

  void loadStatus(DailyRewardStatus status) {
    _status = _updateStatusForToday(status);
  }

  DailyRewardStatus get status => _status;

  DailyRewardStatus _updateStatusForToday(DailyRewardStatus status) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (status.lastClaimDate == null) {
      return status.copyWith(canClaimToday: true, currentDay: 1);
    }

    final lastClaim = DateTime(
      status.lastClaimDate!.year,
      status.lastClaimDate!.month,
      status.lastClaimDate!.day,
    );

    final difference = today.difference(lastClaim).inDays;

    if (difference == 0) {
      return status.copyWith(canClaimToday: false);
    } else if (difference == 1) {
      // Consecutive day
      final nextDay = (status.currentDay % 7) + 1;
      return status.copyWith(
        canClaimToday: true,
        currentDay: nextDay,
        currentStreak: status.currentStreak + 1,
      );
    } else {
      // Streak broken
      return status.copyWith(
        canClaimToday: true,
        currentDay: 1,
        currentStreak: 0,
      );
    }
  }

  DailyReward? claim() {
    if (!_status.canClaimToday) return null;

    final reward = DailyRewards.getRewardForDay(_status.currentDay);
    _status = _status.copyWith(
      lastClaimDate: DateTime.now(),
      canClaimToday: false,
      currentStreak: _status.currentStreak + 1,
    );

    return reward;
  }

  List<DailyReward> getWeekRewards() {
    return DailyRewards.weekCycle;
  }
}
