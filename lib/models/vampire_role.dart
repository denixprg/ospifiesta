enum VampireRole { human, vampire }

class VampirePlayerState {
  final int playerId;
  VampireRole role;

  VampirePlayerState({required this.playerId, required this.role});
}
