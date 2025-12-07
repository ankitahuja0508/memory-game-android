import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/services/audio_service.dart';
import '../../../state/player/player_cubit.dart';
import '../../widgets/common/gradient_background.dart';
import '../../widgets/common/tutorial_overlay.dart';

/// Welcome screen shown on first app launch with tutorial.
/// After tutorial completion, navigates to menu.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  late AudioService _audioService;

  @override
  void initState() {
    super.initState();
    _audioService = AudioService.instance;
    
    // Start background music immediately on welcome screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_audioService.isMusicPlaying) {
        _audioService.startMusic();
      }
    });
  }

  void _onTutorialComplete() {
    // Mark tutorial as completed
    final playerCubit = context.read<PlayerCubit>();
    playerCubit.updateSettings(
      playerCubit.state.settings.copyWith(tutorialCompleted: true),
    );
    
    // Navigate to menu
    Navigator.of(context).pushReplacementNamed('/menu');
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: TutorialOverlay(
          onComplete: _onTutorialComplete,
        ),
      ),
    );
  }
}
