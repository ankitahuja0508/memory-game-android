import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:confetti/confetti.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../config/ad_config.dart';
import '../../../config/iap_config.dart';
import '../../../data/models/power_up_model.dart';
import '../../../domain/services/services.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/currency_display.dart';

class ShopScreen extends StatefulWidget {
  final int initialTabIndex;
  
  const ShopScreen({
    super.key,
    this.initialTabIndex = 0, // 0 = Power-ups, 1 = Store
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  BannerAd? _bannerAd;
  Timer? _adCheckTimer;
  bool _adLoadAttempted = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      initialIndex: widget.initialTabIndex,
      vsync: this,
    );
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
    _tabController.dispose();
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
          title: Text('Shop', style: AppTextStyles.headline3),
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

                // Tab Bar
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: 'Power-ups'),
                    Tab(text: 'Store'),
                  ],
                ),

                // Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _PowerUpsTab(playerState: state),
                      _StoreTab(playerState: state),
                    ],
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

class _StoreTab extends StatefulWidget {
  final PlayerState playerState;

  const _StoreTab({required this.playerState});

  @override
  State<_StoreTab> createState() => _StoreTabState();
}

class _StoreTabState extends State<_StoreTab> {
  final iapService = IAPService.instance;
  bool _isLoading = false;
  String? _loadingProductId;

  @override
  void initState() {
    super.initState();
    // Set up purchase callback
    iapService.onPurchaseComplete = _handlePurchaseComplete;
    // Load products if not already loaded
    if (iapService.productDetails.isEmpty) {
      iapService.loadProductDetails();
      iapService.onProductsLoaded = () {
        if (mounted) setState(() {});
      };
    }
  }

  @override
  void dispose() {
    iapService.onPurchaseComplete = null;
    iapService.onProductsLoaded = null;
    super.dispose();
  }

  void _handlePurchaseComplete(String productId, bool success, String? error) {
    if (mounted) {
      setState(() {
        _isLoading = false;
        _loadingProductId = null;
      });

      if (success) {
        // Get rewards and grant them
        final rewards = iapService.getPurchaseRewards(productId);
        final playerCubit = context.read<PlayerCubit>();

        if (rewards.containsKey('coins')) {
          playerCubit.addCoins(rewards['coins']!);
        }
        if (rewards.containsKey('gems')) {
          playerCubit.addGems(rewards['gems']!);
        }

        // Show success dialog with confetti
        _showPurchaseSuccessDialog(productId, rewards);
      } else {
        // Show error dialog
        _showPurchaseFailureDialog(error);
      }
    }
  }

  void _showPurchaseSuccessDialog(String productId, Map<String, int> rewards) {
    final confettiController = ConfettiController(duration: const Duration(seconds: 3));
    confettiController.play();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // Confetti layer
              Align(
                alignment: Alignment.topCenter,
                child: ConfettiWidget(
                  confettiController: confettiController,
                  blastDirection: pi / 2,
                  maxBlastForce: 5,
                  minBlastForce: 2,
                  emissionFrequency: 0.05,
                  numberOfParticles: 50,
                  gravity: 0.1,
                  colors: const [
                    AppColors.primary,
                    AppColors.secondary,
                    AppColors.accent,
                    AppColors.success,
                    AppColors.coinColor,
                    AppColors.gemColor,
                  ],
                ),
              ),
              // Dialog content
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.surface,
                      AppColors.surfaceLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.success.withAlpha(100),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withAlpha(50),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success icon
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.success.withAlpha(51),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 50,
                        color: AppColors.success,
                      ),
                    ).animate().scale(delay: 100.ms, duration: 300.ms),
                    const SizedBox(height: 20),
                    
                    // Title
                    Text(
                      '🎉 Purchase Successful!',
                      style: AppTextStyles.headline2.copyWith(
                        color: AppColors.success,
                      ),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: 16),
                    
                    // Product name
                    Text(
                      _getProductDisplayName(productId),
                      style: AppTextStyles.headline3,
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 300.ms),
                    const SizedBox(height: 24),
                    
                    // Rewards section
                    if (rewards.isNotEmpty || IAPConfig.isRemoveAds(productId)) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLight.withAlpha(100),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            if (IAPConfig.isRemoveAds(productId)) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.block, color: AppColors.success, size: 24),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Ads Removed Permanently!',
                                    style: AppTextStyles.body1.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.success,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Enjoy an uninterrupted, ad-free gaming experience!',
                                style: AppTextStyles.body2,
                                textAlign: TextAlign.center,
                              ),
                            ] else ...[
                              Text(
                                'You received:',
                                style: AppTextStyles.body2,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              if (rewards.containsKey('coins'))
                                _RewardItem(
                                  icon: '💰',
                                  label: '${rewards['coins']} Coins',
                                  color: AppColors.coinColor,
                                ),
                              if (rewards.containsKey('coins') && rewards.containsKey('gems'))
                                const SizedBox(height: 8),
                              if (rewards.containsKey('gems'))
                                _RewardItem(
                                  icon: '💎',
                                  label: '${rewards['gems']} Gems',
                                  color: AppColors.gemColor,
                                ),
                            ],
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                      const SizedBox(height: 24),
                    ],
                    
                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          confettiController.stop();
                          confettiController.dispose();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 8,
                        ),
                        child: Text(
                          'Awesome!',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPurchaseFailureDialog(String? error) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.surface,
                AppColors.surfaceLight,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.error.withAlpha(100),
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(51),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 50,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Purchase Failed',
                style: AppTextStyles.headline2.copyWith(
                  color: AppColors.error,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Error message
              Text(
                _getUserFriendlyErrorMessage(error),
                style: AppTextStyles.body1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              
              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Optionally retry purchase here
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Try Again',
                        style: AppTextStyles.button.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getProductDisplayName(String productId) {
    final productInfo = IAPConfig.getProductInfo(productId);
    return productInfo?.name ?? 'Product';
  }

  String _getUserFriendlyErrorMessage(String? error) {
    if (error == null || error.isEmpty) {
      return 'Something went wrong with your purchase. Please try again later.';
    }
    
    final lowerError = error.toLowerCase();
    
    if (lowerError.contains('cancel')) {
      return 'Purchase was canceled. No charges were made.';
    } else if (lowerError.contains('network') || lowerError.contains('connection')) {
      return 'Network error. Please check your internet connection and try again.';
    } else if (lowerError.contains('payment') || lowerError.contains('billing')) {
      return 'Payment issue. Please check your payment method and try again.';
    } else if (lowerError.contains('item already owned')) {
      return 'You already own this item!';
    } else if (lowerError.contains('unavailable')) {
      return 'This item is currently unavailable. Please try again later.';
    } else {
      return 'Purchase failed: ${error.length > 100 ? error.substring(0, 100) + '...' : error}';
    }
  }

  Future<void> _purchaseProduct(String productId) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _loadingProductId = productId;
    });

    await iapService.purchaseProduct(productId);
  }

  Future<void> _restorePurchases() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await iapService.restorePurchases();
      
      // Wait a bit for restore to process (restored purchases come through the stream)
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchases restored! If you had purchased "Remove Ads", ads should now be removed.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to restore purchases: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final productDetails = iapService.productDetails;
    final adsRemoved = iapService.adsRemoved;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Remove Ads Section
        if (!adsRemoved) ...[
          Text(
            '✨ PREMIUM',
            style: AppTextStyles.headline3.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 12),
          _IAPProductCard(
            productId: IAPConfig.removeAds,
            productDetails: productDetails[IAPConfig.removeAds],
            isLoading: _isLoading && _loadingProductId == IAPConfig.removeAds,
            onPurchase: () => _purchaseProduct(IAPConfig.removeAds),
            icon: '🚫',
            isPremium: true,
          ),
          const SizedBox(height: 24),
        ],

        // Coin Packs Section
        Text(
          '💰 COIN PACKS',
          style: AppTextStyles.headline3.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        _IAPProductCard(
          productId: IAPConfig.coinsSmall,
          productDetails: productDetails[IAPConfig.coinsSmall],
          isLoading: _isLoading && _loadingProductId == IAPConfig.coinsSmall,
          onPurchase: () => _purchaseProduct(IAPConfig.coinsSmall),
          icon: '💰',
        ),
        const SizedBox(height: 12),
        _IAPProductCard(
          productId: IAPConfig.coinsMedium,
          productDetails: productDetails[IAPConfig.coinsMedium],
          isLoading: _isLoading && _loadingProductId == IAPConfig.coinsMedium,
          onPurchase: () => _purchaseProduct(IAPConfig.coinsMedium),
          icon: '💰',
          isPopular: true,
        ),
        const SizedBox(height: 12),
        _IAPProductCard(
          productId: IAPConfig.coinsLarge,
          productDetails: productDetails[IAPConfig.coinsLarge],
          isLoading: _isLoading && _loadingProductId == IAPConfig.coinsLarge,
          onPurchase: () => _purchaseProduct(IAPConfig.coinsLarge),
          icon: '💰',
        ),
        const SizedBox(height: 12),
        _IAPProductCard(
          productId: IAPConfig.coinsExtraLarge,
          productDetails: productDetails[IAPConfig.coinsExtraLarge],
          isLoading: _isLoading && _loadingProductId == IAPConfig.coinsExtraLarge,
          onPurchase: () => _purchaseProduct(IAPConfig.coinsExtraLarge),
          icon: '💰',
          isBestValue: true,
        ),
        const SizedBox(height: 24),

        // Gem Packs Section
        Text(
          '💎 GEM PACKS',
          style: AppTextStyles.headline3.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        _IAPProductCard(
          productId: IAPConfig.gemsSmall,
          productDetails: productDetails[IAPConfig.gemsSmall],
          isLoading: _isLoading && _loadingProductId == IAPConfig.gemsSmall,
          onPurchase: () => _purchaseProduct(IAPConfig.gemsSmall),
          icon: '💎',
        ),
        const SizedBox(height: 12),
        _IAPProductCard(
          productId: IAPConfig.gemsMedium,
          productDetails: productDetails[IAPConfig.gemsMedium],
          isLoading: _isLoading && _loadingProductId == IAPConfig.gemsMedium,
          onPurchase: () => _purchaseProduct(IAPConfig.gemsMedium),
          icon: '💎',
        ),
        const SizedBox(height: 12),
        _IAPProductCard(
          productId: IAPConfig.gemsLarge,
          productDetails: productDetails[IAPConfig.gemsLarge],
          isLoading: _isLoading && _loadingProductId == IAPConfig.gemsLarge,
          onPurchase: () => _purchaseProduct(IAPConfig.gemsLarge),
          icon: '💎',
        ),
        const SizedBox(height: 24),

        // Starter Pack Section
        Text(
          '🎁 STARTER PACKS',
          style: AppTextStyles.headline3.copyWith(fontSize: 16),
        ),
        const SizedBox(height: 12),
        _IAPProductCard(
          productId: IAPConfig.starterPack,
          productDetails: productDetails[IAPConfig.starterPack],
          isLoading: _isLoading && _loadingProductId == IAPConfig.starterPack,
          onPurchase: () => _purchaseProduct(IAPConfig.starterPack),
          icon: '🎁',
          isPopular: true,
        ),
        const SizedBox(height: 24),

        // Restore Purchases Button
        Center(
          child: TextButton.icon(
            onPressed: _isLoading ? null : _restorePurchases,
            icon: const Icon(Icons.restore, color: AppColors.textSecondary),
            label: Text(
              'Restore Purchases',
              style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _RewardItem extends StatelessWidget {
  final String icon;
  final String label;
  final Color color;

  const _RewardItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: AppTextStyles.body1.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _IAPProductCard extends StatelessWidget {
  final String productId;
  final dynamic productDetails; // ProductDetails from in_app_purchase
  final bool isLoading;
  final VoidCallback onPurchase;
  final String icon;
  final bool isPremium;
  final bool isPopular;
  final bool isBestValue;

  const _IAPProductCard({
    required this.productId,
    this.productDetails,
    required this.isLoading,
    required this.onPurchase,
    required this.icon,
    this.isPremium = false,
    this.isPopular = false,
    this.isBestValue = false,
  });

  String get _price {
    // Priority 1: Use localized price from Play Console (automatically formatted for device locale)
    if (productDetails != null && productDetails.price.isNotEmpty) {
      return productDetails.price; // Already localized (e.g., "$4.99", "€4.99", "£4.99")
    }
    // Fallback: Use config price (only if store data not available)
    final productInfo = IAPConfig.getProductInfo(productId);
    if (productInfo != null) {
      // Note: Fallback price is in USD, but this should rarely be used
      // Store price is always preferred and automatically localized
      return '\$${productInfo.price.toStringAsFixed(2)}';
    }
    return 'Loading...';
  }

  String get _title {
    // Priority 1: Use localized product name from Play Console
    if (productDetails != null && 
        productDetails.title != null && 
        productDetails.title!.isNotEmpty) {
      // Google Play automatically appends app name to product titles
      // Strip the app name suffix (e.g., "Remove Ads (Memory HD)" -> "Remove Ads")
      String title = productDetails.title!;
      
      // Remove app name in parentheses: "Product Name (App Name)" -> "Product Name"
      title = title.replaceAll(RegExp(r'\s*\([^)]+\)\s*$'), '');
      
      // Remove app name with dash: "Product Name - App Name" -> "Product Name"
      title = title.replaceAll(RegExp(r'\s*-\s*[^-]+$'), '');
      
      // Trim any extra whitespace
      return title.trim();
    }
    // Fallback: Use config name (only if store data not available)
    final productInfo = IAPConfig.getProductInfo(productId);
    return productInfo?.name ?? 'Product';
  }

  String get _description {
    // Priority 1: Use localized product description from Play Console
    if (productDetails != null && 
        productDetails.description != null && 
        productDetails.description!.isNotEmpty) {
      return productDetails.description!; // Already localized based on device locale
    }
    // Fallback: Use config description (only if store data not available)
    final productInfo = IAPConfig.getProductInfo(productId);
    return productInfo?.description ?? 'Purchase this product';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface.withAlpha(179),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPremium
              ? Colors.amber.withAlpha(100)
              : isPopular
                  ? AppColors.primary.withAlpha(100)
                  : isBestValue
                      ? Colors.green.withAlpha(100)
                      : AppColors.primary.withAlpha(51),
          width: isPremium || isPopular || isBestValue ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isPremium
                      ? Colors.amber.withAlpha(51)
                      : AppColors.primary.withAlpha(51),
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
                        Expanded(
                          child: Text(
                            _title,
                            style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                        if (isPopular) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'POPULAR',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        if (isBestValue) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'BEST VALUE',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(_description, style: AppTextStyles.caption),
                  ],
                ),
              ),
              Column(
                children: [
                  Text(
                    _price,
                    style: AppTextStyles.headline3.copyWith(
                      fontSize: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: isLoading ? null : onPurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPremium ? Colors.amber : AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Buy'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

