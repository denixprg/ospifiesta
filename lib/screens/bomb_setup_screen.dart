import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/bomb_settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class BombSetupScreen extends StatefulWidget {
  const BombSetupScreen({super.key});

  @override
  State<BombSetupScreen> createState() => _BombSetupScreenState();
}

class _BombSetupScreenState extends State<BombSetupScreen> {
  final BombSettingsService _settings = BombSettingsService();
  late BombVariant _selected;

  @override
  void initState() {
    super.initState();
    _selected = _settings.variant;
  }

  void _start() {
    _settings.setVariant(_selected);
    Navigator.pushNamed(context, AppRoutes.bomb);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('🧨 Bomba de tiempo'),
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
                  'Elige variante',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 12),
                _buildOption(
                  title: 'Explosión normal',
                  description: 'Pantalla roja y boom.',
                  variant: BombVariant.normal,
                ),
                const SizedBox(height: 10),
                _buildOption(
                  title: 'Explosión falsa',
                  description: 'Falsa alarma en medio, luego sigue.',
                  variant: BombVariant.fake,
                ),
                const SizedBox(height: 10),
                _buildOption(
                  title: 'Explosión silenciosa',
                  description: 'Solo mensaje final, sin animación.',
                  variant: BombVariant.silent,
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

  Widget _buildOption({
    required String title,
    required String description,
    required BombVariant variant,
  }) {
    final bool selected = _selected == variant;
    return InkWell(
      onTap: () => setState(() => _selected = variant),
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
            Radio<BombVariant>(
              value: variant,
              groupValue: _selected,
              activeColor: AppTheme.primary,
              onChanged: (_) => setState(() => _selected = variant),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
