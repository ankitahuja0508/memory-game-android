import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/models.dart';
import '../../domain/services/services.dart';
import 'player_state.dart';

/// Cubit for managing player state
class PlayerCubit extends Cubit<PlayerState> {
  final StorageService _storageService;
  final AchievementService _achievementService;
  final DailyRewardService _dailyRewardService;

  PlayerCubit({
    required StorageService storageService,
    required AchievementService achievementService,
    required DailyRewardService dailyRewardService,
  })  : _storageService = storageService,
        _achievementService = achievementService,
        _dailyRewardService = dailyRewardService,
        super(PlayerState(player: PlayerModel.newPlayer()));

  /// Initialize player data from storage
  Future<void> init() async {
    emit(state.copyWith(isLoading: true));

    try {
      await _storageService.init();

      // Load player data
      final savedPlayer = _storageService.loadPlayer();
      final player = savedPlayer ?? PlayerModel.newPlayer();

      // Load other data
      final levelProgress = _storageService.loadLevelProgress();
      final settings = _storageService.loadSettings();
      final achievementProgress = _storageService.loadAchievements();
      final dailyRewardStatus = _storageService.loadDailyRewardStatus();

      // Initialize services
      _achievementService.init(achievementProgress);
      _dailyRewardService.init(dailyRewardStatus);

      emit(PlayerState(
        player: player,
        levelProgress: levelProgress,
        settings: settings,
        dailyRewardStatus: _dailyRewardService.status,
        achievementProgress: _achievementService.progress,
        isLoading: false,
      ));

      // Save new player if first time
      if (savedPlayer == null) {
        await _savePlayer();
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to load player data',
      ));
    }
  }

  /// Save player data
  Future<void> _savePlayer() async {
    await _storageService.savePlayer(state.player);
  }

  /// Update level progress after completing a level
  Future<void> updateLevelProgress(GameResult result) async {
    final existingProgress = state.levelProgress[result.level];
    final isNewBest = existingProgress == null ||
        result.stars > existingProgress.stars ||
        (result.stars == existingProgress.stars &&
            result.moves < existingProgress.bestMoves);

    LevelProgress newProgress;
    if (existingProgress == null) {
      newProgress = LevelProgress(
        level: result.level,
        stars: result.stars,
        bestMoves: result.moves,
        bestTime: result.timeTaken,
        completed: true,
        attempts: 1,
      );
    } else {
      newProgress = existingProgress.copyWith(
        stars: result.stars > existingProgress.stars
            ? result.stars
            : existingProgress.stars,
        bestMoves: result.moves < existingProgress.bestMoves || existingProgress.bestMoves == 0
            ? result.moves
            : existingProgress.bestMoves,
        bestTime: result.timeTaken < existingProgress.bestTime || existingProgress.bestTime == Duration.zero
            ? result.timeTaken
            : existingProgress.bestTime,
        completed: true,
        attempts: existingProgress.attempts + 1,
      );
    }

    final updatedProgress = Map<int, LevelProgress>.from(state.levelProgress);
    updatedProgress[result.level] = newProgress;

    // Update player stats
    final updatedPlayer = state.player.copyWith(
      coins: state.player.coins + result.totalCoins,
      xp: state.player.xp + result.xpEarned,
      totalStars: _calculateTotalStars(updatedProgress),
      totalGamesPlayed: state.player.totalGamesPlayed + 1,
      perfectGames: result.isPerfect
          ? state.player.perfectGames + 1
          : state.player.perfectGames,
      longestStreak: result.longestStreak > state.player.longestStreak
          ? result.longestStreak
          : state.player.longestStreak,
      currentGameLevel: result.level + 1,
      lastPlayedDate: DateTime.now(),
    );

    // Check for level up
    final finalPlayer = _checkLevelUp(updatedPlayer);

    emit(state.copyWith(
      player: finalPlayer,
      levelProgress: updatedProgress,
    ));

    // Check achievements
    _checkAchievements(result);

    // Save to storage
    await _storageService.savePlayer(finalPlayer);
    await _storageService.saveLevelProgress(updatedProgress);
  }

  int _calculateTotalStars(Map<int, LevelProgress> progress) {
    return progress.values.fold(0, (sum, p) => sum + p.stars);
  }

  PlayerModel _checkLevelUp(PlayerModel player) {
    var current = player;
    while (current.xp >= current.xpForNextLevel) {
      final remainingXp = current.xp - current.xpForNextLevel;
      current = current.copyWith(
        playerLevel: current.playerLevel + 1,
        xp: remainingXp,
      );
    }
    return current;
  }

  void _checkAchievements(GameResult result) {
    final newAchievements = _achievementService.checkAchievements(
      levelsCompleted: state.completedLevelsCount,
      totalStars: state.totalStars,
      currentStreak: result.longestStreak,
      totalMatches: result.matches,
      perfectGames: state.player.perfectGames,
      dailyStreak: state.player.currentDailyStreak,
      themesUnlocked: state.player.unlockedThemes.length,
      isPerfectGame: result.isPerfect,
      levelTime: result.timeTaken,
    );

    if (newAchievements.isNotEmpty) {
      emit(state.copyWith(
        achievementProgress: _achievementService.progress,
      ));
      _storageService.saveAchievements(_achievementService.progress);
    }
  }

  /// Add coins
  Future<void> addCoins(int amount) async {
    final updatedPlayer = state.player.copyWith(
      coins: state.player.coins + amount,
    );
    emit(state.copyWith(player: updatedPlayer));
    await _savePlayer();
  }

  /// Spend coins
  Future<bool> spendCoins(int amount) async {
    if (state.player.coins < amount) return false;

    final updatedPlayer = state.player.copyWith(
      coins: state.player.coins - amount,
    );
    emit(state.copyWith(player: updatedPlayer));
    await _savePlayer();
    return true;
  }

  /// Add gems
  Future<void> addGems(int amount) async {
    final updatedPlayer = state.player.copyWith(
      gems: state.player.gems + amount,
    );
    emit(state.copyWith(player: updatedPlayer));
    await _savePlayer();
  }

  /// Spend gems
  Future<bool> spendGems(int amount) async {
    if (state.player.gems < amount) return false;

    final updatedPlayer = state.player.copyWith(
      gems: state.player.gems - amount,
    );
    emit(state.copyWith(player: updatedPlayer));
    await _savePlayer();
    return true;
  }

  /// Add power-up to inventory
  Future<void> addPowerUp(String powerUpId, [int count = 1]) async {
    final inventory = Map<String, int>.from(state.player.powerUpInventory);
    inventory[powerUpId] = (inventory[powerUpId] ?? 0) + count;

    final updatedPlayer = state.player.copyWith(powerUpInventory: inventory);
    emit(state.copyWith(player: updatedPlayer));
    await _savePlayer();
  }

  /// Use power-up from inventory
  Future<bool> usePowerUp(String powerUpId) async {
    final count = state.player.getPowerUpCount(powerUpId);
    if (count <= 0) return false;

    final inventory = Map<String, int>.from(state.player.powerUpInventory);
    inventory[powerUpId] = count - 1;

    final updatedPlayer = state.player.copyWith(powerUpInventory: inventory);
    emit(state.copyWith(player: updatedPlayer));
    await _savePlayer();
    return true;
  }

  /// Unlock theme
  Future<void> unlockTheme(String themeId) async {
    if (state.player.unlockedThemes.contains(themeId)) return;

    final themes = List<String>.from(state.player.unlockedThemes)..add(themeId);
    final updatedPlayer = state.player.copyWith(unlockedThemes: themes);
    emit(state.copyWith(player: updatedPlayer));
    await _savePlayer();
  }

  /// Equip theme
  Future<void> equipTheme(String themeId) async {
    if (!state.player.unlockedThemes.contains(themeId)) return;

    final updatedPlayer = state.player.copyWith(equippedTheme: themeId);
    emit(state.copyWith(player: updatedPlayer));
    await _savePlayer();
  }

  /// Claim daily reward
  Future<DailyReward?> claimDailyReward() async {
    final reward = _dailyRewardService.claimReward();
    if (reward == null) return null;

    // Apply rewards
    for (final r in reward.rewards) {
      switch (r.type) {
        case RewardType.coins:
          await addCoins(r.amount);
          break;
        case RewardType.gems:
          await addGems(r.amount);
          break;
        case RewardType.powerUp:
          if (r.itemId != null) {
            await addPowerUp(r.itemId!, r.amount);
          }
          break;
        case RewardType.theme:
          if (r.itemId != null) {
            await unlockTheme(r.itemId!);
          }
          break;
        case RewardType.cardBack:
          // Handle card back unlock
          break;
      }
    }

    // Update daily streak
    final updatedPlayer = state.player.copyWith(
      currentDailyStreak: _dailyRewardService.currentStreak,
      lastDailyRewardClaim: DateTime.now(),
      dailyRewardDay: _dailyRewardService.status.currentDay,
    );

    emit(state.copyWith(
      player: updatedPlayer,
      dailyRewardStatus: _dailyRewardService.status,
    ));

    await _savePlayer();
    await _storageService.saveDailyRewardStatus(_dailyRewardService.status);

    return reward;
  }

  /// Claim achievement reward
  Future<void> claimAchievementReward(String achievementId) async {
    final achievement = Achievements.getById(achievementId);
    if (achievement == null) return;

    final progress = _achievementService.progress[achievementId];
    if (progress == null || !progress.isCompleted || progress.isRewardClaimed) {
      return;
    }

    // Apply rewards
    for (final r in achievement.rewards) {
      switch (r.type) {
        case RewardType.coins:
          await addCoins(r.amount);
          break;
        case RewardType.gems:
          await addGems(r.amount);
          break;
        case RewardType.powerUp:
          if (r.itemId != null) {
            await addPowerUp(r.itemId!, r.amount);
          }
          break;
        case RewardType.theme:
          if (r.itemId != null) {
            await unlockTheme(r.itemId!);
          }
          break;
        case RewardType.cardBack:
          // Handle card back
          break;
      }
    }

    _achievementService.claimReward(achievementId);

    emit(state.copyWith(
      achievementProgress: _achievementService.progress,
    ));

    await _storageService.saveAchievements(_achievementService.progress);
  }

  /// Update settings
  Future<void> updateSettings(SettingsModel settings) async {
    emit(state.copyWith(settings: settings));
    await _storageService.saveSettings(settings);
  }

  /// Reset all progress
  Future<void> resetProgress() async {
    await _storageService.clearAllData();

    final newPlayer = PlayerModel.newPlayer();
    _achievementService.init({});
    _dailyRewardService.init(const DailyRewardStatus());

    emit(PlayerState(
      player: newPlayer,
      settings: state.settings, // Keep settings
    ));

    await _savePlayer();
  }
}
