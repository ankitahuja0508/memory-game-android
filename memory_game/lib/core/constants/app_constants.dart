/// Application-wide constants
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Memory Match';
  static const String appVersion = '1.0.0';

  // Game Settings
  static const int maxEnergy = 5;
  static const int energyRefillMinutes = 30;
  static const int freeHintsPerDay = 3;
  static const int maxLevel = 9999; // Essentially infinite

  // Animation Durations (milliseconds)
  static const int cardFlipDuration = 300;
  static const int matchCelebrationDuration = 500;
  static const int mismatchShakeDuration = 400;
  static const int peekRevealDuration = 3000;
  static const int freezeDuration = 10000;

  // Game Timings
  static const int cardShowDuration = 1500; // How long mismatched cards show
  static const int introAnimationDelay = 500;

  // Rewards
  static const int baseCoinsPerLevel = 10;
  static const int threeStarBonus = 25;
  static const int perfectGameBonus = 50;
  static const int speedBonus = 15;
  static const int streakBonusPerMatch = 5;
  static const int dailyLoginReward = 50;
  static const int watchAdReward = 30;

  // XP
  static const int xpPerLevel = 20;
  static const int xpPerStar = 10;
  static const int xpPerfectGame = 50;
  static const int xpAchievement = 100;

  // Power-up Costs
  static const int peekCost = 50;
  static const int freezeCost = 40;
  static const int hintCost = 30;
  static const int undoCost = 25;
  static const int magnetCost = 75;

  // Gem Costs
  static const int peekGemCost = 2;
  static const int freezeGemCost = 2;
  static const int hintGemCost = 1;
  static const int undoGemCost = 1;
  static const int magnetGemCost = 3;

  // Storage Keys
  static const String playerDataKey = 'player_data';
  static const String settingsKey = 'settings';
  static const String achievementsKey = 'achievements';
  static const String dailyRewardsKey = 'daily_rewards';
  static const String levelProgressKey = 'level_progress';
}

/// Card theme symbols
class CardSymbols {
  CardSymbols._();

  static const List<String> animals = [
    '🐶', '🐱', '🐼', '🦊', '🐰', '🦁', '🐸', '🐵', '🦋', '🐢',
    '🐘', '🦒', '🐬', '🦜', '🐝', '🐞', '🦉', '🐧', '🦀', '🐙',
  ];

  static const List<String> space = [
    '🚀', '🌙', '⭐', '🪐', '👽', '🛸', '☄️', '🌍', '🌌', '🔭',
    '🌟', '🌠', '🛰️', '🌑', '🌕', '💫', '🌈', '☀️', '🌊', '⚡',
  ];

  static const List<String> food = [
    '🍕', '🍔', '🍟', '🌮', '🍩', '🍦', '🍰', '🍎', '🍇', '🥤',
    '🍪', '🧁', '🍫', '🥨', '🍿', '🥐', '🍓', '🍌', '🥝', '🍒',
  ];

  static const List<String> nature = [
    '🌸', '🌺', '🌻', '🌹', '🌷', '🍀', '🌴', '🌵', '🍁', '🍂',
    '🌲', '🌳', '🌾', '🌱', '💐', '🪻', '🪷', '🌿', '☘️', '🪴',
  ];

  static const List<String> sports = [
    '⚽', '🏀', '🏈', '⚾', '🎾', '🏐', '🏓', '🎱', '🏆', '🎯',
    '🎳', '⛳', '🏊', '🚴', '🏄', '⛷️', '🎿', '🏋️', '🤸', '🧗',
  ];

  static const List<String> travel = [
    '✈️', '🚗', '🚂', '🚢', '🏰', '🗼', '🗽', '🎡', '🏖️', '🏔️',
    '🌋', '🏕️', '🌉', '🎢', '⛺', '🚁', '🚤', '🛳️', '🏝️', '🗿',
  ];

  static const List<String> emotions = [
    '😀', '😍', '🥳', '😎', '🤩', '😇', '🥰', '😊', '🤗', '😋',
    '🤓', '😜', '🤠', '🥸', '😺', '💀', '👻', '🤖', '👾', '🎃',
  ];

  static const List<String> music = [
    '🎵', '🎶', '🎸', '🎹', '🥁', '🎺', '🎻', '🪕', '🎤', '🎧',
    '📻', '🪗', '🎷', '🪘', '🔔', '🎼', '🎙️', '📯', '🪇', '🥏',
  ];
}
