import 'package:flutter/material.dart';

import '../models/spanish_card.dart';
import '../services/spanish_deck_service.dart';
import '../theme/app_theme.dart';
import '../widgets/spanish_card_view.dart';

class SpanishDuelScreen extends StatefulWidget {
  const SpanishDuelScreen({super.key});

  @override
  State<SpanishDuelScreen> createState() => _SpanishDuelScreenState();
}

class _SpanishDuelScreenState extends State<SpanishDuelScreen> {
  final SpanishDeckService _deckService = SpanishDeckService();

  SpanishCard? _player1Card;
  SpanishCard? _player2Card;
  int _player1Score = 0;
  int _player2Score = 0;
  String _resultMessage = 'Toca el mazo para repartir.';

  void _drawCards() {
    final cards = _deckService.drawTwoCards();
    final p1 = cards.player1;
    final p2 = cards.player2;

    setState(() {
      _player1Card = p1;
      _player2Card = p2;
    });

    if (p1.value > p2.value) {
      _player1Score++;
      _updateResult('Gana jugador 1');
    } else if (p2.value > p1.value) {
      _player2Score++;
      _updateResult('Gana jugador 2');
    } else {
      _updateResult('Empate');
    }
  }

  void _updateResult(String message) {
    setState(() {
      _resultMessage = message;
    });
  }

  void _resetScores() {
    setState(() {
      _player1Score = 0;
      _player2Score = 0;
      _player1Card = null;
      _player2Card = null;
      _resultMessage = 'Toca el mazo para repartir.';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Duelo de cartas'),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A031A),
              Color(0xFF1B1B3A),
              Color(0xFF0F1F3D),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                RotatedBox(
                  quarterTurns: 2,
                  child: _PlayerArea(
                    title: 'Jugador 2',
                    card: _player2Card,
                    score: _player2Score,
                    highlight: AppTheme.accent,
                    flippedCard: true,
                  ),
                ),
                const SizedBox(height: 16),
                _DeckArea(
                  message: _resultMessage,
                  onTap: _drawCards,
                ),
                const SizedBox(height: 16),
                _PlayerArea(
                  title: 'Jugador 1',
                  card: _player1Card,
                  score: _player1Score,
                  highlight: AppTheme.primary,
                  flippedCard: false,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: _resetScores,
                    icon: const Icon(Icons.restart_alt, color: Colors.white70),
                    label: const Text(
                      'Reiniciar marcador',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerArea extends StatelessWidget {
  final String title;
  final SpanishCard? card;
  final int score;
  final Color highlight;
  final bool flippedCard;

  const _PlayerArea({
    required this.title,
    required this.card,
    required this.score,
    required this.highlight,
    this.flippedCard = false,
  });

  @override
  Widget build(BuildContext context) {
    const double cardHeight = 160;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: highlight.withOpacity(0.18),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: highlight.withOpacity(0.6)),
              ),
              child: Text(
                'Puntos: $score',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _CardView(
          card: card,
          highlight: highlight,
          flipped: flippedCard,
          height: cardHeight,
        ),
      ],
    );
  }
}

class _CardView extends StatelessWidget {
  final SpanishCard? card;
  final Color highlight;
  final bool flipped;
  final double height;

  const _CardView({
    required this.card,
    required this.highlight,
    this.flipped = false,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (card == null) {
      return SizedBox(
        height: height,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withOpacity(0.05),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
            boxShadow: [
              BoxShadow(
                color: highlight.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              'Sin carta',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: SpanishCardView(
        card: card!,
        highlighted: true,
        flipped: flipped,
      ),
    );
  }
}

class _DeckArea extends StatelessWidget {
  final String message;
  final VoidCallback onTap;

  const _DeckArea({
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF6D0D88),
              Color(0xFF2D0A4D),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.5),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(Icons.layers_rounded, color: Colors.white, size: 36),
            const SizedBox(height: 8),
            Text(
              'Tocar para sacar cartas',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
