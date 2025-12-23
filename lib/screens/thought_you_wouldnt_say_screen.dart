import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../data/thought_you_wouldnt_say.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class ThoughtYouWouldntSayScreen extends StatefulWidget {
  const ThoughtYouWouldntSayScreen({super.key});

  @override
  State<ThoughtYouWouldntSayScreen> createState() =>
      _ThoughtYouWouldntSayScreenState();
}

class _ThoughtYouWouldntSayScreenState
    extends State<ThoughtYouWouldntSayScreen> {
  final PlayerService _playerService = PlayerService();
  final Random _random = Random();
  List<String> _remainingPhrases = [];
  String _currentPhrase = '';
  String _currentPlayer = 'Jugador';

  Timer? _countdownTimer;
  int _counter = 5;
  bool _timeUp = false;

  @override
  void initState() {
    super.initState();
    _resetPhrases();
    _takeNextPhrase();
    _currentPlayer = _playerService.nextPlayer()?.name ?? 'Jugador';
    _startCountdown();
  }

  void _resetPhrases() {
    _remainingPhrases = List<String>.from(thoughtYouWouldntSayPhrases)
      ..shuffle(_random);
  }

  void _takeNextPhrase() {
    if (_remainingPhrases.isEmpty) {
      _resetPhrases();
    }
    _currentPhrase = _remainingPhrases.removeAt(0);
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() {
      _counter = 5;
      _timeUp = false;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter <= 1) {
        setState(() {
          _counter = 0;
          _timeUp = true;
        });
        timer.cancel();
      } else {
        setState(() {
          _counter--;
        });
      }
    });
  }

  void _nextPlayerAndPhrase() {
    final next = _playerService.nextPlayer();
    setState(() {
      _currentPlayer = next?.name ?? 'Jugador';
      _takeNextPhrase();
    });
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('🧠 Pensé que no ibas a decir eso'),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                        borderRadius: BorderRadius.circular(30),
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
                            _currentPhrase,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  height: 1.3,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Jugador: $_currentPlayer',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(
                                  color: Colors.white70,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            _timeUp ? '⏱️ Tiempo' : '$_counter',
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  color: AppTheme.accent,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_timeUp) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.white.withOpacity(0.1),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('😐 Fue flojo → bebe'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: AppTheme.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('😈 Muy heavy → otros beben'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                PrimaryButton(
                  text: 'Siguiente jugador',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: _nextPlayerAndPhrase,
                ),
                const SizedBox(height: 10),
                const FiestaBackButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
