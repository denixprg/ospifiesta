import 'package:flutter/material.dart';

import '../models/mole_args.dart';
import '../models/player.dart';
import '../routes/app_routes.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class MoleVoteScreen extends StatefulWidget {
  final MoleVoteArgs args;
  const MoleVoteScreen({super.key, required this.args});

  @override
  State<MoleVoteScreen> createState() => _MoleVoteScreenState();
}

class _MoleVoteScreenState extends State<MoleVoteScreen> {
  final PlayerService _playerService = PlayerService();
  String? _resultTitle;
  String? _resultDetail;
  String? _resultPunishment;

  Player? get _molePlayer => _playerService.players.firstWhere(
        (p) => p.id == widget.args.molePlayerId,
        orElse: () => const Player(id: -1, name: 'Topo'),
      );

  void _onVote(Player player) {
    final mole = _molePlayer;
    final isCorrect = player.id == widget.args.molePlayerId;
    setState(() {
      _resultTitle = isCorrect ? 'ACERTASTE ✅' : 'FALLASTE ❌';
      _resultDetail = 'El topo era: ${mole?.name ?? 'Topo'}';
      _resultPunishment =
          isCorrect ? '${mole?.name ?? 'Topo'} bebe 3 🍺' : 'El topo reparte 3 🍺';
    });
  }

  void _goHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  void _playAgain() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.moleSetup,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final players = _playerService.players;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Votación final'),
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
                  '¿Quién es el topo?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: players
                          .map(
                            (p) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ElevatedButton(
                                onPressed: () => _onVote(p),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
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
                          )
                          .toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                if (_resultTitle != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _resultTitle!,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _resultDetail ?? '',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _resultPunishment ?? '',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppTheme.accent,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                PrimaryButton(
                  text: 'Volver al menú',
                  icon: Icons.home_rounded,
                  onPressed: _goHome,
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  text: 'Jugar otra vez',
                  icon: Icons.replay_rounded,
                  onPressed: _playAgain,
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
