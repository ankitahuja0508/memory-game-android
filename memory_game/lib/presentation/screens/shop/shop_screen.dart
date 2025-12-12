import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../config/ad_config.dart';
import '../../../data/models/power_up_model.dart';
import '../../../domain/services/services.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/currency_display.dart';

class ShopScreen extends StatefulWidget {
  const ShopScreen({super.key});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  BannerAd? _bannerAd;
  Timer? _adCheckTimer;
  bool _adLoadAttempted = false;

  @override
  void initState() {
    super.initState();
    _startAdCheckTimer();
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
      // Use adaptive banner for better fill rates and revenue
      final width = MediaQuery.of(context).size.width;
      
      // Add timeout to prevent infinite loading
      final ad = await AdService.instance.createAdaptiveBannerAd(width, adUnitId: AdConfig.bannerShopAdUnitId).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          debugPrint('⚠️ Banner ad load timeout in shop');
          return null;
        },
      );
      
      if (mounted) {
        setState(() {
          _bannerAd = ad;
        });
      }
    } catch (e) {
      debugPrint('❌ Error loading banner ad in shop: $e');
    }
  }

  void _startAdCheckTimer() {
    // Check every 5 seconds if rewarded ad is ready and refresh UI
    _adCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() {}); // Refresh to show/hide ad card
      }
    });
  }

  @override
  void dispose() {
    _adCheckTimer?.cancel();
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
          title: Text('Power-ups', style: AppTextStyles.headline3),
          centerTitle: true,
        ),
        body: BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, state) {
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
                        const Text('💡', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Buy power-ups with coins or gems to help you complete levels!',
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Power-ups List
                Expanded(
                  child: _PowerUpsTab(playerState: state),
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

class _PowerUpsTab extends StatelessWidget {
  final PlayerState playerState;

  const _PowerUpsTab({required this.playerState});

  @override
  Widget build(BuildContext context) {
    final adService = AdService.instance;
    final showAdCard = !adService.adsRemoved && adService.isRewardedAdReady();
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Rewarded Ad Section - Only show if ad is ready
        if (showAdCard) ...[
          _RewardedAdCard(),
          const SizedBox(height: 16),
        ],

        // Section Header
        Text(
          '🎁 POWER-UPS',
          style: AppTextStyles.headline3.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),

        // Power-ups
        ...PowerUpConfigs.all.asMap().entries.map((entry) {
          final index = entry.key;
          final config = entry.value;
          final owned = playerState.player.getPowerUpCount(config.id);

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ShopItem(
              icon: config.icon,
              name: config.name,
              description: config.description,
              coinCost: config.coinCost,
              gemCost: config.gemCost,
              owned: owned,
              onBuyWithCoins: () => _buyPowerUp(context, config.id, false),
              onBuyWithGems: () => _buyPowerUp(context, config.id, true),
            ).animate(delay: Duration(milliseconds: 100 * index)).fadeIn().slideX(begin: 0.1),
          );
        }),
      ],
    );
  }

  void _buyPowerUp(BuildContext context, String id, bool useGems) async {
    final config = PowerUpConfigs.getConfigById(id);
    final success = await context.read<PlayerCubit>().buyPowerUp(id, useGems: useGems);
    if (context.mounted) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    success ? (config?.icon ?? '🎁') : '😢',
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        success ? 'Power-up acquired!' : 'Oops!',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        success 
                            ? '${config?.name ?? 'Item'} added to inventory' 
                            : 'Not enough ${useGems ? 'gems' : 'coins'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withAlpha(200),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
          elevation: 8,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }
}

class _RewardedAdCard extends StatefulWidget {
  @override
  State<_RewardedAdCard> createState() => _RewardedAdCardState();
}

class _RewardedAdCardState extends State<_RewardedAdCard> {
  bool _isWatchingAd = false;

  Future<void> _watchRewardedAd() async {
    if (!AdService.instance.isRewardedAdReady()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ad not ready yet. Please try again in a moment.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isWatchingAd = true);

    // Pause music during ad
    AudioService.instance.pauseMusic();

    try {
      final rewarded = await AdService.instance.showRewardedAd(placement: 'shop');
      
      if (rewarded && mounted) {
        // Give coins to player
        await context.read<PlayerCubit>().addCoins(AdConfig.rewardedAdCoins);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Text('🎉', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You earned ${AdConfig.rewardedAdCoins} coins!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } finally {
      // Always resume music after ad (whether successful or not)
      AudioService.instance.resumeMusic();
      if (mounted) {
        setState(() => _isWatchingAd = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = AdService.instance.getRemainingRewardedAds();
    final canWatch = AdService.instance.isRewardedAdReady();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withAlpha(80),
            AppColors.primary.withAlpha(80),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.accent.withAlpha(100), width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withAlpha(50),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_circle_fill,
                  size: 32,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Watch Ad for Coins',
                      style: AppTextStyles.headline3.copyWith(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Get ${AdConfig.rewardedAdCoins} 💰 for watching a short video',
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isWatchingAd || !canWatch ? null : _watchRewardedAd,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 8,
              ),
              child: _isWatchingAd
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(AppColors.primary),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_arrow, size: 28),
                        const SizedBox(width: 8),
                        Text(
                          canWatch ? 'WATCH AD' : 'Loading...',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$remaining ads remaining today',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white60,
              fontSize: 11,
            ),
          ),
        ],
      ),
    ).animate().fadeIn().slideY(begin: -0.1);
  }
}

class _ShopItem extends StatelessWidget {
  final String icon;
  final String name;
  final String description;
  final int coinCost;
  final int gemCost;
  final int owned;
  final VoidCallback onBuyWithCoins;
  final VoidCallback onBuyWithGems;

  const _ShopItem({
    required this.icon,
    required this.name,
    required this.description,
    required this.coinCost,
    required this.gemCost,
    required this.owned,
    required this.onBuyWithCoins,
    required this.onBuyWithGems,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(179),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(51),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(name, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withAlpha(51),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('x$owned', style: AppTextStyles.caption.copyWith(color: AppColors.secondary)),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: AppTextStyles.caption),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: onBuyWithCoins,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.coinColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text('💰', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text('$coinCost', style: AppTextStyles.caption.copyWith(color: AppColors.coinColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onBuyWithGems,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.gemColor.withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text('💎', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 4),
                      Text('$gemCost', style: AppTextStyles.caption.copyWith(color: AppColors.gemColor, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

