import 'package:flutter/material.dart';

import '../models/mole_args.dart';
import '../routes/app_routes.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class MoleRevealScreen extends StatefulWidget {
  final MoleArgs args;
  const MoleRevealScreen({super.key, required this.args});

  @override
  State<MoleRevealScreen> createState() => _MoleRevealScreenState();
}

class _MoleRevealScreenState extends State<MoleRevealScreen> {
  final PlayerService _playerService = PlayerService();
  int _currentIndex = 0;

  bool get _allSeen => _currentIndex >= _playerService.players.length;

  void _showRole() async {
    final players = _playerService.players;
    if (_currentIndex >= players.length) return;
    final player = players[_currentIndex];
    final isMole = player.id == widget.args.molePlayerId;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: const Color(0xFF0E0A1F),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isMole ? 'ERES EL TOPO 🕵️' : 'Eres INOCENTE 😇',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  isMole
                      ? 'Sabotea sin que te descubran.'
                      : 'Ayuda al grupo a cazar al topo.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white70),
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

    setState(() {
      _currentIndex++;
    });
  }

  void _startGame() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.moleGame,
      arguments: widget.args,
    );
  }

  @override
  Widget build(BuildContext context) {
    final players = _playerService.players;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Pasa el móvil a cada jugador para ver su rol',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  _allSeen
                      ? 'Todos han visto su rol.'
                      : 'Turno de: ${players[_currentIndex].name}',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                if (!_allSeen)
                  PrimaryButton(
                    text: 'Ver rol',
                    icon: Icons.remove_red_eye_rounded,
                    onPressed: _showRole,
                  ),
                if (_allSeen) ...[
                  PrimaryButton(
                    text: 'Empezar partida',
                    icon: Icons.play_arrow_rounded,
                    onPressed: _startGame,
                  ),
                  const SizedBox(height: 12),
                ],
                const Spacer(),
                const FiestaBackButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
