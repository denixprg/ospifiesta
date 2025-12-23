import 'package:flutter/material.dart';

import '../models/playing_card.dart';
import '../services/blackjack_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';

enum BlackjackState { initial, playerTurn, dealerTurn, finished }

class BlackjackScreen extends StatefulWidget {
  const BlackjackScreen({super.key});

  @override
  State<BlackjackScreen> createState() => _BlackjackScreenState();
}

class _BlackjackScreenState extends State<BlackjackScreen> {
  final BlackjackService _service = BlackjackService();

  List<PlayingCard> _playerHand = [];
  List<PlayingCard> _dealerHand = [];
  List<PlayingCard> _deck = [];
  BlackjackState _state = BlackjackState.initial;
  String _resultMessage = 'Pulsa "Nueva ronda" para repartir.';

  int get _playerScore =>
      _playerHand.isEmpty ? 0 : _service.calculateHandValue(_playerHand);

  int get _dealerScore =>
      _dealerHand.isEmpty ? 0 : _service.calculateHandValue(_dealerHand);

  bool get _isPlayerTurn => _state == BlackjackState.playerTurn;

  void _startNewRound() {
    setState(() {
      _deck = _service.createShuffledDeck();
      _playerHand = [
        _service.drawCard(_deck),
        _service.drawCard(_deck),
      ];
      _dealerHand = [
        _service.drawCard(_deck),
        _service.drawCard(_deck),
      ];
      _state = BlackjackState.playerTurn;
      _resultMessage = 'Tu turno: pide o plantate.';
    });
  }

  void _playerHit() {
    if (!_isPlayerTurn) return;

    setState(() {
      _playerHand.add(_service.drawCard(_deck));
    });

    final playerTotal = _service.calculateHandValue(_playerHand);
    if (playerTotal > 21) {
      // El jugador se pasa: la banca gana automaticamente.
      _finishRound('La banca gana 🍸 Bebe 2 tragos.');
    }
  }

  void _playerStand() {
    if (!_isPlayerTurn) return;

    setState(() {
      _state = BlackjackState.dealerTurn;
      _resultMessage = 'Turno de la banca...';
    });

    _playDealerTurn();
  }

  void _playDealerTurn() {
    // La banca roba hasta llegar a 17 o mas.
    while (_service.calculateHandValue(_dealerHand) < 17) {
      setState(() {
        _dealerHand.add(_service.drawCard(_deck));
      });
    }

    final dealerTotal = _service.calculateHandValue(_dealerHand);
    final playerTotal = _service.calculateHandValue(_playerHand);

    if (dealerTotal > 21) {
      _finishRound('Has ganado 🎉 Reparte 2 tragos entre quien quieras.');
      return;
    }

    if (playerTotal > dealerTotal) {
      _finishRound('Has ganado 🎉 Reparte 2 tragos entre quien quieras.');
    } else if (dealerTotal > playerTotal) {
      _finishRound('La banca gana 🍸 Bebe 2 tragos.');
    } else {
      _finishRound('Empate 🤝 Todos beben 1 trago.');
    }
  }

  void _finishRound(String message) {
    setState(() {
      _state = BlackjackState.finished;
      _resultMessage = message;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primary,
      ),
    );
  }

  String get _stateLabel {
    switch (_state) {
      case BlackjackState.initial:
        return 'Listo para repartir.';
      case BlackjackState.playerTurn:
        return 'Tu turno.';
      case BlackjackState.dealerTurn:
        return 'Turno de la banca.';
      case BlackjackState.finished:
        return 'Ronda terminada.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blackjack borracho'),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A031A),
              Color(0xFF1A0F3B),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _HandSection(
                  title: 'Banca',
                  score: _dealerHand.isEmpty ? '--' : '$_dealerScore',
                  cards: _dealerHand,
                  highlightColor: AppTheme.accent,
                ),
                const SizedBox(height: 16),
                _StatusCard(
                  stateLabel: _stateLabel,
                  message: _resultMessage,
                ),
                const SizedBox(height: 16),
                _HandSection(
                  title: 'Tu mano',
                  score: _playerHand.isEmpty ? '--' : '$_playerScore',
                  cards: _playerHand,
                  highlightColor: AppTheme.primary,
                ),
                const Spacer(),
                _ActionsRow(
                  onNewRound: _startNewRound,
                  onHit: _playerHit,
                  onStand: _playerStand,
                  playerControlsEnabled: _isPlayerTurn,
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: FiestaBackButton(),
      ),
    );
  }
}

class _HandSection extends StatelessWidget {
  final String title;
  final String score;
  final List<PlayingCard> cards;
  final Color highlightColor;

  const _HandSection({
    required this.title,
    required this.score,
    required this.cards,
    required this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        color: Colors.white.withOpacity(0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  color: highlightColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: highlightColor.withOpacity(0.6)),
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
          const SizedBox(height: 12),
          if (cards.isEmpty)
            Text(
              'Sin cartas',
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                    color: Colors.white70,
                  ),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: cards.map(_CardChip.new).toList(),
            ),
        ],
      ),
    );
  }
}

class _CardChip extends StatelessWidget {
  final PlayingCard card;

  const _CardChip(this.card);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.08),
            Colors.white.withOpacity(0.04),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: card.suit.color.withOpacity(0.6),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Text(
        card.label,
        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              color: card.suit.color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String stateLabel;
  final String message;

  const _StatusCard({
    required this.stateLabel,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            color: AppTheme.primary.withOpacity(0.4),
            blurRadius: 16,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            stateLabel,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.white70,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}

class _ActionsRow extends StatelessWidget {
  final VoidCallback onNewRound;
  final VoidCallback onHit;
  final VoidCallback onStand;
  final bool playerControlsEnabled;

  const _ActionsRow({
    required this.onNewRound,
    required this.onHit,
    required this.onStand,
    required this.playerControlsEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onNewRound,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: const Text('Nueva ronda'),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: playerControlsEnabled ? onHit : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Pedir'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: playerControlsEnabled ? onStand : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.14),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  side: BorderSide(
                    color: Colors.white.withOpacity(0.3),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                child: const Text('Plantarse'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
