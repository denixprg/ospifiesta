import 'dart:math';

import 'package:flutter/material.dart';

import '../data/mole_actions.dart';
import '../data/mole_missions.dart';
import '../models/mole_args.dart';
import '../models/player.dart';
import '../routes/app_routes.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class MoleGameScreen extends StatefulWidget {
  final MoleArgs args;
  const MoleGameScreen({super.key, required this.args});

  @override
  State<MoleGameScreen> createState() => _MoleGameScreenState();
}

class _MoleGameScreenState extends State<MoleGameScreen> {
  final PlayerService _playerService = PlayerService();
  final Random _random = Random();

  late List<String> _remainingActions;
  late List<String> _remainingMissions;
  String _currentAction = '';
  String _currentMission = '';
  int _currentRound = 1;

  Player? get _molePlayer => _playerService.players
      .firstWhere((p) => p.id == widget.args.molePlayerId, orElse: () => const Player(id: -1, name: ''));

  @override
  void initState() {
    super.initState();
    _resetPools();
    _drawAction();
    _drawMission();
  }

  void _resetPools() {
    _remainingActions = List<String>.from(moleGroupActions)..shuffle(_random);
    _remainingMissions =
        List<String>.from(moleSecretMissions)..shuffle(_random);
  }

  void _drawAction() {
    if (_remainingActions.isEmpty) {
      _remainingActions = List<String>.from(moleGroupActions)..shuffle(_random);
    }
    _currentAction = _remainingActions.removeAt(0);
  }

  void _drawMission() {
    if (_remainingMissions.isEmpty) {
      _remainingMissions =
          List<String>.from(moleSecretMissions)..shuffle(_random);
    }
    _currentMission = _remainingMissions.removeAt(0);
  }

  void _onViewMission() {
    final players = _playerService.players;
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0F0A22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '¿Eres el topo?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Selecciona tu nombre para ver la misión (solo el topo puede verla).',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 12),
                ...players.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (p.id == widget.args.molePlayerId) {
                          _showMissionDialog();
                        } else {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              const SnackBar(
                                  content: Text('No tienes misión 😈')),
                            );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        p.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showMissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0E0A1F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Misión secreta',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  _currentMission,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white70, height: 1.3),
                ),
                const SizedBox(height: 18),
                PrimaryButton(
                  text: 'Ocultar',
                  icon: Icons.visibility_off_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _nextRound() {
    if (_currentRound >= widget.args.totalRounds) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.moleVote,
        arguments: MoleVoteArgs(molePlayerId: widget.args.molePlayerId),
      );
      return;
    }
    setState(() {
      _currentRound++;
    });
    _drawAction();
    _drawMission();
  }

  void _goToPlayerSetup() {
    Navigator.pushNamed(context, AppRoutes.playerSetup);
  }

  @override
  Widget build(BuildContext context) {
    final hasPlayers = _playerService.players.length >= 2;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('🕵️ El Topo'),
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
            child: hasPlayers ? _buildGame() : _buildNoPlayers(),
          ),
        ),
      ),
    );
  }

  Widget _buildGame() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Ronda $_currentRound / ${widget.args.totalRounds}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Acción del grupo',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: Center(
                    child: Text(
                      _currentAction,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                          ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'Ver misión secreta',
                  icon: Icons.visibility_rounded,
                  onPressed: _onViewMission,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          text: _currentRound >= widget.args.totalRounds
              ? 'Ir a votación'
              : 'Siguiente ronda',
          icon: Icons.arrow_forward_rounded,
          onPressed: _nextRound,
        ),
        const SizedBox(height: 10),
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
              'Necesitas al menos 2 jugadores',
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
