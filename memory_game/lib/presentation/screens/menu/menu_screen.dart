import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/level_model.dart';
import '../../../domain/services/audio_service.dart';
import '../../../domain/services/level_generator_service.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/currency_display.dart';
import '../../widgets/common/game_button.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with WidgetsBindingObserver {
  late AudioService _audioService;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService.instance;
    WidgetsBinding.instance.addObserver(this);
    
    // Ensure music is playing when entering menu (home screen)
    _ensureMusicPlaying();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Restart music when app resumes
    if (state == AppLifecycleState.resumed) {
      _ensureMusicPlaying();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Ensure music plays when returning to this screen
    _ensureMusicPlaying();
  }
  
  void _ensureMusicPlaying() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // Always try to ensure music is playing when entering menu screen
      // AudioService will handle the checks internally and restart if needed
      await _audioService.ensureMusicPlaying();
    });
  }

  void _onButtonTap(VoidCallback action) {
    _audioService.playButton();
    action();
  }

  void _showGameSnackBar(BuildContext context, String message, String emoji, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Container(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isSuccess)
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
            ],
          ),
        ),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        elevation: 8,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleThemeEquip(BuildContext context, GameCardTheme theme) {
    final playerCubit = context.read<PlayerCubit>();
    
    // Check if already equipped
    if (playerCubit.state.player.equippedTheme == theme.id) {
      return;
    }
    
    // Equip is free once purchased
    playerCubit.equipTheme(theme.id);
    _showGameSnackBar(context, '${theme.name} theme equipped!', theme.icon);
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: BlocBuilder<PlayerCubit, PlayerState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Top Bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: CurrencyDisplay(
                            coins: state.player.coins,
                            gems: state.player.gems,
                          ),
                        ),
                        IconGameButton(
                          icon: Icons.settings,
                          onPressed: () => _onButtonTap(() => Navigator.pushNamed(context, '/settings')),
                        ),
                      ],
                    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.3),

                    const SizedBox(height: 16),

                    // Logo
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: AppColors.primaryGradient),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(77),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('🧠', style: TextStyle(fontSize: 42)),
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),

                    const SizedBox(height: 12),

                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text('Memory Match', style: AppTextStyles.headline1.copyWith(fontSize: 28)),
                    )
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideY(begin: 0.2),

                    const SizedBox(height: 8),

                    // Stats
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _StatChip(icon: '⭐', value: state.totalStars.toString()),
                        const SizedBox(width: 12),
                        _StatChip(icon: '🎮', value: 'Lv ${state.highestUnlockedLevel}'),
                      ],
                    ).animate().fadeIn(delay: 300.ms),

                    const SizedBox(height: 16),

                    // Theme Selector
                    _ThemeSelector(
                      currentThemeId: state.player.equippedTheme,
                      unlockedThemes: state.player.unlockedThemes,
                      highestLevel: state.highestUnlockedLevel,
                      onThemeSelected: (themeId) {
                        _audioService.playButton();
                        final theme = LevelGeneratorService.getThemeById(themeId);
                        _handleThemeEquip(context, theme);
                      },
                      onLockedThemeTap: (theme) => _showThemeUnlockInfo(context, theme, state),
                    ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),

                    const Spacer(),

                    // Menu Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: GameButton(
                        text: 'PLAY',
                        emoji: '🎮',
                        onPressed: () => _onButtonTap(() => Navigator.pushNamed(context, '/levels')),
                        gradient: AppColors.successGradient,
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),

                    const SizedBox(height: 12),

                    SizedBox(
                      height: 44,
                      child: Row(
                        children: [
                          Expanded(
                            child: GameButton(
                              text: 'Shop',
                              emoji: '🛒',
                              onPressed: () => _onButtonTap(() => Navigator.pushNamed(context, '/shop')),
                              isOutlined: true,
                              isSmall: true,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                          child: _BadgedButton(
                            showBadge: state.hasDailyRewardAvailable,
                            badgeColor: AppColors.accent,
                            child: GameButton(
                              text: 'Rewards',
                              emoji: '🎁',
                              onPressed: () => _onButtonTap(() => Navigator.pushNamed(context, '/daily')),
                              isOutlined: true,
                              isSmall: true,
                            ),
                          ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.3),

                    const SizedBox(height: 12),

                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: _BadgedButton(
                        showBadge: state.unclaimedAchievementCount > 0,
                        badgeCount: state.unclaimedAchievementCount,
                        badgeColor: AppColors.success,
                        child: GameButton(
                          text: 'Achievements',
                          emoji: '🏆',
                          onPressed: () => _onButtonTap(() => Navigator.pushNamed(context, '/achievements')),
                          isOutlined: true,
                          isSmall: true,
                        ),
                      ),
                    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3),

                    const SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showThemeUnlockInfo(BuildContext context, GameCardTheme theme, PlayerState state) {
    _audioService.playButton();
    
    final canUnlock = state.highestUnlockedLevel >= theme.unlocksAtLevel;
    final isOwned = state.player.unlockedThemes.contains(theme.id);
    final isEquipped = state.player.equippedTheme == theme.id;
    
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(theme.icon, style: const TextStyle(fontSize: 28)),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(theme.name, style: AppTextStyles.headline3)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme preview
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withAlpha(40), Colors.black.withAlpha(20)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withAlpha(50)),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: theme.symbols.take(8).map((s) => Text(s, style: const TextStyle(fontSize: 24))).toList(),
              ),
            ),
            const SizedBox(height: 16),
            if (!canUnlock) ...[
              // Not reached level yet
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.warning.withAlpha(30), AppColors.warning.withAlpha(10)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.warning.withAlpha(100)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('🔒', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Reach Level ${theme.unlocksAtLevel} to unlock!',
                            style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: state.highestUnlockedLevel / theme.unlocksAtLevel,
                        backgroundColor: Colors.white.withAlpha(30),
                        valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Level ${state.highestUnlockedLevel} / ${theme.unlocksAtLevel} (${((state.highestUnlockedLevel / theme.unlocksAtLevel) * 100).toInt()}%)',
                      style: AppTextStyles.caption.copyWith(color: AppColors.accent),
                    ),
                  ],
                ),
              ),
            ] else if (!isOwned) ...[
              // Can unlock with coins
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.success.withAlpha(30), AppColors.success.withAlpha(10)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withAlpha(100)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('🎉', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(
                          'Ready to unlock!',
                          style: AppTextStyles.body2.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('💰', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          'Purchase: ${theme.cost} coins',
                          style: AppTextStyles.body2,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('✨', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Text(
                          'Equip anytime for FREE!',
                          style: AppTextStyles.body2.copyWith(color: AppColors.success),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ] else if (!isEquipped) ...[
              // Owned but not equipped
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary.withAlpha(30), AppColors.primary.withAlpha(10)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    const Text('👍', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You own this theme!\nTap below to equip it.',
                        style: AppTextStyles.body2,
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Currently equipped
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.success.withAlpha(30), AppColors.success.withAlpha(10)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withAlpha(100)),
                ),
                child: Row(
                  children: [
                    const Text('✅', style: TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(
                      'Currently equipped!',
                      style: AppTextStyles.body2.copyWith(color: AppColors.success, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: AppColors.textSecondary)),
          ),
          if (canUnlock && !isOwned)
            ElevatedButton(
              onPressed: () async {
                final playerCubit = context.read<PlayerCubit>();
                Navigator.pop(context);
                final success = await playerCubit.spendCoins(theme.cost);
                if (success && context.mounted) {
                  await playerCubit.unlockTheme(theme.id);
                  _showGameSnackBar(context, '${theme.name} unlocked! Tap to equip.', theme.icon);
                } else if (context.mounted) {
                  _showGameSnackBar(context, 'Need ${theme.cost} coins to unlock!', '💰', isSuccess: false);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.coinColor,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('💰', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  Text('Buy ${theme.cost}', style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          if (isOwned && !isEquipped)
            ElevatedButton(
              onPressed: () {
                final playerCubit = context.read<PlayerCubit>();
                Navigator.pop(context);
                playerCubit.equipTheme(theme.id);
                _showGameSnackBar(context, '${theme.name} equipped!', theme.icon);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('✨', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('Equip', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final String value;

  const _StatChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(26),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(value, style: AppTextStyles.body2.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

/// Widget that adds a notification badge to its child
class _BadgedButton extends StatelessWidget {
  final Widget child;
  final bool showBadge;
  final int? badgeCount;
  final Color badgeColor;

  const _BadgedButton({
    required this.child,
    this.showBadge = false,
    this.badgeCount,
    this.badgeColor = AppColors.error,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (showBadge)
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: EdgeInsets.all(badgeCount != null ? 4 : 6),
              decoration: BoxDecoration(
                color: badgeColor,
                shape: badgeCount != null ? BoxShape.rectangle : BoxShape.circle,
                borderRadius: badgeCount != null ? BorderRadius.circular(10) : null,
                boxShadow: [
                  BoxShadow(
                    color: badgeColor.withAlpha(100),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: badgeCount != null
                  ? Text(
                      '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    )
                  : null,
            ).animate(onPlay: (c) => c.repeat()).scale(
                  begin: const Offset(1, 1),
                  end: const Offset(1.15, 1.15),
                  duration: 800.ms,
                  curve: Curves.easeInOut,
                ),
          ),
      ],
    );
  }
}

/// Horizontal theme selector carousel
class _ThemeSelector extends StatelessWidget {
  final String currentThemeId;
  final List<String> unlockedThemes;
  final int highestLevel;
  final Function(String) onThemeSelected;
  final Function(GameCardTheme) onLockedThemeTap;

  const _ThemeSelector({
    required this.currentThemeId,
    required this.unlockedThemes,
    required this.highestLevel,
    required this.onThemeSelected,
    required this.onLockedThemeTap,
  });

  @override
  Widget build(BuildContext context) {
    const themes = LevelGeneratorService.themes;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              const Text('🎨', style: TextStyle(fontSize: 14)),
              const SizedBox(width: 6),
              Text(
                'Select Theme',
                style: AppTextStyles.body2.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 82, // Increased to accommodate badge
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(top: 10), // Space for badge at top
            itemCount: themes.length,
            itemBuilder: (context, index) {
              final theme = themes[index];
              final isUnlocked = unlockedThemes.contains(theme.id);
              final isSelected = currentThemeId == theme.id;
              final canUnlock = highestLevel >= theme.unlocksAtLevel;
              
              return Padding(
                padding: EdgeInsets.only(right: index < themes.length - 1 ? 10 : 0),
                child: _ThemeCard(
                  theme: theme,
                  isUnlocked: isUnlocked,
                  isSelected: isSelected,
                  canUnlock: canUnlock && !isUnlocked,
                  onTap: isUnlocked
                      ? () => onThemeSelected(theme.id)
                      : () => onLockedThemeTap(theme),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ThemeCard extends StatelessWidget {
  final GameCardTheme theme;
  final bool isUnlocked;
  final bool isSelected;
  final bool canUnlock;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.theme,
    required this.isUnlocked,
    required this.isSelected,
    required this.canUnlock,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 70,
            decoration: BoxDecoration(
              color: isUnlocked 
                  ? (isSelected ? AppColors.primary : AppColors.surface.withAlpha(200))
                  : AppColors.surface.withAlpha(100),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected 
                    ? AppColors.accent
                    : canUnlock
                        ? AppColors.success.withAlpha(150)
                        : Colors.white.withAlpha(30),
                width: isSelected ? 2 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.primary.withAlpha(80),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  theme.icon,
                  style: TextStyle(
                    fontSize: 24,
                    color: isUnlocked ? null : Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  theme.name,
                  style: AppTextStyles.caption.copyWith(
                    fontSize: 9,
                    color: isSelected 
                        ? Colors.white 
                        : isUnlocked 
                            ? AppColors.textSecondary 
                            : Colors.grey,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                if (!isUnlocked)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.lock,
                          size: 8,
                          color: canUnlock ? AppColors.success : Colors.grey,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Lv${theme.unlocksAtLevel}',
                          style: TextStyle(
                            fontSize: 8,
                            color: canUnlock ? AppColors.success : Colors.grey,
                            fontWeight: canUnlock ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          // "Can unlock" indicator
          if (canUnlock)
            Positioned(
              right: -4,
              top: -4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withAlpha(150),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(Icons.add, size: 10, color: Colors.white),
              ).animate(onPlay: (c) => c.repeat()).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.2, 1.2),
                    duration: 600.ms,
                  ),
            ),
          // Selected checkmark - more visible
          if (isSelected)
            Positioned(
              right: -6,
              top: -6,
              child: Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00E676), Color(0xFF00C853)],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withAlpha(200),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: const Icon(Icons.check, size: 12, color: Colors.white),
              ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 800.ms,
                  ),
            ),
        ],
      ),
    );
  }
}
