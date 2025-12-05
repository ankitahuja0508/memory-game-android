import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'domain/services/services.dart';
import 'state/app/app_cubit.dart';
import 'state/game/game_cubit.dart';
import 'state/player/player_cubit.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/menu/menu_screen.dart';
import 'presentation/screens/level_select/level_select_screen.dart';
import 'presentation/screens/game/game_screen.dart';
import 'presentation/screens/shop/shop_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/achievements/achievements_screen.dart';
import 'presentation/screens/daily_rewards/daily_rewards_screen.dart';

/// Main application widget
class MemoryGameApp extends StatefulWidget {
  const MemoryGameApp({super.key});

  @override
  State<MemoryGameApp> createState() => _MemoryGameAppState();
}

class _MemoryGameAppState extends State<MemoryGameApp> {
  // Services
  late final StorageService _storageService;
  late final LevelGeneratorService _levelGeneratorService;
  late final AudioService _audioService;
  late final HapticService _hapticService;
  late final AchievementService _achievementService;
  late final DailyRewardService _dailyRewardService;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  void _initServices() {
    _storageService = StorageService();
    _levelGeneratorService = LevelGeneratorService();
    _audioService = AudioService();
    _hapticService = HapticService();
    _achievementService = AchievementService();
    _dailyRewardService = DailyRewardService();

    // Initialize audio service
    _audioService.init();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AppCubit(),
        ),
        BlocProvider(
          create: (_) => PlayerCubit(
            storageService: _storageService,
            achievementService: _achievementService,
            dailyRewardService: _dailyRewardService,
          ),
        ),
        BlocProvider(
          create: (_) => GameCubit(
            levelGenerator: _levelGeneratorService,
            audioService: _audioService,
            hapticService: _hapticService,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Memory Match',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/',
        onGenerateRoute: _onGenerateRoute,
      ),
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _buildRoute(const SplashScreen(), settings);
      case '/menu':
        return _buildRoute(const MenuScreen(), settings);
      case '/levels':
        return _buildRoute(const LevelSelectScreen(), settings);
      case '/game':
        final level = settings.arguments as int? ?? 1;
        return _buildRoute(GameScreen(level: level), settings);
      case '/shop':
        return _buildRoute(const ShopScreen(), settings);
      case '/settings':
        return _buildRoute(const SettingsScreen(), settings);
      case '/achievements':
        return _buildRoute(const AchievementsScreen(), settings);
      case '/daily-rewards':
        return _buildRoute(const DailyRewardsScreen(), settings);
      default:
        return _buildRoute(const MenuScreen(), settings);
    }
  }

  Route<dynamic> _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
