import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../data/models/settings_model.dart';

/// Audio service for playing game sounds and background music.
/// Uses audio pool for reliable SFX playback.
class AudioService {
  static final AudioService _instance = AudioService._internal();
  static AudioService get instance => _instance;
  
  AudioService._internal();
  factory AudioService() => _instance;

  // Pool of SFX players for overlapping sounds
  final List<AudioPlayer> _sfxPool = [];
  static const int _poolSize = 5;
  int _currentPoolIndex = 0;
  
  // Dedicated music player
  AudioPlayer? _musicPlayer;
  
  // Track available audio files
  final Map<String, bool> _audioAvailable = {};
  
  SettingsModel _settings = const SettingsModel();
  bool _isMusicPlaying = false;
  bool _isInitialized = false;
  bool _isInitializing = false;

  bool get isInitialized => _isInitialized;
  bool get isMusicPlaying => _isMusicPlaying;

  /// Initialize the audio service
  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;
    _isInitializing = true;
    
    debugPrint('[Audio] Initializing...');
    
    try {
      // Create pool of SFX players
      for (int i = 0; i < _poolSize; i++) {
        final player = AudioPlayer();
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setVolume(1.0);
        _sfxPool.add(player);
      }
      
      // Create music player
      _musicPlayer = AudioPlayer();
      await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer!.setVolume(0.35);
      
      // Check available audio files
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
        'background_music.mp3',
      ];
      
      for (final file in audioFiles) {
        try {
          await rootBundle.load('assets/audio/$file');
          _audioAvailable[file] = true;
        } catch (e) {
          _audioAvailable[file] = false;
          debugPrint('[Audio] Missing: $file');
        }
      }
      
      _isInitialized = true;
      _isInitializing = false;
      
      final count = _audioAvailable.values.where((v) => v).length;
      debugPrint('[Audio] Ready - $count/${audioFiles.length} files');
      
    } catch (e) {
      debugPrint('[Audio] Init error: $e');
      _isInitializing = false;
    }
  }

  /// Update settings
  void updateSettings(SettingsModel settings) {
    _settings = settings;
    if (!settings.musicEnabled && _isMusicPlaying) {
      stopMusic();
    }
  }

  /// Get next player from pool (round-robin)
  AudioPlayer _getNextPlayer() {
    final player = _sfxPool[_currentPoolIndex];
    _currentPoolIndex = (_currentPoolIndex + 1) % _poolSize;
    return player;
  }

  /// Play a sound effect using pooled players
  Future<void> _playSfx(String filename) async {
    if (!_settings.soundEnabled) return;
    if (!_isInitialized) await initialize();
    if (_audioAvailable[filename] != true) return;
    
    try {
      final player = _getNextPlayer();
      await player.play(AssetSource('audio/$filename'));
    } catch (e) {
      // Silent fail - don't interrupt gameplay
    }
  }

  // Sound effect methods
  Future<void> playFlip() => _playSfx('card_flip.wav');
  Future<void> playMatch() => _playSfx('match_success.wav');
  Future<void> playMismatch() => _playSfx('match_fail.wav');
  Future<void> playSuccess() => _playSfx('level_complete.wav');
  Future<void> playAchievement() => _playSfx('achievement.wav');
  Future<void> playPowerUp() => _playSfx('power_up.wav');
  Future<void> playButton() => _playSfx('button_click.wav');
  Future<void> playTimerWarning() => _playSfx('timer_warning.wav');
  Future<void> playCountdown() => _playSfx('countdown.wav');

  /// Start background music
  Future<void> startMusic() async {
    if (!_settings.musicEnabled) return;
    if (_isMusicPlaying) return;
    if (!_isInitialized) await initialize();
    if (_musicPlayer == null) return;
    if (_audioAvailable['background_music.mp3'] != true) return;
    
    try {
      debugPrint('[Audio] Starting music...');
      await _musicPlayer!.stop();
      await _musicPlayer!.setVolume(0.35);
      await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer!.play(AssetSource('audio/background_music.mp3'));
      _isMusicPlaying = true;
      debugPrint('[Audio] Music playing!');
    } catch (e) {
      debugPrint('[Audio] Music error: $e');
      _isMusicPlaying = false;
    }
  }

  Future<void> stopMusic() async {
    try {
      await _musicPlayer?.stop();
    } catch (_) {}
    _isMusicPlaying = false;
  }

  Future<void> pauseMusic() async {
    if (_isMusicPlaying) {
      try {
        await _musicPlayer?.pause();
      } catch (_) {}
    }
  }

  Future<void> resumeMusic() async {
    if (!_settings.musicEnabled) return;
    if (_isMusicPlaying) {
      try {
        await _musicPlayer?.resume();
      } catch (_) {}
    } else {
      await startMusic();
    }
  }

  Future<void> setMusicVolume(double volume) async {
    try {
      await _musicPlayer?.setVolume(volume.clamp(0.0, 1.0));
    } catch (_) {}
  }

  bool isAudioAvailable(String filename) => _audioAvailable[filename] ?? false;

  void dispose() {
    for (final player in _sfxPool) {
      player.dispose();
    }
    _musicPlayer?.dispose();
  }
}
