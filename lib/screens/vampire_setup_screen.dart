import 'dart:math';

import 'package:flutter/material.dart';

import '../models/vampire_args.dart';
import '../models/vampire_role.dart';
import '../routes/app_routes.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class VampireSetupScreen extends StatefulWidget {
  const VampireSetupScreen({super.key});

  @override
  State<VampireSetupScreen> createState() => _VampireSetupScreenState();
}

class _VampireSetupScreenState extends State<VampireSetupScreen> {
  final PlayerService _playerService = PlayerService();
  final Random _random = Random();
  int _rounds = 6;

  bool get _hasPlayers => _playerService.players.isNotEmpty;
  bool get _recommended => _playerService.players.length >= 4;

  void _startGame() {
    final players = _playerService.players;
    if (players.isEmpty) return;
    final initialVampire = players[_random.nextInt(players.length)];
    final states = players
        .map(
          (p) => VampirePlayerState(
            playerId: p.id,
            role: p.id == initialVampire.id ? VampireRole.vampire : VampireRole.human,
          ),
        )
        .toList();
    final args = VampireArgs(states: states, totalRounds: _rounds);
    Navigator.pushNamed(context, AppRoutes.vampireReveal, arguments: args);
  }

  void _goToPlayerSetup() {
    Navigator.pushNamed(context, AppRoutes.playerSetup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('🧛 Vampiro'),
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
            child: _hasPlayers ? _buildForm() : _buildNoPlayers(),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Rondas: $_rounds',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Slider(
          min: 3,
          max: 12,
          divisions: 9,
          value: _rounds.toDouble(),
          activeColor: AppTheme.accent,
          inactiveColor: Colors.white24,
          label: '$_rounds',
          onChanged: (v) => setState(() => _rounds = v.round()),
        ),
        if (!_recommended)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Text(
              'Recomendado 4+ jugadores (se puede jugar igual).',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.yellow.shade200),
            ),
          )
        else
          const SizedBox(height: 16),
        PrimaryButton(
          text: 'Empezar',
          icon: Icons.play_arrow_rounded,
          onPressed: _startGame,
        ),
        const SizedBox(height: 12),
        const FiestaBackButton(),
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
            Text(
              'Necesitas jugadores configurados',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(
              text: 'Configurar jugadores',
              icon: Icons.settings_rounded,
              onPressed: _goToPlayerSetup,
            ),
            const SizedBox(height: 12),
            const FiestaBackButton(),
          ],
        ),
      ),
    );
  }
}
