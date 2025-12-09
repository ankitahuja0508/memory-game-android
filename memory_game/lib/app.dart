import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'domain/services/services.dart';
import 'state/app/app_cubit.dart';
import 'state/player/player_cubit.dart';
import 'state/player/player_state.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/menu/menu_screen.dart';
import 'presentation/screens/level_select/level_select_screen.dart';
import 'presentation/screens/game/game_screen.dart';
import 'presentation/screens/shop/shop_screen.dart';
import 'presentation/screens/themes/themes_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/achievements/achievements_screen.dart';
import 'presentation/screens/daily_rewards/daily_rewards_screen.dart';
import 'presentation/screens/welcome/welcome_screen.dart';
import 'presentation/screens/leaderboard/leaderboard_screen.dart';
import 'domain/services/app_update_service.dart';

/// Route observer to ensure music plays across screen navigation
class MusicRouteObserver extends RouteObserver<PageRoute<dynamic>> {
  final AudioService audioService;
  
  MusicRouteObserver(this.audioService);
  
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _ensureMusic();
  }
  
  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _ensureMusic();
  }
  
  void _ensureMusic() {
    // Small delay to let the navigation settle, then check music
    Future.delayed(const Duration(milliseconds: 500), () {
      audioService.ensureMusicPlaying();
    });
  }
}

class MemoryGameApp extends StatefulWidget {
  const MemoryGameApp({super.key});

  @override
  State<MemoryGameApp> createState() => _MemoryGameAppState();
}

class _MemoryGameAppState extends State<MemoryGameApp> with WidgetsBindingObserver {
  late StorageService _storageService;
  late AchievementService _achievementService;
  late DailyRewardService _dailyRewardService;
  late AudioService _audioService;
  late MusicRouteObserver _musicRouteObserver;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initServices();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Pause/resume music when app goes to background/foreground
    if (state == AppLifecycleState.paused) {
      _audioService.pauseMusic();
    } else if (state == AppLifecycleState.resumed) {
      _audioService.resumeMusic();
    }
  }

  Future<void> _initServices() async {
    _storageService = StorageService();
    await _storageService.init();
    
    _achievementService = AchievementService();
    _dailyRewardService = DailyRewardService();
    
    // Initialize audio service (singleton) - this prepares it for playback
    _audioService = AudioService.instance;
    await _audioService.initialize();
    
    // Sign in anonymously to Firebase (if not already signed in)
    debugPrint('🔥 Checking Firebase authentication...');
    final firebaseService = FirebaseService.instance;
    if (firebaseService.currentUser == null) {
      debugPrint('🔑 No user found, signing in anonymously...');
      await firebaseService.signInAnonymously();
    } else {
      debugPrint('✅ Already signed in: ${firebaseService.currentUser?.uid}');
    }
    
    // Initialize Remote Config (feature toggles)
    await RemoteConfigService.instance.initialize();
    
    // Initialize Rate App Service
    await RateAppService.instance.initialize();
    
    // Initialize Notification Service
    await NotificationService.instance.initialize();
    await NotificationService.instance.onAppOpened();
    
    // Initialize App Update Service
    await AppUpdateService.instance.initialize();
    
    // Create route observer for music management
    _musicRouteObserver = MusicRouteObserver(_audioService);
    
    setState(() => _isInitialized = true);
    
    // Check for updates after initialization (non-blocking)
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    // Wait a bit to let the app fully load
    await Future.delayed(const Duration(seconds: 2));
    
    final updateInfo = await AppUpdateService.instance.checkForUpdate();
    
    if (updateInfo != null && mounted) {
      // Show update dialog
      showDialog(
        context: context,
        barrierDismissible: !updateInfo.isRequired,
        builder: (context) => AlertDialog(
          title: const Text('🚀 Update Available!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('New version ${updateInfo.latestVersion} is available'),
              const SizedBox(height: 8),
              Text(updateInfo.updateMessage),
              if (updateInfo.isRequired) ...[
                const SizedBox(height: 8),
                const Text(
                  '⚠️ This update is required to continue playing',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
          actions: [
            if (!updateInfo.isRequired)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  AppUpdateService.instance.dismissUpdate(updateInfo.latestVersion);
                },
                child: const Text('Later'),
              ),
            ElevatedButton(
              onPressed: () {
                if (!updateInfo.isRequired) {
                  Navigator.of(context).pop();
                }
                AppUpdateService.instance.openStorePage();
              },
              child: const Text('Update Now'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => AppCubit()),
        BlocProvider(
          create: (_) => PlayerCubit(
            storageService: _storageService,
            achievementService: _achievementService,
            dailyRewardService: _dailyRewardService,
          ),
        ),
      ],
      child: BlocListener<PlayerCubit, PlayerState>(
        listenWhen: (previous, current) => 
          previous.settings.soundEnabled != current.settings.soundEnabled ||
          previous.settings.musicEnabled != current.settings.musicEnabled,
        listener: (context, state) {
          // Update audio service when settings change
          _audioService.updateSettings(state.settings);
          
          // If music was enabled, start it
          if (state.settings.musicEnabled && !_audioService.isMusicPlaying) {
            _audioService.startMusic();
          }
        },
        child: MaterialApp(
          title: 'Memory Match - Brain Training',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          initialRoute: '/',
          navigatorObservers: [_musicRouteObserver],
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(builder: (_) => const SplashScreen());
              case '/welcome':
                return MaterialPageRoute(builder: (_) => const WelcomeScreen());
              case '/menu':
                return MaterialPageRoute(builder: (_) => const MenuScreen());
              case '/levels':
                return MaterialPageRoute(builder: (_) => const LevelSelectScreen());
              case '/game':
                final args = settings.arguments as Map<String, dynamic>?;
                final level = args?['level'] as int? ?? 1;
                return MaterialPageRoute(builder: (_) => GameScreen(level: level));
              case '/shop':
                return MaterialPageRoute(builder: (_) => const ShopScreen());
              case '/themes':
                return MaterialPageRoute(builder: (_) => const ThemesScreen());
              case '/settings':
                return MaterialPageRoute(builder: (_) => const SettingsScreen());
              case '/achievements':
                return MaterialPageRoute(builder: (_) => const AchievementsScreen());
              case '/daily':
                return MaterialPageRoute(builder: (_) => const DailyRewardsScreen());
              case '/leaderboard':
                return MaterialPageRoute(builder: (_) => const LeaderboardScreen());
              default:
                return MaterialPageRoute(builder: (_) => const MenuScreen());
            }
          },
        ),
      ),
    );
  }
}
