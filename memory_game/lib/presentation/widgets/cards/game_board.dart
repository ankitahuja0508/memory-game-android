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
        // Available space
        final availableWidth = constraints.maxWidth - 24; // 12px padding each side
        final availableHeight = constraints.maxHeight - 24;

        // Calculate card size that fits
        const spacing = 6.0;
        
        // Max size based on width
        final maxCardWidth = (availableWidth - (spacing * (columns - 1))) / columns;
        // Max size based on height
        final maxCardHeight = (availableHeight - (spacing * (rows - 1))) / rows;
        
        // Use the smaller to ensure it fits, cap at 90px
        final cardSize = [maxCardWidth, maxCardHeight, 90.0].reduce((a, b) => a < b ? a : b);

        // Build grid
        return Padding(
          padding: const EdgeInsets.all(12),
          child: AnimationLimiter(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(rows, (rowIndex) {
                return Padding(
                  padding: EdgeInsets.only(bottom: rowIndex < rows - 1 ? spacing : 0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(columns, (colIndex) {
                      final index = rowIndex * columns + colIndex;
                      if (index >= cards.length) {
                        return SizedBox(width: cardSize, height: cardSize);
                      }

                      return AnimationConfiguration.staggeredGrid(
                        position: index,
                        duration: const Duration(milliseconds: 300),
                        columnCount: columns,
                        child: ScaleAnimation(
                          child: FadeInAnimation(
                            child: Padding(
                              padding: EdgeInsets.only(right: colIndex < columns - 1 ? spacing : 0),
                              child: SizedBox(
                                width: cardSize,
                                height: cardSize,
                                child: MemoryCard(
                                  card: cards[index],
                                  size: cardSize,
                                  onTap: () => onCardTap(index),
                                  interactive: interactive,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
