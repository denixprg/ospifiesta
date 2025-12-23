class MoleArgs {
  final int molePlayerId;
  final int totalRounds;

  const MoleArgs({
    required this.molePlayerId,
    required this.totalRounds,
  });
}

class MoleVoteArgs {
  final int molePlayerId;

  const MoleVoteArgs({required this.molePlayerId});
}
