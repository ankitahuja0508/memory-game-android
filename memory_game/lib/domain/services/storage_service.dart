import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/models.dart';

class StorageService {
  late SharedPreferences _prefs;

  static const String _playerKey = 'player_data';
  static const String _settingsKey = 'settings';
  static const String _levelProgressKey = 'level_progress';
  static const String _achievementsKey = 'achievements';
  static const String _dailyRewardKey = 'daily_reward';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Player Data
  Future<void> savePlayer(PlayerModel player) async {
    await _prefs.setString(_playerKey, jsonEncode(player.toJson()));
  }

  PlayerModel? loadPlayer() {
    final data = _prefs.getString(_playerKey);
    if (data == null) return null;
    return PlayerModel.fromJson(jsonDecode(data));
  }

  // Settings
  Future<void> saveSettings(SettingsModel settings) async {
    await _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  SettingsModel loadSettings() {
    final data = _prefs.getString(_settingsKey);
    if (data == null) return const SettingsModel();
    return SettingsModel.fromJson(jsonDecode(data));
  }

  // Level Progress
  Future<void> saveLevelProgress(Map<int, LevelProgress> progress) async {
    final map = progress.map((k, v) => MapEntry(k.toString(), v.toJson()));
    await _prefs.setString(_levelProgressKey, jsonEncode(map));
  }

  Map<int, LevelProgress> loadLevelProgress() {
    final data = _prefs.getString(_levelProgressKey);
    if (data == null) return {};
    final map = jsonDecode(data) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(int.parse(k), LevelProgress.fromJson(v)));
  }

  // Achievements
  Future<void> saveAchievements(Map<String, AchievementProgress> progress) async {
    final map = progress.map((k, v) => MapEntry(k, v.toJson()));
    await _prefs.setString(_achievementsKey, jsonEncode(map));
  }

  Map<String, AchievementProgress> loadAchievements() {
    final data = _prefs.getString(_achievementsKey);
    if (data == null) return {};
    final map = jsonDecode(data) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, AchievementProgress.fromJson(v)));
  }

  // Daily Rewards
  Future<void> saveDailyRewardStatus(DailyRewardStatus status) async {
    await _prefs.setString(_dailyRewardKey, jsonEncode(status.toJson()));
  }

  DailyRewardStatus loadDailyRewardStatus() {
    final data = _prefs.getString(_dailyRewardKey);
    if (data == null) return const DailyRewardStatus();
    return DailyRewardStatus.fromJson(jsonDecode(data));
  }

  // Reset
  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
