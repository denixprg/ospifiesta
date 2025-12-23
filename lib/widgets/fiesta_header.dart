import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import 'fiesta_back_button.dart';

class FiestaHeader extends StatelessWidget {
  final String title;
  final Widget? rightAction;
  final bool showBack;

  const FiestaHeader({
    super.key,
    required this.title,
    this.rightAction,
    this.showBack = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (showBack)
            IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
              tooltip: 'Atrás',
            )
          else
            const SizedBox(width: 48),
          Expanded(
            child: Center(
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          SizedBox(
            width: 48,
            child: rightAction,
          ),
        ],
      ),
    );
  }
}
