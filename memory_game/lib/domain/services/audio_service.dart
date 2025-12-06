import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import '../../data/models/settings_model.dart';

/// Audio service for playing game sounds and background music.
/// 
/// This is a singleton - use AudioService.instance to access.
/// Call AudioService.instance.initialize() once at app startup.
/// 
/// ## Required Audio Files (in assets/audio/):
/// - card_flip.mp3      - Card flip sound (short whoosh)
/// - match_success.mp3  - Correct match (chime/ding)
/// - match_fail.mp3     - Wrong match (soft buzz)
/// - level_complete.mp3 - Level victory (fanfare)
/// - achievement.mp3    - Achievement unlocked (triumphant)
/// - power_up.mp3       - Power-up activation (magic sparkle)
/// - button_click.mp3   - UI button press (soft click)
/// - timer_warning.mp3  - Low time alert (tick)
/// - countdown.mp3      - Countdown beep (beep)
/// - background_music.mp3 - Game background music (looping)
class AudioService {
  // Singleton instance
  static final AudioService _instance = AudioService._internal();
  static AudioService get instance => _instance;
  
  // Private constructor for singleton
  AudioService._internal();
  
  // Public constructor for backwards compatibility (returns singleton)
  factory AudioService() => _instance;

  // Separate players for different sound types
  final AudioPlayer _sfxPlayer = AudioPlayer();
  final AudioPlayer _musicPlayer = AudioPlayer();
  
  // Pre-cached audio sources for quick playback
  final Map<String, bool> _audioAvailable = {};
  
  SettingsModel _settings = const SettingsModel();
  bool _isMusicPlaying = false;
  bool _isInitialized = false;
  bool _isInitializing = false;

  /// Check if the audio service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the audio service and check available audio files
  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;
    _isInitializing = true;
    
    // List of all audio files to check
    final audioFiles = [
      'card_flip.mp3',
      'match_success.mp3',
      'match_fail.mp3',
      'level_complete.mp3',
      'achievement.mp3',
      'power_up.mp3',
      'button_click.mp3',
      'timer_warning.mp3',
      'countdown.mp3',
      'background_music.mp3',
    ];
    
    // Check which audio files are available
    for (final file in audioFiles) {
      try {
        await rootBundle.load('assets/audio/$file');
        _audioAvailable[file] = true;
      } catch (e) {
        _audioAvailable[file] = false;
      }
    }
    
    // Configure audio players
    await _sfxPlayer.setReleaseMode(ReleaseMode.stop);
    await _musicPlayer.setReleaseMode(ReleaseMode.loop);
    await _musicPlayer.setVolume(0.4);
    
    _isInitialized = true;
    _isInitializing = false;
  }

  /// Update audio settings (e.g., from player preferences)
  void updateSettings(SettingsModel settings) {
    final musicWasEnabled = _settings.musicEnabled;
    _settings = settings;
    
    // Handle music toggle
    if (!settings.musicEnabled && _isMusicPlaying) {
      stopMusic();
    } else if (settings.musicEnabled && !_isMusicPlaying && musicWasEnabled != settings.musicEnabled) {
      // Only auto-start if music was just enabled
      startMusic();
    }
  }

  /// Internal method to play a sound effect
  Future<void> _playSfx(String filename) async {
    if (!_settings.soundEnabled) return;
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_audioAvailable[filename] == true) {
      try {
        // Stop any current sound and play new one
        await _sfxPlayer.stop();
        await _sfxPlayer.play(AssetSource('audio/$filename'));
      } catch (e) {
        // Fall back to system sound if playback fails
        _playSystemSound();
      }
    } else {
      // Fall back to system sound when audio file not available
      _playSystemSound();
    }
  }
  
  /// Play system click sound as fallback
  void _playSystemSound() {
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {
      // Silently ignore if system sound also fails
    }
  }

  /// Play card flip sound - soft whoosh/paper sound
  Future<void> playFlip() async {
    await _playSfx('card_flip.mp3');
  }

  /// Play match success sound - satisfying chime/ding
  Future<void> playMatch() async {
    if (!_settings.soundEnabled) return;
    
    if (_audioAvailable['match_success.mp3'] == true) {
      await _playSfx('match_success.mp3');
    } else {
      // Fallback: double click pattern for positive feedback
      _playSystemSound();
      await Future.delayed(const Duration(milliseconds: 100));
      _playSystemSound();
    }
  }

  /// Play mismatch sound - soft error buzz
  Future<void> playMismatch() async {
    await _playSfx('match_fail.mp3');
  }

  /// Play level complete sound - victory fanfare
  Future<void> playSuccess() async {
    if (!_settings.soundEnabled) return;
    
    if (_audioAvailable['level_complete.mp3'] == true) {
      await _playSfx('level_complete.mp3');
    } else {
      // Fallback: triple click pattern for celebration
      for (int i = 0; i < 3; i++) {
        _playSystemSound();
        await Future.delayed(const Duration(milliseconds: 80));
      }
    }
  }

  /// Play achievement unlocked sound - triumphant brass/bells
  Future<void> playAchievement() async {
    if (!_settings.soundEnabled) return;
    
    if (_audioAvailable['achievement.mp3'] == true) {
      await _playSfx('achievement.mp3');
    } else {
      // Fallback: special pattern
      for (int i = 0; i < 4; i++) {
        _playSystemSound();
        await Future.delayed(Duration(milliseconds: 60 + (i * 20)));
      }
    }
  }

  /// Play power-up activation sound - magic sparkle
  Future<void> playPowerUp() async {
    await _playSfx('power_up.mp3');
  }

  /// Play button press sound - soft UI click
  Future<void> playButton() async {
    await _playSfx('button_click.mp3');
  }

  /// Play timer warning sound - tick/alert
  Future<void> playTimerWarning() async {
    await _playSfx('timer_warning.mp3');
  }

  /// Play countdown beep
  Future<void> playCountdown() async {
    await _playSfx('countdown.mp3');
  }

  /// Start background music (loops indefinitely)
  Future<void> startMusic() async {
    if (!_settings.musicEnabled) return;
    if (_isMusicPlaying) return;
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_audioAvailable['background_music.mp3'] == true) {
      try {
        await _musicPlayer.setSource(AssetSource('audio/background_music.mp3'));
        await _musicPlayer.setReleaseMode(ReleaseMode.loop);
        await _musicPlayer.setVolume(0.4);
        await _musicPlayer.resume();
        _isMusicPlaying = true;
      } catch (e) {
        _isMusicPlaying = false;
      }
    }
  }

  /// Stop background music
  Future<void> stopMusic() async {
    try {
      await _musicPlayer.stop();
    } catch (_) {}
    _isMusicPlaying = false;
  }

  /// Pause background music (e.g., when game is paused or app backgrounded)
  Future<void> pauseMusic() async {
    if (_isMusicPlaying) {
      try {
        await _musicPlayer.pause();
      } catch (_) {}
    }
  }

  /// Resume background music
  Future<void> resumeMusic() async {
    if (!_settings.musicEnabled) return;
    if (_isMusicPlaying) {
      try {
        await _musicPlayer.resume();
      } catch (_) {}
    }
  }

  /// Set music volume (0.0 to 1.0)
  Future<void> setMusicVolume(double volume) async {
    try {
      await _musicPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (_) {}
  }

  /// Set SFX volume (0.0 to 1.0)
  Future<void> setSfxVolume(double volume) async {
    try {
      await _sfxPlayer.setVolume(volume.clamp(0.0, 1.0));
    } catch (_) {}
  }

  /// Check if a specific audio file is available
  bool isAudioAvailable(String filename) {
    return _audioAvailable[filename] ?? false;
  }

  /// Get list of missing audio files
  List<String> getMissingAudioFiles() {
    return _audioAvailable.entries
        .where((entry) => !entry.value)
        .map((entry) => entry.key)
        .toList();
  }
  
  /// Get list of available audio files
  List<String> getAvailableAudioFiles() {
    return _audioAvailable.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();
  }

  /// Check if music is currently playing
  bool get isMusicPlaying => _isMusicPlaying;

  void dispose() {
    _sfxPlayer.dispose();
    _musicPlayer.dispose();
  }
}
