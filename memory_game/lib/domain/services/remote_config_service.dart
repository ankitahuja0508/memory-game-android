import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';

/// Service for managing feature toggles via Firebase Remote Config
class RemoteConfigService {
  RemoteConfigService._();
  static final RemoteConfigService instance = RemoteConfigService._();

  FirebaseRemoteConfig? _remoteConfig;
  bool _isInitialized = false;

  // Feature flag keys
  static const String _leaderboardEnabled = 'leaderboard_enabled';
  static const String _shareEnabled = 'share_enabled';
  static const String _rateAppEnabled = 'rate_app_enabled';
  static const String _notificationsEnabled = 'notifications_enabled';
  static const String _maintenanceMode = 'maintenance_mode';
  static const String _maintenanceMessage = 'maintenance_message';
  static const String _minAppVersion = 'min_app_version';
  static const String _maxRewardedAdsPerDay = 'max_rewarded_ads_per_day';
  static const String _dailyRewardMultiplier = 'daily_reward_multiplier';

  /// Initialize Remote Config with default values
  Future<void> initialize() async {
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      // Set default values
      await _remoteConfig!.setDefaults({
        _leaderboardEnabled: true,
        _shareEnabled: true,
        _rateAppEnabled: true,
        _notificationsEnabled: true,
        _maintenanceMode: false,
        _maintenanceMessage: 'The game is under maintenance. Please try again later.',
        _minAppVersion: '1.0.0',
        _maxRewardedAdsPerDay: 10,
        _dailyRewardMultiplier: 1.0,
      });

      // Set fetch settings
      await _remoteConfig!.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: kDebugMode 
            ? const Duration(minutes: 5) // More frequent in debug
            : const Duration(hours: 1),  // Less frequent in production
      ));

      // Fetch and activate
      await _remoteConfig!.fetchAndActivate();
      _isInitialized = true;

      debugPrint('✅ Remote Config initialized');
      debugPrint('   Leaderboard: $isLeaderboardEnabled');
      debugPrint('   Share: $isShareEnabled');
      debugPrint('   Rate App: $isRateAppEnabled');
      debugPrint('   Notifications: $isNotificationsEnabled');
    } catch (e) {
      debugPrint('❌ Remote Config initialization failed: $e');
      _isInitialized = false;
    }
  }

  /// Refresh config from server
  Future<void> refresh() async {
    if (!_isInitialized || _remoteConfig == null) return;
    
    try {
      await _remoteConfig!.fetchAndActivate();
      debugPrint('✅ Remote Config refreshed');
    } catch (e) {
      debugPrint('❌ Remote Config refresh failed: $e');
    }
  }

  // ============================================
  // FEATURE FLAGS
  // ============================================

  /// Is leaderboard feature enabled?
  bool get isLeaderboardEnabled {
    if (!_isInitialized || _remoteConfig == null) return false; // Default enabled
    return _remoteConfig!.getBool(_leaderboardEnabled);
  }

  /// Is share feature enabled?
  bool get isShareEnabled {
    if (!_isInitialized || _remoteConfig == null) return true;
    return _remoteConfig!.getBool(_shareEnabled);
  }

  /// Is rate app feature enabled?
  bool get isRateAppEnabled {
    if (!_isInitialized || _remoteConfig == null) return true;
    return _remoteConfig!.getBool(_rateAppEnabled);
  }

  /// Is notifications feature enabled?
  bool get isNotificationsEnabled {
    if (!_isInitialized || _remoteConfig == null) return true;
    return _remoteConfig!.getBool(_notificationsEnabled);
  }

  /// Is app in maintenance mode?
  bool get isMaintenanceMode {
    if (!_isInitialized || _remoteConfig == null) return false;
    return _remoteConfig!.getBool(_maintenanceMode);
  }

  /// Get maintenance message
  String get maintenanceMessage {
    if (!_isInitialized || _remoteConfig == null) {
      return 'The game is under maintenance. Please try again later.';
    }
    return _remoteConfig!.getString(_maintenanceMessage);
  }

  /// Get minimum required app version
  String get minAppVersion {
    if (!_isInitialized || _remoteConfig == null) return '1.0.0';
    return _remoteConfig!.getString(_minAppVersion);
  }

  /// Get max rewarded ads per day
  int get maxRewardedAdsPerDay {
    if (!_isInitialized || _remoteConfig == null) return 10;
    return _remoteConfig!.getInt(_maxRewardedAdsPerDay);
  }

  /// Get daily reward multiplier
  double get dailyRewardMultiplier {
    if (!_isInitialized || _remoteConfig == null) return 1.0;
    return _remoteConfig!.getDouble(_dailyRewardMultiplier);
  }
}
