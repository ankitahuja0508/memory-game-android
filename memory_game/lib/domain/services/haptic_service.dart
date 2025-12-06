import 'package:flutter/services.dart';
import '../../data/models/settings_model.dart';

class HapticService {
  SettingsModel _settings = const SettingsModel();

  void updateSettings(SettingsModel settings) {
    _settings = settings;
  }

  void light() {
    if (!_settings.vibrationEnabled) return;
    HapticFeedback.lightImpact();
  }

  void medium() {
    if (!_settings.vibrationEnabled) return;
    HapticFeedback.mediumImpact();
  }

  void heavy() {
    if (!_settings.vibrationEnabled) return;
    HapticFeedback.heavyImpact();
  }

  void selection() {
    if (!_settings.vibrationEnabled) return;
    HapticFeedback.selectionClick();
  }

  void success() {
    if (!_settings.vibrationEnabled) return;
    HapticFeedback.mediumImpact();
  }

  void error() {
    if (!_settings.vibrationEnabled) return;
    HapticFeedback.vibrate();
  }
}
