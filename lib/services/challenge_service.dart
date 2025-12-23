import 'dart:math';

import '../data/challenges_seed.dart';
import '../models/challenge.dart';

class ChallengeService {
  final Random _random = Random();

  Challenge getRandomChallenge() {
    if (challengesSeed.isEmpty) {
      return Challenge(
        id: 0,
        text: 'No hay retos disponibles. Añade algunos retos en challenges_seed.dart',
        category: 'info',
      );
    }

    final index = _random.nextInt(challengesSeed.length);
    return challengesSeed[index];
  }
}
