import 'dart:math';

import 'package:flutter/material.dart';

import '../data/secret_roles.dart';
import '../models/secret_role_state.dart';
import '../models/secret_roles_args.dart';
import '../routes/app_routes.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class SecretRolesSetupScreen extends StatefulWidget {
  const SecretRolesSetupScreen({super.key});

  @override
  State<SecretRolesSetupScreen> createState() => _SecretRolesSetupScreenState();
}

class _SecretRolesSetupScreenState extends State<SecretRolesSetupScreen> {
  final PlayerService _playerService = PlayerService();
  final Random _random = Random();
  int _minutes = 5;

  bool get _hasPlayers => _playerService.players.isNotEmpty;
  bool get _recommended => _playerService.players.length >= 3;

  void _startGame() {
    final players = _playerService.players;
    if (players.isEmpty) return;

    final rolesPool = List<String>.from(secretRoles)..shuffle(_random);
    final List<SecretRoleState> states = [];

    for (var i = 0; i < players.length; i++) {
      if (rolesPool.isEmpty) {
        rolesPool.addAll(secretRoles);
        rolesPool.shuffle(_random);
      }
      states.add(SecretRoleState(playerId: players[i].id, role: rolesPool.removeAt(0)));
    }

    final args = SecretRolesArgs(states: states, minutes: _minutes);
    Navigator.pushNamed(context, AppRoutes.secretRolesReveal, arguments: args);
  }

  void _goToPlayerSetup() {
    Navigator.pushNamed(context, AppRoutes.playerSetup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('🎭 Personaje secreto'),
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
          'Duración: $_minutes min',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        Slider(
          min: 1,
          max: 15,
          divisions: 14,
          value: _minutes.toDouble(),
          activeColor: AppTheme.accent,
          inactiveColor: Colors.white24,
          label: '$_minutes',
          onChanged: (v) => setState(() => _minutes = v.round()),
        ),
        if (!_recommended)
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 12),
            child: Text(
              'Recomendado 3+ jugadores (se puede jugar igual).',
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
