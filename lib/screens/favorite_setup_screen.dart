import 'dart:math';

import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';
import 'favorite_screen.dart';

class FavoriteSetupScreen extends StatefulWidget {
  const FavoriteSetupScreen({super.key});

  @override
  State<FavoriteSetupScreen> createState() => _FavoriteSetupScreenState();
}

class _FavoriteSetupScreenState extends State<FavoriteSetupScreen> {
  final PlayerService _playerService = PlayerService();
  final Random _random = Random();

  int _durationMinutes = 5;
  bool _byRounds = false;
  int _rounds = 8;

  void _start() {
    final players = _playerService.players;
    if (players.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configura jugadores antes de empezar')),
      );
      return;
    }
    final favorite = players[_random.nextInt(players.length)];
    Navigator.pushNamed(
      context,
      AppRoutes.favorite,
      arguments: FavoriteArgs(
        favoritePlayerId: favorite.id,
        mode: _byRounds ? FavoriteMode.rounds : FavoriteMode.time,
        durationMinutes: _durationMinutes,
        rounds: _rounds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Duración del favorito',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                if (_playerService.players.length < 3)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Recomendado mínimo 3 jugadores',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.orangeAccent,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Expanded(
                      child: _ModeTile(
                        title: 'Por tiempo',
                        selected: !_byRounds,
                        onTap: () => setState(() => _byRounds = false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ModeTile(
                        title: 'Por rondas',
                        selected: _byRounds,
                        onTap: () => setState(() => _byRounds = true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (!_byRounds) ...[
                  Text(
                    'Minutos: $_durationMinutes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Slider(
                    value: _durationMinutes.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: AppTheme.primary,
                    inactiveColor: Colors.white24,
                    label: '$_durationMinutes',
                    onChanged: (v) =>
                        setState(() => _durationMinutes = v.toInt()),
                  ),
                ] else ...[
                  Text(
                    'Rondas: $_rounds',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  Slider(
                    value: _rounds.toDouble(),
                    min: 5,
                    max: 20,
                    divisions: 15,
                    activeColor: AppTheme.primary,
                    inactiveColor: Colors.white24,
                    label: '$_rounds',
                    onChanged: (v) => setState(() => _rounds = v.toInt()),
                  ),
                ],
                const Spacer(),
                PrimaryButton(
                  text: 'Empezar',
                  icon: Icons.play_arrow_rounded,
                  onPressed: _start,
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

class _ModeTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _ModeTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.primary : Colors.white.withOpacity(0.12),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Center(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
      ),
    );
  }
}
