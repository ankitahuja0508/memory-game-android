import 'package:equatable/equatable.dart';

/// App settings
class SettingsModel extends Equatable {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;
  final bool notificationsEnabled;
  final double soundVolume;
  final double musicVolume;
  final String language;
  final bool showTimer;
  final bool showMoveCount;
  final String cardBackStyle;
  final bool reducedAnimations;

  const SettingsModel({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.vibrationEnabled = true,
    this.notificationsEnabled = true,
    this.soundVolume = 0.8,
    this.musicVolume = 0.5,
    this.language = 'en',
    this.showTimer = true,
    this.showMoveCount = true,
    this.cardBackStyle = 'default',
    this.reducedAnimations = false,
  });

  SettingsModel copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    bool? notificationsEnabled,
    double? soundVolume,
    double? musicVolume,
    String? language,
    bool? showTimer,
    bool? showMoveCount,
    String? cardBackStyle,
    bool? reducedAnimations,
  }) {
    return SettingsModel(
      soundEnabled: soundEnabled ?? this.soundEnabled,
      musicEnabled: musicEnabled ?? this.musicEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      soundVolume: soundVolume ?? this.soundVolume,
      musicVolume: musicVolume ?? this.musicVolume,
      language: language ?? this.language,
      showTimer: showTimer ?? this.showTimer,
      showMoveCount: showMoveCount ?? this.showMoveCount,
      cardBackStyle: cardBackStyle ?? this.cardBackStyle,
      reducedAnimations: reducedAnimations ?? this.reducedAnimations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soundEnabled': soundEnabled,
      'musicEnabled': musicEnabled,
      'vibrationEnabled': vibrationEnabled,
      'notificationsEnabled': notificationsEnabled,
      'soundVolume': soundVolume,
      'musicVolume': musicVolume,
      'language': language,
      'showTimer': showTimer,
      'showMoveCount': showMoveCount,
      'cardBackStyle': cardBackStyle,
      'reducedAnimations': reducedAnimations,
    };
  }

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      soundEnabled: json['soundEnabled'] as bool? ?? true,
      musicEnabled: json['musicEnabled'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      soundVolume: (json['soundVolume'] as num?)?.toDouble() ?? 0.8,
      musicVolume: (json['musicVolume'] as num?)?.toDouble() ?? 0.5,
      language: json['language'] as String? ?? 'en',
      showTimer: json['showTimer'] as bool? ?? true,
      showMoveCount: json['showMoveCount'] as bool? ?? true,
      cardBackStyle: json['cardBackStyle'] as String? ?? 'default',
      reducedAnimations: json['reducedAnimations'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
        soundEnabled,
        musicEnabled,
        vibrationEnabled,
        notificationsEnabled,
        soundVolume,
        musicVolume,
        language,
        showTimer,
        showMoveCount,
        cardBackStyle,
        reducedAnimations,
      ];
}
