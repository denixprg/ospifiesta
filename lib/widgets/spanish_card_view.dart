import 'package:flutter/material.dart';

import '../models/spanish_card.dart';
import '../theme/app_theme.dart';

class SpanishCardView extends StatelessWidget {
  final SpanishCard card;
  final bool highlighted;
  final bool flipped;

  const SpanishCardView({
    super.key,
    required this.card,
    this.highlighted = false,
    this.flipped = false,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: highlighted
              ? [AppTheme.accent, AppTheme.primary]
              : [const Color(0xFF1F2933), const Color(0xFF111827)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accent.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.15),
          width: 1.2,
        ),
      ),
      child: AspectRatio(
        aspectRatio: 0.68,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.rankLabel,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  card.suitShortLabel,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.white70,
                      ),
                ),
              ],
            ),
            Center(
              child: Text(
                card.suitEmoji,
                style: const TextStyle(fontSize: 42),
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    card.rankLabel,
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    card.suitShortLabel,
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Colors.white70,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    if (flipped) {
      return RotatedBox(
        quarterTurns: 2,
        child: content,
      );
    }

    return content;
  }
}
