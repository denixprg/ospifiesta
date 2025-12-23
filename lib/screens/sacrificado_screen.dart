import 'dart:math';

import 'package:flutter/material.dart';

import '../data/sacrificado_challenges.dart';
import '../models/player.dart';
import '../routes/app_routes.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

enum SacrificadoMode { voluntario, aleatorio }
enum SacrificadoPhase { waitingVolunteer, challenge, result }

class SacrificadoScreen extends StatefulWidget {
  const SacrificadoScreen({super.key, required this.mode});

  final SacrificadoMode mode;

  @override
  State<SacrificadoScreen> createState() => _SacrificadoScreenState();
}

class _SacrificadoScreenState extends State<SacrificadoScreen> {
  final PlayerService _playerService = PlayerService();
  final Random _random = Random();

  SacrificadoPhase _phase = SacrificadoPhase.challenge;
  Player? _sacrificado;
  String _challenge = '';
  String? _resultText;
  List<String> _remainingChallenges = [];

  @override
  void initState() {
    super.initState();
    _resetChallenges();
    _startRound(initial: true);
  }

  bool get _hasEnoughPlayers => _playerService.players.length >= 2;

  void _resetChallenges() {
    _remainingChallenges = List<String>.from(sacrificadoChallenges)
      ..shuffle(_random);
  }

  void _nextChallenge() {
    if (_remainingChallenges.isEmpty) {
      _resetChallenges();
    }
    _challenge = _remainingChallenges.removeAt(0);
  }

  void _startRound({bool initial = false}) {
    _nextChallenge();
    _resultText = null;
    if (widget.mode == SacrificadoMode.voluntario) {
      if (initial && _sacrificado == null) {
        _sacrificado = _playerService.nextPlayer();
      }
      _phase = SacrificadoPhase.waitingVolunteer;
    } else {
      _sacrificado = _pickRandomPlayer();
      _phase = SacrificadoPhase.challenge;
    }
    setState(() {});
  }

  Player? _pickRandomPlayer() {
    if (_playerService.players.isEmpty) return null;
    final players = _playerService.players;
    final index = _random.nextInt(players.length);
    return players[index];
  }

  void _confirmVolunteer() {
    setState(() {
      _phase = SacrificadoPhase.challenge;
    });
  }

  void _onResult(bool success) {
    final name = _sacrificado?.name ?? 'Jugador';
    setState(() {
      _phase = SacrificadoPhase.result;
      _resultText = success
          ? 'Lo logró. TODOS beben 🍻'
          : 'Falló → $name bebe por todos 🍺🍺';
    });
  }

  void _nextRound() {
    if (widget.mode == SacrificadoMode.voluntario) {
      _sacrificado = _playerService.nextPlayer();
    } else {
      _sacrificado = _pickRandomPlayer();
    }
    _startRound();
  }

  void _goToPlayerSetup() {
    Navigator.pushNamed(context, AppRoutes.playerSetup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('🪦 El Sacrificado'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF050016),
              Color(0xFF2D0A4D),
              Color(0xFF0E1B36),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _hasEnoughPlayers ? _buildContent() : _buildNoPlayers(),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final name = _sacrificado?.name ?? 'Jugador';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 10),
        Text(
          'Sacrificado: $name',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.08),
                    Colors.white.withOpacity(0.03),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.35),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: _buildCardContent(name),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildControls(),
        const SizedBox(height: 10),
        const FiestaBackButton(),
      ],
    );
  }

  Widget _buildCardContent(String name) {
    switch (_phase) {
      case SacrificadoPhase.waitingVolunteer:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pasa el móvil al sacrificado',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
            ),
          ],
        );
      case SacrificadoPhase.challenge:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _challenge,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
            ),
          ],
        );
      case SacrificadoPhase.result:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _resultText ?? '',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
            ),
          ],
        );
    }
  }

  Widget _buildControls() {
    switch (_phase) {
      case SacrificadoPhase.waitingVolunteer:
        return PrimaryButton(
          text: 'Listo',
          icon: Icons.check_circle_rounded,
          onPressed: _confirmVolunteer,
        );
      case SacrificadoPhase.challenge:
        return Column(
          children: [
            ElevatedButton(
              onPressed: () => _onResult(true),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                '✅ Lo logró → TODOS beben 🍻',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _onResult(false),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: Text(
                '❌ Falló → ${_sacrificado?.name ?? 'Jugador'} bebe por todos 🍺🍺',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      case SacrificadoPhase.result:
        return PrimaryButton(
          text: 'Siguiente ronda',
          icon: Icons.refresh_rounded,
          onPressed: _nextRound,
        );
    }
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
            Text(
              'Necesitas al menos 2 jugadores',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configura jugadores para empezar.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 14),
            PrimaryButton(
              text: 'Configurar jugadores',
              icon: Icons.settings_rounded,
              onPressed: _goToPlayerSetup,
            ),
          ],
        ),
      ),
    );
  }
}
