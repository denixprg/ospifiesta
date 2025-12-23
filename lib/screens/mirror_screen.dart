import 'package:flutter/material.dart';

import '../models/player.dart';
import '../routes/app_routes.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

enum MirrorPhase { makeGesture, copyGesture, result }

class MirrorScreen extends StatefulWidget {
  const MirrorScreen({super.key});

  @override
  State<MirrorScreen> createState() => _MirrorScreenState();
}

class _MirrorScreenState extends State<MirrorScreen> {
  final PlayerService _playerService = PlayerService();

  MirrorPhase _phase = MirrorPhase.makeGesture;
  Player? _gestureOwner;
  Player? _copier;
  String? _resultText;

  @override
  void initState() {
    super.initState();
    _gestureOwner = _playerService.nextPlayer();
  }

  bool get _hasEnoughPlayers => _playerService.players.length >= 2;

  void _toCopyPhase() {
    final next = _playerService.nextPlayer();
    setState(() {
      _copier = next;
      _phase = MirrorPhase.copyGesture;
      _resultText = null;
    });
  }

  void _onCopiedWell() {
    setState(() {
      _gestureOwner = _copier;
      _copier = _playerService.nextPlayer();
      _phase = MirrorPhase.makeGesture;
      _resultText = null;
    });
  }

  void _onFailed() {
    setState(() {
      _phase = MirrorPhase.result;
      _resultText = '${_copier?.name ?? 'Jugador'} bebe 🍺';
    });
  }

  void _continueAfterResult() {
    setState(() {
      _gestureOwner = _playerService.nextPlayer();
      _copier = null;
      _phase = MirrorPhase.makeGesture;
      _resultText = null;
    });
  }

  void _goToPlayerSetup() {
    Navigator.pushNamed(context, AppRoutes.playerSetup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('🪞 El Espejo'),
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
            child: _hasEnoughPlayers ? _buildGame() : _buildNoPlayers(),
          ),
        ),
      ),
    );
  }

  Widget _buildGame() {
    String titleText;
    String subtitle;

    switch (_phase) {
      case MirrorPhase.makeGesture:
        titleText = 'Jugador actual: ${_gestureOwner?.name ?? 'Jugador'}';
        subtitle = 'Haz un gesto ridículo 😈';
        break;
      case MirrorPhase.copyGesture:
        titleText = 'Ahora copia el gesto de ${_gestureOwner?.name ?? '...'}';
        subtitle = 'Copia el gesto de ${_gestureOwner?.name ?? '...'}';
        break;
      case MirrorPhase.result:
        titleText = _resultText ?? 'Resultado';
        subtitle = 'Fin de la ronda';
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        Text(
          titleText,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
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
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildControls(),
        const SizedBox(height: 12),
        const FiestaBackButton(),
      ],
    );
  }

  Widget _buildControls() {
    switch (_phase) {
      case MirrorPhase.makeGesture:
        return PrimaryButton(
          text: 'Hecho → pasar',
          icon: Icons.arrow_forward_rounded,
          onPressed: _toCopyPhase,
        );
      case MirrorPhase.copyGesture:
        return Column(
          children: [
            ElevatedButton(
              onPressed: _onCopiedWell,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                '✅ Lo copió bien',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _onFailed,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              child: const Text(
                '❌ Falló → bebe 🍺',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      case MirrorPhase.result:
        return PrimaryButton(
          text: 'Continuar',
          icon: Icons.refresh_rounded,
          onPressed: _continueAfterResult,
        );
    }
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
            Text(
              'Configura jugadores para empezar.',
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
