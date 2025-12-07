import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/settings_model.dart';
import '../../../domain/services/audio_service.dart';
import '../../../state/player/player_cubit.dart';
import '../../../state/player/player_state.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/tutorial_overlay.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showTutorial = false;

  void _showTutorialOverlay() {
    setState(() => _showTutorial = true);
  }

  void _hideTutorialOverlay() {
    setState(() => _showTutorial = false);
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text('Settings', style: AppTextStyles.headline3),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            BlocBuilder<PlayerCubit, PlayerState>(
              builder: (context, state) {
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _SettingsSection(
                      title: 'Game Settings',
                      children: [
                        _ToggleTile(
                          icon: Icons.visibility,
                          title: 'Show Preview',
                          subtitle: 'Show cards at start of level',
                          value: state.settings.showPreview,
                          onChanged: (value) => _updateSettings(
                            context,
                            state.settings.copyWith(showPreview: value),
                          ),
                        ),
                        _ToggleTile(
                          icon: Icons.volume_up,
                          title: 'Sound Effects',
                          subtitle: 'Play sound effects',
                          value: state.settings.soundEnabled,
                          onChanged: (value) => _updateSettings(
                            context,
                            state.settings.copyWith(soundEnabled: value),
                          ),
                        ),
                        _ToggleTile(
                          icon: Icons.music_note,
                          title: 'Music',
                          subtitle: 'Play background music',
                          value: state.settings.musicEnabled,
                          onChanged: (value) => _updateSettings(
                            context,
                            state.settings.copyWith(musicEnabled: value),
                          ),
                        ),
                        _ToggleTile(
                          icon: Icons.vibration,
                          title: 'Vibration',
                          subtitle: 'Haptic feedback',
                          value: state.settings.vibrationEnabled,
                          onChanged: (value) => _updateSettings(
                            context,
                            state.settings.copyWith(vibrationEnabled: value),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SettingsSection(
                      title: 'Help',
                      children: [
                        ListTile(
                          leading: const Icon(Icons.help_outline, color: AppColors.primary),
                          title: Text('View Tutorial', style: AppTextStyles.body1),
                          subtitle: Text('Learn how to play', style: AppTextStyles.caption),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                          onTap: () {
                            AudioService.instance.playButton();
                            _showTutorialOverlay();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SettingsSection(
                      title: 'Statistics',
                      children: [
                        _StatTile(icon: '🎮', title: 'Games Played', value: state.player.totalGamesPlayed.toString()),
                        _StatTile(icon: '⭐', title: 'Total Stars', value: state.totalStars.toString()),
                        _StatTile(icon: '🏆', title: 'Perfect Games', value: state.player.perfectGames.toString()),
                        _StatTile(icon: '🔥', title: 'Longest Streak', value: state.player.longestStreak.toString()),
                        _StatTile(icon: '✅', title: 'Levels Completed', value: state.completedLevels.toString()),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SettingsSection(
                      title: 'Danger Zone',
                      children: [
                        ListTile(
                          leading: const Icon(Icons.delete_forever, color: AppColors.error),
                          title: const Text('Reset Progress', style: TextStyle(color: AppColors.error)),
                          subtitle: const Text('Delete all game data'),
                          onTap: () => _showResetDialog(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text('Version 1.0.0', style: AppTextStyles.caption),
                    ),
                  ],
                );
              },
            ),
            // Tutorial overlay
            if (_showTutorial)
              Positioned.fill(
                child: TutorialOverlay(onComplete: _hideTutorialOverlay),
              ),
          ],
        ),
      ),
    );
  }

  void _updateSettings(BuildContext context, SettingsModel settings) {
    context.read<PlayerCubit>().updateSettings(settings);
  }

  void _showResetDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Progress?'),
        content: const Text('This will delete all your game data including coins, gems, and progress. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<PlayerCubit>().resetProgress();
              Navigator.pop(context);
              Navigator.pop(context);
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

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 8),
          child: Text(title, style: AppTextStyles.body2.copyWith(color: AppColors.textSecondary)),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withAlpha(179),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _ToggleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.body1),
      subtitle: Text(subtitle, style: AppTextStyles.caption),
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.primary,
    );
  }
}

class _StatTile extends StatelessWidget {
  final String icon;
  final String title;
  final String value;

  const _StatTile({required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 24)),
      title: Text(title, style: AppTextStyles.body1),
      trailing: Text(value, style: AppTextStyles.body1.copyWith(fontWeight: FontWeight.bold, color: AppColors.primary)),
    );
  }
}
