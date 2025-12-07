import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/models.dart';
import '../../domain/services/services.dart';
import 'player_state.dart';

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

  Future<void> loadPlayerData() async {
    emit(state.copyWith(isLoading: true));

    final player = _storageService.loadPlayer() ?? PlayerModel.newPlayer();
    final settings = _storageService.loadSettings();
    final levelProgress = _storageService.loadLevelProgress();
    final achievementProgress = _storageService.loadAchievements();
    final dailyRewardStatus = _storageService.loadDailyRewardStatus();

    _achievementService.loadProgress(achievementProgress);
    _dailyRewardService.loadStatus(dailyRewardStatus);

    emit(PlayerState(
      player: player,
      settings: settings,
      levelProgress: levelProgress,
      achievementProgress: _achievementService.progress,
      dailyRewardStatus: _dailyRewardService.status,
      isLoading: false,
    ));
  }

  /// Newly unlocked achievements from the last level completion
  List<String> _lastUnlockedAchievements = [];
  List<String> get lastUnlockedAchievements => _lastUnlockedAchievements;
  
  /// Newly available themes (can be unlocked now)
  List<String> _lastUnlockedThemeAvailability = [];
  List<String> get lastUnlockedThemeAvailability => _lastUnlockedThemeAvailability;

  Future<void> updateLevelProgress(GameResult result) async {
    final current = state.levelProgress[result.level];
    final previousHighestLevel = state.highestUnlockedLevel;
    
    final newProgress = LevelProgress(
      level: result.level,
      stars: current != null && current.stars > result.stars ? current.stars : result.stars,
      bestMoves: current != null && current.bestMoves > 0 && current.bestMoves < result.moves
          ? current.bestMoves
          : result.moves,
      bestTime: current != null && current.bestTime > Duration.zero && current.bestTime < result.timeTaken
          ? current.bestTime
          : result.timeTaken,
      completed: true,
      attempts: (current?.attempts ?? 0) + 1,
    );

    final newLevelProgress = Map<int, LevelProgress>.from(state.levelProgress);
    newLevelProgress[result.level] = newProgress;

    // Calculate stats for achievements
    final levelsCompleted = newLevelProgress.values.where((p) => p.completed).length;
    final threeStarCount = newLevelProgress.values.where((p) => p.stars >= 3).length;
    final newTotalStars = state.player.totalStars + result.stars;
    final newTotalCoinsEarned = state.player.totalCoinsEarned + result.totalCoins;
    final newTotalMatchesMade = state.player.totalMatchesMade + result.matches;
    final newPerfectGames = result.isPerfect ? state.player.perfectGames + 1 : state.player.perfectGames;
    final levelTimeSeconds = result.timeTaken.inSeconds;
    final newFastestTime = levelTimeSeconds < state.player.fastestLevelTime 
        ? levelTimeSeconds 
        : state.player.fastestLevelTime;
    final newBossLevelsCompleted = (result.level % 10 == 0) 
        ? state.player.bossLevelsCompleted + 1 
        : state.player.bossLevelsCompleted;

    // Check achievements and store newly unlocked ones
    _lastUnlockedAchievements = _achievementService.checkAndUnlock(
      matchesMade: result.matches,
      levelsCompleted: levelsCompleted,
      currentStreak: result.longestStreak,
      perfectGame: result.isPerfect,
      perfectGamesCount: newPerfectGames,
      totalStars: newTotalStars,
      themesUnlocked: state.player.unlockedThemes.length,
      dailyStreak: state.player.currentDailyStreak,
      totalCoinsEarned: newTotalCoinsEarned,
      powerUpsUsed: state.player.powerUpsUsed,
      threeStarLevels: threeStarCount,
      totalMatches: newTotalMatchesMade,
      bossLevelsCompleted: newBossLevelsCompleted,
      fastestLevelSeconds: newFastestTime,
    );

    // Update player
    final newPlayer = state.player.copyWith(
      coins: state.player.coins + result.totalCoins,
      xp: state.player.xp + result.xpEarned,
      totalStars: newTotalStars,
      totalGamesPlayed: state.player.totalGamesPlayed + 1,
      perfectGames: newPerfectGames,
      longestStreak: result.longestStreak > state.player.longestStreak
          ? result.longestStreak
          : state.player.longestStreak,
      lastPlayedDate: DateTime.now(),
      totalCoinsEarned: newTotalCoinsEarned,
      totalMatchesMade: newTotalMatchesMade,
      threeStarLevels: threeStarCount,
      bossLevelsCompleted: newBossLevelsCompleted,
      fastestLevelTime: newFastestTime,
    );

    emit(state.copyWith(
      player: newPlayer,
      levelProgress: newLevelProgress,
      achievementProgress: _achievementService.progress,
    ));
    
    // Calculate new highest level after state update
    final newHighestLevel = state.highestUnlockedLevel;
    
    // Check for newly available themes (themes that just became unlockable)
    _lastUnlockedThemeAvailability = [];
    if (newHighestLevel > previousHighestLevel) {
      // Import themes list from level generator
      const themeUnlockLevels = {
        'space': 8,
        'food': 15,
        'nature': 25,
        'sports': 35,
        'travel': 45,
        'emotions': 55,
        'music': 70,
      };
      
      for (final entry in themeUnlockLevels.entries) {
        if (previousHighestLevel < entry.value && newHighestLevel >= entry.value) {
          if (!state.player.unlockedThemes.contains(entry.key)) {
            _lastUnlockedThemeAvailability.add(entry.key);
          }
        }
      }
    }

    // Save
    await _storageService.savePlayer(newPlayer);
    await _storageService.saveLevelProgress(newLevelProgress);
    await _storageService.saveAchievements(_achievementService.progress);
  }

  Future<void> updateSettings(SettingsModel settings) async {
    emit(state.copyWith(settings: settings));
    await _storageService.saveSettings(settings);
  }

  Future<void> addCoins(int amount) async {
    final newPlayer = state.player.copyWith(coins: state.player.coins + amount);
    emit(state.copyWith(player: newPlayer));
    await _storageService.savePlayer(newPlayer);
  }

  Future<void> addGems(int amount) async {
    final newPlayer = state.player.copyWith(gems: state.player.gems + amount);
    emit(state.copyWith(player: newPlayer));
    await _storageService.savePlayer(newPlayer);
  }

  Future<bool> spendCoins(int amount) async {
    if (!state.player.canAffordCoins(amount)) return false;
    final newPlayer = state.player.copyWith(coins: state.player.coins - amount);
    emit(state.copyWith(player: newPlayer));
    await _storageService.savePlayer(newPlayer);
    return true;
  }

  Future<bool> spendGems(int amount) async {
    if (!state.player.canAffordGems(amount)) return false;
    final newPlayer = state.player.copyWith(gems: state.player.gems - amount);
    emit(state.copyWith(player: newPlayer));
    await _storageService.savePlayer(newPlayer);
    return true;
  }

  Future<bool> buyPowerUp(String powerUpId, {bool useGems = false}) async {
    final config = PowerUpConfigs.getConfigById(powerUpId);
    if (config == null) return false;

    final cost = useGems ? config.gemCost : config.coinCost;
    final canAfford = useGems
        ? state.player.canAffordGems(cost)
        : state.player.canAffordCoins(cost);

    if (!canAfford) return false;

    final newInventory = Map<String, int>.from(state.player.powerUpInventory);
    newInventory[powerUpId] = (newInventory[powerUpId] ?? 0) + 1;

    final newPlayer = state.player.copyWith(
      coins: useGems ? state.player.coins : state.player.coins - cost,
      gems: useGems ? state.player.gems - cost : state.player.gems,
      powerUpInventory: newInventory,
    );

    emit(state.copyWith(player: newPlayer));
    await _storageService.savePlayer(newPlayer);
    return true;
  }

  Future<bool> usePowerUp(String powerUpId) async {
    final count = state.player.getPowerUpCount(powerUpId);
    if (count <= 0) return false;

    final newInventory = Map<String, int>.from(state.player.powerUpInventory);
    newInventory[powerUpId] = count - 1;

    final newPowerUpsUsed = state.player.powerUpsUsed + 1;
    
    // Check power-up achievements
    final newlyUnlocked = _achievementService.checkAndUnlock(
      powerUpsUsed: newPowerUpsUsed,
    );
    if (newlyUnlocked.isNotEmpty) {
      _lastUnlockedAchievements = newlyUnlocked;
    }

    final newPlayer = state.player.copyWith(
      powerUpInventory: newInventory,
      powerUpsUsed: newPowerUpsUsed,
    );
    emit(state.copyWith(
      player: newPlayer,
      achievementProgress: _achievementService.progress,
    ));
    await _storageService.savePlayer(newPlayer);
    await _storageService.saveAchievements(_achievementService.progress);
    return true;
  }

  Future<void> unlockTheme(String themeId) async {
    if (state.player.unlockedThemes.contains(themeId)) return;

    final newThemes = [...state.player.unlockedThemes, themeId];
    
    // Check theme collection achievements
    final newlyUnlocked = _achievementService.checkAndUnlock(
      themesUnlocked: newThemes.length,
    );
    if (newlyUnlocked.isNotEmpty) {
      _lastUnlockedAchievements = newlyUnlocked;
    }
    
    final newPlayer = state.player.copyWith(unlockedThemes: newThemes);
    emit(state.copyWith(
      player: newPlayer,
      achievementProgress: _achievementService.progress,
    ));
    await _storageService.savePlayer(newPlayer);
    await _storageService.saveAchievements(_achievementService.progress);
  }

  Future<void> equipTheme(String themeId) async {
    final newPlayer = state.player.copyWith(equippedTheme: themeId);
    emit(state.copyWith(player: newPlayer));
    await _storageService.savePlayer(newPlayer);
  }

  Future<DailyReward?> claimDailyReward() async {
    final reward = _dailyRewardService.claim();
    if (reward == null) return null;

    int newCoins = state.player.coins;
    int newGems = state.player.gems;
    final newInventory = Map<String, int>.from(state.player.powerUpInventory);

    for (final r in reward.rewards) {
      switch (r.type) {
        case RewardType.coins:
          newCoins += r.amount;
          break;
        case RewardType.gems:
          newGems += r.amount;
          break;
        case RewardType.powerUp:
          if (r.itemId != null) {
            newInventory[r.itemId!] = (newInventory[r.itemId!] ?? 0) + r.amount;
          }
          break;
        case RewardType.theme:
          if (r.itemId != null) {
            await unlockTheme(r.itemId!);
          }
          break;
      }
    }

    final newPlayer = state.player.copyWith(
      coins: newCoins,
      gems: newGems,
      powerUpInventory: newInventory,
    );

    emit(state.copyWith(
      player: newPlayer,
      dailyRewardStatus: _dailyRewardService.status,
    ));

    await _storageService.savePlayer(newPlayer);
    await _storageService.saveDailyRewardStatus(_dailyRewardService.status);

    return reward;
  }

  Future<void> claimAchievementReward(String achievementId) async {
    final achievement = Achievements.getById(achievementId);
    if (achievement == null) return;

    _achievementService.claimReward(achievementId);

    int newCoins = state.player.coins;
    int newGems = state.player.gems;
    final newInventory = Map<String, int>.from(state.player.powerUpInventory);

    for (final r in achievement.rewards) {
      switch (r.type) {
        case RewardType.coins:
          newCoins += r.amount;
          break;
        case RewardType.gems:
          newGems += r.amount;
          break;
        case RewardType.powerUp:
          if (r.itemId != null) {
            newInventory[r.itemId!] = (newInventory[r.itemId!] ?? 0) + r.amount;
          }
          break;
        case RewardType.theme:
          if (r.itemId != null) {
            await unlockTheme(r.itemId!);
          }
          break;
      }
    }

    final newPlayer = state.player.copyWith(
      coins: newCoins,
      gems: newGems,
      powerUpInventory: newInventory,
    );

    emit(state.copyWith(
      player: newPlayer,
      achievementProgress: _achievementService.progress,
    ));

    await _storageService.savePlayer(newPlayer);
    await _storageService.saveAchievements(_achievementService.progress);
  }

  Future<void> resetProgress() async {
    await _storageService.clearAll();
    emit(PlayerState(player: PlayerModel.newPlayer(), isLoading: false));
  }
}
