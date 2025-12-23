import 'package:flutter/material.dart';

import '../data/yo_nunca_data.dart';
import '../routes/app_routes.dart';
import '../services/yo_nunca_settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class YoNuncaSetupScreen extends StatefulWidget {
  const YoNuncaSetupScreen({super.key});

  @override
  State<YoNuncaSetupScreen> createState() => _YoNuncaSetupScreenState();
}

class _YoNuncaSetupScreenState extends State<YoNuncaSetupScreen> {
  final YoNuncaSettingsService _settings = YoNuncaSettingsService();

  late Set<YoNuncaCategory> _selectedCategories;
  late bool _mixAll;

  @override
  void initState() {
    super.initState();
    _selectedCategories = _settings.enabledCategories;
    _mixAll = _settings.mixAll;
  }

  void _toggleCategory(YoNuncaCategory category) {
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
        YoNuncaCategory.suave,
        YoNuncaCategory.picante,
        YoNuncaCategory.extremo,
      });
    } else {
      _settings.setCategories(_selectedCategories);
    }

    Navigator.pushNamed(context, AppRoutes.yoNunca);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Yo Nunca'),
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
              Color(0xFF3A0A2E),
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
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _CategoryChip(
          label: 'Suave 😇',
          color: AppTheme.accent,
          selected: _selectedCategories.contains(YoNuncaCategory.suave),
          onTap: () => _toggleCategory(YoNuncaCategory.suave),
          disabled: _mixAll,
        ),
        _CategoryChip(
          label: 'Picante 😈',
          color: AppTheme.primary,
          selected: _selectedCategories.contains(YoNuncaCategory.picante),
          onTap: () => _toggleCategory(YoNuncaCategory.picante),
          disabled: _mixAll,
        ),
        _CategoryChip(
          label: 'Extremo 💀',
          color: Colors.redAccent,
          selected: _selectedCategories.contains(YoNuncaCategory.extremo),
          onTap: () => _toggleCategory(YoNuncaCategory.extremo),
          disabled: _mixAll,
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
