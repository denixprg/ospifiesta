import 'dart:math';

import 'package:flutter/material.dart';

import '../models/horse.dart';
import '../routes/app_routes.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';
import 'horse_race_setup_screen.dart';

class HorseRaceScreen extends StatefulWidget {
  const HorseRaceScreen({super.key, required this.args});

  final HorseRaceArgs args;

  @override
  State<HorseRaceScreen> createState() => _HorseRaceScreenState();
}

class _HorseRaceScreenState extends State<HorseRaceScreen> {
  final PlayerService _playerService = PlayerService();
  final Random _random = Random();

  late List<Horse> _horses;
  late int _finishLine;
  String? _lastMessage;
  bool _raceFinished = false;
  Horse? _winner;

  @override
  void initState() {
    super.initState();
    _finishLine = widget.args.finishLine;
    _initHorses();
  }

  void _initHorses() {
    final players = _playerService.players;
    final int horseCount =
        widget.args.horsesEqualPlayers ? players.length : (widget.args.horseCount ?? players.length);
    _horses = List.generate(horseCount, (index) {
      final playerName =
          widget.args.horsesEqualPlayers && index < players.length ? players[index].name : null;
      return Horse(
        id: index + 1,
        name: 'Caballo ${index + 1}',
        position: 0,
        playerName: playerName,
      );
    });
    _lastMessage = null;
    _raceFinished = false;
    _winner = null;
    setState(() {});
  }

  void _nextRound() {
    if (_raceFinished) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.horseRaceSetup,
        (route) => route.settings.name == AppRoutes.start,
      );
      return;
    }

    String? eventMessage;
    for (final horse in _horses) {
      int move = _random.nextInt(4); // 0..3 base
      final roll = _random.nextDouble();
      if (roll < 0.1) {
        final penalty = 1 + _random.nextInt(2);
        move = -penalty;
        eventMessage = '${horse.name} tropieza → -$penalty';
      } else if (roll < 0.2) {
        final bonus = 1 + _random.nextInt(2);
        move += bonus;
        eventMessage = '${horse.name} acelera → +$bonus';
      } else if (roll < 0.3) {
        move = 0;
        eventMessage = '${horse.name} se queda quieto';
      }
      horse.position = max(0, horse.position + move);
    }

    final topPosition = _horses.map((h) => h.position).reduce(max);
    final List<Horse> winners = _horses.where((h) => h.position >= _finishLine).toList();
    if (winners.isNotEmpty) {
      _winner = winners.first;
      _raceFinished = true;
      _lastMessage =
          'GANADOR: ${_winner!.name}${_winner!.playerName != null ? " (${_winner!.playerName})" : ""} → reparte 3 🍺';
      setState(() {});
      return;
    }

    final bottomPosition = _horses.map((h) => h.position).reduce(min);
    final lastHorses = _horses.where((h) => h.position == bottomPosition).toList();
    final Horse last = lastHorses[_random.nextInt(lastHorses.length)];

    final String lastMsg = last.playerName == null
        ? 'Último: ${last.name} → todos beben 1 🍺'
        : 'Último: ${last.name} (${last.playerName}) bebe 1 🍺';

    _lastMessage = eventMessage != null ? '$lastMsg\n$eventMessage' : lastMsg;
    setState(() {});
  }

  void _restart() {
    _initHorses();
  }

  void _goToSetup() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.horseRaceSetup,
      (route) => route.settings.name == AppRoutes.start,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('🐎 Carrera de caballos'),
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
                  'Meta: $_finishLine',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.separated(
                    itemCount: _horses.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final horse = _horses[index];
                      return _HorseRow(
                        horse: horse,
                        finishLine: _finishLine,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                if (_lastMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: Text(
                      _lastMessage!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                const SizedBox(height: 12),
                if (_raceFinished)
                  PrimaryButton(
                    text: 'Nueva carrera',
                    icon: Icons.refresh_rounded,
                    onPressed: _restart,
                  )
                else
                  PrimaryButton(
                    text: 'Siguiente ronda',
                    icon: Icons.play_arrow_rounded,
                    onPressed: _nextRound,
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

class _HorseRow extends StatelessWidget {
  final Horse horse;
  final int finishLine;

  const _HorseRow({
    required this.horse,
    required this.finishLine,
  });

  @override
  Widget build(BuildContext context) {
    final double progress =
        (horse.position / finishLine).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                horse.name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(width: 6),
              if (horse.playerName != null)
                Text(
                  '(Jugador: ${horse.playerName})',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: Colors.white.withOpacity(0.08),
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppTheme.primary),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Posición: ${horse.position}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.white70,
                ),
          ),
        ],
      ),
    );
  }
}
