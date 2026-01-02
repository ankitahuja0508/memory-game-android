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
      // First time - can claim day 1
      return const DailyRewardStatus(
        currentStreak: 0,
        canClaimToday: true,
      );
    }

    final lastClaim = DateTime(
      status.lastClaimDate!.year,
      status.lastClaimDate!.month,
      status.lastClaimDate!.day,
    );

    final difference = today.difference(lastClaim).inDays;

    if (difference == 0) {
      // Already claimed today
      return status.copyWith(canClaimToday: false);
    } else if (difference == 1) {
      // Consecutive day - streak continues, can claim next day
      return status.copyWith(canClaimToday: true);
    } else {
      // Streak broken (missed days) - reset to day 1
      return const DailyRewardStatus(
        currentStreak: 0,
        canClaimToday: true,
      );
    }
  }

  DailyReward? claim() {
    if (!_status.canClaimToday) return null;

    // Get reward for the NEXT day (currentStreak + 1)
    final dayToClaim = _status.currentStreak + 1;
    final reward = DailyRewards.getRewardForDay(dayToClaim);
    
    // Update status: increment streak, mark as claimed today
    _status = _status.copyWith(
      lastClaimDate: DateTime.now(),
      canClaimToday: false,
      currentStreak: dayToClaim, // Now the streak equals the day just claimed
    );

    return reward;
  }

  List<DailyReward> getWeekRewards() {
    return DailyRewards.getWeekRewards(_status.currentStreak);
  }
}
