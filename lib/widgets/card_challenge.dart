import 'package:flutter/material.dart';
import '../data/challenges.dart';
import '../theme/app_theme.dart';

class ChallengeCard extends StatelessWidget {
  final Challenge challenge;

  const ChallengeCard({
    super.key,
    required this.challenge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [
              Color(0xFF3A0D73),
              Color(0xFF6D0D88),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withOpacity(0.5),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _categoryLabel(challenge.category),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _categoryColor(challenge.category),
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              challenge.text,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.suave:
        return 'Suave 😇';
      case ChallengeCategory.picante:
        return 'Picante 😈';
      case ChallengeCategory.extremo:
        return 'Extremo 💀';
    }
  }

  Color _categoryColor(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.suave:
        return AppTheme.accent;
      case ChallengeCategory.picante:
        return AppTheme.primary;
      case ChallengeCategory.extremo:
        return Colors.redAccent;
    }
  }
}
