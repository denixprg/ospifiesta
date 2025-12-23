import 'dart:math';

import 'package:flutter/material.dart';

import '../data/yo_nunca_data.dart';
import '../services/yo_nunca_settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';
import '../widgets/primary_button.dart';

class YoNuncaScreen extends StatefulWidget {
  const YoNuncaScreen({super.key});

  @override
  State<YoNuncaScreen> createState() => _YoNuncaScreenState();
}

class _YoNuncaScreenState extends State<YoNuncaScreen> {
  final YoNuncaSettingsService _settings = YoNuncaSettingsService();
  final Random _random = Random();

  List<YoNuncaItem> _pool = [];
  YoNuncaItem? _currentItem;

  @override
  void initState() {
    super.initState();
    _resetPoolAndPick();
  }

  void _resetPoolAndPick() {
    final List<YoNuncaItem> source;
    if (_settings.mixAll) {
      source = List<YoNuncaItem>.from(yoNuncaItems);
    } else {
      source = yoNuncaItems
          .where((item) => _settings.enabledCategories.contains(item.category))
          .toList();
    }

    if (source.isEmpty) {
      setState(() {
        _pool = [];
        _currentItem = null;
      });
      return;
    }

    source.shuffle(_random);
    _pool = source;
    _pickNext();
  }

  void _pickNext() {
    if (_pool.isEmpty) {
      _resetPoolAndPick();
      return;
    }
    setState(() {
      _currentItem = _pool.removeAt(0);
    });
  }

  String _categoryLabel(YoNuncaCategory category) {
    switch (category) {
      case YoNuncaCategory.suave:
        return 'Suave 😇';
      case YoNuncaCategory.picante:
        return 'Picante 😈';
      case YoNuncaCategory.extremo:
        return 'Extremo 💀';
    }
  }

  Color _categoryColor(YoNuncaCategory category) {
    switch (category) {
      case YoNuncaCategory.suave:
        return AppTheme.accent;
      case YoNuncaCategory.picante:
        return AppTheme.primary;
      case YoNuncaCategory.extremo:
        return Colors.redAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final YoNuncaItem? item = _currentItem;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Yo nunca'),
        centerTitle: true,
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
                const SizedBox(height: 12),
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.08),
                            Colors.white.withOpacity(0.03),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withOpacity(0.08)),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.35),
                            blurRadius: 24,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: item == null
                          ? Text(
                              'No hay preguntas disponibles con esta selección.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Align(
                                  alignment: Alignment.center,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _categoryColor(item.category).withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: _categoryColor(item.category).withOpacity(0.4),
                                      ),
                                    ),
                                    child: Text(
                                      _categoryLabel(item.category),
                                      style: TextStyle(
                                        color: _categoryColor(item.category),
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  item.text,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.w700,
                                        height: 1.3,
                                      ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Los que sí lo hayan hecho beben 🍻',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Colors.white70,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PrimaryButton(
                text: 'Siguiente',
                icon: Icons.arrow_forward_rounded,
                onPressed: item == null ? _resetPoolAndPick : _pickNext,
              ),
              const SizedBox(height: 10),
              const FiestaBackButton(),
            ],
          ),
        ),
      ),
    );
  }
}
