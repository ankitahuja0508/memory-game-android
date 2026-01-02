import 'dart:io';
import 'package:flutter/foundation.dart';

/// AdMob Configuration
/// 
/// - Test IDs are used automatically in DEBUG mode
/// - Production IDs are used only in RELEASE mode
/// - Each ad placement has its own ID for better analytics
class AdConfig {
  AdConfig._();

  // ============================================
  // DEBUG MODE CHECK
  // ============================================
  
  /// Returns true if running in release/production mode
  /// CRITICAL: kReleaseMode is the most reliable indicator
  static bool get isProduction {
    // kReleaseMode is a compile-time constant
    // It's true ONLY when built with --release flag
    return kReleaseMode;
  }
  
  /// Returns true if running in debug/development mode
  static bool get isDebug => kDebugMode;

  // ============================================
  // GOOGLE'S OFFICIAL TEST AD IDs
  // Used automatically in debug mode
  // ============================================
  
  static const String _testAppIdAndroid = 'ca-app-pub-3940256099942544~3347511713';
  static const String _testAppIdIOS = 'ca-app-pub-3940256099942544~1458002511';
  static const String _testRewardedAndroid = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testRewardedIOS = 'ca-app-pub-3940256099942544/1712485313';
  static const String _testInterstitialAndroid = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testInterstitialIOS = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testBannerAndroid = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIOS = 'ca-app-pub-3940256099942544/2934735716';

  // ============================================
  // PRODUCTION AD IDs (Live - Only used in RELEASE builds)
  // ============================================
  
  // APP IDs (Required in AndroidManifest.xml and Info.plist)
  static const String _prodAppIdAndroid = 'ca-app-pub-3419805534245719~2518069278';
  static const String _prodAppIdIOS = 'ca-app-pub-3419805534245719~2518069278'; // Use same for now
  
  // REWARDED VIDEO ADs (3 placements)
  static const String _prodRewardedShopAndroid = 'ca-app-pub-3419805534245719/8571523492'; // rewarded_shop_coins
  static const String _prodRewardedExtraTimeAndroid = 'ca-app-pub-3419805534245719/6523944658'; // rewarded_extra_time
  static const String _prodRewardedDailyBonusAndroid = 'ca-app-pub-3419805534245719/7258441823'; // rewarded_daily_bonus
  
  // INTERSTITIAL AD (1 placement)
  static const String _prodInterstitialAndroid = 'ca-app-pub-3419805534245719/5210862981'; // interstitial_between_levels
  
  // BANNER ADs (6 placements)
  static const String _prodBannerHomeAndroid = 'ca-app-pub-3419805534245719/9192122989'; // banner_home
  static const String _prodBannerLevelsAndroid = 'ca-app-pub-3419805534245719/3319196817'; // banner_levels
  static const String _prodBannerShopAndroid = 'ca-app-pub-3419805534245719/2006115140'; // banner_shop
  static const String _prodBannerThemesAndroid = 'ca-app-pub-3419805534245719/3170366466'; // banner_themes
  static const String _prodBannerAchievementsAndroid = 'ca-app-pub-3419805534245719/5276928707'; // banner_achievements
  static const String _prodBannerRewardsAndroid = 'ca-app-pub-3419805534245719/3670550607'; // banner_rewards

  // ============================================
  // APP ID GETTERS
  // ============================================
  
  static String get appId {
    if (Platform.isAndroid) {
      return isProduction ? _prodAppIdAndroid : _testAppIdAndroid;
    } else if (Platform.isIOS) {
      return isProduction ? _prodAppIdIOS : _testAppIdIOS;
    }
    return '';
  }

  // ============================================
  // REWARDED VIDEO AD GETTERS (Per Placement)
  // ============================================
  
  /// Rewarded ad for Shop - Watch ad for coins
  static String get rewardedShopAdUnitId {
    if (Platform.isAndroid) {
      return isProduction ? _prodRewardedShopAndroid : _testRewardedAndroid;
    } else if (Platform.isIOS) {
      return isProduction ? _prodRewardedShopAndroid : _testRewardedIOS; // Use same prod ID for now
    }
    return '';
  }
  
  /// Rewarded ad for Game - Watch ad for extra time
  static String get rewardedExtraTimeAdUnitId {
    if (Platform.isAndroid) {
      return isProduction ? _prodRewardedExtraTimeAndroid : _testRewardedAndroid;
    } else if (Platform.isIOS) {
      return isProduction ? _prodRewardedExtraTimeAndroid : _testRewardedIOS;
    }
    return '';
  }
  
  /// Rewarded ad for Daily Bonus multiplier
  static String get rewardedDailyBonusAdUnitId {
    if (Platform.isAndroid) {
      return isProduction ? _prodRewardedDailyBonusAndroid : _testRewardedAndroid;
    } else if (Platform.isIOS) {
      return isProduction ? _prodRewardedDailyBonusAndroid : _testRewardedIOS;
    }
    return '';
  }
  
  /// Legacy getter - defaults to shop rewarded ad
  static String get rewardedAdUnitId => rewardedShopAdUnitId;

  // ============================================
  // INTERSTITIAL AD GETTER
  // ============================================
  
  /// Interstitial ad between levels
  static String get interstitialAdUnitId {
    if (Platform.isAndroid) {
      return isProduction ? _prodInterstitialAndroid : _testInterstitialAndroid;
    } else if (Platform.isIOS) {
      return isProduction ? _prodInterstitialAndroid : _testInterstitialIOS;
    }
    return '';
  }

  // ============================================
  // BANNER AD GETTERS (Per Screen)
  // ============================================
  
  /// Banner Ad - Home/Menu Screen
  static String get bannerHomeAdUnitId {
    if (Platform.isAndroid) {
      return isProduction ? _prodBannerHomeAndroid : _testBannerAndroid;
    } else if (Platform.isIOS) {
      return isProduction ? _prodBannerHomeAndroid : _testBannerIOS;
    }
    return '';
  }

  /// Banner Ad - Level Select Screen
  static String get bannerLevelsAdUnitId {
    if (Platform.isAndroid) {
      return isProduction ? _prodBannerLevelsAndroid : _testBannerAndroid;
    } else if (Platform.isIOS) {
      return isProduction ? _prodBannerLevelsAndroid : _testBannerIOS;
    }
    return '';
  }

  /// Banner Ad - Shop/Power-ups Screen
  static String get bannerShopAdUnitId {
    if (Platform.isAndroid) {
      return isProduction ? _prodBannerShopAndroid : _testBannerAndroid;
    } else if (Platform.isIOS) {
      return isProduction ? _prodBannerShopAndroid : _testBannerIOS;
    }
    return '';
  }

  /// Banner Ad - Themes Screen
  static String get bannerThemesAdUnitId {
    if (Platform.isAndroid) {
      return isProduction ? _prodBannerThemesAndroid : _testBannerAndroid;
    } else if (Platform.isIOS) {
      return isProduction ? _prodBannerThemesAndroid : _testBannerIOS;
    }
    return '';
  }

  /// Banner Ad - Achievements Screen
  static String get bannerAchievementsAdUnitId {
    if (Platform.isAndroid) {
      return isProduction ? _prodBannerAchievementsAndroid : _testBannerAndroid;
    } else if (Platform.isIOS) {
      return isProduction ? _prodBannerAchievementsAndroid : _testBannerIOS;
    }
    return '';
  }

  /// Banner Ad - Daily Rewards Screen
  static String get bannerRewardsAdUnitId {
    if (Platform.isAndroid) {
      return isProduction ? _prodBannerRewardsAndroid : _testBannerAndroid;
    } else if (Platform.isIOS) {
      return isProduction ? _prodBannerRewardsAndroid : _testBannerIOS;
    }
    return '';
  }

  /// Legacy getter for backwards compatibility
  static String get bannerAdUnitId => bannerHomeAdUnitId;

  // ============================================
  // AD BEHAVIOR CONFIGURATION
  // ============================================

  /// Coins rewarded for watching a shop rewarded video ad
  static const int rewardedAdCoins = 100;
  
  /// Extra seconds given for watching extra time ad
  static const int rewardedExtraTimeSeconds = 30;

  /// Minimum time between interstitial ads (seconds)
  /// Increased for new app - can be reduced later when user base grows
  static const int interstitialAdCooldown = 600; // 10 minutes

  /// Show interstitial ad every N levels completed
  /// Increased for new app - can be reduced later when user base grows
  static const int interstitialAdFrequency = 10; // Every 10 levels

  /// Maximum rewarded ads user can watch per day
  static const int maxRewardedAdsPerDay = 10;

  // ============================================
  // HELPER METHODS
  // ============================================
  
  /// Print current ad configuration (for debugging)
  static void printConfig() {
    debugPrint('');
    debugPrint('==========================================');
    debugPrint('📺 AD CONFIGURATION');
    debugPrint('==========================================');
    debugPrint('🏗️ kReleaseMode: $kReleaseMode');
    debugPrint('🔧 kDebugMode: $kDebugMode');
    debugPrint('🎯 isProduction: $isProduction');
    debugPrint('🔧 Mode: ${isProduction ? "PRODUCTION (Real Ads)" : "DEBUG/TEST (Test Ads)"}');
    debugPrint('📱 Platform: ${Platform.isAndroid ? "Android" : "iOS"}');
    debugPrint('');
    debugPrint('🆔 App ID: $appId');
    
    // Show if using test or prod
    final isTestAppId = appId.contains('3940256099942544');
    debugPrint('   ⚠️ Type: ${isTestAppId ? "TEST APP ID" : "PRODUCTION APP ID"}');
    debugPrint('');
    debugPrint('🎬 Rewarded Ads:');
    debugPrint('   Shop Coins: $rewardedShopAdUnitId');
    final isTestRewarded = rewardedShopAdUnitId.contains('3940256099942544');
    debugPrint('   ⚠️ Type: ${isTestRewarded ? "TEST AD" : "PRODUCTION AD"}');
    debugPrint('   Extra Time: $rewardedExtraTimeAdUnitId');
    debugPrint('   Daily Bonus: $rewardedDailyBonusAdUnitId');
    debugPrint('');
    debugPrint('📺 Interstitial: $interstitialAdUnitId');
    final isTestInterstitial = interstitialAdUnitId.contains('3940256099942544');
    debugPrint('   ⚠️ Type: ${isTestInterstitial ? "TEST AD" : "PRODUCTION AD"}');
    debugPrint('');
    debugPrint('🏷️ Banner Ads:');
    debugPrint('   Home: $bannerHomeAdUnitId');
    final isTestBanner = bannerHomeAdUnitId.contains('3940256099942544');
    debugPrint('   ⚠️ Type: ${isTestBanner ? "TEST AD" : "PRODUCTION AD"}');
    debugPrint('   Levels: $bannerLevelsAdUnitId');
    debugPrint('   Shop: $bannerShopAdUnitId');
    debugPrint('   Themes: $bannerThemesAdUnitId');
    debugPrint('   Achievements: $bannerAchievementsAdUnitId');
    debugPrint('   Rewards: $bannerRewardsAdUnitId');
    debugPrint('==========================================');
    debugPrint('');
  }
}
