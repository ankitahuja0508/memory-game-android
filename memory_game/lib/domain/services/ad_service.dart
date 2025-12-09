import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/ad_config.dart';

/// Service for managing Google AdMob ads
/// 
/// Handles:
/// - Rewarded video ads (watch for coins)
/// - Interstitial ads (between levels)
/// - Banner ads (shop, level select)
class AdService {
  AdService._();
  static final AdService instance = AdService._();

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Rewarded Ad
  RewardedAd? _rewardedAd;
  bool _isLoadingRewardedAd = false;
  int _rewardedAdsWatchedToday = 0;
  DateTime? _lastRewardedAdDate;

  // Interstitial Ad
  InterstitialAd? _interstitialAd;
  bool _isLoadingInterstitialAd = false;
  DateTime? _lastInterstitialAdTime;
  int _levelsCompletedSinceLastAd = 0;

  // Banner Ad
  BannerAd? _bannerAd;
  bool _isBannerAdLoaded = false; // TODO: Either use this field or remove all assignments to it

  // Settings
  bool _adsRemoved = false; // Set to true if user bought "Remove Ads"
  bool get adsRemoved => _adsRemoved;

  /// Initialize the Mobile Ads SDK
  Future<void> initialize() async {
    try {
      debugPrint('==========================================');
      debugPrint('🚀 INITIALIZING ADMOB...');
      debugPrint('==========================================');
      
      // Load persisted rewarded ad count from storage
      await _loadRewardedAdCount();
      
      // Enable test mode for emulator/simulator
      // This makes test ads show immediately on emulators and real devices
      final configuration = RequestConfiguration(
        testDeviceIds: [
          // Add your device ID here when testing on real device
          // Get it from logcat: "Use RequestConfiguration.Builder().setTestDeviceIds(Arrays.asList("YOUR_DEVICE_ID"))"
        ],
      );
      await MobileAds.instance.updateRequestConfiguration(configuration);
      debugPrint('✅ Test device configuration set');
      
      // Initialize Mobile Ads SDK
      debugPrint('🔄 Calling MobileAds.instance.initialize()...');
      final initCompleter = await MobileAds.instance.initialize();
      _isInitialized = true;
      
      debugPrint('==========================================');
      debugPrint('✅ ADMOB INITIALIZED SUCCESSFULLY');
      debugPrint('📱 Adapter status: ${initCompleter.adapterStatuses}');
      debugPrint('🏷️ Build Mode: ${AdConfig.isProduction ? "PRODUCTION (Real Ads)" : "DEBUG (Test Ads)"}');
      debugPrint('🔑 Using App ID: ${AdConfig.appId.substring(0, 30)}...');
      debugPrint('==========================================');
      
      // Print full ad configuration
      AdConfig.printConfig();
      
      // Pre-load ads after SDK is ready
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (_isInitialized) {
          debugPrint('🔄 Pre-loading ads...');
          _loadRewardedAd();
          _loadInterstitialAd();
        }
      });
    } catch (e, stackTrace) {
      debugPrint('==========================================');
      debugPrint('❌ ADMOB INITIALIZATION FAILED');
      debugPrint('Error: $e');
      debugPrint('Stack: $stackTrace');
      debugPrint('==========================================');
      _isInitialized = false;
    }
  }

  /// Set whether ads are removed (user purchased "Remove Ads")
  void setAdsRemoved(bool removed) {
    _adsRemoved = removed;
    if (removed) {
      // Dispose all ads if user removed ads
      _disposeAllAds();
    }
  }

  // ============================================
  // REWARDED VIDEO ADS
  // ============================================
  
  /// Current ad unit ID being used for rewarded ad
  String _currentRewardedAdUnitId = '';

  /// Load a rewarded video ad with specific ad unit ID
  /// Defaults to shop ad if no ID provided
  Future<void> _loadRewardedAd({String? adUnitId}) async {
    if (!_isInitialized || _isLoadingRewardedAd || _rewardedAd != null) {
      if (!_isInitialized) {
        debugPrint('⏭️  Cannot load rewarded ad - AdMob not initialized');
      } else if (_isLoadingRewardedAd) {
        debugPrint('⏭️  Already loading rewarded ad');
      } else if (_rewardedAd != null) {
        debugPrint('⏭️  Rewarded ad already loaded');
      }
      return;
    }

    _currentRewardedAdUnitId = adUnitId ?? AdConfig.rewardedShopAdUnitId;
    _isLoadingRewardedAd = true;
    debugPrint('');
    debugPrint('🔄 LOADING REWARDED AD...');
    debugPrint('   Ad Unit ID: $_currentRewardedAdUnitId');

    try {
      await RewardedAd.load(
        adUnitId: _currentRewardedAdUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('✅✅✅ REWARDED AD LOADED SUCCESSFULLY ✅✅✅');
            _rewardedAd = ad;
            _isLoadingRewardedAd = false;

            // Set callbacks
            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('Rewarded ad dismissed');
                ad.dispose();
                _rewardedAd = null;
                _loadRewardedAd(); // Preload next ad
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('❌ Rewarded ad failed to show: $error');
                ad.dispose();
                _rewardedAd = null;
                _loadRewardedAd(); // Retry loading
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('❌❌❌ REWARDED AD FAILED TO LOAD ❌❌❌');
            debugPrint('   Message: ${error.message}');
            debugPrint('   Code: ${error.code}');
            debugPrint('   Domain: ${error.domain}');
            debugPrint('   Response Info: ${error.responseInfo}');
            debugPrint('');
            _isLoadingRewardedAd = false;
            _rewardedAd = null;
            
            // Retry after delay
            debugPrint('⏰ Will retry rewarded ad in 30 seconds...');
            Future.delayed(const Duration(seconds: 30), () {
              _loadRewardedAd();
            });
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Error loading rewarded ad: $e');
      _isLoadingRewardedAd = false;
    }
  }

  /// Check if rewarded ad is ready to show
  bool isRewardedAdReady() {
    _checkDailyRewardedAdLimit();
    return _rewardedAd != null && 
           _rewardedAdsWatchedToday < AdConfig.maxRewardedAdsPerDay;
  }

  /// Show rewarded video ad
  /// [placement] - Optional placement identifier for analytics (e.g., 'shop', 'extra_time', 'daily_bonus')
  /// Returns true if reward should be given
  Future<bool> showRewardedAd({String placement = 'shop'}) async {
    if (!isRewardedAdReady()) {
      debugPrint('⚠️ Rewarded ad not ready');
      return false;
    }

    debugPrint('📺 Showing rewarded ad for placement: $placement');
    final completer = Completer<bool>();

    try {
      await _rewardedAd!.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint('✅ User earned reward: ${reward.amount} ${reward.type} (placement: $placement)');
          _incrementRewardedAdCount();
          completer.complete(true);
        },
      );
    } catch (e) {
      debugPrint('❌ Error showing rewarded ad: $e');
      completer.complete(false);
    }

    return completer.future;
  }
  
  /// Pre-load rewarded ad for specific placement
  void preloadRewardedAdForPlacement(String placement) {
    String adUnitId;
    switch (placement) {
      case 'extra_time':
        adUnitId = AdConfig.rewardedExtraTimeAdUnitId;
        break;
      case 'daily_bonus':
        adUnitId = AdConfig.rewardedDailyBonusAdUnitId;
        break;
      case 'shop':
      default:
        adUnitId = AdConfig.rewardedShopAdUnitId;
    }
    
    // Only reload if no ad loaded or different placement
    if (_rewardedAd == null) {
      _loadRewardedAd(adUnitId: adUnitId);
    }
  }

  /// Load rewarded ad count from persistent storage
  Future<void> _loadRewardedAdCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDate = prefs.getString('last_rewarded_ad_date');
      final savedCount = prefs.getInt('rewarded_ads_watched_today') ?? 0;
      
      if (savedDate != null) {
        _lastRewardedAdDate = DateTime.parse(savedDate);
        final now = DateTime.now();
        
        if (_isSameDay(_lastRewardedAdDate!, now)) {
          _rewardedAdsWatchedToday = savedCount;
          debugPrint('📊 Loaded rewarded ad count: $_rewardedAdsWatchedToday/${AdConfig.maxRewardedAdsPerDay}');
        } else {
          _rewardedAdsWatchedToday = 0;
          _lastRewardedAdDate = now;
          await _saveRewardedAdCount();
          debugPrint('📊 New day - reset rewarded ad count to 0');
        }
      } else {
        debugPrint('📊 No saved rewarded ad data - starting fresh');
      }
    } catch (e) {
      debugPrint('❌ Error loading rewarded ad count: $e');
    }
  }

  /// Save rewarded ad count to persistent storage
  Future<void> _saveRewardedAdCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_rewarded_ad_date', _lastRewardedAdDate?.toIso8601String() ?? DateTime.now().toIso8601String());
      await prefs.setInt('rewarded_ads_watched_today', _rewardedAdsWatchedToday);
      debugPrint('💾 Saved rewarded ad count: $_rewardedAdsWatchedToday/${AdConfig.maxRewardedAdsPerDay}');
    } catch (e) {
      debugPrint('❌ Error saving rewarded ad count: $e');
    }
  }

  void _checkDailyRewardedAdLimit() {
    final now = DateTime.now();
    if (_lastRewardedAdDate == null || 
        !_isSameDay(_lastRewardedAdDate!, now)) {
      _rewardedAdsWatchedToday = 0;
      _lastRewardedAdDate = now;
      _saveRewardedAdCount(); // Save the reset
    }
  }

  void _incrementRewardedAdCount() {
    _rewardedAdsWatchedToday++;
    _lastRewardedAdDate = DateTime.now();
    _saveRewardedAdCount(); // Save immediately after increment
  }

  int getRemainingRewardedAds() {
    _checkDailyRewardedAdLimit();
    return AdConfig.maxRewardedAdsPerDay - _rewardedAdsWatchedToday;
  }

  // ============================================
  // INTERSTITIAL ADS
  // ============================================

  /// Load an interstitial ad
  Future<void> _loadInterstitialAd() async {
    if (!_isInitialized || 
        _isLoadingInterstitialAd || 
        _interstitialAd != null ||
        _adsRemoved) {
      if (!_isInitialized) {
        debugPrint('⏭️  Cannot load interstitial ad - AdMob not initialized');
      } else if (_isLoadingInterstitialAd) {
        debugPrint('⏭️  Already loading interstitial ad');
      } else if (_interstitialAd != null) {
        debugPrint('⏭️  Interstitial ad already loaded');
      } else if (_adsRemoved) {
        debugPrint('⏭️  Ads removed by user');
      }
      return;
    }

    _isLoadingInterstitialAd = true;
    debugPrint('');
    debugPrint('🔄 LOADING INTERSTITIAL AD...');
    debugPrint('   Ad Unit ID: ${AdConfig.interstitialAdUnitId}');

    try {
      await InterstitialAd.load(
        adUnitId: AdConfig.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('✅✅✅ INTERSTITIAL AD LOADED SUCCESSFULLY ✅✅✅');
            _interstitialAd = ad;
            _isLoadingInterstitialAd = false;

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                debugPrint('Interstitial ad dismissed');
                ad.dispose();
                _interstitialAd = null;
                _loadInterstitialAd(); // Preload next ad
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                debugPrint('❌ Interstitial ad failed to show: $error');
                ad.dispose();
                _interstitialAd = null;
                _loadInterstitialAd(); // Retry loading
              },
            );
          },
          onAdFailedToLoad: (error) {
            debugPrint('❌❌❌ INTERSTITIAL AD FAILED TO LOAD ❌❌❌');
            debugPrint('   Message: ${error.message}');
            debugPrint('   Code: ${error.code}');
            debugPrint('   Domain: ${error.domain}');
            debugPrint('   Response Info: ${error.responseInfo}');
            debugPrint('');
            _isLoadingInterstitialAd = false;
            _interstitialAd = null;
            
            // Retry after delay
            debugPrint('⏰ Will retry interstitial ad in 30 seconds...');
            Future.delayed(const Duration(seconds: 30), () {
              _loadInterstitialAd();
            });
          },
        ),
      );
    } catch (e) {
      debugPrint('❌ Error loading interstitial ad: $e');
      _isLoadingInterstitialAd = false;
    }
  }

  /// Check if should show interstitial ad
  bool _shouldShowInterstitialAd() {
    if (_adsRemoved || _interstitialAd == null) return false;

    // Check frequency (every N levels)
    if (_levelsCompletedSinceLastAd < AdConfig.interstitialAdFrequency) {
      return false;
    }

    // Check cooldown (minimum time between ads)
    if (_lastInterstitialAdTime != null) {
      final timeSinceLastAd = DateTime.now().difference(_lastInterstitialAdTime!);
      if (timeSinceLastAd.inSeconds < AdConfig.interstitialAdCooldown) {
        return false;
      }
    }

    return true;
  }

  /// Call this when user completes a level
  void onLevelComplete() {
    _levelsCompletedSinceLastAd++;

    if (_shouldShowInterstitialAd()) {
      showInterstitialAd();
    }
  }

  /// Show interstitial ad
  Future<void> showInterstitialAd() async {
    if (!_shouldShowInterstitialAd()) {
      debugPrint('⚠️ Interstitial ad not ready or on cooldown');
      return;
    }

    try {
      await _interstitialAd!.show();
      _levelsCompletedSinceLastAd = 0;
      _lastInterstitialAdTime = DateTime.now();
      debugPrint('✅ Interstitial ad shown');
    } catch (e) {
      debugPrint('❌ Error showing interstitial ad: $e');
    }
  }

  // ============================================
  // BANNER ADS
  // ============================================

  /// Create and load a banner ad (standard size)
  BannerAd? createBannerAd() {
    if (!_isInitialized || _adsRemoved) {
      return null;
    }

    try {
      final banner = BannerAd(
        adUnitId: AdConfig.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('✅ Banner ad loaded');
            _isBannerAdLoaded = true;
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('❌ Banner ad failed to load: $error');
            ad.dispose();
            _isBannerAdLoaded = false;
          },
        ),
      );

      banner.load();
      return banner;
    } catch (e) {
      debugPrint('❌ Error creating banner ad: $e');
      return null;
    }
  }

  /// Create and load an adaptive banner ad
  /// Adaptive banners automatically adjust to screen width for better fill rates
  /// [adUnitId] - Optional specific ad unit ID for per-screen tracking
  Future<BannerAd?> createAdaptiveBannerAd(double width, {String? adUnitId}) async {
    if (!_isInitialized || _adsRemoved) {
      debugPrint('⏭️  Cannot create banner ad - initialized: $_isInitialized, adsRemoved: $_adsRemoved');
      return null;
    }

    final effectiveAdUnitId = adUnitId ?? AdConfig.bannerHomeAdUnitId;

    try {
      debugPrint('');
      debugPrint('🔄 CREATING ADAPTIVE BANNER AD...');
      debugPrint('   Width: ${width.truncate()}px');
      debugPrint('   Ad Unit ID: $effectiveAdUnitId');
      
      final AnchoredAdaptiveBannerAdSize? adSize = 
          await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
            width.truncate(),
          );

      if (adSize == null) {
        debugPrint('❌ Could not determine adaptive banner size');
        return null;
      }

      debugPrint('   Banner size: ${adSize.width}x${adSize.height}');

      final banner = BannerAd(
        adUnitId: effectiveAdUnitId,
        size: adSize,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            debugPrint('✅✅✅ BANNER AD LOADED (${adSize.width}x${adSize.height}) ✅✅✅');
            _isBannerAdLoaded = true;
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('❌❌❌ BANNER AD FAILED TO LOAD ❌❌❌');
            debugPrint('   Message: ${error.message}');
            debugPrint('   Code: ${error.code}');
            debugPrint('   Domain: ${error.domain}');
            debugPrint('');
            ad.dispose();
            _isBannerAdLoaded = false;
          },
        ),
      );

      debugPrint('🔄 Calling banner.load()...');
      banner.load();
      return banner;
    } catch (e, stackTrace) {
      debugPrint('❌ EXCEPTION creating adaptive banner ad: $e');
      debugPrint('Stack: $stackTrace');
      return null;
    }
  }

  // ============================================
  // UTILITY
  // ============================================

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _disposeAllAds() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _bannerAd?.dispose();
    _bannerAd = null;
  }

  void dispose() {
    _disposeAllAds();
    _isInitialized = false;
  }
}

