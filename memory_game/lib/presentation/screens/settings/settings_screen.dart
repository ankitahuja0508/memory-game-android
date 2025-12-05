import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/settings_model.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/game_button.dart';

/// Settings screen
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: BlocBuilder<PlayerCubit, PlayerState>(
            builder: (context, state) {
              final settings = state.settings;

              return Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: AppColors.textPrimary,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const Expanded(
                          child: Text(
                            AppStrings.settings,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(width: 48),
                      ],
                    ),
                  ),

                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // Sound section
                        _SettingsSection(
                          title: 'Sound & Haptics',
                          children: [
                            _SettingsTile(
                              icon: Icons.volume_up,
                              title: AppStrings.sound,
                              trailing: Switch(
                                value: settings.soundEnabled,
                                onChanged: (value) {
                                  _updateSettings(
                                    context,
                                    settings.copyWith(soundEnabled: value),
                                  );
                                },
                              ),
                            ),
                            _SettingsTile(
                              icon: Icons.music_note,
                              title: AppStrings.music,
                              trailing: Switch(
                                value: settings.musicEnabled,
                                onChanged: (value) {
                                  _updateSettings(
                                    context,
                                    settings.copyWith(musicEnabled: value),
                                  );
                                },
                              ),
                            ),
                            _SettingsTile(
                              icon: Icons.vibration,
                              title: AppStrings.vibration,
                              trailing: Switch(
                                value: settings.vibrationEnabled,
                                onChanged: (value) {
                                  _updateSettings(
                                    context,
                                    settings.copyWith(vibrationEnabled: value),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Gameplay section
                        _SettingsSection(
                          title: 'Gameplay',
                          children: [
                            _SettingsTile(
                              icon: Icons.timer,
                              title: 'Show Timer',
                              trailing: Switch(
                                value: settings.showTimer,
                                onChanged: (value) {
                                  _updateSettings(
                                    context,
                                    settings.copyWith(showTimer: value),
                                  );
                                },
                              ),
                            ),
                            _SettingsTile(
                              icon: Icons.touch_app,
                              title: 'Show Move Count',
                              trailing: Switch(
                                value: settings.showMoveCount,
                                onChanged: (value) {
                                  _updateSettings(
                                    context,
                                    settings.copyWith(showMoveCount: value),
                                  );
                                },
                              ),
                            ),
                            _SettingsTile(
                              icon: Icons.animation,
                              title: 'Reduced Animations',
                              trailing: Switch(
                                value: settings.reducedAnimations,
                                onChanged: (value) {
                                  _updateSettings(
                                    context,
                                    settings.copyWith(reducedAnimations: value),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Account section
                        _SettingsSection(
                          title: 'Account',
                          children: [
                            _SettingsTile(
                              icon: Icons.person,
                              title: 'Player Name',
                              subtitle: state.player.name,
                              onTap: () => _showNameDialog(context, state.player.name),
                            ),
                            _SettingsTile(
                              icon: Icons.bar_chart,
                              title: 'Statistics',
                              onTap: () => _showStatsDialog(context, state),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // About section
                        _SettingsSection(
                          title: 'About',
                          children: [
                            _SettingsTile(
                              icon: Icons.info_outline,
                              title: AppStrings.about,
                              onTap: () => _showAboutDialog(context),
                            ),
                            _SettingsTile(
                              icon: Icons.privacy_tip_outlined,
                              title: AppStrings.privacy,
                              onTap: () {},
                            ),
                            _SettingsTile(
                              icon: Icons.description_outlined,
                              title: AppStrings.terms,
                              onTap: () {},
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Reset progress
                        GameButton(
                          text: AppStrings.resetProgress,
                          emoji: '⚠️',
                          width: double.infinity,
                          gradient: const [Colors.red, Colors.redAccent],
                          onPressed: () => _showResetDialog(context),
                        ),

                        const SizedBox(height: 40),

                        // Version
                        Text(
                          'Memory Match v1.0.0',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _updateSettings(BuildContext context, SettingsModel settings) {
    context.read<PlayerCubit>().updateSettings(settings);
  }

  void _showNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Change Name',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Enter your name',
            hintStyle: TextStyle(color: AppColors.textSecondary),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Update name in player model
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showStatsDialog(BuildContext context, PlayerState state) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Your Statistics',
          style: TextStyle(color: AppColors.textPrimary),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatRow('Player Level', '${state.player.playerLevel}'),
            _StatRow('Total XP', '${state.player.xp}'),
            _StatRow('Levels Completed', '${state.completedLevelsCount}'),
            _StatRow('Total Stars', '${state.totalStars}'),
            _StatRow('Games Played', '${state.player.totalGamesPlayed}'),
            _StatRow('Perfect Games', '${state.player.perfectGames}'),
            _StatRow('Best Streak', '${state.player.longestStreak}'),
            _StatRow('Daily Streak', '${state.player.currentDailyStreak}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🧠 ', style: TextStyle(fontSize: 24)),
            Text(
              'Memory Match',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'A fun memory matching game with infinite levels, power-ups, and achievements!',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            const Text(
              'Version 1.0.0',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              '© 2024 Memory Match',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          '⚠️ Reset Progress',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          AppStrings.resetWarning,
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              context.read<PlayerCubit>().resetProgress();
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Progress reset!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(
            title,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: TextStyle(color: AppColors.textSecondary),
            )
          : null,
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: AppColors.textSecondary)
              : null),
      onTap: onTap,
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
