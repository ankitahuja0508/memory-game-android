import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../data/models/settings_model.dart';

/// Audio service for playing game sounds and background music.
/// 
/// This is a singleton - use AudioService.instance to access.
/// Call AudioService.instance.initialize() once at app startup.
class AudioService {
  // Singleton instance
  static final AudioService _instance = AudioService._internal();
  static AudioService get instance => _instance;
  
  // Private constructor for singleton
  AudioService._internal();
  
  // Public constructor for backwards compatibility (returns singleton)
  factory AudioService() => _instance;

  // Separate players for different sound types
  AudioPlayer? _sfxPlayer;
  AudioPlayer? _musicPlayer;
  
  // Pre-cached audio sources for quick playback
  final Map<String, bool> _audioAvailable = {};
  
  SettingsModel _settings = const SettingsModel();
  bool _isMusicPlaying = false;
  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _musicStartedOnce = false;

  /// Check if the audio service is initialized
  bool get isInitialized => _isInitialized;

  /// Initialize the audio service and check available audio files
  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;
    _isInitializing = true;
    
    debugPrint('[AudioService] Initializing...');
    
    try {
      // Create audio players
      _sfxPlayer = AudioPlayer();
      _musicPlayer = AudioPlayer();
      
      // List of all audio files to check (with correct extensions)
      final audioFiles = [
        'card_flip.wav',
        'match_success.wav',
        'match_fail.wav',
        'level_complete.wav',
        'achievement.wav',
        'power_up.wav',
        'button_click.wav',
        'timer_warning.wav',
        'countdown.wav',
        'background_music.mp3',  // This one is actually MP3
      ];
      
      // Check which audio files are available
      for (final file in audioFiles) {
        try {
          await rootBundle.load('assets/audio/$file');
          _audioAvailable[file] = true;
          debugPrint('[AudioService] ✓ Found: $file');
        } catch (e) {
          _audioAvailable[file] = false;
          debugPrint('[AudioService] ✗ Missing: $file');
        }
      }
      
      // Configure audio players
      await _sfxPlayer?.setReleaseMode(ReleaseMode.stop);
      await _sfxPlayer?.setVolume(1.0);
      
      _isInitialized = true;
      _isInitializing = false;
      
      final availableCount = _audioAvailable.values.where((v) => v).length;
      debugPrint('[AudioService] Initialized - $availableCount/${audioFiles.length} files available');
      
    } catch (e) {
      debugPrint('[AudioService] Initialization error: $e');
      _isInitializing = false;
    }
  }

  /// Update audio settings (e.g., from player preferences)
  void updateSettings(SettingsModel settings) {
    debugPrint('[AudioService] Settings updated - sound: ${settings.soundEnabled}, music: ${settings.musicEnabled}');
    _settings = settings;
    
    // Handle music toggle
    if (!settings.musicEnabled && _isMusicPlaying) {
      stopMusic();
    }
  }

  /// Internal method to play a sound effect
  Future<void> _playSfx(String filename) async {
    if (!_settings.soundEnabled) {
      return;
    }
    
    if (!_isInitialized) {
      await initialize();
    }
    
    if (_audioAvailable[filename] == true && _sfxPlayer != null) {
      try {
        debugPrint('[AudioService] ▶ Playing: $filename');
        await _sfxPlayer!.stop();
        await _sfxPlayer!.play(AssetSource('audio/$filename'));
      } catch (e) {
        debugPrint('[AudioService] ✗ Error playing $filename: $e');
        _playSystemSound();
      }
    } else {
      _playSystemSound();
    }
  }
  
  /// Play system click sound as fallback
  void _playSystemSound() {
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (_) {}
  }

  /// Play card flip sound
  Future<void> playFlip() async {
    await _playSfx('card_flip.wav');
  }

  /// Play match success sound
  Future<void> playMatch() async {
    await _playSfx('match_success.wav');
  }

  /// Play mismatch sound
  Future<void> playMismatch() async {
    await _playSfx('match_fail.wav');
  }

  /// Play level complete sound
  Future<void> playSuccess() async {
    await _playSfx('level_complete.wav');
  }

  /// Play achievement unlocked sound
  Future<void> playAchievement() async {
    await _playSfx('achievement.wav');
  }

  /// Play power-up activation sound
  Future<void> playPowerUp() async {
    await _playSfx('power_up.wav');
  }

  /// Play button press sound
  Future<void> playButton() async {
    await _playSfx('button_click.wav');
  }

  /// Play timer warning sound
  Future<void> playTimerWarning() async {
    await _playSfx('timer_warning.wav');
  }

  /// Play countdown beep
  Future<void> playCountdown() async {
    await _playSfx('countdown.wav');
  }

  /// Start background music (loops indefinitely)
  /// Call this as soon as app starts
  Future<void> startMusic() async {
    debugPrint('[AudioService] startMusic() called');
    
    if (_isMusicPlaying) {
      debugPrint('[AudioService] Music already playing, skipping');
      return;
    }
    
    if (!_isInitialized) {
      await initialize();
    }
    
    // Check if music should play
    if (!_settings.musicEnabled) {
      debugPrint('[AudioService] Music disabled in settings');
      return;
    }
    
    if (_musicPlayer == null) {
      debugPrint('[AudioService] Music player is null');
      return;
    }
    
    if (_audioAvailable['background_music.mp3'] != true) {
      debugPrint('[AudioService] Background music file not available');
      return;
    }
    
    try {
      debugPrint('[AudioService] ♫ Starting background music...');
      
      // Stop any existing playback first
      await _musicPlayer!.stop();
      
      // Set up the music player
      await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer!.setVolume(0.4);
      
      // Play the music
      await _musicPlayer!.play(AssetSource('audio/background_music.mp3'));
      
      _isMusicPlaying = true;
      _musicStartedOnce = true;
      debugPrint('[AudioService] ♫ Background music started!');
      
    } catch (e) {
      debugPrint('[AudioService] ✗ Error starting music: $e');
      _isMusicPlaying = false;
    }
  }

  /// Stop background music
  Future<void> stopMusic() async {
    debugPrint('[AudioService] Stopping music');
    try {
      await _musicPlayer?.stop();
    } catch (_) {}
    _isMusicPlaying = false;
  }

  /// Pause background music
  Future<void> pauseMusic() async {
    if (_isMusicPlaying) {
      debugPrint('[AudioService] Pausing music');
      try {
        await _musicPlayer?.pause();
      } catch (_) {}
    }
  }

  /// Resume background music
  Future<void> resumeMusic() async {
    if (!_settings.musicEnabled) return;
    
    if (_musicStartedOnce) {
      debugPrint('[AudioService] Resuming music');
      try {
        await _musicPlayer?.resume();
        _isMusicPlaying = true;
      } catch (_) {}
    } else {
      // If music was never started, start it now
      await startMusic();
    }
  }

  /// Set music volume (0.0 to 1.0)
  Future<void> setMusicVolume(double volume) async {
    try {
      await _musicPlayer?.setVolume(volume.clamp(0.0, 1.0));
    } catch (_) {}
  }

  /// Set SFX volume (0.0 to 1.0)
  Future<void> setSfxVolume(double volume) async {
    try {
      await _sfxPlayer?.setVolume(volume.clamp(0.0, 1.0));
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
    _sfxPlayer?.dispose();
    _musicPlayer?.dispose();
  }
}
