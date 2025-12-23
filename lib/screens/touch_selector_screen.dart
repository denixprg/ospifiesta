import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/fiesta_back_button.dart';

enum TouchSelectorState { waiting, selected }

class TouchSelectorScreen extends StatefulWidget {
  const TouchSelectorScreen({super.key});

  @override
  State<TouchSelectorScreen> createState() => _TouchSelectorScreenState();
}

class _TouchSelectorScreenState extends State<TouchSelectorScreen>
    with SingleTickerProviderStateMixin {
  final Map<int, Offset> _activePointers = {};
  final Random _random = Random();

  int? _selectedPointerId;
  TouchSelectorState _state = TouchSelectorState.waiting;
  Timer? _stabilityTimer;
  bool _flashActive = false;

  static const Duration _stabilityDuration = Duration(seconds: 5);

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stabilityTimer?.cancel();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent event) {
    if (_state == TouchSelectorState.selected) return;
    setState(() {
      _activePointers[event.pointer] = event.localPosition;
    });
    _restartStabilityTimer();
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_state == TouchSelectorState.selected) return;
    if (_activePointers.containsKey(event.pointer)) {
      setState(() {
        _activePointers[event.pointer] = event.localPosition;
      });
    }
  }

  void _onPointerUp(PointerUpEvent event) {
    if (_state == TouchSelectorState.selected) return;
    setState(() {
      _activePointers.remove(event.pointer);
    });
    _restartStabilityTimer();
  }

  void _onPointerCancel(PointerCancelEvent event) {
    if (_state == TouchSelectorState.selected) return;
    setState(() {
      _activePointers.remove(event.pointer);
    });
    _restartStabilityTimer();
  }

  void _restartStabilityTimer() {
    _stabilityTimer?.cancel();
    if (_activePointers.isEmpty) {
      _stabilityTimer = null;
      return;
    }
    // Si durante _stabilityDuration no cambia el numero de dedos, seleccionamos.
    _stabilityTimer = Timer(_stabilityDuration, _lockAndSelectPointer);
  }

  void _lockAndSelectPointer() {
    if (!mounted) return;
    if (_state == TouchSelectorState.selected) return;
    if (_activePointers.isEmpty) return;

    final keys = _activePointers.keys.toList();
    final selected = keys[_random.nextInt(keys.length)];

    setState(() {
      _selectedPointerId = selected;
      _state = TouchSelectorState.selected;
      _stabilityTimer = null;
    });

    _triggerFlash();
  }

  void _triggerFlash() {
    setState(() {
      _flashActive = true;
    });
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) {
        setState(() {
          _flashActive = false;
        });
      }
    });
  }

  void _resetGame() {
    _stabilityTimer?.cancel();
    setState(() {
      _activePointers.clear();
      _selectedPointerId = null;
      _state = TouchSelectorState.waiting;
      _flashActive = false;
      _stabilityTimer = null;
    });
  }

  String get _statusLabel {
    if (_state == TouchSelectorState.selected) {
      return 'El elegido!';
    }
    return _stabilityTimer == null ? 'Esperando dedos...' : 'Analizando...';
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final Map<int, Offset> pointersToShow;
    if (_state == TouchSelectorState.selected && _selectedPointerId != null) {
      final selectedPos = _activePointers[_selectedPointerId];
      if (selectedPos != null) {
        pointersToShow = {_selectedPointerId!: selectedPos};
      } else {
        pointersToShow = {};
      }
    } else {
      pointersToShow = Map<int, Offset>.from(_activePointers);
    }

    return Scaffold(
      body: Listener(
        onPointerDown: _onPointerDown,
        onPointerMove: _onPointerMove,
        onPointerUp: _onPointerUp,
        onPointerCancel: _onPointerCancel,
        behavior: HitTestBehavior.opaque,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _state == TouchSelectorState.selected ? _resetGame : null,
          child: Stack(
            children: [
              _AnimatedBackground(controller: _pulseController),
              if (_flashActive)
                AnimatedOpacity(
                  opacity: _flashActive ? 0.7 : 0.0,
                  duration: const Duration(milliseconds: 150),
                  child: Container(color: Colors.white.withOpacity(0.7)),
                ),
              Positioned.fill(
                child: Stack(
                  children: [
                    ...pointersToShow.entries.map(
                      (entry) => _PointerCircle(
                        position: entry.value,
                        size: size,
                        isSelected: entry.key == _selectedPointerId,
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FiestaBackButton(),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.12)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'El elegido',
                                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                        color: AppTheme.accent,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                if (_state == TouchSelectorState.selected)
                                  Text(
                                    'Toca para reiniciar',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(color: Colors.white70),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _statusLabel,
                              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                    color: Colors.white70,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PointerCircle extends StatelessWidget {
  final Offset position;
  final Size size;
  final bool isSelected;

  const _PointerCircle({
    required this.position,
    required this.size,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final double radius = isSelected ? 52 : 34;
    final Color color = isSelected ? AppTheme.accent : AppTheme.primary;
    final double border = isSelected ? 4 : 2;

    // Asegura que el circulo queda dentro del Stack visible.
    final double left = (position.dx - radius).clamp(0, size.width - radius * 2);
    final double top = (position.dy - radius).clamp(0, size.height - radius * 2);

    return Positioned(
      left: left,
      top: top,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        width: radius * 2,
        height: radius * 2,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(isSelected ? 0.35 : 0.2),
          border: Border.all(
            color: Colors.white.withOpacity(isSelected ? 0.9 : 0.5),
            width: border,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.6),
              blurRadius: isSelected ? 20 : 12,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedBackground extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedBackground({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double t = controller.value;
        final double pulse = 0.04 + 0.04 * sin(t * 2 * pi); // parpadeo suave
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [
                Color(0xFF050016),
                Color(0xFF2D0A4D),
                Color(0xFF0A1F3A),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            color: Colors.white.withOpacity(pulse),
          ),
        );
      },
    );
  }
}
