import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../../data/models/settings_model.dart';

/// Sound effect types
enum SoundEffect {
  cardFlip,
  match,
  mismatch,
  levelComplete,
  starEarned,
  buttonTap,
  coinCollect,
  powerUp,
  achievement,
  countdown,
  gameOver,
}

/// Service for managing game audio
class AudioService {
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  double _soundVolume = 0.8;
  double _musicVolume = 0.5;

  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;

  /// Initialize audio service
  Future<void> init() async {
    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
  }

  /// Update settings
  void updateSettings(SettingsModel settings) {
    _soundEnabled = settings.soundEnabled;
    _musicEnabled = settings.musicEnabled;
    _soundVolume = settings.soundVolume;
    _musicVolume = settings.musicVolume;

    if (!_musicEnabled) {
      _musicPlayer.stop();
    }
  }

  /// Play sound effect
  Future<void> playSound(SoundEffect effect) async {
    if (!_soundEnabled) return;

    // Since we don't have actual audio files, we'll use system sounds
    // In a real app, you would load from assets
    try {
      await HapticFeedback.lightImpact();
      // Placeholder for actual sound playing
      // await _sfxPlayer.play(AssetSource(_getSoundPath(effect)));
    } catch (e) {
      // Silently fail if audio not available
    }
  }

  /// Play card flip sound
  Future<void> playFlip() => playSound(SoundEffect.cardFlip);

  /// Play match sound
  Future<void> playMatch() => playSound(SoundEffect.match);

  /// Play mismatch sound
  Future<void> playMismatch() => playSound(SoundEffect.mismatch);

  /// Play level complete sound
  Future<void> playLevelComplete() => playSound(SoundEffect.levelComplete);

  /// Play star earned sound
  Future<void> playStar() => playSound(SoundEffect.starEarned);

  /// Play button tap sound
  Future<void> playButtonTap() => playSound(SoundEffect.buttonTap);

  /// Play coin collect sound
  Future<void> playCoinCollect() => playSound(SoundEffect.coinCollect);

  /// Play power-up sound
  Future<void> playPowerUp() => playSound(SoundEffect.powerUp);

  /// Play achievement sound
  Future<void> playAchievement() => playSound(SoundEffect.achievement);

  /// Start background music
  Future<void> startMusic() async {
    if (!_musicEnabled) return;

    try {
      await _musicPlayer.setVolume(_musicVolume);
      // await _musicPlayer.play(AssetSource('audio/background_music.mp3'));
    } catch (e) {
      // Silently fail if music not available
    }
  }

  /// Stop background music
  Future<void> stopMusic() async {
    await _musicPlayer.stop();
  }

  /// Pause background music
  Future<void> pauseMusic() async {
    await _musicPlayer.pause();
  }

  /// Resume background music
  Future<void> resumeMusic() async {
    if (!_musicEnabled) return;
    await _musicPlayer.resume();
  }

  /// Set sound enabled
  void setSoundEnabled(bool enabled) {
    _soundEnabled = enabled;
  }

  /// Set music enabled
  void setMusicEnabled(bool enabled) {
    _musicEnabled = enabled;
    if (!enabled) {
      _musicPlayer.stop();
    }
  }

  /// Set sound volume
  void setSoundVolume(double volume) {
    _soundVolume = volume.clamp(0.0, 1.0);
  }

  /// Set music volume
  void setMusicVolume(double volume) {
    _musicVolume = volume.clamp(0.0, 1.0);
    _musicPlayer.setVolume(_musicVolume);
  }

  /// Dispose audio players
  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }

  String _getSoundPath(SoundEffect effect) {
    switch (effect) {
      case SoundEffect.cardFlip:
        return 'audio/flip.mp3';
      case SoundEffect.match:
        return 'audio/match.mp3';
      case SoundEffect.mismatch:
        return 'audio/mismatch.mp3';
      case SoundEffect.levelComplete:
        return 'audio/level_complete.mp3';
      case SoundEffect.starEarned:
        return 'audio/star.mp3';
      case SoundEffect.buttonTap:
        return 'audio/button.mp3';
      case SoundEffect.coinCollect:
        return 'audio/coin.mp3';
      case SoundEffect.powerUp:
        return 'audio/powerup.mp3';
      case SoundEffect.achievement:
        return 'audio/achievement.mp3';
      case SoundEffect.countdown:
        return 'audio/countdown.mp3';
      case SoundEffect.gameOver:
        return 'audio/game_over.mp3';
    }
  }
}
