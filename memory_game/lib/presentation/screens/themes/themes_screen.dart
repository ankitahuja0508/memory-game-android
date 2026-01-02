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
import '../../widgets/common/currency_display.dart';

class ThemesScreen extends StatefulWidget {
  const ThemesScreen({super.key});

  @override
  State<ThemesScreen> createState() => _ThemesScreenState();
}

class _ThemesScreenState extends State<ThemesScreen> {
  BannerAd? _bannerAd;
  bool _adLoadAttempted = false;
  final audioService = AudioService.instance;

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
      final ad = await AdService.instance.createAdaptiveBannerAd(width, adUnitId: AdConfig.bannerThemesAdUnitId).timeout(
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
            onPressed: () {
              audioService.playButton();
              Navigator.pop(context);
            },
          ),
          title: Text('Themes', style: AppTextStyles.headline3),
          centerTitle: true,
        ),
        body: BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, state) {
            const themes = LevelGeneratorService.themes;
            
            return Column(
              children: [
                // Currency Display
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: CurrencyDisplay(
                    coins: state.player.coins,
                    gems: state.player.gems,
                  ),
                ),

                // Info card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.primary.withAlpha(50)),
                    ),
                    child: Row(
                      children: [
                        const Text('🎨', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Unlock new card themes as you progress! Equipped theme affects your game cards.',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Themes Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: themes.length,
                    itemBuilder: (context, index) {
                      final theme = themes[index];
                      final isUnlocked = state.player.unlockedThemes.contains(theme.id);
                      final isEquipped = state.player.equippedTheme == theme.id;
                      final canUnlock = state.highestUnlockedLevel >= theme.unlocksAtLevel;
                      final canAfford = state.player.canAffordCoins(theme.cost);

                      return _ThemeCard(
                        theme: theme,
                        isUnlocked: isUnlocked,
                        isEquipped: isEquipped,
                        canUnlock: canUnlock,
                        canAfford: canAfford,
                        onTap: () => _handleThemeTap(
                          context,
                          theme,
                          isUnlocked,
                          canUnlock,
                          canAfford,
                          state,
                        ),
                      ).animate(delay: Duration(milliseconds: 100 * index))
                          .fadeIn()
                          .scale(begin: const Offset(0.8, 0.8));
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

  void _handleThemeTap(
    BuildContext context,
    GameCardTheme theme,
    bool isUnlocked,
    bool canUnlock,
    bool canAfford,
    PlayerState state,
  ) {
    final audioService = AudioService.instance;

    if (isUnlocked) {
      // Equip theme
      audioService.playButton();
      context.read<PlayerCubit>().equipTheme(theme.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${theme.icon} ${theme.name} theme equipped!'),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 1),
        ),
      );
    } else if (!canUnlock) {
      // Show unlock requirement
      audioService.playMismatch();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reach level ${theme.unlocksAtLevel} to unlock this theme'),
          backgroundColor: AppColors.error,
        ),
      );
    } else if (!canAfford) {
      // Show insufficient funds
      audioService.playMismatch();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Need ${theme.cost} coins to unlock this theme'),
          backgroundColor: AppColors.error,
        ),
      );
    } else {
      // Show unlock confirmation
      _showUnlockDialog(context, theme);
    }
  }

  void _showUnlockDialog(BuildContext context, GameCardTheme theme) {
    final audioService = AudioService.instance;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Text(theme.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text('Unlock ${theme.name}?', style: const TextStyle(fontSize: 18)),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              theme.symbols.take(8).join('  '),
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('💰', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  '${theme.cost} Coins',
                  style: AppTextStyles.headline3.copyWith(
                    color: AppColors.coinColor,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              audioService.playButton();
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              audioService.playSuccess();
              context.read<PlayerCubit>().unlockTheme(theme.id);
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${theme.icon} ${theme.name} theme unlocked!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('Unlock'),
          ),
        ],
      ),
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final GameCardTheme theme;
  final bool isUnlocked;
  final bool isEquipped;
  final bool canUnlock;
  final bool canAfford;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isUnlocked,
    required this.isEquipped,
    required this.canUnlock,
    required this.canAfford,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: isEquipped
              ? LinearGradient(
                  colors: [
                    AppColors.success.withAlpha(100),
                    AppColors.success.withAlpha(50),
                  ],
                )
              : LinearGradient(
                  colors: [
                    AppColors.surface.withAlpha(180),
                    AppColors.surfaceLight.withAlpha(100),
                  ],
                ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isEquipped
                ? AppColors.success
                : isUnlocked
                    ? AppColors.primary.withAlpha(80)
                    : AppColors.textSecondary.withAlpha(50),
            width: isEquipped ? 3 : 2,
          ),
          boxShadow: isEquipped
              ? [
                  BoxShadow(
                    color: AppColors.success.withAlpha(100),
                    blurRadius: 12,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Theme icon
                  Text(theme.icon, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 6),
                  
                  // Theme name
                  Text(
                    theme.name,
                    style: AppTextStyles.body1.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isUnlocked ? Colors.white : AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  
                  // Theme symbols preview - limit to 4 symbols to prevent overflow
                  Wrap(
                    spacing: 3,
                    runSpacing: 3,
                    children: theme.symbols.take(4).map((symbol) {
                      return Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(isUnlocked ? 30 : 20),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          symbol,
                          style: TextStyle(
                            fontSize: 14,
                            color: isUnlocked ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  
                  const Spacer(flex: 1),
                  
                  // Status / Cost
                  if (isEquipped)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        '✓ Equipped',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else if (isUnlocked)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(100),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Tap to Equip',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                        ),
                      ),
                    )
                  else if (!canUnlock)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(80),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Level ${theme.unlocksAtLevel}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('💰', style: TextStyle(fontSize: 12)),
                        const SizedBox(width: 3),
                        Text(
                          '${theme.cost}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: canAfford ? AppColors.coinColor : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            
            // Lock icon for locked themes
            if (!isUnlocked)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(120),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock,
                    color: canUnlock ? AppColors.accent : AppColors.textSecondary,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

