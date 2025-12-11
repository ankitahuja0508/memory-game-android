import 'package:equatable/equatable.dart';

class SettingsModel extends Equatable {
  final bool soundEnabled;
  final bool musicEnabled;
  final bool vibrationEnabled;
  final bool showMemorizationDialog; // Show memorization dialog before game starts
  final bool tutorialCompleted; // Has user seen the tutorial

  const SettingsModel({
    this.soundEnabled = true,
    this.musicEnabled = true,
    this.vibrationEnabled = true,
    this.showMemorizationDialog = true,
    this.tutorialCompleted = false,
  });

  SettingsModel copyWith({
    bool? soundEnabled,
    bool? musicEnabled,
    bool? vibrationEnabled,
    bool? showMemorizationDialog,
    bool? tutorialCompleted,
  }) => SettingsModel(
    soundEnabled: soundEnabled ?? this.soundEnabled,
    musicEnabled: musicEnabled ?? this.musicEnabled,
    vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    showMemorizationDialog: showMemorizationDialog ?? this.showMemorizationDialog,
    tutorialCompleted: tutorialCompleted ?? this.tutorialCompleted,
  );

  Map<String, dynamic> toJson() => {
    'soundEnabled': soundEnabled,
    'musicEnabled': musicEnabled,
    'vibrationEnabled': vibrationEnabled,
    'showMemorizationDialog': showMemorizationDialog,
    'tutorialCompleted': tutorialCompleted,
  };

  factory SettingsModel.fromJson(Map<String, dynamic> json) => SettingsModel(
    soundEnabled: json['soundEnabled'] as bool? ?? true,
    musicEnabled: json['musicEnabled'] as bool? ?? true,
    vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    // Support old 'showPreview' key for backward compatibility
    showMemorizationDialog: json['showMemorizationDialog'] as bool? ?? json['showPreview'] as bool? ?? true,
    tutorialCompleted: json['tutorialCompleted'] as bool? ?? false,
  );

  @override
  List<Object?> get props => [soundEnabled, musicEnabled, vibrationEnabled, showMemorizationDialog, tutorialCompleted];
}
