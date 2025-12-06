import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class TutorialOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const TutorialOverlay({super.key, required this.onComplete});

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay> {
  int _currentStep = 0;

  final List<TutorialStep> _steps = [
    const TutorialStep(
      icon: '🎮',
      title: 'Welcome to Memory Match!',
      description: 'A fun memory game where you match pairs of cards.',
    ),
    const TutorialStep(
      icon: '👆',
      title: 'Tap to Flip',
      description: 'Tap any card to reveal what\'s underneath.',
    ),
    const TutorialStep(
      icon: '🎯',
      title: 'Find Matching Pairs',
      description: 'Remember card positions and find matching pairs to clear them.',
    ),
    const TutorialStep(
      icon: '⏱️',
      title: 'Beat the Clock',
      description: 'Complete each level before time runs out!',
    ),
    const TutorialStep(
      icon: '⭐',
      title: 'Earn Stars',
      description: 'Fewer moves = more stars = more coins!',
    ),
    const TutorialStep(
      icon: '🔮',
      title: 'Use Power-ups',
      description: 'Stuck? Use power-ups like Peek 👁️, Freeze ❄️, Hint 🔦, or Magnet 🧲 to help!',
    ),
    const TutorialStep(
      icon: '🚀',
      title: 'Ready to Play!',
      description: 'Good luck and have fun!',
    ),
  ];

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() => _currentStep++);
    } else {
      widget.onComplete();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_currentStep];
    final isLastStep = _currentStep == _steps.length - 1;

    return Container(
      color: Colors.black.withAlpha(200),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: widget.onComplete,
                  child: Text(
                    'Skip',
                    style: AppTextStyles.body2.copyWith(color: Colors.white70),
                  ),
                ),
              ),
            ),

            const Spacer(),

            // Tutorial content
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.surface, AppColors.backgroundLight],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.primary.withAlpha(100)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(50),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icon
                  Text(
                    step.icon,
                    style: const TextStyle(fontSize: 64),
                  )
                      .animate(key: ValueKey(_currentStep))
                      .fadeIn(duration: 300.ms)
                      .scale(begin: const Offset(0.5, 0.5)),

                  const SizedBox(height: 20),

                  // Title
                  Text(
                    step.title,
                    style: AppTextStyles.headline2,
                    textAlign: TextAlign.center,
                  )
                      .animate(key: ValueKey('title_$_currentStep'))
                      .fadeIn(delay: 100.ms),

                  const SizedBox(height: 12),

                  // Description
                  Text(
                    step.description,
                    style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  )
                      .animate(key: ValueKey('desc_$_currentStep'))
                      .fadeIn(delay: 200.ms),

                  const SizedBox(height: 24),

                  // Progress dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_steps.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: index == _currentStep ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == _currentStep
                              ? AppColors.primary
                              : AppColors.primary.withAlpha(50),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous button
                  _currentStep > 0
                      ? TextButton.icon(
                          onPressed: _previousStep,
                          icon: const Icon(Icons.arrow_back, color: Colors.white70),
                          label: Text(
                            'Back',
                            style: AppTextStyles.body2.copyWith(color: Colors.white70),
                          ),
                        )
                      : const SizedBox(width: 80),

                  // Next/Start button
                  ElevatedButton.icon(
                    onPressed: _nextStep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isLastStep ? AppColors.success : AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: Icon(
                      isLastStep ? Icons.play_arrow : Icons.arrow_forward,
                      size: 20,
                    ),
                    label: Text(
                      isLastStep ? 'Start Playing!' : 'Next',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class TutorialStep {
  final String icon;
  final String title;
  final String description;

  const TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
  });
}
