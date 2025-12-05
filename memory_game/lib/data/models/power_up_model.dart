import 'package:equatable/equatable.dart';

/// Types of power-ups available in the game
enum PowerUpType {
  peek,       // Reveal all cards briefly
  freeze,     // Pause timer
  hint,       // Highlight a matching pair
  undo,       // Undo last wrong match
  magnet,     // Auto-match one pair
  doubleCoins, // Double coins for level
  shield,     // Protect from one mistake
}

/// Power-up configuration
class PowerUpConfig extends Equatable {
  final PowerUpType type;
  final String id;
  final String name;
  final String description;
  final String icon;
  final int coinCost;
  final int gemCost;
  final Duration? duration;
  final Duration? cooldown;

  const PowerUpConfig({
    required this.type,
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.coinCost,
    required this.gemCost,
    this.duration,
    this.cooldown,
  });

  @override
  List<Object?> get props => [type, id, name, coinCost, gemCost];
}

/// Predefined power-up configurations
class PowerUpConfigs {
  PowerUpConfigs._();

  static const PowerUpConfig peek = PowerUpConfig(
    type: PowerUpType.peek,
    id: 'peek',
    name: 'Peek',
    description: 'Reveal all cards for 3 seconds',
    icon: '👁️',
    coinCost: 50,
    gemCost: 2,
    duration: Duration(seconds: 3),
    cooldown: Duration(minutes: 5),
  );

  static const PowerUpConfig freeze = PowerUpConfig(
    type: PowerUpType.freeze,
    id: 'freeze',
    name: 'Freeze',
    description: 'Pause timer for 10 seconds',
    icon: '❄️',
    coinCost: 40,
    gemCost: 2,
    duration: Duration(seconds: 10),
  );

  static const PowerUpConfig hint = PowerUpConfig(
    type: PowerUpType.hint,
    id: 'hint',
    name: 'Hint',
    description: 'Highlight a matching pair',
    icon: '🔦',
    coinCost: 30,
    gemCost: 1,
  );

  static const PowerUpConfig undo = PowerUpConfig(
    type: PowerUpType.undo,
    id: 'undo',
    name: 'Undo',
    description: 'Undo your last wrong match',
    icon: '↩️',
    coinCost: 25,
    gemCost: 1,
  );

  static const PowerUpConfig magnet = PowerUpConfig(
    type: PowerUpType.magnet,
    id: 'magnet',
    name: 'Magnet',
    description: 'Auto-match one pair',
    icon: '🧲',
    coinCost: 75,
    gemCost: 3,
  );

  static const PowerUpConfig doubleCoins = PowerUpConfig(
    type: PowerUpType.doubleCoins,
    id: 'doubleCoins',
    name: 'Double Coins',
    description: '2x coins for this level',
    icon: '💰',
    coinCost: 100,
    gemCost: 4,
  );

  static const PowerUpConfig shield = PowerUpConfig(
    type: PowerUpType.shield,
    id: 'shield',
    name: 'Shield',
    description: 'Protect from one mistake',
    icon: '🛡️',
    coinCost: 60,
    gemCost: 2,
  );

  static const List<PowerUpConfig> all = [
    peek,
    freeze,
    hint,
    undo,
    magnet,
    doubleCoins,
    shield,
  ];

  static PowerUpConfig getConfig(PowerUpType type) {
    return all.firstWhere((config) => config.type == type);
  }

  static PowerUpConfig? getConfigById(String id) {
    try {
      return all.firstWhere((config) => config.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Active power-up state during gameplay
class ActivePowerUp extends Equatable {
  final PowerUpType type;
  final DateTime activatedAt;
  final Duration duration;

  const ActivePowerUp({
    required this.type,
    required this.activatedAt,
    required this.duration,
  });

  bool get isExpired {
    return DateTime.now().isAfter(activatedAt.add(duration));
  }

  Duration get remainingTime {
    final endTime = activatedAt.add(duration);
    final remaining = endTime.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  List<Object?> get props => [type, activatedAt, duration];
}
