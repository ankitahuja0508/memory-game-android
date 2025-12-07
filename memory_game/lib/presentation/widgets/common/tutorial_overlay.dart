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
  late PageController _pageController;

  final List<TutorialStep> _steps = [
    const TutorialStep(
      icon: '🎮',
      title: 'Welcome to Memory Match!',
      description: 'A fun memory game where you match pairs of cards.',
      illustration: '🃏🃏',
    ),
    const TutorialStep(
      icon: '👆',
      title: 'Tap to Flip',
      description: 'Tap any card to reveal what\'s underneath.',
      illustration: '👆🃏',
    ),
    const TutorialStep(
      icon: '🎯',
      title: 'Find Matching Pairs',
      description: 'Remember card positions and find matching pairs to clear them.',
      illustration: '🌟🌟',
    ),
    const TutorialStep(
      icon: '⏱️',
      title: 'Beat the Clock',
      description: 'Complete each level before time runs out!',
      illustration: '⏰',
    ),
    const TutorialStep(
      icon: '⭐',
      title: 'Earn Stars',
      description: 'Fewer moves = more stars = more coins!',
      illustration: '⭐⭐⭐',
    ),
    const TutorialStep(
      icon: '🔮',
      title: 'Use Power-ups',
      description: 'Stuck? Use power-ups like Peek 👁️, Freeze ❄️, Hint 🔦, or Magnet 🧲 to help!',
      illustration: '👁️❄️🔦🧲',
    ),
    const TutorialStep(
      icon: '🚀',
      title: 'Ready to Play!',
      description: 'Good luck and have fun!',
      illustration: '🎉',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    } else {
      widget.onComplete();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastStep = _currentStep == _steps.length - 1;
    final size = MediaQuery.of(context).size;

    return SafeArea(
      child: Column(
        children: [
          // Top bar with skip button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Step indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(26),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentStep + 1} / ${_steps.length}',
                    style: AppTextStyles.body2.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: widget.onComplete,
                  child: Text(
                    'Skip',
                    style: AppTextStyles.body2.copyWith(color: Colors.white70),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms).slideY(begin: -0.3),

          // Main content - PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _steps.length,
              onPageChanged: (index) {
                setState(() => _currentStep = index);
              },
              itemBuilder: (context, index) {
                final step = _steps[index];
                return _TutorialPage(
                  step: step,
                  index: index,
                  size: size,
                );
              },
            ),
          ),

          // Progress dots
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_steps.length, (index) {
                final isActive = index == _currentStep;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 28 : 10,
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: isActive
                        ? const LinearGradient(colors: AppColors.primaryGradient)
                        : null,
                    color: isActive ? null : Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(5),
                  ),
                );
              }),
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Row(
              children: [
                // Previous button
                AnimatedOpacity(
                  opacity: _currentStep > 0 ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedScale(
                    scale: _currentStep > 0 ? 1.0 : 0.8,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        onPressed: _currentStep > 0 ? _previousStep : null,
                        icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Next/Start button
                GestureDetector(
                  onTap: _nextStep,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isLastStep
                            ? AppColors.successGradient
                            : AppColors.primaryGradient,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: (isLastStep ? AppColors.success : AppColors.primary)
                              .withAlpha(100),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isLastStep ? 'Start Playing!' : 'Next',
                          style: AppTextStyles.body1.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          isLastStep ? Icons.play_arrow_rounded : Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ],
                    ),
                  ),
                ).animate(target: isLastStep ? 1 : 0).scale(
                      begin: const Offset(1, 1),
                      end: const Offset(1.05, 1.05),
                      duration: 600.ms,
                      curve: Curves.easeInOut,
                    ),
              ],
            ),
          ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.3),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _TutorialPage extends StatelessWidget {
  final TutorialStep step;
  final int index;
  final Size size;

  const _TutorialPage({
    required this.step,
    required this.index,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Large illustration container
          Container(
            width: size.width * 0.65,
            height: size.width * 0.65,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withAlpha(40),
                  AppColors.secondary.withAlpha(30),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withAlpha(60),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withAlpha(30),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Main icon
                  Text(
                    step.icon,
                    style: const TextStyle(fontSize: 72),
                  )
                      .animate(key: ValueKey('icon_$index'))
                      .fadeIn(duration: 400.ms)
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        curve: Curves.elasticOut,
                        duration: 600.ms,
                      ),
                  const SizedBox(height: 12),
                  // Illustration
                  Text(
                    step.illustration,
                    style: const TextStyle(fontSize: 28),
                  )
                      .animate(key: ValueKey('illust_$index'))
                      .fadeIn(delay: 200.ms, duration: 300.ms),
                ],
              ),
            ),
          )
              .animate(key: ValueKey('container_$index'))
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.1),

          const SizedBox(height: 40),

          // Title
          Text(
            step.title,
            style: AppTextStyles.headline1.copyWith(fontSize: 26),
            textAlign: TextAlign.center,
          )
              .animate(key: ValueKey('title_$index'))
              .fadeIn(delay: 150.ms, duration: 400.ms)
              .slideY(begin: 0.2),

          const SizedBox(height: 16),

          // Description
          Text(
            step.description,
            style: AppTextStyles.body1.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          )
              .animate(key: ValueKey('desc_$index'))
              .fadeIn(delay: 250.ms, duration: 400.ms)
              .slideY(begin: 0.2),
        ],
      ),
    );
  }
}

class TutorialStep {
  final String icon;
  final String title;
  final String description;
  final String illustration;

  const TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
    required this.illustration,
  });
}
