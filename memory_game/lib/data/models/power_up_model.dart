import 'package:equatable/equatable.dart';

enum PowerUpType { peek, freeze, hint, undo, magnet, doubleCoins, shield }

class PowerUpConfig extends Equatable {
  final PowerUpType type;
  final String id;
  final String name;
  final String description;
  final String icon;
  final int coinCost;
  final int gemCost;
  final Duration? duration;

  const PowerUpConfig({
    required this.type,
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.coinCost,
    required this.gemCost,
    this.duration,
  });

  @override
  List<Object?> get props => [type, id, name, coinCost, gemCost];
}

class PowerUpConfigs {
  PowerUpConfigs._();

  static const PowerUpConfig peek = PowerUpConfig(
    type: PowerUpType.peek,
    id: 'peek',
    name: 'Peek',
    description: 'Reveal all cards for 3 seconds',
    icon: '👁️',
    coinCost: 150,
    gemCost: 5,
    duration: Duration(seconds: 3),
  );

  static const PowerUpConfig freeze = PowerUpConfig(
    type: PowerUpType.freeze,
    id: 'freeze',
    name: 'Freeze',
    description: 'Pause timer for 10 seconds',
    icon: '❄️',
    coinCost: 120,
    gemCost: 4,
    duration: Duration(seconds: 10),
  );

  static const PowerUpConfig hint = PowerUpConfig(
    type: PowerUpType.hint,
    id: 'hint',
    name: 'Hint',
    description: 'Highlight a matching pair',
    icon: '🔦',
    coinCost: 100,
    gemCost: 3,
  );

  static const PowerUpConfig undo = PowerUpConfig(
    type: PowerUpType.undo,
    id: 'undo',
    name: 'Undo',
    description: 'Undo your last wrong match',
    icon: '↩️',
    coinCost: 80,
    gemCost: 3,
  );

  static const PowerUpConfig magnet = PowerUpConfig(
    type: PowerUpType.magnet,
    id: 'magnet',
    name: 'Magnet',
    description: 'Auto-match one pair instantly',
    icon: '🧲',
    coinCost: 200,
    gemCost: 7,
  );

  static const PowerUpConfig doubleCoins = PowerUpConfig(
    type: PowerUpType.doubleCoins,
    id: 'double_coins',
    name: 'Double Coins',
    description: '2x coins for the next level',
    icon: '💰',
    coinCost: 250,
    gemCost: 8,
  );

  static const PowerUpConfig shield = PowerUpConfig(
    type: PowerUpType.shield,
    id: 'shield',
    name: 'Shield',
    description: 'Protect from 1 wrong match penalty',
    icon: '🛡️',
    coinCost: 180,
    gemCost: 6,
  );

  static const List<PowerUpConfig> all = [peek, freeze, hint, undo, magnet, doubleCoins, shield];

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
