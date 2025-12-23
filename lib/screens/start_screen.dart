import 'package:flutter/material.dart';

import '../routes/app_routes.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final SettingsService _settings = SettingsService();
  late bool _randomModeEnabled;

  @override
  void initState() {
    super.initState();
    _randomModeEnabled = _settings.randomModeEnabled;
  }

  void _openContactPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contacto en construccion')),
    );
  }

  void _toggleRandomMode(bool value) {
    setState(() {
      _randomModeEnabled = value;
      _settings.randomModeEnabled = value;
    });
  }

  void _openSettings() {
    Navigator.pushNamed(context, AppRoutes.settings);
  }

  void _goToModes() {
    Navigator.pushNamed(context, AppRoutes.home);
  }

  Widget _buildQuickOptions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 18,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.auto_awesome_rounded, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Opciones rapidas',
                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    Text(
                      'Ajusta antes de jugar',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.white70,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SwitchListTile(
            value: _randomModeEnabled,
            onChanged: _toggleRandomMode,
            activeColor: AppTheme.accent,
            activeTrackColor: AppTheme.accent.withOpacity(0.35),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            title: Text(
              'Modo Random',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            subtitle: Text(
              'Cada cierto tiempo durante la partida se activaran eventos sorpresa.',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Colors.white70,
                  ),
            ),
          ),
          Divider(color: Colors.white.withOpacity(0.12), height: 1),
          ListTile(
            onTap: _openSettings,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.settings_rounded, color: Colors.white),
            ),
            title: Text(
              'Opciones / Ajustes',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            subtitle: Text(
              'Fondos, sonido y mas proximamente.',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Colors.white70,
                  ),
            ),
            trailing: Icon(Icons.arrow_forward_ios_rounded, color: Colors.white.withOpacity(0.9), size: 18),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF050016),
              Color(0xFF2D0A4D),
              Color(0xFF550B78),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _openContactPlaceholder,
                      icon: const Icon(Icons.mail_outline_rounded, color: Colors.white),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'OSPIFIESTA',
                          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                color: AppTheme.accent,
                                fontSize: 36,
                                shadows: [
                                  Shadow(
                                    color: AppTheme.primary.withOpacity(0.7),
                                    blurRadius: 18,
                                  ),
                                ],
                              ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _openSettings,
                      icon: const Icon(Icons.settings_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Configura tu fiesta y dale a jugar',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: _buildQuickOptions(),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: PrimaryButton(
                  text: 'Jugar',
                  icon: Icons.play_arrow_rounded,
                  onPressed: _goToModes,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
