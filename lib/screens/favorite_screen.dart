import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../models/player.dart';
import '../routes/app_routes.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

enum FavoriteMode { time, rounds }

class FavoriteArgs {
  final int favoritePlayerId;
  final FavoriteMode mode;
  final int durationMinutes;
  final int rounds;

  FavoriteArgs({
    required this.favoritePlayerId,
    required this.mode,
    required this.durationMinutes,
    required this.rounds,
  });
}

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key, required this.args});

  final FavoriteArgs args;

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final PlayerService _playerService = PlayerService();
  Timer? _timer;
  int _elapsedSeconds = 0;
  int _currentRound = 0;
  int _abusePoints = 0;
  bool _finished = false;
  Player? _currentPlayer;

  @override
  void initState() {
    super.initState();
    _currentPlayer = _playerService.nextPlayer();
    if (widget.args.mode == FavoriteMode.time) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  int get _favoriteId => widget.args.favoritePlayerId;

  Player? get _favoritePlayer =>
      _playerService.players.firstWhere((p) => p.id == _favoriteId,
          orElse: () => Player(id: _favoriteId, name: 'Jugador'));

  bool get _isCurrentFavorite => _currentPlayer?.id == _favoriteId;

  int get _secondsLimit => widget.args.durationMinutes * 60;

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_finished) {
        setState(() {
          _elapsedSeconds++;
        });
        if (_elapsedSeconds >= _secondsLimit) {
          _finishGame();
        }
      }
    });
  }

  void _passPhone() {
    if (_finished) return;
    final next = _playerService.nextPlayer();
    setState(() {
      _currentPlayer = next;
      if (widget.args.mode == FavoriteMode.rounds) {
        _currentRound++;
        if (_currentRound >= widget.args.rounds) {
          _finishGame();
        }
      }
    });
  }

  void _showFavoriteCheck() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final bool isFav = _isCurrentFavorite;
        return Dialog(
          backgroundColor: const Color(0xFF0F0A22),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: isFav ? _buildFavoriteActions() : _buildNotFavorite(),
          ),
        );
      },
    );
  }

  Widget _buildFavoriteActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ERES EL FAVORITO 👑',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 14),
        ElevatedButton(
          onPressed: () => _applyAbuse(1),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: AppTheme.accent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Reparte 1 🍺'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _applyAbuse(2),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Reparte 2 🍺'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () => _applyAbuse(1),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            backgroundColor: Colors.white.withOpacity(0.12),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text('Todos beben 1 🍻'),
        ),
      ],
    );
  }

  Widget _buildNotFavorite() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'No eres el favorito 😈',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Sigue jugando.',
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  void _applyAbuse(int points) {
    Navigator.of(context).pop();
    setState(() {
      _abusePoints += points;
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('Castigo aplicado')));
  }

  void _finishGame() {
    setState(() {
      _finished = true;
    });
    _timer?.cancel();
  }

  String get _penaltyText {
    if (_abusePoints <= 2) return 'El favorito bebe 1 🍺';
    if (_abusePoints <= 5) return 'El favorito bebe 2 🍺';
    return 'El favorito bebe 3 🍺';
  }

  void _playAgain() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.favoriteSetup,
      (route) => route.settings.name == AppRoutes.start,
    );
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool lowPlayers = _playerService.players.length < 3;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('👑 El Favorito'),
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
            child: _playerService.players.isEmpty
                ? _buildNoPlayers()
                : (_finished ? _buildReveal() : _buildGame(lowPlayers)),
          ),
        ),
      ),
    );
  }

  Widget _buildGame(bool lowPlayers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (lowPlayers)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(
              'Recomendado mínimo 3 jugadores',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
        Text(
          'Nadie sabe quién es…',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Jugador con el móvil: ${_currentPlayer?.name ?? 'Jugador'}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Acciones del favorito',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _showFavoriteCheck,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Ver si eres el favorito',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Nadie debe mirar salvo el jugador actual.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          text: 'PASAR EL MÓVIL',
          icon: Icons.arrow_forward_rounded,
          onPressed: _finished ? null : () => _passPhone(),
        ),
        const SizedBox(height: 10),
        const FiestaBackButton(),
      ],
    );
  }

  Widget _buildReveal() {
    final favName = _favoritePlayer?.name ?? 'Jugador';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Center(
          child: Column(
            children: [
              Text(
                '👑 El favorito era:',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white70,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                favName,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Abusó: $_abusePoints veces',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                _penaltyText,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const Spacer(),
        PrimaryButton(
          text: 'Volver al menú',
          icon: Icons.home_rounded,
          onPressed: _goHome,
        ),
        const SizedBox(height: 10),
        PrimaryButton(
          text: 'Jugar otra vez',
          icon: Icons.refresh_rounded,
          onPressed: _playAgain,
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
              'Necesitas jugadores para jugar',
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
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.playerSetup),
            ),
          ],
        ),
      ),
    );
  }
}
