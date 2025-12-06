import 'package:equatable/equatable.dart';

class SettingsModel extends Equatable {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;
  final bool showPreview; // Show cards at start of level
  final bool tutorialCompleted; // Has user seen the tutorial

  const SettingsModel({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.vibrationEnabled = true,
    this.showPreview = true,
    this.tutorialCompleted = false,
  });

  SettingsModel copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    bool? showPreview,
    bool? tutorialCompleted,
  }) => SettingsModel(
    soundEnabled: soundEnabled ?? this.soundEnabled,
    musicEnabled: musicEnabled ?? this.musicEnabled,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    showPreview: showPreview ?? this.showPreview,
    tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
  );

  Map<String, dynamic> toJson() => {
    'soundEnabled': soundEnabled,
    'musicEnabled': musicEnabled,
    'vibrationEnabled': vibrationEnabled,
    'showPreview': showPreview,
    'tutorialCompleted': tutorialCompleted,
  };

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
    soundEnabled: json['soundEnabled'] as bool? ?? true,
    musicEnabled: json['musicEnabled'] as bool? ?? true,
    vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    showPreview: json['showPreview'] as bool? ?? true,
    tutorialCompleted: json['tutorialCompleted'] as bool? ?? false,
  );

  @override
  List<Object?> get props => [soundEnabled, musicEnabled, vibrationEnabled, showPreview, tutorialCompleted];
}
