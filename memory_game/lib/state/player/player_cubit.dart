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

  Future<void> updateLevelProgress(GameResult result) async {
    final current = state.levelProgress[result.level];
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

    // Check achievements
    _achievementService.checkAndUnlock(
      matchesMade: result.matches,
      levelsCompleted: newLevelProgress.values.where((p) => p.completed).length,
      currentStreak: result.longestStreak,
      perfectGame: result.isPerfect,
    );

    // Update player
    final newPlayer = state.player.copyWith(
      coins: state.player.coins + result.totalCoins,
      xp: state.player.xp + result.xpEarned,
      totalGamesPlayed: state.player.totalGamesPlayed + 1,
      perfectGames: result.isPerfect ? state.player.perfectGames + 1 : state.player.perfectGames,
      longestStreak: result.longestStreak > state.player.longestStreak
          ? result.longestStreak
          : state.player.longestStreak,
      lastPlayedDate: DateTime.now(),
    );

    emit(state.copyWith(
      player: newPlayer,
      levelProgress: newLevelProgress,
      achievementProgress: _achievementService.progress,
    ));

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

    final newPlayer = state.player.copyWith(powerUpInventory: newInventory);
    emit(state.copyWith(player: newPlayer));
    await _storageService.savePlayer(newPlayer);
    return true;
  }

  Future<void> unlockTheme(String themeId) async {
    if (state.player.unlockedThemes.contains(themeId)) return;

    final newThemes = [...state.player.unlockedThemes, themeId];
    final newPlayer = state.player.copyWith(unlockedThemes: newThemes);
    emit(state.copyWith(player: newPlayer));
    await _storageService.savePlayer(newPlayer);
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
