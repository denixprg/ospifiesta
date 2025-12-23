import 'dart:math';

import 'package:flutter/material.dart';

import '../data/arbitrary_rules.dart';
import '../models/player.dart';
import '../routes/app_routes.dart';
import '../services/night_dna_service.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class MultasScreen extends StatefulWidget {
  const MultasScreen({super.key});

  @override
  State<MultasScreen> createState() => _MultasScreenState();
}

class _MultasScreenState extends State<MultasScreen> {
  final PlayerService _playerService = PlayerService();
  final Random _random = Random();

  List<String> _activeRules = [];
  List<String> _remainingRules = [];
  int _round = 0;
  final Map<int, int> _finesByPlayerId = {};

  @override
  void initState() {
    super.initState();
    _resetPool();
  }

  bool get _hasEnoughPlayers => _playerService.players.length >= 2;

  void _resetPool() {
    _remainingRules = List<String>.from(arbitraryRules)..shuffle(_random);
    _activeRules = [];
    _round = 0;
    _finesByPlayerId.clear();
    setState(() {});
  }

  void _addRule() {
    if (_remainingRules.isEmpty) {
      _remainingRules = List<String>.from(arbitraryRules)..shuffle(_random);
    }
    final rule = _remainingRules.removeAt(0);
    setState(() {
      _activeRules.add(rule);
      _round++;
    });
  }

  void _applyFine(Player player) {
    setState(() {
      _finesByPlayerId[player.id] = (_finesByPlayerId[player.id] ?? 0) + 1;
    });
    final dna = NightDnaService();
    dna.addDrink(player.id);
    dna.addLoss(player.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Multa para ${player.name} → bebe 🍺')),
      );
  }

  void _openFineDialog() {
    final players = _playerService.players;
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '¿Quién incumplió?',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                ...players.map(
                  (p) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _applyFine(p);
                      },
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
            ),
          ),
        );
      },
    );
  }

  void _goToPlayerSetup() {
    Navigator.pushNamed(context, AppRoutes.playerSetup);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('🧾 Multas arbitrarias'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Reglas activas (se acumulan)',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          'Ronda: $_round',
          textAlign: TextAlign.center,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 14),
        Expanded(
          child: _activeRules.isEmpty
              ? Center(
                  child: Text(
                    'Sin reglas aún. Añade una.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                )
              : ListView.separated(
                  itemCount: _activeRules.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final rule = _activeRules[index];
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Text(
                        '• $rule',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    );
                  },
                ),
        ),
        const SizedBox(height: 12),
        if (_finesByPlayerId.isNotEmpty) _buildFinesSummary(),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _addRule,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: AppTheme.accent,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            '➕ Añadir regla',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _playerService.players.isEmpty ? null : _openFineDialog,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            '🚨 Multa',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: _resetPool,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Colors.white.withOpacity(0.12),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          child: const Text(
            'Reset',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        const SizedBox(height: 12),
        const FiestaBackButton(),
      ],
    );
  }

  Widget _buildFinesSummary() {
    final players = _playerService.players;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Multas acumuladas:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        ..._finesByPlayerId.entries.map((entry) {
          final player =
              players.firstWhere((p) => p.id == entry.key, orElse: () => Player(id: entry.key, name: 'Jugador ${entry.key}'));
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '${player.name}: ${entry.value}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
            ),
          );
        }),
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
            Text(
              'Configura jugadores para jugar.',
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
