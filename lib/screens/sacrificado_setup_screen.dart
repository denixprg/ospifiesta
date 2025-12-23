import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';
import 'sacrificado_screen.dart';

class SacrificadoSetupScreen extends StatefulWidget {
  const SacrificadoSetupScreen({super.key});

  @override
  State<SacrificadoSetupScreen> createState() => _SacrificadoSetupScreenState();
}

class _SacrificadoSetupScreenState extends State<SacrificadoSetupScreen> {
  SacrificadoMode _mode = SacrificadoMode.voluntario;

  void _start() {
    Navigator.pushNamed(
      context,
      AppRoutes.sacrificado,
      arguments: _mode,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('🪦 El Sacrificado'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0A0318),
              Color(0xFF210721),
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
                  'Uno se la juega por todos',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Elige cómo se selecciona el sacrificado.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                _buildOption(
                  title: 'Voluntario (pasa el móvil)',
                  mode: SacrificadoMode.voluntario,
                ),
                const SizedBox(height: 10),
                _buildOption(
                  title: 'Aleatorio (la app elige)',
                  mode: SacrificadoMode.aleatorio,
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

  Widget _buildOption({required String title, required SacrificadoMode mode}) {
    final bool selected = _mode == mode;
    return InkWell(
      onTap: () => setState(() => _mode = mode),
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.primary : Colors.white.withOpacity(0.12),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<SacrificadoMode>(
              value: mode,
              groupValue: _mode,
              activeColor: AppTheme.primary,
              onChanged: (_) => setState(() => _mode = mode),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
