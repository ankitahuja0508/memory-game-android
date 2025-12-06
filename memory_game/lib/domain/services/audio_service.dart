import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../../data/models/settings_model.dart';

/// Audio service for playing game sounds.
/// Currently uses system haptics as audio feedback since no audio assets are included.
/// To add real sounds, add audio files to assets/audio/ and update the play methods.
class AudioService {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  SettingsModel _settings = const SettingsModel();
  bool _isMusicPlaying = false;

  void updateSettings(SettingsModel settings) {
    _settings = settings;
    
    // Handle music toggle
    if (!settings.musicEnabled && _isMusicPlaying) {
      stopMusic();
    }
  }

  /// Play card flip sound
  Future<void> playFlip() async {
    if (!_settings.soundEnabled) return;
    // Play a light system tick for feedback
    await SystemSound.play(SystemSoundType.click);
  }

  /// Play match success sound
  Future<void> playMatch() async {
    if (!_settings.soundEnabled) return;
    // Double click for match feedback
    await SystemSound.play(SystemSoundType.click);
    await Future.delayed(const Duration(milliseconds: 100));
    await SystemSound.play(SystemSoundType.click);
  }

  /// Play mismatch sound
  Future<void> playMismatch() async {
    if (!_settings.soundEnabled) return;
    // No system sound for mismatch - haptics handle this
  }

  /// Play level complete sound
  Future<void> playSuccess() async {
    if (!_settings.soundEnabled) return;
    // Triple click for success
    for (int i = 0; i < 3; i++) {
      await SystemSound.play(SystemSoundType.click);
      await Future.delayed(const Duration(milliseconds: 80));
    }
  }

  /// Play power-up activation sound
  Future<void> playPowerUp() async {
    if (!_settings.soundEnabled) return;
    await SystemSound.play(SystemSoundType.click);
  }

  /// Play button press sound
  Future<void> playButton() async {
    if (!_settings.soundEnabled) return;
    await SystemSound.play(SystemSoundType.click);
  }

  /// Start background music
  /// Note: Requires adding a music file to assets/audio/background_music.mp3
  Future<void> startMusic() async {
    if (!_settings.musicEnabled) return;
    // TODO: Add background music file
    // await _musicPlayer.setSource(AssetSource('audio/background_music.mp3'));
    // await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    // await _musicPlayer.resume();
    // _isMusicPlaying = true;
  }

  /// Stop background music
  Future<void> stopMusic() async {
    await _musicPlayer.stop();
    _isMusicPlaying = false;
  }

  /// Pause background music
  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  /// Resume background music
  Future<void> resumeMusic() async {
    if (!_settings.musicEnabled) return;
    await _musicPlayer.resume();
  }

  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}
