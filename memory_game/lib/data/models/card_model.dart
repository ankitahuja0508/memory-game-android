import 'package:equatable/equatable.dart';

/// Represents the state of a card
enum CardState {
  faceDown,   // Hidden, can be flipped
  faceUp,     // Currently revealed
  matched,    // Matched pair, permanently shown
  hinted,     // Being hinted at
}

/// Model representing a memory card
class CardModel extends Equatable {
  final String id;
  final String symbol;
  final int pairId;
  final CardState state;
  final bool isNew; // For tracking if card was never flipped

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
  bool get canBeFlipped => state == CardState.faceDown || state == CardState.hinted;
  bool get isRevealed => state == CardState.faceUp || state == CardState.matched;

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'pairId': pairId,
      'state': state.index,
      'isNew': isNew,
    };
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      pairId: json['pairId'] as int,
      state: CardState.values[json['state'] as int],
      isNew: json['isNew'] as bool? ?? true,
    );
  }

  @override
  List<Object?> get props => [id, symbol, pairId, state, isNew];

  @override
  String toString() {
    return 'CardModel(id: $id, symbol: $symbol, pairId: $pairId, state: $state)';
  }
}
