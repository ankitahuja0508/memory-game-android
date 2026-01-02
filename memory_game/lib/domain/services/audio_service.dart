import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../data/models/settings_model.dart';

/// Audio service for playing game sounds and background music.
/// Uses audio pool for reliable SFX playback with robust music fallback.
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
  
  // Stream subscriptions
  StreamSubscription<void>? _musicCompletionSubscription;
  StreamSubscription<PlayerState>? _musicStateSubscription;
  StreamSubscription<Duration>? _musicPositionSubscription;
  Timer? _musicHealthCheckTimer;
  
  // Track available audio files
  final Map<String, bool> _audioAvailable = {};
  
  SettingsModel _settings = const SettingsModel();
  bool _isMusicPlaying = false;
  bool _isInitialized = false;
  bool _isInitializing = false;
  bool _isMusicDesired = false;
  bool _isRestarting = false;
  bool _expectingStop = false;
  DateTime _lastSuccessfulPlay = DateTime.now();
  DateTime _lastRestartTime = DateTime.now();
  DateTime _lastPositionUpdate = DateTime.now();
  Duration _lastPosition = Duration.zero;
  int _healthCheckCount = 0;

  bool get isInitialized => _isInitialized;
  bool get isMusicPlaying => _isMusicPlaying;
  
  void _log(String message) {
    debugPrint('[Audio ${DateTime.now().toString().substring(11, 19)}] $message');
  }

  /// Initialize the audio service
  Future<void> initialize() async {
    if (_isInitialized || _isInitializing) return;
    _isInitializing = true;
    
    _log('Initializing audio service...');
    
    try {
      // Configure audio context for SFX - no audio focus management
      // This prevents SFX from stealing focus from music
      const sfxContext = AudioContext(
        android: AudioContextAndroid(
          isSpeakerphoneOn: false,
          stayAwake: false,
          contentType: AndroidContentType.sonification,
          usageType: AndroidUsageType.game,
          audioFocus: AndroidAudioFocus.none, // Don't request focus for SFX
        ),
        iOS: AudioContextIOS(
          category: AVAudioSessionCategory.ambient,
          options: [AVAudioSessionOptions.mixWithOthers],
        ),
      );
      
      // Create pool of SFX players with no audio focus
      for (int i = 0; i < _poolSize; i++) {
        final player = AudioPlayer();
        await player.setAudioContext(sfxContext);
        await player.setReleaseMode(ReleaseMode.stop);
        await player.setVolume(1.0);
        _sfxPool.add(player);
      }
      
      // Create music player with listeners
      await _createMusicPlayer();
      
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
        }
      }
      
      _isInitialized = true;
      _isInitializing = false;
      
      final count = _audioAvailable.values.where((v) => v).length;
      _log('Initialized - $count/${audioFiles.length} audio files available');
      
    } catch (e) {
      _log('Init error: $e');
      _isInitializing = false;
    }
  }
  
  /// Create or recreate the music player with listeners
  Future<void> _createMusicPlayer() async {
    _log('Creating new music player...');
    
    // Dispose old player if exists
    _musicCompletionSubscription?.cancel();
    _musicStateSubscription?.cancel();
    _musicPositionSubscription?.cancel();
    try {
      _musicPlayer?.dispose();
    } catch (e) {
      _log('Error disposing old player: $e');
    }
    
    _musicPlayer = AudioPlayer();
    
    // Configure audio context for music - request focus and keep it
    const musicContext = AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: false,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.game,
        audioFocus: AndroidAudioFocus.gainTransientMayDuck,
      ),
      iOS: AudioContextIOS(
        category: AVAudioSessionCategory.playback,
        options: [AVAudioSessionOptions.mixWithOthers],
      ),
    );
    
    await _musicPlayer!.setAudioContext(musicContext);
    // DON'T use loop mode - we'll handle looping manually
    await _musicPlayer!.setReleaseMode(ReleaseMode.release);
    await _musicPlayer!.setVolume(0.5);
    
    // Position listener - monitors if music is actually progressing
    _musicPositionSubscription = _musicPlayer!.onPositionChanged.listen((position) {
      if (position != _lastPosition) {
        _lastPosition = position;
        _lastPositionUpdate = DateTime.now();
      }
    });
    
    // Completion listener - restart when track ends
    _musicCompletionSubscription = _musicPlayer!.onPlayerComplete.listen((_) {
      _log('🔄 Track COMPLETED - restarting');
      if (_isMusicDesired && _settings.musicEnabled) {
        _restartOnComplete();
      }
    });
    
    // State change listener
    _musicStateSubscription = _musicPlayer!.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        _lastSuccessfulPlay = DateTime.now();
        _lastPositionUpdate = DateTime.now();
        _isMusicPlaying = true;
        _expectingStop = false;
        _log('✓ Music PLAYING');
      } else if (state == PlayerState.stopped) {
        _isMusicPlaying = false;
        if (!_expectingStop && !_isRestarting) {
          _log('⚠ Music STOPPED');
        }
      } else if (state == PlayerState.paused) {
        _isMusicPlaying = false;
      } else if (state == PlayerState.completed) {
        _log('🔄 State: COMPLETED');
        _isMusicPlaying = false;
        if (_isMusicDesired && _settings.musicEnabled && !_isRestarting) {
          _restartOnComplete();
        }
      }
    });
    
    _log('Music player created');
  }
  
  /// Restart immediately when music completes (no debouncing)
  Future<void> _restartOnComplete() async {
    if (_isRestarting) return;
    
    _isRestarting = true;
    _log('>>> LOOP RESTART');
    
    try {
      if (_musicPlayer == null) {
        await _createMusicPlayer();
      }
      
      if (_musicPlayer != null) {
        await _musicPlayer!.seek(Duration.zero);
        await _musicPlayer!.resume();
        
        // If resume doesn't work, try play
        await Future.delayed(const Duration(milliseconds: 100));
        if (_musicPlayer!.state != PlayerState.playing) {
          await _musicPlayer!.play(AssetSource('audio/background_music.mp3'));
        }
        
        _isMusicPlaying = true;
        _lastSuccessfulPlay = DateTime.now();
        _lastRestartTime = DateTime.now();
        _log('<<< LOOP SUCCESS');
      }
    } catch (e) {
      _log('Loop restart error: $e, doing full restart...');
      _isRestarting = false;
      await _forceRestart('loop failed');
      return;
    }
    
    _isRestarting = false;
  }
  
  /// Force restart music with proper debouncing
  Future<void> _forceRestart(String reason) async {
    if (!_isMusicDesired || !_settings.musicEnabled) {
      _log('Skip restart ($reason): desired=$_isMusicDesired, enabled=${_settings.musicEnabled}');
      return;
    }
    
    // Debounce: minimum 2 seconds between restarts
    final timeSinceRestart = DateTime.now().difference(_lastRestartTime).inMilliseconds;
    if (timeSinceRestart < 2000 && _isRestarting) {
      _log('Skip restart ($reason): debounced (${timeSinceRestart}ms ago)');
      return;
    }
    
    // Check if _isRestarting is stuck (more than 10 seconds)
    if (_isRestarting && timeSinceRestart < 10000) {
      _log('Skip restart ($reason): already restarting');
      return;
    }
    
    _isRestarting = true;
    _lastRestartTime = DateTime.now();
    
    _log('>>> RESTART ($reason)');
    
    try {
      // Recreate player if null or stale (no play in 60+ seconds)
      final timeSinceLastPlay = DateTime.now().difference(_lastSuccessfulPlay).inSeconds;
      if (_musicPlayer == null || timeSinceLastPlay > 60) {
        _log('Recreating player (stale=${timeSinceLastPlay}s)');
        await _createMusicPlayer();
      }
      
      if (_musicPlayer == null) {
        _log('ERROR: Music player is null!');
        return;
      }
      
      // Mark that we're about to stop (so listener ignores it)
      _expectingStop = true;
      
      // Stop current playback
    try {
      await _musicPlayer!.stop();
      } catch (_) {}
      
      // Small delay
      await Future.delayed(const Duration(milliseconds: 50));
      
      // Configure and play
      await _musicPlayer!.setReleaseMode(ReleaseMode.loop);
      await _musicPlayer!.setVolume(0.5);
      await _musicPlayer!.play(AssetSource('audio/background_music.mp3'));
      
      _isMusicPlaying = true;
      _lastSuccessfulPlay = DateTime.now();
      _log('<<< SUCCESS');
      
    } catch (e) {
      _log('<<< FAILED: $e');
      _isMusicPlaying = false;
      _expectingStop = false;
    } finally {
      _isRestarting = false;
    }
  }
  
  /// Start periodic health check for music
  void _startMusicHealthCheck() {
    _musicHealthCheckTimer?.cancel();
    _healthCheckCount = 0;
    
    _log('Starting health check (every 5 seconds)');
    
    // Health check every 5 seconds to catch stopped music quickly
    _musicHealthCheckTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _healthCheckCount++;
      _runHealthCheck();
    });
  }
  
  /// Run a health check
  void _runHealthCheck() {
    if (!_isMusicDesired || !_settings.musicEnabled) {
      return;
    }
    
    final state = _musicPlayer?.state;
    final timeSinceRestart = DateTime.now().difference(_lastRestartTime).inSeconds;
    final timeSincePositionUpdate = DateTime.now().difference(_lastPositionUpdate).inSeconds;
    
    // Log every 6th check (every 30 seconds)
    final isPlaying = state == PlayerState.playing;
    if (_healthCheckCount % 6 == 0) {
      _log('Health #$_healthCheckCount: state=$state, pos=${_lastPosition.inSeconds}s, lastUpdate=${timeSincePositionUpdate}s ago');
    }
    
    // Restart if needed and enough time since last restart
    if (!_isRestarting && timeSinceRestart > 5) {
      if (!isPlaying) {
        _log('Health: Music not playing! Restarting...');
        _forceRestart('health - not playing');
      } else if (timeSincePositionUpdate > 10) {
        // Position hasn't changed in 10 seconds - music is frozen/silent
        _log('Health: Position frozen for ${timeSincePositionUpdate}s! Restarting...');
        _forceRestart('health - position frozen');
        }
      }
  }
  
  
  /// Stop music health check
  void _stopMusicHealthCheck() {
    _log('Stopping health check timer');
    _musicHealthCheckTimer?.cancel();
    _musicHealthCheckTimer = null;
  }
  
  /// Force ensure music is playing - call this from screens
  Future<void> ensureMusicPlaying() async {
    if (!_settings.musicEnabled) return;
    if (!_isInitialized) await initialize();
    
    _isMusicDesired = true;
    
    // Start health check if not running
    if (_musicHealthCheckTimer == null || !_musicHealthCheckTimer!.isActive) {
      _startMusicHealthCheck();
    }
    
    // Check current state and restart if needed (with debounce)
    final state = _musicPlayer?.state;
    final timeSinceRestart = DateTime.now().difference(_lastRestartTime).inSeconds;
    
    if (state != PlayerState.playing && timeSinceRestart > 3) {
      _log('ensureMusicPlaying: state=$state, starting...');
      await _forceRestart('ensureMusicPlaying');
    }
  }

  /// Update settings
  void updateSettings(SettingsModel settings) {
    final wasEnabled = _settings.musicEnabled;
    _settings = settings;
    
    _log('updateSettings: music ${settings.musicEnabled ? 'enabled' : 'disabled'}');
    
    if (!settings.musicEnabled && _isMusicPlaying) {
      stopMusic();
    } else if (settings.musicEnabled && !wasEnabled && _isMusicDesired) {
      // Music was just enabled, start it
      _log('updateSettings: music just enabled, starting...');
      startMusic();
    }
  }

  /// Get next player from pool (round-robin)
  AudioPlayer _getNextPlayer() {
    final player = _sfxPool[_currentPoolIndex];
    _currentPoolIndex = (_currentPoolIndex + 1) % _poolSize;
    return player;
  }

  /// Play a sound effect using pooled players
  Future<void> _playSfx(String filename, {String? fallback}) async {
    if (!_settings.soundEnabled) return;
    if (!_isInitialized) await initialize();
    
    // Try primary file, then fallback
    String? fileToPlay;
    if (_audioAvailable[filename] == true) {
      fileToPlay = filename;
    } else if (fallback != null && _audioAvailable[fallback] == true) {
      fileToPlay = fallback;
    }
    
    if (fileToPlay == null) return;
    
    try {
      final player = _getNextPlayer();
      await player.play(AssetSource('audio/$fileToPlay'));
    } catch (e) {
      // Mark file as unavailable to avoid repeated errors
      _audioAvailable[fileToPlay] = false;
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
  // Countdown uses button_click as fallback since countdown.wav has issues
  Future<void> playCountdown() => _playSfx('countdown.wav', fallback: 'button_click.wav');

  /// Start background music
  Future<void> startMusic() async {
    if (!_settings.musicEnabled) return;
    if (!_isInitialized) await initialize();
    if (_audioAvailable['background_music.mp3'] != true) {
      _log('startMusic: audio file not available!');
      return;
    }
    
    _log('startMusic()');
    _isMusicDesired = true;
      
    // Ensure health checks are running
    if (_musicHealthCheckTimer == null || !_musicHealthCheckTimer!.isActive) {
      _startMusicHealthCheck();
    }
    
    // Start if not playing
    if (_musicPlayer?.state != PlayerState.playing) {
      await _forceRestart('startMusic');
    }
  }

  Future<void> stopMusic() async {
    _log('stopMusic()');
    _isMusicDesired = false;
    _expectingStop = true;
    _stopMusicHealthCheck();
    try {
      await _musicPlayer?.stop();
    } catch (_) {}
    _isMusicPlaying = false;
  }

  Future<void> pauseMusic() async {
    _log('pauseMusic() - pausing for background/lock');
    _isMusicDesired = false; // Temporarily not desired while in background
    _expectingStop = true;
    _stopMusicHealthCheck(); // Stop health check while paused
      try {
        await _musicPlayer?.pause();
      } catch (_) {}
    _isMusicPlaying = false;
  }

  Future<void> resumeMusic() async {
    if (!_settings.musicEnabled) {
      _log('resumeMusic() - music disabled in settings');
      return;
    }
    
    _log('resumeMusic() - resuming from background/lock');
    _isMusicDesired = true;
    _expectingStop = false;
    
    // Restart health checks
    _startMusicHealthCheck();
    
    final currentState = _musicPlayer?.state;
    if (currentState == PlayerState.paused) {
      try {
        await _musicPlayer?.resume();
        _isMusicPlaying = true;
        _lastSuccessfulPlay = DateTime.now();
        _lastPositionUpdate = DateTime.now();
        _log('resumeMusic() - resumed successfully');
      } catch (e) {
        _log('resumeMusic() - resume failed: $e');
        await _forceRestart('resume failed');
      }
    } else if (currentState != PlayerState.playing) {
      _log('resumeMusic() - player not paused (state=$currentState), restarting');
      await _forceRestart('resumeMusic');
    } else {
      _log('resumeMusic() - already playing');
      _isMusicPlaying = true;
    }
  }

  Future<void> setMusicVolume(double volume) async {
    try {
      await _musicPlayer?.setVolume(volume.clamp(0.0, 1.0));
    } catch (_) {}
  }

  bool isAudioAvailable(String filename) => _audioAvailable[filename] ?? false;

  void dispose() {
    _stopMusicHealthCheck();
    _musicCompletionSubscription?.cancel();
    _musicStateSubscription?.cancel();
    _musicPositionSubscription?.cancel();
    for (final player in _sfxPool) {
      player.dispose();
    }
    _musicPlayer?.dispose();
    _musicPlayer = null;
    _isMusicPlaying = false;
    _isMusicDesired = false;
    _isInitialized = false;
  }
}
