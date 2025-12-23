import 'package:flutter/material.dart';

import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final SettingsService _settings = SettingsService();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Personaliza tu fiesta',
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _buildFutureSettingTile(
            context,
            icon: Icons.wallpaper_rounded,
            title: 'Fondos personalizados (proximamente)',
            subtitle: 'Sube imagenes o elige gradientes para ambientar el juego.',
            color: colorScheme.primary,
          ),
          _buildFutureSettingTile(
            context,
            icon: Icons.music_note_rounded,
            title: 'Sonido y musica (proximamente)',
            subtitle: 'Controla volumen, efectos y playlists para tus partidas.',
            color: colorScheme.secondary,
          ),
          _buildStatusTile(
            context,
            title: 'Modo Random',
            subtitle: 'Estado actual para la partida.',
            enabled: _settings.randomModeEnabled,
            color: colorScheme.tertiary,
          ),
        ],
      ),
    );
  }

  Widget _buildFutureSettingTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'Proximamente',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool enabled,
    required Color color,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.12),
          child: Icon(Icons.shuffle_rounded, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Chip(
          label: Text(enabled ? 'Activado' : 'Desactivado'),
          backgroundColor: enabled
              ? color.withOpacity(0.14)
              : colorScheme.surfaceVariant.withOpacity(0.8),
          labelStyle: TextStyle(
            color: enabled ? color : colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
