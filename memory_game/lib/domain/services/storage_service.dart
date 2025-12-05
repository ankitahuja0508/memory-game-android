import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/models.dart';

/// Service for persisting game data
class StorageService {
  static const String _playerKey = 'player_data';
  static const String _settingsKey = 'settings';
  static const String _levelProgressKey = 'level_progress';
  static const String _achievementsKey = 'achievements';
  static const String _dailyRewardsKey = 'daily_rewards';

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // Player Data
  Future<void> savePlayer(PlayerModel player) async {
    await prefs.setString(_playerKey, jsonEncode(player.toJson()));
  }

  PlayerModel? loadPlayer() {
    final data = prefs.getString(_playerKey);
    if (data == null) return null;
    try {
      return PlayerModel.fromJson(jsonDecode(data));
    } catch (e) {
      return null;
    }
  }

  // Settings
  Future<void> saveSettings(SettingsModel settings) async {
    await prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  SettingsModel loadSettings() {
    final data = prefs.getString(_settingsKey);
    if (data == null) return const SettingsModel();
    try {
      return SettingsModel.fromJson(jsonDecode(data));
    } catch (e) {
      return const SettingsModel();
    }
  }

  // Level Progress
  Future<void> saveLevelProgress(Map<int, LevelProgress> progress) async {
    final data = progress.map(
      (key, value) => MapEntry(key.toString(), value.toJson()),
    );
    await prefs.setString(_levelProgressKey, jsonEncode(data));
  }

  Map<int, LevelProgress> loadLevelProgress() {
    final data = prefs.getString(_levelProgressKey);
    if (data == null) return {};
    try {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(
          int.parse(key),
          LevelProgress.fromJson(value as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      return {};
    }
  }

  Future<void> updateLevelProgress(int level, LevelProgress progress) async {
    final allProgress = loadLevelProgress();
    allProgress[level] = progress;
    await saveLevelProgress(allProgress);
  }

  // Achievements
  Future<void> saveAchievements(Map<String, AchievementProgress> achievements) async {
    final data = achievements.map(
      (key, value) => MapEntry(key, value.toJson()),
    );
    await prefs.setString(_achievementsKey, jsonEncode(data));
  }

  Map<String, AchievementProgress> loadAchievements() {
    final data = prefs.getString(_achievementsKey);
    if (data == null) return {};
    try {
      final decoded = jsonDecode(data) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(
          key,
          AchievementProgress.fromJson(value as Map<String, dynamic>),
        ),
      );
    } catch (e) {
      return {};
    }
  }

  // Daily Rewards
  Future<void> saveDailyRewardStatus(DailyRewardStatus status) async {
    await prefs.setString(_dailyRewardsKey, jsonEncode(status.toJson()));
  }

  DailyRewardStatus loadDailyRewardStatus() {
    final data = prefs.getString(_dailyRewardsKey);
    if (data == null) return const DailyRewardStatus();
    try {
      return DailyRewardStatus.fromJson(jsonDecode(data));
    } catch (e) {
      return const DailyRewardStatus();
    }
  }

  // Clear all data
  Future<void> clearAllData() async {
    await prefs.remove(_playerKey);
    await prefs.remove(_settingsKey);
    await prefs.remove(_levelProgressKey);
    await prefs.remove(_achievementsKey);
    await prefs.remove(_dailyRewardsKey);
  }

  // Generic helpers
  Future<void> setString(String key, String value) async {
    await prefs.setString(key, value);
  }

  String? getString(String key) {
    return prefs.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    await prefs.setInt(key, value);
  }

  int? getInt(String key) {
    return prefs.getInt(key);
  }

  Future<void> setBool(String key, bool value) async {
    await prefs.setBool(key, value);
  }

  bool? getBool(String key) {
    return prefs.getBool(key);
  }
}
