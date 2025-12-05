import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../data/models/card_model.dart';

/// Memory card widget with flip animation
class MemoryCard extends StatefulWidget {
  final CardModel card;
  final VoidCallback? onTap;
  final bool isInteractive;
  final double size;

  const MemoryCard({
    super.key,
    required this.card,
    this.onTap,
    this.isInteractive = true,
    this.size = 80,
  });

  @override
  State<MemoryCard> createState() => _MemoryCardState();
}

class _MemoryCardState extends State<MemoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _flipAnimation;
  bool _showFront = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _flipAnimation.addListener(() {
      if (_flipAnimation.value >= 0.5 && !_showFront) {
        setState(() => _showFront = true);
      } else if (_flipAnimation.value < 0.5 && _showFront) {
        setState(() => _showFront = false);
      }
    });

    // Set initial state
    if (widget.card.isRevealed) {
      _controller.value = 1.0;
      _showFront = true;
    }
  }

  @override
  void didUpdateWidget(MemoryCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.card.state != oldWidget.card.state) {
      if (widget.card.isRevealed && !oldWidget.card.isRevealed) {
        _controller.forward();
      } else if (!widget.card.isRevealed && oldWidget.card.isRevealed) {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canTap = widget.isInteractive && widget.card.canBeFlipped;

    return GestureDetector(
      onTap: canTap ? widget.onTap : null,
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * math.pi;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: _showFront
                ? Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(math.pi),
                    child: _buildFrontFace(),
                  )
                : _buildBackFace(),
          );
        },
      ),
    );
  }

  Widget _buildFrontFace() {
    final isMatched = widget.card.isMatched;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: AppColors.cardFront,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isMatched
              ? AppColors.matchGlow
              : AppColors.primary.withOpacity(0.3),
          width: isMatched ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isMatched
                ? AppColors.matchGlow.withOpacity(0.4)
                : Colors.black26,
            blurRadius: isMatched ? 15 : 8,
            spreadRadius: isMatched ? 2 : 0,
          ),
        ],
      ),
      child: Center(
        child: Text(
          widget.card.symbol,
          style: TextStyle(
            fontSize: widget.size * 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildBackFace() {
    final isHinted = widget.card.isHinted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isHinted
              ? [AppColors.accent, AppColors.accent.withOpacity(0.8)]
              : AppColors.cardGradient,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHinted
              ? AppColors.accent
              : AppColors.primary.withOpacity(0.5),
          width: isHinted ? 3 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isHinted
                ? AppColors.accent.withOpacity(0.4)
                : Colors.black26,
            blurRadius: isHinted ? 15 : 8,
            spreadRadius: isHinted ? 2 : 0,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.question_mark_rounded,
          color: Colors.white.withOpacity(0.5),
          size: widget.size * 0.35,
        ),
      ),
    );
  }
}

/// Matched card with celebration effect
class MatchedCard extends StatefulWidget {
  final CardModel card;
  final double size;

  const MatchedCard({
    super.key,
    required this.card,
    this.size = 80,
  });

  @override
  State<MatchedCard> createState() => _MatchedCardState();
}

class _MatchedCardState extends State<MatchedCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward().then((_) => _controller.reverse());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardFront,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.matchGlow,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.matchGlow.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Text(
                widget.card.symbol,
                style: TextStyle(fontSize: widget.size * 0.5),
              ),
            ),
          ),
        );
      },
    );
  }
}
