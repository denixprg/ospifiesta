import 'dart:async';

import 'package:flutter/material.dart';

import '../models/secret_roles_args.dart';
import '../models/secret_role_state.dart';
import '../routes/app_routes.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class SecretRolesGameScreen extends StatefulWidget {
  final SecretRolesArgs args;
  const SecretRolesGameScreen({super.key, required this.args});

  @override
  State<SecretRolesGameScreen> createState() => _SecretRolesGameScreenState();
}

class AccusationRecord {
  final String accuser;
  final String accused;
  final String guessedRole;
  final bool success;

  AccusationRecord({
    required this.accuser,
    required this.accused,
    required this.guessedRole,
    required this.success,
  });
}

class _SecretRolesGameScreenState extends State<SecretRolesGameScreen> {
  final PlayerService _playerService = PlayerService();
  Timer? _timer;
  int _secondsLeft = 0;
  final List<AccusationRecord> _history = [];

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.args.minutes * 60;
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 1) {
        timer.cancel();
        setState(() {
          _secondsLeft = 0;
        });
        _goToEnd();
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  void _goToEnd() {
    _timer?.cancel();
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.secretRolesEnd,
      arguments: widget.args,
    );
  }

  void _openAccusation() {
    final players = _playerService.players;
    final roles = widget.args.states.map((s) => s.role).toSet().toList();
    int? accuserId;
    int? accusedId;
    String? guessedRole;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF0F0A22),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Acusación',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Selecciona acusador, acusado y rol',
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0x22000000),
                      border: OutlineInputBorder(),
                      labelText: 'Acusador',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    dropdownColor: const Color(0xFF0F0A22),
                    value: accuserId,
                    items: players
                        .map(
                          (p) => DropdownMenuItem<int>(
                            value: p.id,
                            child: Text(p.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setSheetState(() => accuserId = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0x22000000),
                      border: OutlineInputBorder(),
                      labelText: 'Acusado',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    dropdownColor: const Color(0xFF0F0A22),
                    value: accusedId,
                    items: players
                        .map(
                          (p) => DropdownMenuItem<int>(
                            value: p.id,
                            child: Text(p.name),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setSheetState(() => accusedId = v),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Color(0x22000000),
                      border: OutlineInputBorder(),
                      labelText: 'Rol sospechado',
                      labelStyle: TextStyle(color: Colors.white70),
                    ),
                    dropdownColor: const Color(0xFF0F0A22),
                    value: guessedRole,
                    items: roles
                        .map(
                          (r) => DropdownMenuItem<String>(
                            value: r,
                            child: Text(r),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setSheetState(() => guessedRole = v),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    text: 'Confirmar',
                    icon: Icons.check_rounded,
                    onPressed: () {
                      if (accuserId == null ||
                          accusedId == null ||
                          guessedRole == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Completa acusador, acusado y rol')),
                        );
                        return;
                      }
                      Navigator.pop(context);
                      _resolveAccusation(
                        accuserId!,
                        accusedId!,
                        guessedRole!,
                      );
                    },
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _resolveAccusation(int accuserId, int accusedId, String guessedRole) {
    final players = _playerService.players;
    final accuser =
        players.firstWhere((p) => p.id == accuserId, orElse: () => players.first);
    final accused =
        players.firstWhere((p) => p.id == accusedId, orElse: () => players.first);
    final state =
        widget.args.states.firstWhere((s) => s.playerId == accused.id);
    final success = state.role == guessedRole;

    setState(() {
      _history.insert(
        0,
        AccusationRecord(
          accuser: accuser.name,
          accused: accused.name,
          guessedRole: guessedRole,
          success: success,
        ),
      );
      if (_history.length > 5) {
        _history.removeLast();
      }
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '✅ Acertaste. Bebe ${accused.name} 🍺'
                : '❌ Fallaste. Bebe ${accuser.name} 🍺',
          ),
        ),
      );
  }

  String get _timeLabel {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
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
        title: const Text('🎭 Personaje secreto'),
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
          'Actúa tu rol',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tiempo restante: $_timeLabel',
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
                  '¿Quién actúa raro? ¡Acusa si lo ves!',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                PrimaryButton(
                  text: 'ACUSAR',
                  icon: Icons.report_rounded,
                  onPressed: _openAccusation,
                ),
                const SizedBox(height: 16),
                if (_history.isNotEmpty)
                  Text(
                    'Últimas acusaciones:',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                if (_history.isNotEmpty) ..._history.map(
                  (h) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: h.success
                                ? Colors.greenAccent.withOpacity(0.5)
                                : Colors.redAccent.withOpacity(0.5)),
                      ),
                      child: Text(
                        '${h.accuser} acusó a ${h.accused} de "${h.guessedRole}" — ${h.success ? '✅' : '❌'}',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white70),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        PrimaryButton(
          text: 'Finalizar y revelar',
          icon: Icons.flag_rounded,
          onPressed: _goToEnd,
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
