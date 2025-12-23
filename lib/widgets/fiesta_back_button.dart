import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class FiestaBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;

  const FiestaBackButton({
    super.key,
    this.onPressed,
    this.label = 'Atrás',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed ?? () => Navigator.of(context).pop(),
        icon: const Icon(Icons.arrow_back_rounded, size: 22),
        label: Text(label.toUpperCase()),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(26),
          ),
          elevation: 8,
          shadowColor: AppTheme.accent.withOpacity(0.45),
          textStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
