import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/open_mic_prompts.dart';
import '../models/player.dart';
import '../routes/app_routes.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

enum OpenMicPhase { speaking, voting }

class OpenMicScreen extends StatefulWidget {
  const OpenMicScreen({super.key});

  @override
  State<OpenMicScreen> createState() => _OpenMicScreenState();
}

class _OpenMicScreenState extends State<OpenMicScreen> {
  final PlayerService _playerService = PlayerService();
  final Random _random = Random();

  List<String> _remainingPrompts = [];
  String _currentPrompt = '';
  Player? _currentPlayer;
  OpenMicPhase _phase = OpenMicPhase.speaking;
  Timer? _timer;
  int _timeLeft = 6;

  @override
  void initState() {
    super.initState();
    _resetPrompts();
    _takeNextPrompt();
    _currentPlayer = _playerService.nextPlayer();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _hasEnoughPlayers => _playerService.players.length >= 2;

  void _resetPrompts() {
    _remainingPrompts = List<String>.from(openMicPrompts)..shuffle(_random);
  }

  void _takeNextPrompt() {
    if (_remainingPrompts.isEmpty) {
      _resetPrompts();
    }
    _currentPrompt = _remainingPrompts.removeAt(0);
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 6;
      _phase = OpenMicPhase.speaking;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 1) {
        setState(() {
          _timeLeft = 0;
          _phase = OpenMicPhase.voting;
        });
        timer.cancel();
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  void _nextRound() {
    final next = _playerService.nextPlayer();
    setState(() {
      _currentPlayer = next;
    });
    _takeNextPrompt();
    _startTimer();
  }

  void _openCredibleDialog() {
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
                  '¿Quién bebe?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...players.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(content: Text('Bebe: ${p.name} 🍺')),
                          );
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

  void _onWeak() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Bebes: ${_currentPlayer?.name ?? 'Jugador'} 🍺')),
      );
  }

  void _goToPlayerSetup() {
    Navigator.pushNamed(context, AppRoutes.playerSetup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('🎤 Micrófono abierto'),
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
            child: _hasEnoughPlayers ? _buildGame() : _buildNoPlayers(),
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
          'Jugador: ${_currentPlayer?.name ?? 'Jugador'}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 12),
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _currentPrompt,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _phase == OpenMicPhase.speaking ? '$_timeLeft' : '⏱️ Tiempo',
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: AppTheme.accent,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_phase == OpenMicPhase.voting)
          Column(
            children: [
              ElevatedButton(
                onPressed: _openCredibleDialog,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  '✅ Fue creíble → bebe otro',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _onWeak,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  '❌ Fue flojo → bebes ${_currentPlayer?.name ?? ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        PrimaryButton(
          text: 'Siguiente',
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
            Text(
              'Configura jugadores para jugar.',
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
