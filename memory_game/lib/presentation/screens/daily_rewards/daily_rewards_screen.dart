import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:confetti/confetti.dart';
import '../../../config/ad_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/daily_reward_model.dart';
import '../../../data/models/achievement_model.dart';
import '../../../domain/services/ad_service.dart';
import '../../../domain/services/audio_service.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/game_button.dart';

class DailyRewardsScreen extends StatefulWidget {
  const DailyRewardsScreen({super.key});

  @override
  State<DailyRewardsScreen> createState() => _DailyRewardsScreenState();
}

class _DailyRewardsScreenState extends State<DailyRewardsScreen> with SingleTickerProviderStateMixin {
  BannerAd? _bannerAd;
  bool _adLoadAttempted = false;
  late ConfettiController _confettiController;
  late AnimationController _pulseController;
  bool _isClaimAnimating = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_adLoadAttempted) {
      _adLoadAttempted = true;
      _loadBannerAd();
    }
  }

  void _loadBannerAd() async {
    try {
      final width = MediaQuery.of(context).size.width;
      final ad = await AdService.instance.createAdaptiveBannerAd(width, adUnitId: AdConfig.bannerRewardsAdUnitId).timeout(
        const Duration(seconds: 10),
        onTimeout: () => null,
      );
      if (mounted) setState(() => _bannerAd = ad);
    } catch (e) {
      debugPrint('❌ Error loading banner ad: $e');
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Daily Rewards', style: AppTextStyles.headline3),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            BlocBuilder<PlayerCubit, PlayerState>(
              builder: (context, state) {
                final status = state.dailyRewardStatus;
                final currentDay = status.currentDay;
                final weekRewards = DailyRewards.getWeekRewards(status.currentStreak);
                final weekStartDay = weekRewards.isNotEmpty ? weekRewards.first.day : 1;

                return Column(
                  children: [
                    // Streak Header with Animation
                    _buildStreakHeader(status),

                    // Progress Indicator
                    _buildProgressIndicator(status, weekStartDay),

                    // Week Grid
                    Expanded(
                      child: _buildWeekGrid(weekRewards, currentDay, status.canClaimToday),
                    ),

                    // Claim Button or Next Reward Timer
                    _buildClaimSection(status, currentDay),
                    
                    // Banner Ad at bottom
                    if (_bannerAd != null && !AdService.instance.adsRemoved)
                      Container(
                        alignment: Alignment.center,
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                  ],
                );
              },
            ),

            // Confetti overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  AppColors.accent,
                  AppColors.primary,
                  AppColors.success,
                  Colors.amber,
                  Colors.pink,
                ],
                numberOfParticles: 30,
                gravity: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakHeader(DailyRewardStatus status) {
    final streakEmoji = _getStreakEmoji(status.currentStreak);
    final streakTitle = _getStreakTitle(status.currentStreak);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: status.currentStreak >= 7 
              ? [Colors.amber.shade700, Colors.orange.shade800]
              : AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (status.currentStreak >= 7 ? Colors.amber : AppColors.primary).withAlpha(100),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Streak Icon
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                streakEmoji,
                style: const TextStyle(fontSize: 36),
              ),
            ),
          ).animate(onPlay: (c) => c.repeat())
              .scale(duration: 1.seconds, begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05)),
          const SizedBox(width: 16),
          
          // Streak Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${status.currentStreak} Day Streak',
                  style: AppTextStyles.headline2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  streakTitle,
                  style: AppTextStyles.body2.copyWith(
                    color: Colors.white.withAlpha(200),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  status.canClaimToday 
                      ? '✨ Reward ready to claim!' 
                      : '⏰ Come back tomorrow!',
                  style: AppTextStyles.caption.copyWith(
                    color: status.canClaimToday 
                        ? Colors.greenAccent 
                        : Colors.white.withAlpha(180),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.2);
  }

  String _getStreakEmoji(int streak) {
    if (streak >= 30) return '👑';
    if (streak >= 21) return '💎';
    if (streak >= 14) return '⭐';
    if (streak >= 7) return '🔥';
    if (streak >= 3) return '🌟';
    return '✨';
  }

  String _getStreakTitle(int streak) {
    if (streak >= 30) return 'Legendary Dedication!';
    if (streak >= 21) return 'True Champion!';
    if (streak >= 14) return 'Unstoppable!';
    if (streak >= 7) return 'On Fire!';
    if (streak >= 3) return 'Building Momentum!';
    if (streak > 0) return 'Keep it up!';
    return 'Start your streak today!';
  }

  Widget _buildProgressIndicator(DailyRewardStatus status, int weekStartDay) {
    final weekNumber = ((status.currentStreak > 0 ? status.currentStreak - 1 : 0) ~/ 7) + 1;
    final daysInWeek = status.currentStreak > 0 
        ? ((status.currentStreak - 1) % 7) + 1 
        : 0;
    
    // If can claim today, show progress to the current day being claimed
    final progressInWeek = status.canClaimToday ? daysInWeek : daysInWeek;
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Week $weekNumber',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Days $weekStartDay-${weekStartDay + 6}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progressInWeek / 7,
              minHeight: 8,
              backgroundColor: AppColors.surface.withAlpha(100),
              valueColor: AlwaysStoppedAnimation(
                status.currentStreak >= 7 ? Colors.amber : AppColors.accent,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$progressInWeek/7 days completed this week',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildWeekGrid(List<DailyReward> weekRewards, int currentDay, bool canClaimToday) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: weekRewards.length,
      itemBuilder: (context, index) {
        final reward = weekRewards[index];
        final dayNumber = reward.day;
        
        // Determine the state of this day card
        final isClaimed = dayNumber < currentDay || (dayNumber == currentDay && !canClaimToday);
        final isToday = dayNumber == currentDay && canClaimToday;
        final isFuture = dayNumber > currentDay;

        return _DayCard(
          reward: reward,
          isClaimed: isClaimed,
          isToday: isToday,
          isFuture: isFuture,
          canClaim: isToday,
          isAnimating: isToday && _isClaimAnimating,
        ).animate(delay: Duration(milliseconds: 80 * index))
            .fadeIn()
            .scale(begin: const Offset(0.8, 0.8));
      },
    );
  }

  Widget _buildClaimSection(DailyRewardStatus status, int currentDay) {
    if (status.canClaimToday) {
      final todayReward = DailyRewards.getRewardForDay(currentDay);
      
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Today's reward preview
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surface.withAlpha(150),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accent.withAlpha(100),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Day $currentDay Reward: ',
                    style: AppTextStyles.body2.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  ...todayReward.rewards.map((r) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      r.displayText,
                      style: AppTextStyles.body1.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 16),
            
            // Claim button with pulse animation
            AnimatedBuilder(
              animation: _pulseController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + (_pulseController.value * 0.03),
                  child: child,
                );
              },
              child: SizedBox(
                width: double.infinity,
                child: GameButton(
                  text: 'CLAIM REWARD',
                  emoji: todayReward.isMilestone ? '🎁' : '🎉',
                  gradient: todayReward.isMilestone 
                      ? [Colors.amber.shade600, Colors.orange.shade700]
                      : AppColors.successGradient,
                  onPressed: _isClaimAnimating ? () {} : () => _claimReward(context),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),
          ],
        ),
      );
    } else {
      // Show next reward timer
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Reward Claimed! 🎉',
              style: AppTextStyles.headline3.copyWith(
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Come back tomorrow for Day ${status.currentStreak + 1}',
              style: AppTextStyles.body2.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            _buildNextRewardCountdown(),
          ],
        ),
      ).animate().fadeIn(delay: 300.ms);
    }
  }

  Widget _buildNextRewardCountdown() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final timeUntilTomorrow = tomorrow.difference(now);
    
    final hours = timeUntilTomorrow.inHours;
    final minutes = timeUntilTomorrow.inMinutes % 60;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.timer_outlined, color: AppColors.textSecondary, size: 18),
        const SizedBox(width: 6),
        Text(
          'Next reward in ${hours}h ${minutes}m',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  void _claimReward(BuildContext context) async {
    setState(() => _isClaimAnimating = true);
    
    // Play sound
    AudioService.instance.playSuccess();
    
    final reward = await context.read<PlayerCubit>().claimDailyReward();
    
    if (reward != null && mounted) {
      // Trigger confetti
      _confettiController.play();
      
      // Show beautiful reward dialog
      await Future.delayed(const Duration(milliseconds: 300));
      
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      _showRewardDialog(context, reward);
    }
    
    if (mounted) {
      setState(() => _isClaimAnimating = false);
    }
  }

  void _showRewardDialog(BuildContext context, DailyReward reward) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: reward.isMilestone 
                  ? [Colors.amber.shade800, Colors.orange.shade900]
                  : [AppColors.surface, AppColors.surfaceLight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: reward.isMilestone ? Colors.amber : AppColors.accent,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: (reward.isMilestone ? Colors.amber : AppColors.accent).withAlpha(100),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy or gift animation
              Text(
                reward.isMilestone ? '🏆' : '🎁',
                style: const TextStyle(fontSize: 64),
              ).animate()
                  .scale(duration: 500.ms, curve: Curves.elasticOut)
                  .then()
                  .shake(duration: 300.ms),
              const SizedBox(height: 16),
              
              // Title
              Text(
                reward.isMilestone ? 'MILESTONE REWARD!' : 'Day ${reward.day} Complete!',
                style: AppTextStyles.headline2.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              
              if (reward.isMilestone)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${reward.day} Days Streak! 🔥',
                    style: AppTextStyles.body2.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ).animate().fadeIn(delay: 300.ms),
              
              const SizedBox(height: 24),
              
              // Rewards list with animations
              ...reward.rewards.asMap().entries.map((entry) {
                final index = entry.key;
                final r = entry.value;
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withAlpha(40),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _getRewardEmoji(r),
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        r.displayText,
                        style: AppTextStyles.headline3.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: Duration(milliseconds: 400 + (index * 150)))
                    .fadeIn()
                    .slideX(begin: 0.2);
              }),
              
              const SizedBox(height: 24),
              
              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: reward.isMilestone ? Colors.amber.shade800 : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Awesome!',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ).animate(delay: 800.ms).fadeIn().scale(begin: const Offset(0.8, 0.8)),
            ],
          ),
        ),
      ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  String _getRewardEmoji(Reward reward) {
    switch (reward.type) {
      case RewardType.coins:
        return '💰';
      case RewardType.gems:
        return '💎';
      case RewardType.powerUp:
        return _getPowerUpEmoji(reward.itemId ?? '');
      case RewardType.theme:
        return '🎨';
    }
  }

  String _getPowerUpEmoji(String powerUpId) {
    switch (powerUpId) {
      case 'peek': return '👁️';
      case 'freeze': return '❄️';
      case 'hint': return '🔦';
      case 'undo': return '↩️';
      case 'magnet': return '🧲';
      case 'double_coins': return '💰';
      case 'shield': return '🛡️';
      default: return '⚡';
    }
  }
}

class _DayCard extends StatelessWidget {
  final DailyReward reward;
  final bool isClaimed;
  final bool isToday;
  final bool isFuture;
  final bool canClaim;
  final bool isAnimating;

  const _DayCard({
    required this.reward,
    required this.isClaimed,
    required this.isToday,
    required this.isFuture,
    required this.canClaim,
    this.isAnimating = false,
  });

  @override
  Widget build(BuildContext context) {
    // Determine colors based on state
    Color bgColor;
    Color borderColor;
    Color textColor;
    
    if (isClaimed) {
      bgColor = AppColors.success.withAlpha(40);
      borderColor = AppColors.success;
      textColor = Colors.white;
    } else if (isToday) {
      bgColor = AppColors.accent.withAlpha(30);
      borderColor = AppColors.accent;
      textColor = Colors.white;
    } else {
      bgColor = AppColors.surface.withAlpha(80);
      borderColor = AppColors.surface;
      textColor = AppColors.textSecondary;
    }

    Widget card = Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: isToday ? 3 : 2,
        ),
        boxShadow: isToday ? [
          BoxShadow(
            color: AppColors.accent.withAlpha(60),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Day number
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
            decoration: BoxDecoration(
              color: isToday 
                  ? AppColors.accent 
                  : isClaimed 
                      ? AppColors.success 
                      : Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              'Day ${reward.day}',
              style: AppTextStyles.caption.copyWith(
                color: isToday || isClaimed ? Colors.white : textColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 6),
          
          // Reward icon
          Text(
            isClaimed 
                ? '✓' 
                : reward.isMilestone 
                    ? '🏆' 
                    : reward.isSpecial 
                        ? '🎁' 
                        : '💰',
            style: TextStyle(
              fontSize: isClaimed ? 24 : 28,
              color: isClaimed ? AppColors.success : null,
            ),
          ),
          const SizedBox(height: 4),
          
          // Reward preview (first reward only for space)
          if (!isClaimed)
            Text(
              reward.rewards.first.displayText,
              style: AppTextStyles.caption.copyWith(
                color: isToday ? AppColors.accent : textColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          
          // Extra rewards indicator
          if (!isClaimed && reward.rewards.length > 1)
            Text(
              '+${reward.rewards.length - 1} more',
              style: AppTextStyles.caption.copyWith(
                color: textColor.withAlpha(150),
                fontSize: 8,
              ),
            ),
          
          // Claimed checkmark
          if (isClaimed)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Claimed',
                style: TextStyle(
                  fontSize: 9,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );

    // Add shimmer for claimable day
    if (canClaim && !isAnimating) {
      card = card.animate(onPlay: (c) => c.repeat())
          .shimmer(duration: 1500.ms, color: Colors.white.withAlpha(60));
    }

    return card;
  }
}
