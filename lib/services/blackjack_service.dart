import 'dart:math';

import '../models/playing_card.dart';

class BlackjackService {
  final Random _random = Random();

  /// Crea y mezcla una baraja completa de 52 cartas.
  List<PlayingCard> createShuffledDeck() {
    const ranks = [
      ('A', 11),
      ('2', 2),
      ('3', 3),
      ('4', 4),
      ('5', 5),
      ('6', 6),
      ('7', 7),
      ('8', 8),
      ('9', 9),
      ('10', 10),
      ('J', 10),
      ('Q', 10),
      ('K', 10),
    ];

    final deck = <PlayingCard>[];

    for (final suit in CardSuit.values) {
      for (final rank in ranks) {
        deck.add(
          PlayingCard(
            rank: rank.$1,
            suit: suit,
            value: rank.$2,
          ),
        );
      }
    }

    deck.shuffle(_random);
    return deck;
  }

  /// Toma la siguiente carta del mazo.
  PlayingCard drawCard(List<PlayingCard> deck) {
    return deck.removeLast();
  }

  /// Suma los puntos de una mano ajustando Ases de 11 a 1 cuando sea necesario.
  int calculateHandValue(List<PlayingCard> hand) {
    int total = 0;
    int aces = 0;

    for (final card in hand) {
      total += card.value;
      if (card.rank == 'A') {
        aces++;
      }
    }

    // Si nos pasamos de 21, convertimos Ases de 11 -> 1 restando 10 por cada ajuste.
    while (total > 21 && aces > 0) {
      total -= 10;
      aces--;
    }

    return total;
  }
}
