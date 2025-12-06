import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../../../data/models/card_model.dart';
import 'memory_card.dart';

class GameBoard extends StatelessWidget {
  final List<CardModel> cards;
  final int columns;
  final int rows;
  final Function(int) onCardTap;
  final bool interactive;

  const GameBoard({
    super.key,
    required this.cards,
    required this.columns,
    required this.rows,
    required this.onCardTap,
    this.interactive = true,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate card size based on available space
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight;

        // Calculate spacing
        const spacing = 8.0;
        const padding = 8.0;

        // Calculate maximum card size that fits
        final maxCardWidth = (availableWidth - (padding * 2) - (spacing * (columns - 1))) / columns;
        final maxCardHeight = (availableHeight - (padding * 2) - (spacing * (rows - 1))) / rows;

        // Use the smaller dimension to ensure cards fit, with a reasonable max
        final cardSize = [maxCardWidth, maxCardHeight, 100.0].reduce((a, b) => a < b ? a : b);

        // Calculate total grid dimensions
        final gridWidth = (cardSize * columns) + (spacing * (columns - 1)) + (padding * 2);
        final gridHeight = (cardSize * rows) + (spacing * (rows - 1)) + (padding * 2);

        return Center(
          child: SizedBox(
            width: gridWidth,
            height: gridHeight,
            child: Padding(
              padding: const EdgeInsets.all(padding),
              child: AnimationLimiter(
                child: GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childAspectRatio: 1,
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, index) {
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: columns,
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: MemoryCard(
                            card: cards[index],
                            size: cardSize,
                            onTap: () => onCardTap(index),
                            interactive: interactive,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
