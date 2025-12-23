import 'package:flutter/material.dart';

import '../models/secret_roles_args.dart';
import '../routes/app_routes.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class SecretRolesEndScreen extends StatelessWidget {
  final SecretRolesArgs args;
  const SecretRolesEndScreen({super.key, required this.args});

  void _bestActor(BuildContext context) {
    final players = PlayerService().players;
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
                  '¿Quién fue el mejor actor?',
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
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(content: Text('Reparte 2: ${p.name} 🍺')),
                          );
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

  void _goHome(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  void _playAgain(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.secretRolesSetup,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final players = PlayerService().players;
    final Map<int, String> rolesByPlayer =
        {for (final s in args.states) s.playerId: s.role};

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'FIN 🎭',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final p = players[index];
                      final role = rolesByPlayer[p.id] ?? '—';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Text(
                          '${p.name} — $role',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  text: 'Mejor actor reparte 2 🍺',
                  icon: Icons.emoji_events_rounded,
                  onPressed: () => _bestActor(context),
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  text: 'Volver al menú',
                  icon: Icons.home_rounded,
                  onPressed: () => _goHome(context),
                ),
                const SizedBox(height: 10),
                PrimaryButton(
                  text: 'Jugar otra vez',
                  icon: Icons.replay_rounded,
                  onPressed: () => _playAgain(context),
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
