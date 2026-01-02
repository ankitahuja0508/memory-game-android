import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import '../../../config/ad_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/achievement_model.dart';
import '../../../domain/services/ad_service.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  BannerAd? _bannerAd;
  bool _adLoadAttempted = false;

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
      final ad = await AdService.instance.createAdaptiveBannerAd(width, adUnitId: AdConfig.bannerAchievementsAdUnitId).timeout(
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
          title: Text('Achievements', style: AppTextStyles.headline3),
          centerTitle: true,
        ),
        body: BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, state) {
            final completedCount = state.achievementProgress.values.where((p) => p.isCompleted).length;
            final totalCount = Achievements.all.length;
            final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

            return Column(
              children: [
                // Progress Header
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: AppColors.primaryGradient),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      const Text('🏆', style: TextStyle(fontSize: 48)),
                      const SizedBox(height: 8),
                      Text('$completedCount / $totalCount Completed', style: AppTextStyles.headline3),
                      const SizedBox(height: 16),
                      LinearPercentIndicator(
                        lineHeight: 12,
                        percent: progress,
                        backgroundColor: Colors.white.withAlpha(51),
                        progressColor: AppColors.accent,
                        barRadius: const Radius.circular(6),
                        animation: true,
                        animationDuration: 1000,
                      ),
                      const SizedBox(height: 8),
                      Text('${(progress * 100).toInt()}%', style: AppTextStyles.body2),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: -0.2),

                // Achievement List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: Achievements.all.length,
                    itemBuilder: (context, index) {
                      final achievement = Achievements.all[index];
                      final progress = state.achievementProgress[achievement.id];
                      final isCompleted = progress?.isCompleted ?? false;
                      final isRewardClaimed = progress?.isRewardClaimed ?? false;
                      final currentValue = progress?.currentValue ?? 0;

                      return _AchievementTile(
                        achievement: achievement,
                        currentValue: currentValue,
                        isCompleted: isCompleted,
                        isRewardClaimed: isRewardClaimed,
                        onClaimReward: () {
                          context.read<PlayerCubit>().claimAchievementReward(achievement.id);
                        },
                      ).animate(delay: Duration(milliseconds: 50 * index)).fadeIn().slideX(begin: 0.1);
                    },
                  ),
                ),
                
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
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  final int currentValue;
  final bool isCompleted;
  final bool isRewardClaimed;
  final VoidCallback onClaimReward;

  const _AchievementTile({
    required this.achievement,
    required this.currentValue,
    required this.isCompleted,
    required this.isRewardClaimed,
    required this.onClaimReward,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? AppColors.success.withAlpha(26)
            : AppColors.surface.withAlpha(179),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? AppColors.success.withAlpha(128) : Colors.transparent,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isCompleted ? AppColors.success.withAlpha(51) : AppColors.primary.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                achievement.icon,
                style: TextStyle(
                  fontSize: 28,
                  color: isCompleted ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: AppTextStyles.caption,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (achievement.targetValue > 1 && !isCompleted) ...[
                  const SizedBox(height: 8),
                  LinearPercentIndicator(
                    lineHeight: 6,
                    percent: (currentValue / achievement.targetValue).clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withAlpha(26),
                    progressColor: AppColors.primary,
                    barRadius: const Radius.circular(3),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$currentValue / ${achievement.targetValue}',
                    style: AppTextStyles.caption,
                  ),
                ],
                if (isCompleted) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: achievement.rewards.map((r) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withAlpha(51),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          r.displayText,
                          style: AppTextStyles.caption.copyWith(color: AppColors.accent),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          if (isCompleted && !isRewardClaimed)
            GestureDetector(
              onTap: onClaimReward,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: AppColors.successGradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('Claim', style: AppTextStyles.body2.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            )
          else if (isRewardClaimed)
            const Icon(Icons.check_circle, color: AppColors.success, size: 28)
          else
            Icon(Icons.lock_outline, color: Colors.white.withAlpha(77), size: 28),
        ],
      ),
    );
  }
}
