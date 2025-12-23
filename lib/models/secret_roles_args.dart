import 'secret_role_state.dart';

class SecretRolesArgs {
  final List<SecretRoleState> states;
  final int minutes;

  const SecretRolesArgs({
    required this.states,
    required this.minutes,
  });
}
