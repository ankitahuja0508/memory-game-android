import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/settings_model.dart';
import 'remote_config_service.dart';

class AppUpdateService {
  static const String _currentVersion = '1.0.0'; // Update this with each release
  static const int _currentBuildNumber = 6; // Update this with each release
  
  static const String _lastCheckedKey = 'last_update_checked';
  static const String _dismissedVersionKey = 'dismissed_update_version';
  
  // Play Store URL for Android
  static const String _playStoreUrl = 'https://play.google.com/store/apps/details?id=com.aexyn.memorymatch.memorygame';
  
  // App Store URL for iOS (update with your app ID when available)
  static const String _appStoreUrl = 'https://apps.apple.com/app/idYOURAPPID';
  
  // GitHub releases API (optional - if you use GitHub for version management)
  static const String _githubApiUrl = 'https://api.github.com/repos/YOUR_USERNAME/YOUR_REPO/releases/latest';
  
  AppUpdateService._();
  static final instance = AppUpdateService._();
  
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      debugPrint('✅ App Update Service initialized');
    } catch (e) {
      debugPrint('❌ Failed to initialize App Update Service: $e');
    }
  }
  
  /// Check if an update is available
  Future<UpdateInfo?> checkForUpdate({bool force = false}) async {
    if (!_isInitialized) await initialize();
    
    // Don't check in debug mode
    if (kDebugMode && !force) return null;
    
    try {
      // Check if we've already checked today (unless forced)
      if (!force) {
        final lastChecked = _prefs.getInt(_lastCheckedKey) ?? 0;
        final now = DateTime.now().millisecondsSinceEpoch;
        final dayInMillis = 24 * 60 * 60 * 1000;
        
        if (now - lastChecked < dayInMillis) {
          debugPrint('⏭️ Skipping update check (already checked today)');
          return null;
        }
      }
      
      // First, try to get version info from Firebase Remote Config
      final remoteVersion = RemoteConfigService.instance.latestVersion;
      final remoteBuildNumber = RemoteConfigService.instance.latestBuildNumber;
      final updateRequired = RemoteConfigService.instance.updateRequired;
      final updateMessage = RemoteConfigService.instance.updateMessage;
      
      UpdateInfo? updateInfo;
      
      if (remoteVersion.isNotEmpty) {
        // Use Remote Config values
        updateInfo = _compareVersions(
          currentVersion: _currentVersion,
          currentBuild: _currentBuildNumber,
          latestVersion: remoteVersion,
          latestBuild: remoteBuildNumber,
          isRequired: updateRequired,
          message: updateMessage,
        );
      } else {
        // Fallback to GitHub API (optional)
        updateInfo = await _checkGitHubForUpdate();
      }
      
      // Update last checked time
      await _prefs.setInt(_lastCheckedKey, DateTime.now().millisecondsSinceEpoch);
      
      if (updateInfo != null) {
        debugPrint('🔄 Update available: ${updateInfo.latestVersion}');
        
        // Check if user has dismissed this version
        final dismissedVersion = _prefs.getString(_dismissedVersionKey) ?? '';
        if (!updateInfo.isRequired && dismissedVersion == updateInfo.latestVersion) {
          debugPrint('⏭️ User dismissed version ${updateInfo.latestVersion}');
          return null;
        }
      } else {
        debugPrint('✅ App is up to date');
      }
      
      return updateInfo;
    } catch (e) {
      debugPrint('❌ Error checking for update: $e');
      return null;
    }
  }
  
  /// Compare version numbers and determine if update is needed
  UpdateInfo? _compareVersions({
    required String currentVersion,
    required int currentBuild,
    required String latestVersion,
    required int latestBuild,
    bool isRequired = false,
    String? message,
  }) {
    // Compare build numbers (more reliable)
    if (latestBuild > currentBuild) {
      return UpdateInfo(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        isRequired: isRequired,
        updateMessage: message ?? 'A new version is available with bug fixes and improvements!',
        downloadUrl: Platform.isAndroid ? _playStoreUrl : _appStoreUrl,
      );
    }
    
    // Fallback to version string comparison
    final current = _parseVersion(currentVersion);
    final latest = _parseVersion(latestVersion);
    
    if (latest.major > current.major ||
        (latest.major == current.major && latest.minor > current.minor) ||
        (latest.major == current.major && latest.minor == current.minor && latest.patch > current.patch)) {
      return UpdateInfo(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        isRequired: isRequired,
        updateMessage: message ?? 'A new version is available with bug fixes and improvements!',
        downloadUrl: Platform.isAndroid ? _playStoreUrl : _appStoreUrl,
      );
    }
    
    return null;
  }
  
  /// Check GitHub releases for update (optional fallback)
  Future<UpdateInfo?> _checkGitHubForUpdate() async {
    // Skip if URL not configured
    if (_githubApiUrl.contains('YOUR_')) return null;
    
    try {
      final response = await http.get(Uri.parse(_githubApiUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['tag_name']?.replaceAll('v', '') ?? '';
        
        if (latestVersion.isNotEmpty) {
          return _compareVersions(
            currentVersion: _currentVersion,
            currentBuild: _currentBuildNumber,
            latestVersion: latestVersion,
            latestBuild: _currentBuildNumber + 1, // Assume newer
            isRequired: false,
          );
        }
      }
    } catch (e) {
      debugPrint('⚠️ GitHub update check failed: $e');
    }
    
    return null;
  }
  
  /// Parse version string (e.g., "1.2.3") into components
  Version _parseVersion(String version) {
    final parts = version.split('.');
    return Version(
      major: parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0,
      minor: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      patch: parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0,
    );
  }
  
  /// Open the store page for updates
  Future<void> openStorePage() async {
    final url = Platform.isAndroid ? _playStoreUrl : _appStoreUrl;
    final uri = Uri.parse(url);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      debugPrint('❌ Could not launch store URL: $url');
    }
  }
  
  /// Dismiss the current update notification
  Future<void> dismissUpdate(String version) async {
    if (!_isInitialized) await initialize();
    await _prefs.setString(_dismissedVersionKey, version);
    debugPrint('✅ Dismissed update version: $version');
  }
  
  /// Clear dismissed version (useful when forcing update check)
  Future<void> clearDismissedVersion() async {
    if (!_isInitialized) await initialize();
    await _prefs.remove(_dismissedVersionKey);
  }
}

/// Update information model
class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final bool isRequired;
  final String updateMessage;
  final String downloadUrl;
  
  const UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.isRequired,
    required this.updateMessage,
    required this.downloadUrl,
  });
}

/// Version components for comparison
class Version {
  final int major;
  final int minor;
  final int patch;
  
  const Version({
    required this.major,
    required this.minor,
    required this.patch,
  });
}
