import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/vampire_args.dart';
import '../models/vampire_role.dart';
import '../routes/app_routes.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class VampireGameScreen extends StatefulWidget {
  final VampireArgs args;
  const VampireGameScreen({super.key, required this.args});

  @override
  State<VampireGameScreen> createState() => _VampireGameScreenState();
}

class _VampireGameScreenState extends State<VampireGameScreen> {
  final PlayerService _playerService = PlayerService();
  late List<VampirePlayerState> _states;
  int _currentRound = 1;
  Player? _currentHolder;

  @override
  void initState() {
    super.initState();
    _states = widget.args.states
        .map((s) => VampirePlayerState(playerId: s.playerId, role: s.role))
        .toList();
    _currentHolder = _playerService.nextPlayer();
  }

  int get _humans =>
      _states.where((s) => s.role == VampireRole.human).length;
  int get _vampires =>
      _states.where((s) => s.role == VampireRole.vampire).length;

  void _openInfectionPhase() {
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
            child: _buildInfectionContent(),
          ),
        );
      },
    );
  }

  Widget _buildInfectionContent() {
    final current = _currentHolder;
    final state = current == null
        ? null
        : _states.firstWhere((s) => s.playerId == current.id);
    final isVampire = state?.role == VampireRole.vampire;

    if (!isVampire) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Solo los vampiros pueden infectar 😈',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: 'Cerrar',
            icon: Icons.close_rounded,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    }

    final humans = _states
        .where((s) => s.role == VampireRole.human)
        .map((s) => _playerService.players
            .firstWhere((p) => p.id == s.playerId))
        .toList();

    if (humans.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'No quedan humanos por infectar.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            text: 'Cerrar',
            icon: Icons.close_rounded,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Solo los vampiros miran ahora',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 12),
        Text(
          'Elige a quién infectar:',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 12),
        ...humans.map(
          (p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ElevatedButton(
              onPressed: () => _infect(p.id),
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
    );
  }

  void _infect(int playerId) {
    final state = _states.firstWhere((s) => s.playerId == playerId);
    if (state.role == VampireRole.vampire) return;
    setState(() {
      state.role = VampireRole.vampire;
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('Infectado ✅')),
      );
  }

  void _nextRound() {
    if (_currentRound >= widget.args.totalRounds || _humans == 0) {
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.vampireEnd,
        arguments:
            VampireArgs(states: _states, totalRounds: widget.args.totalRounds),
      );
      return;
    }
    setState(() {
      _currentRound++;
      _currentHolder = _playerService.nextPlayer();
    });
  }

  void _goToPlayerSetup() {
    Navigator.pushNamed(context, AppRoutes.playerSetup);
  }

  @override
  Widget build(BuildContext context) {
    final hasPlayers = _playerService.players.length >= 2;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('🧛 Vampiro'),
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
            child: hasPlayers ? _buildGame() : _buildNoPlayers(),
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
          'Ronda $_currentRound / ${widget.args.totalRounds}',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Humanos: $_humans   Vampiros: $_vampires',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
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
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Noche cae sobre la fiesta...',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Los vampiros se mueven en secreto. Prepárate para la infección.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white70),
                ),
                const Spacer(),
                PrimaryButton(
                  text: 'Fase de infección (solo vampiros)',
                  icon: Icons.bloodtype_rounded,
                  onPressed: _openInfectionPhase,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          text: (_currentRound >= widget.args.totalRounds || _humans == 0)
              ? 'Ir al final'
              : 'Siguiente ronda',
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
              'Necesitas al menos 2 jugadores',
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
              onPressed: _goToPlayerSetup,
            ),
            const SizedBox(height: 12),
            const FiestaBackButton(),
          ],
        ),
      ),
    );
  }
}
