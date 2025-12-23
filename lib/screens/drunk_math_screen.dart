import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/night_dna_service.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class DrunkMathScreen extends StatefulWidget {
  const DrunkMathScreen({super.key});

  @override
  State<DrunkMathScreen> createState() => _DrunkMathScreenState();
}

class _DrunkMathScreenState extends State<DrunkMathScreen> {
  final PlayerService _playerService = PlayerService();
  final Random _random = Random();
  final TextEditingController _answerController = TextEditingController();

  Timer? _timer;
  int _timeLeft = 7;
  String _questionText = '';
  int _correctAnswer = 0;
  String? _resultText;
  String _currentPlayer = 'Jugador';
  int _currentPlayerId = -1;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    if (_playerService.players.isNotEmpty) {
      final player = _playerService.nextPlayer();
      _currentPlayer = player?.name ?? 'Jugador';
      _currentPlayerId = player?.id ?? -1;
    }
    _generateQuestion();
    _startTimer();
  }

  bool get _hasPlayers => _playerService.players.isNotEmpty;

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 7;
      _resultText = null;
      _finished = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft <= 1) {
        setState(() {
          _timeLeft = 0;
          _finished = true;
          _resultText = '⏱️ Tiempo. Bebes 🍺';
        });
        _recordDrinkAndLoss();
        timer.cancel();
      } else {
        setState(() {
          _timeLeft--;
        });
      }
    });
  }

  void _generateQuestion() {
    final int type = _random.nextInt(3); // 0 suma, 1 resta, 2 multi
    switch (type) {
      case 0:
        final a = 1 + _random.nextInt(20);
        final b = 1 + _random.nextInt(20);
        _questionText = '$a + $b';
        _correctAnswer = a + b;
        break;
      case 1:
        final a = 5 + _random.nextInt(26); // 5..30
        final b = 1 + _random.nextInt(min(20, a));
        _questionText = '$a - $b';
        _correctAnswer = a - b;
        break;
      case 2:
      default:
        final a = 2 + _random.nextInt(8); // 2..9
        final b = 2 + _random.nextInt(8);
        _questionText = '$a × $b';
        _correctAnswer = a * b;
        break;
    }
  }

  void _checkAnswer() {
    if (_finished) return;
    _timer?.cancel();
    final text = _answerController.text.trim();
    final int? value = int.tryParse(text);

    String result;
    int punish = 0;
    if (value == null) {
      result = 'Incorrecto. Bebes 🍺';
      _recordDrinkAndLoss();
    } else if (value == _correctAnswer) {
      punish = 1 + _random.nextInt(2);
      result = 'Correcto. Reparte $punish 🍺';
      _recordWin(punish);
    } else {
      result = 'Incorrecto. Bebes 🍺';
      _recordDrinkAndLoss();
    }

    setState(() {
      _resultText = result;
      _finished = true;
    });
  }

  void _nextRound() {
    final next = _playerService.nextPlayer();
    setState(() {
      _currentPlayer = next?.name ?? 'Jugador';
      _currentPlayerId = next?.id ?? -1;
      _answerController.clear();
    });
    _generateQuestion();
    _startTimer();
  }

  void _goToPlayerSetup() {
    Navigator.pushNamed(context, AppRoutes.playerSetup);
  }

  void _recordDrinkAndLoss({int drinks = 1}) {
    if (_currentPlayerId == -1) return;
    final dna = NightDnaService();
    dna.addDrink(_currentPlayerId, amount: drinks);
    dna.addLoss(_currentPlayerId);
  }

  void _recordWin(int punishments) {
    if (_currentPlayerId == -1) return;
    final dna = NightDnaService();
    dna.addWin(_currentPlayerId);
    if (punishments > 0) {
      dna.addPunishmentGiven(_currentPlayerId, amount: punishments);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('🧮 Matemáticas borrachas'),
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
            child: _hasPlayers ? _buildGame() : _buildNoPlayers(),
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
          'Jugador: $_currentPlayer',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
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
                    _questionText,
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$_timeLeft',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.accent,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 18),
                  TextField(
                    controller: _answerController,
                    enabled: !_finished,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 24),
                    decoration: InputDecoration(
                      hintText: 'Tu respuesta',
                      hintStyle:
                          TextStyle(color: Colors.white.withOpacity(0.6)),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: _finished ? null : _checkAnswer,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Comprobar',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (_resultText != null)
                    Text(
                      _resultText!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
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
              'Configura jugadores para jugar',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Necesitas al menos 1 jugador.',
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
