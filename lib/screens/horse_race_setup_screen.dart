import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class HorseRaceSetupScreen extends StatefulWidget {
  const HorseRaceSetupScreen({super.key});

  @override
  State<HorseRaceSetupScreen> createState() => _HorseRaceSetupScreenState();
}

class _HorseRaceSetupScreenState extends State<HorseRaceSetupScreen> {
  bool _horsesEqualPlayers = true;
  int _horseCount = 4;
  double _finishLine = 20;

  void _start() {
    Navigator.pushNamed(
      context,
      AppRoutes.horseRace,
      arguments: HorseRaceArgs(
        horseCount: _horsesEqualPlayers ? null : _horseCount,
        finishLine: _finishLine.toInt(),
        horsesEqualPlayers: _horsesEqualPlayers,
      ),
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
                  'Configura la carrera',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Azar puro. El último bebe.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  value: _horsesEqualPlayers,
                  onChanged: (v) => setState(() => _horsesEqualPlayers = v),
                  activeColor: AppTheme.accent,
                  title: Text(
                    'Caballos = jugadores',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  subtitle: Text(
                    'Uno por jugador (por defecto)',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white70),
                  ),
                ),
                if (!_horsesEqualPlayers) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Caballos: $_horseCount',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: _horseCount > 2
                                ? () => setState(() => _horseCount--)
                                : null,
                            icon: const Icon(Icons.remove_circle_outline_rounded),
                            color: Colors.white,
                          ),
                          IconButton(
                            onPressed: _horseCount < 8
                                ? () => setState(() => _horseCount++)
                                : null,
                            icon: const Icon(Icons.add_circle_outline_rounded),
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  'Meta: ${_finishLine.toInt()}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Slider(
                  value: _finishLine,
                  min: 10,
                  max: 30,
                  divisions: 20,
                  activeColor: AppTheme.primary,
                  inactiveColor: Colors.white24,
                  label: '${_finishLine.toInt()}',
                  onChanged: (v) => setState(() => _finishLine = v),
                ),
                const Spacer(),
                PrimaryButton(
                  text: 'Empezar',
                  icon: Icons.play_arrow_rounded,
                  onPressed: _start,
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

class HorseRaceArgs {
  final int? horseCount;
  final int finishLine;
  final bool horsesEqualPlayers;

  HorseRaceArgs({
    required this.horseCount,
    required this.finishLine,
    required this.horsesEqualPlayers,
  });
}
