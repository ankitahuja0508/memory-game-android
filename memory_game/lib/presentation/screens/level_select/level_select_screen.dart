import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../config/ad_config.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/level_model.dart';
import '../../../domain/services/audio_service.dart';
import '../../../domain/services/ad_service.dart';
import '../../../domain/services/level_generator_service.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/star_rating.dart';

class LevelSelectScreen extends StatefulWidget {
  const LevelSelectScreen({super.key});

  @override
  State<LevelSelectScreen> createState() => _LevelSelectScreenState();
}

class _LevelSelectScreenState extends State<LevelSelectScreen> {
  final _audioService = AudioService.instance;
  final _levelGenerator = LevelGeneratorService();
  BannerAd? _bannerAd;
  bool _adLoadAttempted = false;

  @override
  void initState() {
    super.initState();
    // Ensure music keeps playing when entering level select
    _ensureMusicPlaying();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load banner ad after context is available (only once)
    if (!_adLoadAttempted) {
      _adLoadAttempted = true;
      _loadBannerAd();
    }
  }

  void _loadBannerAd() async {
    try {
      final width = MediaQuery.of(context).size.width;
      final ad = await AdService.instance.createAdaptiveBannerAd(width, adUnitId: AdConfig.bannerLevelsAdUnitId).timeout(
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

  void _ensureMusicPlaying() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_audioService.isMusicPlaying) {
        _audioService.startMusic();
      }
    });
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
          title: Text('Select Level', style: AppTextStyles.headline3),
          centerTitle: true,
        ),
        body: BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, state) {
            final highestLevel = state.highestUnlockedLevel;
            // Show more levels - display up to highest unlocked + 30 or minimum 100
            final displayLevels = (highestLevel + 30).clamp(100, 9999);
            // Determine the "next" level to play (highest uncompleted or the next level)
            final nextLevel = _getNextLevelToPlay(state);
            final nextLevelConfig = _levelGenerator.generateLevel(nextLevel);

            return Column(
              children: [
                // Quick Play Card
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: GestureDetector(
                    onTap: () {
                      _audioService.playButton();
                      Navigator.pushNamed(
                        context,
                        '/game',
                        arguments: {'level': nextLevel},
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: AppColors.successGradient,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.success.withAlpha(80),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.levelProgress[nextLevel]?.completed == true
                                      ? 'Continue Playing'
                                      : 'Play Next Level',
                                  style: AppTextStyles.body2.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Level $nextLevel',
                                  style: AppTextStyles.headline2.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                if (nextLevelConfig.isSpecialLevel) ...[
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha(40),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${nextLevelConfig.specialLevelEmoji} ${LevelGeneratorService.getSpecialLevelDescription(nextLevelConfig.specialType)?.split(' - ').first ?? ''}',
                                      style: AppTextStyles.caption.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn().slideY(begin: -0.2),

                // Stats Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _CompactStatItem(icon: '⭐', value: state.totalStars.toString(), label: 'Stars'),
                      _CompactStatItem(icon: '✅', value: state.completedLevels.toString(), label: 'Done'),
                      _CompactStatItem(icon: '🔓', value: highestLevel.toString(), label: 'Level'),
                    ],
                  ),
                ).animate().fadeIn(delay: 100.ms),

                // Level Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: displayLevels,
                    itemBuilder: (context, index) {
                      final level = index + 1;
                      
                      final progress = state.levelProgress[level];
                      final isUnlocked = level <= highestLevel;
                      final isCompleted = progress?.completed ?? false;
                      final stars = progress?.stars ?? 0;
                      final isNextLevel = level == nextLevel;
                      
                      // Get special level type
                      final levelConfig = _levelGenerator.generateLevel(level);
                      final specialType = levelConfig.specialType;

                      return _LevelTile(
                        level: level,
                        stars: stars,
                        isUnlocked: isUnlocked,
                        isCompleted: isCompleted,
                        isNextLevel: isNextLevel,
                        specialType: specialType,
                        onTap: isUnlocked
                            ? () {
                                _audioService.playButton();
                                Navigator.pushNamed(
                                  context,
                                  '/game',
                                  arguments: {'level': level},
                                );
                              }
                            : null,
                      ).animate(delay: Duration(milliseconds: 20 * (index % 25))).fadeIn().scale(
                            begin: const Offset(0.8, 0.8),
                            duration: 200.ms,
                          );
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

  int _getNextLevelToPlay(PlayerState state) {
    // Find the highest uncompleted level up to the highest unlocked
    for (int level = 1; level <= state.highestUnlockedLevel; level++) {
      final progress = state.levelProgress[level];
      if (progress == null || !progress.completed) {
        return level;
      }
    }
    // If all completed, return the highest unlocked level
    return state.highestUnlockedLevel;
  }
}

class _CompactStatItem extends StatelessWidget {
  final String icon;
  final String value;
  final String label;

  const _CompactStatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
              Text(label, style: AppTextStyles.caption.copyWith(fontSize: 9)),
            ],
          ),
        ],
      ),
    );
  }
}

class _LevelTile extends StatelessWidget {
  final int level;
  final int stars;
  final bool isUnlocked;
  final bool isCompleted;
  final bool isNextLevel;
  final SpecialLevelType? specialType;
  final VoidCallback? onTap;

  const _LevelTile({
    required this.level,
    required this.stars,
    required this.isUnlocked,
    required this.isCompleted,
    required this.isNextLevel,
    this.specialType,
    this.onTap,
  });

  Color _getColor() {
    // Special level colors override difficulty colors
    if (specialType != null && isUnlocked) {
      switch (specialType!) {
        case SpecialLevelType.bossLevel:
          return const Color(0xFFFF5722); // Deep Orange for Boss
        case SpecialLevelType.bonusRound:
          return const Color(0xFF4CAF50); // Green for Bonus
        case SpecialLevelType.speedChallenge:
          return const Color(0xFFFFEB3B); // Yellow for Speed
        case SpecialLevelType.memoryMaster:
          return const Color(0xFF9C27B0); // Purple for Memory
        case SpecialLevelType.mysteryLevel:
          return const Color(0xFF607D8B); // Blue Grey for Mystery
        case SpecialLevelType.dailyChallenge:
          return const Color(0xFF2196F3); // Blue for Daily
      }
    }
    
    // Difficulty colors
    if (level <= 10) return AppColors.levelBeginner;
    if (level <= 25) return AppColors.levelEasy;
    if (level <= 50) return AppColors.levelMedium;
    if (level <= 100) return AppColors.levelHard;
    return AppColors.levelExpert;
  }

  String? _getSpecialEmoji() {
    if (specialType == null) return null;
    switch (specialType!) {
      case SpecialLevelType.bossLevel:
        return '🔥';
      case SpecialLevelType.bonusRound:
        return '🎁';
      case SpecialLevelType.speedChallenge:
        return '⚡';
      case SpecialLevelType.memoryMaster:
        return '🧠';
      case SpecialLevelType.mysteryLevel:
        return '❓';
      case SpecialLevelType.dailyChallenge:
        return '📅';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final emoji = _getSpecialEmoji();
    final isSpecial = specialType != null && isUnlocked;

    Widget tile = Container(
      decoration: BoxDecoration(
        gradient: isUnlocked
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [color, color.withAlpha(179)],
              )
            : null,
        color: isUnlocked ? null : Colors.grey.withAlpha(77),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNextLevel 
              ? AppColors.accent 
              : isSpecial
                  ? color
                  : isCompleted 
                      ? AppColors.starFilled 
                      : Colors.transparent,
          width: isNextLevel ? 3 : (isSpecial ? 2 : 2),
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color: isNextLevel ? AppColors.accent.withAlpha(100) : color.withAlpha(100),
                  blurRadius: isNextLevel || isSpecial ? 12 : 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Show special level emoji or level number
                if (isSpecial && emoji != null) ...[
                  Text(emoji, style: const TextStyle(fontSize: 16)),
                  Text(
                    level.toString(),
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ] else ...[
                  Text(
                    level.toString(),
                    style: AppTextStyles.headline3.copyWith(
                      color: isUnlocked ? Colors.white : Colors.white.withAlpha(128),
                      fontWeight: FontWeight.bold,
                      fontSize: isUnlocked ? null : 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (!isUnlocked)
                    Icon(Icons.lock, color: Colors.white.withAlpha(128), size: 16)
                  else
                    StarRating(stars: stars, size: 12),
                ],
              ],
            ),
          ),
          // "NEXT" badge for the next level
          if (isNextLevel && !isCompleted)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 1),
                decoration: const BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(9),
                    topRight: Radius.circular(9),
                  ),
                ),
                child: const Text(
                  'NEXT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 7,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          // Special level indicator at bottom
          if (isSpecial && !isNextLevel)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(100),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(9),
                    bottomRight: Radius.circular(9),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StarRating(stars: stars, size: 8),
                  ],
                ),
              ),
            ),
        ],
      ),
    );

    // Add pulsing animation to next level or special levels
    if (isNextLevel && !isCompleted) {
      tile = tile.animate(onPlay: (c) => c.repeat(reverse: true)).scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: 1.seconds,
            curve: Curves.easeInOut,
          );
    } else if (isSpecial && !isCompleted) {
      tile = tile.animate(onPlay: (c) => c.repeat(reverse: true)).shimmer(
            duration: 2.seconds,
            color: Colors.white.withAlpha(50),
          );
    }

    return GestureDetector(
      onTap: onTap,
      child: tile,
    );
  }
}

/// Native ad placeholder for level grid
/// Shows a simple "AD" card - replace with actual native ad implementation later
