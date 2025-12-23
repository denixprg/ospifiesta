import 'package:flutter/material.dart';

import '../models/vampire_args.dart';
import '../models/vampire_role.dart';
import '../routes/app_routes.dart';
import '../services/player_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class VampireEndScreen extends StatelessWidget {
  final VampireArgs args;
  const VampireEndScreen({super.key, required this.args});

  int get _humans =>
      args.states.where((s) => s.role == VampireRole.human).length;
  int get _vampires =>
      args.states.where((s) => s.role == VampireRole.vampire).length;

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
      AppRoutes.vampireSetup,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final vampiresDrink = _humans > 0;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'FIN',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Humanos restantes: $_humans',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white70),
                ),
                Text(
                  'Vampiros: $_vampires',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    vampiresDrink
                        ? 'Quedan humanos. Vampiros beben 3 🍺'
                        : 'Todos infectados. Humanos beben 3 🍺',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.accent,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                const Spacer(),
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
