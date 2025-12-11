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
  static const int maxLevel = 9999;

  // Preview time at start of level (milliseconds)
  static const int previewDuration = 5000; // 5 seconds to memorize

  // Animation Durations (milliseconds)
  static const int cardFlipDuration = 300;
  static const int matchCelebrationDuration = 500;
  static const int mismatchShakeDuration = 400;
  static const int peekRevealDuration = 3000;
  static const int freezeDuration = 10000;

  // Game Timings
  static const int cardShowDuration = 1000;
  static const int introAnimationDelay = 500;

  // Rewards (balanced for economy)
  static const int baseCoinsPerLevel = 20;
  static const int threeStarBonus = 40;
  static const int perfectGameBonus = 75;
  static const int speedBonus = 25;
  static const int streakBonusPerMatch = 8;
  static const int dailyLoginReward = 100;
  static const int watchAdReward = 50;

  // Starting resources for new players
  static const int startingCoins = 750;
  static const int startingGems = 25;
  static const int startingPeekPowerUps = 3;
  static const int startingFreezePowerUps = 2;
  static const int startingHintPowerUps = 5;
  static const int startingMagnetPowerUps = 2;
  static const int startingUndoPowerUps = 2;
  static const int startingShieldPowerUps = 1;

  // Power-up Costs (updated in power_up_model.dart)
  static const int peekCost = 150;
  static const int freezeCost = 120;
  static const int hintCost = 100;
  static const int undoCost = 80;
  static const int magnetCost = 200;
  static const int doubleCoinsCost = 250;
  static const int shieldCost = 180;
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
