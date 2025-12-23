import 'dart:math';

import '../models/spanish_card.dart';

class SpanishDeckService {
  final Random _random = Random();
  late List<SpanishCard> _deck;

  SpanishDeckService() {
    _deck = _createShuffledDeck();
  }

  /// Genera la baraja completa de 40 cartas y la mezcla.
  List<SpanishCard> _createShuffledDeck() {
    final cards = <SpanishCard>[];
    for (final suit in SpanishSuit.values) {
      for (int value = 1; value <= 12; value++) {
        if (value >= 8 && value <= 9) continue; // Se saltan 8 y 9 en la baraja espanola
        cards.add(SpanishCard(suit: suit, value: value));
      }
    }
    cards.shuffle(_random);
    return cards;
  }

  void resetDeck() {
    _deck = _createShuffledDeck();
  }

  /// Devuelve dos cartas. Si no hay suficientes, remezcla antes de repartir.
  ({SpanishCard player1, SpanishCard player2}) drawTwoCards() {
    if (_deck.length < 2) {
      resetDeck();
    }

    final player1 = _deck.removeLast();
    final player2 = _deck.removeLast();
    return (player1: player1, player2: player2);
  }
}
