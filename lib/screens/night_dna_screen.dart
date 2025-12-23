import 'package:flutter/material.dart';

import '../models/player.dart';
import '../services/night_dna_service.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class NightDnaScreen extends StatelessWidget {
  const NightDnaScreen({super.key});

  Player? _playerById(int id, List<Player> players) {
    return players.firstWhere((p) => p.id == id, orElse: () => Player(id: id, name: 'Jugador $id'));
  }

  @override
  Widget build(BuildContext context) {
    final dna = NightDnaService();
    final players = PlayerService().players;

    String nameOr(int id) {
      if (id == -1) return '—';
      return _playerById(id, players)?.name ?? 'Jugador';
    }

    final dominantName = nameOr(dna.getDominantPlayerId());
    final punishedName = nameOr(dna.getMostPunishedPlayerId());
    final savedName = nameOr(dna.getMostSavedPlayerId());
    final targetName = nameOr(dna.getBalancedTargetPlayerId());

    final ranks = dna.rankByDrinksDesc();

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('🧬 ADN de la noche'),
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
                _buildInsights(
                  context,
                  dominantName,
                  punishedName,
                  savedName,
                  targetName,
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ranks.isEmpty
                      ? Center(
                          child: Text(
                            'Aún no hay estadísticas de esta sesión.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge
                                ?.copyWith(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        )
                      : ListView.builder(
                          itemCount: ranks.length,
                          itemBuilder: (context, index) {
                            final playerId = ranks[index];
                            final player = _playerById(playerId, players);
                            return _buildPlayerCard(context, player, index);
                          },
                        ),
                ),
                const SizedBox(height: 12),
                PrimaryButton(
                  text: 'Reset stats de sesión',
                  icon: Icons.refresh_rounded,
                  onPressed: () {
                    dna.resetSession();
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        const SnackBar(
                            content: Text('Stats reiniciadas para la sesión')),
                      );
                    (context as Element).markNeedsBuild();
                  },
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

  Widget _buildInsights(
    BuildContext context,
    String dominant,
    String punished,
    String saved,
    String target,
  ) {
    final textStyle = Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        );
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Dominante: $dominant', style: textStyle),
          Text('Más castigado: $punished', style: textStyle),
          Text('Más salvado: $saved', style: textStyle),
          Text('Recomendación: ahora bebe $target', style: textStyle),
        ],
      ),
    );
  }

  Widget _buildPlayerCard(BuildContext context, Player? player, int index) {
    final dna = NightDnaService();
    final id = player?.id ?? -1;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${index + 1}. ${player?.name ?? 'Jugador'}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Drinks: ${dna.drinks(id)} | Dominance: ${dna.dominanceScore(id)}',
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
          ),
          Text(
            'Wins: ${dna.wins(id)}  | Losses: ${dna.losses(id)}  | Castigos dados: ${dna.punishmentsGiven(id)}',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
