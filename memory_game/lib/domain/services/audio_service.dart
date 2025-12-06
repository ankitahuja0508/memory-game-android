import 'package:audioplayers/audioplayers.dart';
import '../../data/models/settings_model.dart';

class AudioService {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  SettingsModel _settings = const SettingsModel();

  void updateSettings(SettingsModel settings) {
    _settings = settings;
  }

  Future<void> playFlip() async {
    if (!_settings.soundEnabled) return;
    // Using system sound as fallback
  }

  Future<void> playMatch() async {
    if (!_settings.soundEnabled) return;
  }

  Future<void> playMismatch() async {
    if (!_settings.soundEnabled) return;
  }

  Future<void> playSuccess() async {
    if (!_settings.soundEnabled) return;
  }

  Future<void> playPowerUp() async {
    if (!_settings.soundEnabled) return;
  }

  Future<void> playButton() async {
    if (!_settings.soundEnabled) return;
  }

  void dispose() {
    _sfxPlayer.dispose();
  }
}
