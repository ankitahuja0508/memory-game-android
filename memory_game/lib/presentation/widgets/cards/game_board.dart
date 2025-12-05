import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../data/models/card_model.dart';
import 'memory_card.dart';

/// Game board with card grid
class GameBoard extends StatelessWidget {
  final List<CardModel> cards;
  final int columns;
  final Function(int) onCardTap;
  final bool isInteractive;

  const GameBoard({
    super.key,
    required this.cards,
    required this.columns,
    required this.onCardTap,
    this.isInteractive = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final rows = (cards.length / columns).ceil();

        // Calculate card size based on available space
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        const spacing = 8.0;
        final totalHorizontalSpacing = (columns + 1) * spacing;
        final totalVerticalSpacing = (rows + 1) * spacing;

        final cardWidth = (availableWidth - totalHorizontalSpacing) / columns;
        final cardHeight = (availableHeight - totalVerticalSpacing) / rows;

        // Use the smaller dimension to keep cards square-ish
        final cardSize = math.min(cardWidth, cardHeight);

        // Calculate actual grid size
        final gridWidth = (cardSize * columns) + totalHorizontalSpacing;
        final gridHeight = (cardSize * rows) + totalVerticalSpacing;

        return Center(
          child: SizedBox(
            width: gridWidth,
            height: gridHeight,
            child: AnimationLimiter(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: spacing,
                  crossAxisSpacing: spacing,
                  childAspectRatio: 1.0,
                ),
                itemCount: cards.length,
                itemBuilder: (context, index) {
                  return AnimationConfiguration.staggeredGrid(
                    position: index,
                    duration: const Duration(milliseconds: 300),
                    columnCount: columns,
                    child: ScaleAnimation(
                      child: FadeInAnimation(
                        child: MemoryCard(
                          card: cards[index],
                          onTap: () => onCardTap(index),
                          isInteractive: isInteractive,
                          size: cardSize,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Compact game board for smaller spaces
class CompactGameBoard extends StatelessWidget {
  final List<CardModel> cards;
  final int columns;
  final double maxCardSize;

  const CompactGameBoard({
    super.key,
    required this.cards,
    required this.columns,
    this.maxCardSize = 60,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      alignment: WrapAlignment.center,
      children: cards.map((card) {
        return SizedBox(
          width: maxCardSize,
          height: maxCardSize,
          child: Container(
            decoration: BoxDecoration(
              color: card.isMatched ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: card.isRevealed
                  ? Text(card.symbol, style: const TextStyle(fontSize: 24))
                  : const Icon(Icons.question_mark, size: 20),
            ),
          ),
        );
      }).toList(),
    );
  }
}
