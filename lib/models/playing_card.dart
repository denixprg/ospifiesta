import 'package:flutter/material.dart';

enum CardSuit { spades, hearts, clubs, diamonds }

extension CardSuitSymbol on CardSuit {
  String get symbol {
    switch (this) {
      case CardSuit.spades:
        return '♠';
      case CardSuit.hearts:
        return '♥';
      case CardSuit.clubs:
        return '♣';
      case CardSuit.diamonds:
        return '♦';
    }
  }

  Color get color {
    switch (this) {
      case CardSuit.hearts:
      case CardSuit.diamonds:
        return Colors.redAccent;
      case CardSuit.spades:
      case CardSuit.clubs:
        return Colors.white;
    }
  }
}

class PlayingCard {
  final String rank; // 'A', '2'...'10', 'J', 'Q', 'K'
  final CardSuit suit;

  /// Valor base de blackjack (As vale 11 por defecto; se ajusta en la suma).
  final int value;

  const PlayingCard({
    required this.rank,
    required this.suit,
    required this.value,
  });

  /// Ej: "A♠" o "10♥"
  String get label => '$rank${suit.symbol}';
}
