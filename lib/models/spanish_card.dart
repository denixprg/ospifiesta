enum SpanishSuit { oros, copas, espadas, bastos }

class SpanishCard {
  final SpanishSuit suit;
  final int value; // valores validos: 1-7, 10-12

  const SpanishCard({
    required this.suit,
    required this.value,
  });

  String get rankLabel {
    return switch (value) {
      10 => 'Sota',
      11 => 'Caballo',
      12 => 'Rey',
      _ => value.toString(),
    };
  }

  String get suitShortLabel {
    return switch (suit) {
      SpanishSuit.oros => 'O',
      SpanishSuit.copas => 'C',
      SpanishSuit.espadas => 'E',
      SpanishSuit.bastos => 'B',
    };
  }

  String get suitEmoji {
    return switch (suit) {
      SpanishSuit.oros => '⭐',
      SpanishSuit.copas => '🍷',
      SpanishSuit.espadas => '🗡️',
      SpanishSuit.bastos => '🪵',
    };
  }

  String get displayName {
    final suitName = switch (suit) {
      SpanishSuit.oros => 'oros',
      SpanishSuit.copas => 'copas',
      SpanishSuit.espadas => 'espadas',
      SpanishSuit.bastos => 'bastos',
    };

    final rankName = switch (value) {
      10 => 'Sota',
      11 => 'Caballo',
      12 => 'Rey',
      _ => value.toString(),
    };

    return '$rankName de $suitName';
  }
}
