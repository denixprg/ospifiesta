import 'dart:math';

import 'package:flutter/material.dart';

import '../data/duel_daress.dart';
import '../data/duel_questions.dart';
import '../models/player.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';
import 'player_setup_screen.dart';

enum DuelType { rps, question, dare }

class DuelScreen extends StatefulWidget {
  const DuelScreen({super.key});

  @override
  State<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends State<DuelScreen> {
  final PlayerService _playerService = PlayerService();
  final Random _random = Random();

  Player? _playerA;
  Player? _playerB;
  DuelType? _duelType;
  String? _duelText;
  String? _resultText;

  bool get _hasEnoughPlayers => _playerService.players.length >= 2;
  bool get _duelActive => _playerA != null && _playerB != null && _duelType != null;
  bool get _resultReady => _resultText != null;

  void _startDuel() {
    if (!_hasEnoughPlayers) {
      _openPlayerSetup();
      return;
    }

    final players = _playerService.players;
    if (players.length < 2) return;

    final int firstIndex = _random.nextInt(players.length);
    int secondIndex = _random.nextInt(players.length);
    while (secondIndex == firstIndex) {
      secondIndex = _random.nextInt(players.length);
    }

    final DuelType type = DuelType.values[_random.nextInt(DuelType.values.length)];
    final String duelText = _buildDuelText(type);

    setState(() {
      _playerA = players[firstIndex];
      _playerB = players[secondIndex];
      _duelType = type;
      _duelText = duelText;
      _resultText = null;
    });
  }

  String _buildDuelText(DuelType type) {
    switch (type) {
      case DuelType.rps:
        return 'Piedra, papel o tijera. Pulsa quién perdió.';
      case DuelType.question:
        return duelQuestions[_random.nextInt(duelQuestions.length)];
      case DuelType.dare:
        return duelDares[_random.nextInt(duelDares.length)];
    }
  }

  void _resolveWinner(Player? winner) {
    if (!_duelActive) return;
    final Player playerA = _playerA!;
    final Player playerB = _playerB!;

    String result;
    if (winner == null) {
      result = 'Empate: ${playerA.name} y ${playerB.name} beben 🍺🍺';
    } else {
      final Player loser = winner.id == playerA.id ? playerB : playerA;
      result = 'Perdedor: ${loser.name} bebe 🍺';
    }

    setState(() {
      _resultText = result;
    });
  }

  Future<void> _openPlayerSetup() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const PlayerSetupScreen()),
    );
    setState(() {
      // Refrescamos estado para reflejar nuevos jugadores.
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Duelo ⚔️'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF060018),
              Color(0xFF1B0630),
              Color(0xFF0F233F),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _hasEnoughPlayers ? _buildDuelContent(context) : _buildNoPlayers(),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                text: _resultReady ? 'Siguiente duelo' : 'Empezar duelo',
                icon: Icons.flash_on_rounded,
                onPressed: _startDuel,
              ),
              const SizedBox(height: 10),
              FiestaBackButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDuelContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 4),
        Text(
          _duelActive ? 'Elige quién ganó el duelo' : 'Pulsa "Empezar duelo" para elegir rivales',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                letterSpacing: 0.2,
              ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _PlayerCard(player: _playerA, alignLeft: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _PlayerCard(player: _playerB, alignLeft: false)),
                ],
              ),
              const SizedBox(height: 16),
              _DuelCard(
                duelType: _duelType,
                text: _duelText ?? 'Aun no hay duelo activo',
              ),
              const SizedBox(height: 12),
              if (_duelActive) _buildResultButtons(context),
              if (_resultReady) ...[
                const SizedBox(height: 12),
                _ResultBanner(text: _resultText!),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildResultButtons(BuildContext context) {
    final Player playerA = _playerA!;
    final Player playerB = _playerB!;
    return Column(
      children: [
        Text(
          '¿Quién ganó?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _resolveWinner(playerA),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text('Gana ${playerA.name}'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _resolveWinner(playerB),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.deepPurpleAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text('Gana ${playerB.name}'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => _resolveWinner(null),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: Colors.white.withOpacity(0.4)),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text('Empate'),
          ),
        ),
      ],
    );
  }

  Widget _buildNoPlayers() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.group_add_rounded, color: Colors.white, size: 40),
            const SizedBox(height: 10),
            const Text(
              'Necesitas al menos 2 jugadores',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configura jugadores para comenzar los duelos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              text: 'Configurar jugadores',
              icon: Icons.settings_rounded,
              onPressed: _openPlayerSetup,
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final Player? player;
  final bool alignLeft;

  const _PlayerCard({required this.player, required this.alignLeft});

  @override
  Widget build(BuildContext context) {
    final String label = player?.name ?? 'Jugador';
    final Alignment alignment = alignLeft ? Alignment.centerLeft : Alignment.centerRight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: alignLeft
              ? [AppTheme.primary.withOpacity(0.75), const Color(0xFF1E0A2F)]
              : [AppTheme.accent.withOpacity(0.75), const Color(0xFF0E1F38)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Align(
        alignment: alignment,
        child: Column(
          crossAxisAlignment: alignLeft ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              alignLeft ? 'Jugador A' : 'Jugador B',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white70,
                    letterSpacing: 0.3,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DuelCard extends StatelessWidget {
  final DuelType? duelType;
  final String text;

  const _DuelCard({required this.duelType, required this.text});

  @override
  Widget build(BuildContext context) {
    final String typeLabel = switch (duelType) {
      DuelType.rps => 'PPT',
      DuelType.question => 'Pregunta',
      DuelType.dare => 'Reto',
      _ => 'Duelo',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: const [
            Color(0xFF1F0A2E),
            Color(0xFF0A1C35),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Text(
              typeLabel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.4,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            text,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
          ),
        ],
      ),
    );
  }
}

class _ResultBanner extends StatelessWidget {
  final String text;

  const _ResultBanner({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_rounded, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
