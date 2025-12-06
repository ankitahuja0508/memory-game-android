import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'domain/services/services.dart';
import 'state/app/app_cubit.dart';
import 'state/player/player_cubit.dart';
import 'presentation/screens/splash/splash_screen.dart';
import 'presentation/screens/menu/menu_screen.dart';
import 'presentation/screens/level_select/level_select_screen.dart';
import 'presentation/screens/game/game_screen.dart';
import 'presentation/screens/shop/shop_screen.dart';
import 'presentation/screens/settings/settings_screen.dart';
import 'presentation/screens/achievements/achievements_screen.dart';
import 'presentation/screens/daily_rewards/daily_rewards_screen.dart';

class MemoryGameApp extends StatefulWidget {
  const MemoryGameApp({super.key});

  @override
  State<MemoryGameApp> createState() => _MemoryGameAppState();
}

class _MemoryGameAppState extends State<MemoryGameApp> {
  late StorageService _storageService;
  late AchievementService _achievementService;
  late DailyRewardService _dailyRewardService;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initServices();
  }

  Future<void> _initServices() async {
    _storageService = StorageService();
    await _storageService.init();
    _achievementService = AchievementService();
    _dailyRewardService = DailyRewardService();
    setState(() => _isInitialized = true);
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
      child: MaterialApp(
        title: 'Memory Match',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (_) => const SplashScreen());
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
            case '/settings':
              return MaterialPageRoute(builder: (_) => const SettingsScreen());
            case '/achievements':
              return MaterialPageRoute(builder: (_) => const AchievementsScreen());
            case '/daily':
              return MaterialPageRoute(builder: (_) => const DailyRewardsScreen());
            default:
              return MaterialPageRoute(builder: (_) => const MenuScreen());
          }
        },
      ),
    );
  }
}
