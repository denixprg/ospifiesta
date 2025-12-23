import 'dart:math';

import 'package:flutter/material.dart';

import '../data/challenges.dart';
import '../services/challenge_settings_service.dart';
import '../services/player_service.dart';
import '../widgets/card_challenge.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key});

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  final ChallengeSettingsService _settings = ChallengeSettingsService();
  final PlayerService _playerService = PlayerService();
  final Random _random = Random();

  Challenge? _currentChallenge;
  List<Challenge> _pool = [];
  String? _currentPlayerName;

  @override
  void initState() {
    super.initState();
    _resetPoolAndPick();
  }

  void _resetPoolAndPick() {
    final List<Challenge> source;
    if (_settings.mixAll) {
      source = List<Challenge>.from(challenges);
    } else {
      source = challenges
          .where((c) => _settings.enabledCategories.contains(c.category))
          .toList();
    }
    if (source.isEmpty) {
      setState(() {
        _pool = [];
        _currentChallenge = null;
        _currentPlayerName = null;
      });
      return;
    }
    source.shuffle(_random);
    _pool = source;
    _pickNext();
  }

  void _pickNext() {
    if (_pool.isEmpty) {
      _resetPoolAndPick();
      return;
    }
    final challenge = _pool.removeAt(0);
    final player = _playerService.nextPlayer();
    setState(() {
      _currentChallenge = challenge;
      _currentPlayerName = player?.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reto actual'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: _currentChallenge == null
                      ? const Text(
                          'No hay retos disponibles.',
                          style: TextStyle(color: Colors.white),
                        )
                      : ChallengeCard(challenge: _currentChallenge!),
                ),
              ),
              if (_currentPlayerName != null) ...[
                const SizedBox(height: 6),
                Text(
                  'Turno de $_currentPlayerName',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
              const SizedBox(height: 16),
              PrimaryButton(
                text: 'Otro reto',
                icon: Icons.casino,
                onPressed: _pickNext,
              ),
              const SizedBox(height: 8),
              FiestaBackButton(label: 'Volver al inicio'),
            ],
          ),
        ),
      ),
    );
  }
}
