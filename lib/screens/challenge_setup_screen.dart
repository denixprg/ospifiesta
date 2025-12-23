import 'package:flutter/material.dart';

import '../data/challenges.dart';
import '../routes/app_routes.dart';
import '../services/challenge_settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class ChallengeSetupScreen extends StatefulWidget {
  const ChallengeSetupScreen({super.key});

  @override
  State<ChallengeSetupScreen> createState() => _ChallengeSetupScreenState();
}

class _ChallengeSetupScreenState extends State<ChallengeSetupScreen> {
  final ChallengeSettingsService _settings = ChallengeSettingsService();

  late Set<ChallengeCategory> _selectedCategories;
  late bool _mixAll;

  @override
  void initState() {
    super.initState();
    _selectedCategories = _settings.enabledCategories;
    _mixAll = _settings.mixAll;
  }

  void _toggleCategory(ChallengeCategory category) {
    if (_mixAll) return;
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
    });
  }

  void _toggleMixAll(bool value) {
    setState(() {
      _mixAll = value;
    });
  }

  void _start() {
    if (!_mixAll && _selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos una categoría')),
      );
      return;
    }

    _settings.setMixAll(_mixAll);
    if (_mixAll) {
      _settings.setCategories({
        ChallengeCategory.suave,
        ChallengeCategory.picante,
        ChallengeCategory.extremo,
      });
    } else {
      _settings.setCategories(_selectedCategories);
    }

    Navigator.pushNamed(context, AppRoutes.play);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Retos'),
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
              Color(0xFF0F233F),
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
                  'Elige intensidad',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Selecciona categorías o mezcla todo al azar.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                _buildCategoryChips(),
                const SizedBox(height: 16),
                _buildMixSwitch(),
                const Spacer(),
                PrimaryButton(
                  text: 'Empezar',
                  icon: Icons.play_arrow_rounded,
                  onPressed: _start,
                ),
                const SizedBox(height: 10),
                FiestaBackButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _CategoryChip(
              label: 'Suave 😇',
              color: AppTheme.accent,
              selected: _selectedCategories.contains(ChallengeCategory.suave),
              onTap: () => _toggleCategory(ChallengeCategory.suave),
              disabled: _mixAll,
            ),
            _CategoryChip(
              label: 'Picante 😈',
              color: AppTheme.primary,
              selected: _selectedCategories.contains(ChallengeCategory.picante),
              onTap: () => _toggleCategory(ChallengeCategory.picante),
              disabled: _mixAll,
            ),
            _CategoryChip(
              label: 'Extremo 💀',
              color: Colors.redAccent,
              selected: _selectedCategories.contains(ChallengeCategory.extremo),
              onTap: () => _toggleCategory(ChallengeCategory.extremo),
              disabled: _mixAll,
            ),
          ],
        ),
        if (_mixAll)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Mezclar todo activado: se ignorarán las categorías.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
      ],
    );
  }

  Widget _buildMixSwitch() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mezclar todo (aleatorio)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  'Ignora selección y usa todas las categorías.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          Switch(
            value: _mixAll,
            onChanged: _toggleMixAll,
            activeColor: AppTheme.accent,
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final bool disabled;

  const _CategoryChip({
    required this.label,
    required this.color,
    required this.selected,
    required this.onTap,
    required this.disabled,
  });

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: disabled ? null : (_) => onTap(),
      selectedColor: color.withOpacity(0.25),
      backgroundColor: Colors.white.withOpacity(0.08),
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.white70,
        fontWeight: FontWeight.w700,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? color : Colors.white.withOpacity(0.2),
        ),
      ),
    );
  }
}
