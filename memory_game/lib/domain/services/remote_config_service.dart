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
  static const String _latestAppVersion = 'latest_app_version';
  static const String _latestBuildNumber = 'latest_build_number';
  static const String _updateRequired = 'update_required';
  static const String _updateMessage = 'update_message';
  static const String _maxRewardedAdsPerDay = 'max_rewarded_ads_per_day';
  static const String _dailyRewardMultiplier = 'daily_reward_multiplier';

  /// Initialize Remote Config with default values
  Future<void> initialize() async {
    try {
      _remoteConfig = FirebaseRemoteConfig.instance;

      // Set default values
      await _remoteConfig!.setDefaults({
        _leaderboardEnabled: false,
        _shareEnabled: true,
        _rateAppEnabled: true,
        _notificationsEnabled: true,
        _maintenanceMode: false,
        _maintenanceMessage: 'The game is under maintenance. Please try again later.',
        _minAppVersion: '1.0.0',
        _latestAppVersion: '1.0.0',
        _latestBuildNumber: 1,
        _updateRequired: false,
        _updateMessage: 'A new version is available with exciting new features!',
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

  /// Get latest app version available
  String get latestVersion {
    if (!_isInitialized || _remoteConfig == null) return '';
    return _remoteConfig!.getString(_latestAppVersion);
  }

  /// Get latest build number available
  int get latestBuildNumber {
    if (!_isInitialized || _remoteConfig == null) return 1;
    return _remoteConfig!.getInt(_latestBuildNumber);
  }

  /// Check if update is required (force update)
  bool get updateRequired {
    if (!_isInitialized || _remoteConfig == null) return false;
    return _remoteConfig!.getBool(_updateRequired);
  }

  /// Get update message to show to users
  String get updateMessage {
    if (!_isInitialized || _remoteConfig == null) {
      return 'A new version is available with exciting new features!';
    }
    return _remoteConfig!.getString(_updateMessage);
  }
}
