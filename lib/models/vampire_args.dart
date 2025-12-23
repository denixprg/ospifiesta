import 'vampire_role.dart';

class VampireArgs {
  final List<VampirePlayerState> states;
  final int totalRounds;

  const VampireArgs({
    required this.states,
    required this.totalRounds,
  });
}
