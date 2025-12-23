import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/bomb_settings_service.dart';
import '../services/night_dna_service.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class BombScreen extends StatefulWidget {
  const BombScreen({super.key});

  @override
  State<BombScreen> createState() => _BombScreenState();
}

class _BombScreenState extends State<BombScreen>
    with SingleTickerProviderStateMixin {
  final PlayerService _playerService = PlayerService();
  final BombSettingsService _bombSettings = BombSettingsService();
  final Random _random = Random();

  Timer? _explosionTimer;
  Timer? _fakeTimer;
  bool _exploded = false;
  bool _fakeFlash = false;
  String _currentPlayer = 'Jugador';
  int _currentPlayerId = -1;

  @override
  void initState() {
    super.initState();
    final player = _playerService.nextPlayer();
    _currentPlayer = player?.name ?? 'Jugador';
    _currentPlayerId = player?.id ?? -1;
    _startTimers();
  }

  void _startTimers() {
    final int seconds = 30 + _random.nextInt(151); // 30..180
    _explosionTimer = Timer(Duration(seconds: seconds), _explode);

    if (_bombSettings.variant == BombVariant.fake && seconds > 15) {
      final int fakeSeconds = 8 + _random.nextInt(seconds - 10);
      _fakeTimer = Timer(Duration(seconds: fakeSeconds), _triggerFakeFlash);
    }
  }

  void _triggerFakeFlash() {
    setState(() => _fakeFlash = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) {
        setState(() => _fakeFlash = false);
      }
    });
  }

  void _explode() {
    if (!mounted) return;
    setState(() {
      _exploded = true;
      _fakeFlash = false;
    });
    if (_currentPlayerId != -1) {
      final dna = NightDnaService();
      dna.addDrink(_currentPlayerId, amount: 2);
      dna.addLoss(_currentPlayerId);
    }
  }

  void _passBomb() {
    final next = _playerService.nextPlayer();
    setState(() {
      _currentPlayer = next?.name ?? 'Jugador';
      _currentPlayerId = next?.id ?? -1;
    });
  }

  void _finish() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  void dispose() {
    _explosionTimer?.cancel();
    _fakeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showRed =
        _exploded || (_fakeFlash && _bombSettings.variant == BombVariant.fake);
    final bool silent = _bombSettings.variant == BombVariant.silent;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('🧨 Bomba de tiempo'),
        backgroundColor: Colors.transparent,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: showRed
                ? [Colors.red.shade800, Colors.red.shade400]
                : const [
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
            child: _exploded ? _buildExplosion(silent) : _buildActive(),
          ),
        ),
      ),
    );
  }

  Widget _buildActive() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Center(
          child: Column(
            children: [
              Text(
                '🧨 BOMBA ACTIVA',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Pásala rápido',
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(color: Colors.white70),
              ),
            ],
          ),
        ),
        const Spacer(),
        ElevatedButton(
          onPressed: _passBomb,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 20),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 10,
          ),
          child: const Text(
            'PASAR LA BOMBA',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Jugador actual: $_currentPlayer',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
        ),
        const Spacer(),
        const FiestaBackButton(),
      ],
    );
  }

  Widget _buildExplosion(bool silent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Center(
          child: Column(
            children: [
              Text(
                silent ? 'Fin de la ronda' : '💥 BOOM',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Bebe: $_currentPlayer',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const Spacer(),
        PrimaryButton(
          text: 'Volver al menú',
          icon: Icons.home_rounded,
          onPressed: _finish,
        ),
      ],
    );
  }
}
