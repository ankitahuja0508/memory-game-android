import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/card_model.dart';

class MemoryCard extends StatelessWidget {
  final CardModel card;
  final VoidCallback? onTap;
  final double size;
  final bool interactive;

  const MemoryCard({
    super.key,
    required this.card,
    this.onTap,
    this.size = 80,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: interactive && card.canBeFlipped ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        child: _buildCard(),
      ),
    );
  }

  Widget _buildCard() {
    // Determine if card should show front
    final showFront = card.isFaceUp || card.isMatched || card.isHinted || card.isPreview;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: showFront ? 0 : pi, end: showFront ? pi : 0),
      duration: const Duration(milliseconds: 300),
      builder: (context, value, child) {
        // Determine which side to show based on rotation
        final showBack = value < pi / 2;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(value),
          child: showBack ? _buildBackSide() : _buildFrontSide(),
        );
      },
    );
  }

  Widget _buildBackSide() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: AppColors.cardGradient,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(77),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Text('?', style: TextStyle(fontSize: 24, color: Colors.white70)),
          ),
        ),
      ),
    );
  }

  Widget _buildFrontSide() {
    Color bgColor = AppColors.cardFront;
    Color borderColor = Colors.transparent;
    List<BoxShadow>? shadows;

    if (card.isMatched) {
      borderColor = AppColors.matchGlow;
      shadows = [
        BoxShadow(
          color: AppColors.matchGlow.withAlpha(128),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ];
    } else if (card.isHinted) {
      borderColor = AppColors.accent;
      shadows = [
        BoxShadow(
          color: AppColors.accent.withAlpha(128),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ];
    } else if (card.isPreview) {
      borderColor = AppColors.secondary;
      bgColor = Colors.white;
    }

    Widget content = Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 3),
        boxShadow: shadows ?? [
          BoxShadow(
            color: Colors.black.withAlpha(51),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      // We need to flip this side since parent is rotated 180 degrees
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()..rotateY(pi),
        child: Center(
          child: Text(
            card.symbol,
            style: TextStyle(fontSize: size * 0.5),
          ),
        ),
      ),
    );

    if (card.isMatched) {
      content = content
          .animate(onPlay: (c) => c.forward())
          .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 200.ms)
          .then()
          .scale(begin: const Offset(1.05, 1.05), end: const Offset(1, 1), duration: 200.ms);
    }

    return content;
  }
}
