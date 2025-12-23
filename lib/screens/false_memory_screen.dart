import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/false_memories.dart';
import '../models/player.dart';
import '../routes/app_routes.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

enum FalseMemoryPhase { reading, convincing, voting }

class FalseMemoryScreen extends StatefulWidget {
  const FalseMemoryScreen({super.key});

  @override
  State<FalseMemoryScreen> createState() => _FalseMemoryScreenState();
}

class _FalseMemoryScreenState extends State<FalseMemoryScreen> {
  final PlayerService _playerService = PlayerService();
  final Random _random = Random();

  List<String> _remainingMemories = [];
  String _currentMemory = '';
  Player? _currentPlayer;
  FalseMemoryPhase _phase = FalseMemoryPhase.reading;
  Timer? _timer;
  int _timeLeft = 15;

  @override
  void initState() {
    super.initState();
    _resetMemories();
    _takeNextMemory();
    _currentPlayer = _playerService.nextPlayer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  bool get _hasEnoughPlayers => _playerService.players.length >= 2;

  void _resetMemories() {
    _remainingMemories = List<String>.from(falseMemories)..shuffle(_random);
  }

  void _takeNextMemory() {
    if (_remainingMemories.isEmpty) {
      _resetMemories();
    }
    _currentMemory = _remainingMemories.removeAt(0);
  }

  void _startConvincing() {
    _timer?.cancel();
    setState(() {
      _phase = FalseMemoryPhase.convincing;
      _timeLeft = 15;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 1) {
        timer.cancel();
        setState(() {
          _timeLeft = 0;
          _phase = FalseMemoryPhase.voting;
        });
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  void _finishConvincing() {
    _timer?.cancel();
    setState(() {
      _phase = FalseMemoryPhase.voting;
      _timeLeft = 0;
    });
  }

  void _nextRound() {
    _timer?.cancel();
    final next = _playerService.nextPlayer();
    setState(() {
      _currentPlayer = next;
      _phase = FalseMemoryPhase.reading;
      _timeLeft = 15;
    });
    _takeNextMemory();
  }

  void _openBelieveDialog() {
    final players = _playerService.players
        .where((p) => p.id != _currentPlayer?.id)
        .toList();
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

  void _onNotBelieved() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Bebe: ${_currentPlayer?.name ?? 'Jugador'} 🍺')),
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
        title: const Text('🧠 Recuerdo falso'),
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
                    _currentMemory,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                  ),
                  const SizedBox(height: 18),
                  if (_phase == FalseMemoryPhase.convincing)
                    Text(
                      '$_timeLeft s',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: AppTheme.accent,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                    )
                  else if (_phase == FalseMemoryPhase.reading)
                    Text(
                      'Prepárate para convencerlos',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white70,
                          ),
                    )
                  else
                    Text(
                      'Votación',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.accent,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_phase == FalseMemoryPhase.reading)
          PrimaryButton(
            text: 'Estoy listo/a',
            icon: Icons.play_arrow_rounded,
            onPressed: _startConvincing,
          )
        else if (_phase == FalseMemoryPhase.convincing)
          PrimaryButton(
            text: 'Terminé',
            icon: Icons.flag_rounded,
            onPressed: _finishConvincing,
          )
        else ...[
          ElevatedButton(
            onPressed: _openBelieveDialog,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: AppTheme.accent,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              '✅ Me lo creo → beben otros',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: _onNotBelieved,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              '❌ No cuela → bebe ${_currentPlayer?.name ?? ''}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: 'Siguiente',
            icon: Icons.arrow_forward_rounded,
            onPressed: _nextRound,
          ),
        ],
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
