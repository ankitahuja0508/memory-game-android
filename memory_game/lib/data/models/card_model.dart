import 'package:equatable/equatable.dart';

/// Represents the state of a card
enum CardState {
  faceDown,
  faceUp,
  matched,
  hinted,
  preview, // New state for initial preview
}

/// Model representing a memory card
class CardModel extends Equatable {
  final String id;
  final String symbol;
  final int pairId;
  final CardState state;
  final bool isNew;

  const CardModel({
    required this.id,
    required this.symbol,
    required this.pairId,
    this.state = CardState.faceDown,
    this.isNew = true,
  });

  bool get isFaceDown => state == CardState.faceDown;
  bool get isFaceUp => state == CardState.faceUp;
  bool get isMatched => state == CardState.matched;
  bool get isHinted => state == CardState.hinted;
  bool get isPreview => state == CardState.preview;
  bool get canBeFlipped => state == CardState.faceDown || state == CardState.hinted;
  bool get isRevealed => state == CardState.faceUp || state == CardState.matched || state == CardState.preview;

  CardModel copyWith({
    String? id,
    String? symbol,
    int? pairId,
    CardState? state,
    bool? isNew,
  }) {
    return CardModel(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      pairId: pairId ?? this.pairId,
      state: state ?? this.state,
      isNew: isNew ?? this.isNew,
    );
  }

  @override
  List<Object?> get props => [id, symbol, pairId, state, isNew];
}
