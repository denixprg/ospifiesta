import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'screens/blackjack_screen.dart';
import 'screens/home_screen.dart';
import 'screens/play_screen.dart';
import 'screens/challenge_setup_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/spanish_duel_screen.dart';
import 'screens/start_screen.dart';
import 'screens/touch_selector_screen.dart';
import 'screens/duel_screen.dart';
import 'screens/juez_screen.dart';
import 'screens/yo_nunca_screen.dart';
import 'screens/yo_nunca_setup_screen.dart';
import 'screens/bomb_setup_screen.dart';
import 'screens/bomb_screen.dart';
import 'screens/thought_you_wouldnt_say_screen.dart';
import 'screens/mirror_screen.dart';
import 'screens/player_setup_screen.dart';
import 'screens/drunk_math_screen.dart';
import 'screens/sacrificado_setup_screen.dart';
import 'screens/sacrificado_screen.dart';
import 'theme/app_theme.dart';
import 'screens/multas_screen.dart';
import 'screens/horse_race_setup_screen.dart';
import 'screens/horse_race_screen.dart';
import 'screens/favorite_setup_screen.dart';
import 'screens/favorite_screen.dart';
import 'screens/open_mic_screen.dart';
import 'screens/false_memory_screen.dart';
import 'screens/mole_setup_screen.dart';
import 'screens/mole_reveal_screen.dart';
import 'screens/mole_game_screen.dart';
import 'screens/mole_vote_screen.dart';
import 'models/mole_args.dart';
import 'screens/vampire_setup_screen.dart';
import 'screens/vampire_reveal_screen.dart';
import 'screens/vampire_game_screen.dart';
import 'screens/vampire_end_screen.dart';
import 'models/vampire_args.dart';
import 'screens/secret_roles_setup_screen.dart';
import 'screens/secret_roles_reveal_screen.dart';
import 'screens/secret_roles_game_screen.dart';
import 'screens/secret_roles_end_screen.dart';
import 'models/secret_roles_args.dart';
import 'screens/night_dna_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OSPIFIESTA',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.start,
      routes: {
        AppRoutes.start: (context) => const StartScreen(),
        AppRoutes.home: (context) => const HomeScreen(),
        AppRoutes.play: (context) => const PlayScreen(),
        AppRoutes.challengeSetup: (context) => const ChallengeSetupScreen(),
        AppRoutes.settings: (context) => SettingsScreen(),
        AppRoutes.blackjack: (context) => const BlackjackScreen(),
        AppRoutes.spanishDuel: (context) => const SpanishDuelScreen(),
        AppRoutes.touchSelector: (context) => const TouchSelectorScreen(),
        AppRoutes.yoNunca: (context) => const YoNuncaScreen(),
        AppRoutes.yoNuncaSetup: (context) => const YoNuncaSetupScreen(),
        AppRoutes.duel: (context) => const DuelScreen(),
        AppRoutes.juez: (context) => const JuezScreen(),
        AppRoutes.bombSetup: (context) => const BombSetupScreen(),
        AppRoutes.bomb: (context) => const BombScreen(),
        AppRoutes.thoughtYouWouldntSay: (context) =>
            const ThoughtYouWouldntSayScreen(),
        AppRoutes.mirror: (context) => const MirrorScreen(),
        AppRoutes.playerSetup: (context) => const PlayerSetupScreen(),
        AppRoutes.drunkMath: (context) => const DrunkMathScreen(),
        AppRoutes.sacrificadoSetup: (context) => const SacrificadoSetupScreen(),
        AppRoutes.sacrificado: (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as SacrificadoMode?;
          return SacrificadoScreen(mode: args ?? SacrificadoMode.aleatorio);
        },
        AppRoutes.multas: (context) => const MultasScreen(),
        AppRoutes.horseRaceSetup: (context) => const HorseRaceSetupScreen(),
        AppRoutes.horseRace: (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as HorseRaceArgs?;
          if (args == null) {
            return const HorseRaceSetupScreen();
          }
          return HorseRaceScreen(args: args);
        },
        AppRoutes.favoriteSetup: (context) => const FavoriteSetupScreen(),
        AppRoutes.favorite: (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as FavoriteArgs?;
          if (args == null) return const FavoriteSetupScreen();
          return FavoriteScreen(args: args);
        },
        AppRoutes.openMic: (context) => const OpenMicScreen(),
        AppRoutes.falseMemory: (context) => const FalseMemoryScreen(),
        AppRoutes.moleSetup: (context) => const MoleSetupScreen(),
        AppRoutes.moleReveal: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as MoleArgs?;
          if (args == null) return const MoleSetupScreen();
          return MoleRevealScreen(args: args);
        },
        AppRoutes.moleGame: (context) {
          final args = ModalRoute.of(context)?.settings.arguments as MoleArgs?;
          if (args == null) return const MoleSetupScreen();
          return MoleGameScreen(args: args);
        },
        AppRoutes.moleVote: (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as MoleVoteArgs?;
          if (args == null) return const MoleSetupScreen();
          return MoleVoteScreen(args: args);
        },
        AppRoutes.vampireSetup: (context) => const VampireSetupScreen(),
        AppRoutes.vampireReveal: (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as VampireArgs?;
          if (args == null) return const VampireSetupScreen();
          return VampireRevealScreen(args: args);
        },
        AppRoutes.vampireGame: (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as VampireArgs?;
          if (args == null) return const VampireSetupScreen();
          return VampireGameScreen(args: args);
        },
        AppRoutes.vampireEnd: (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as VampireArgs?;
          if (args == null) return const VampireSetupScreen();
          return VampireEndScreen(args: args);
        },
        AppRoutes.secretRolesSetup: (context) =>
            const SecretRolesSetupScreen(),
        AppRoutes.secretRolesReveal: (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as SecretRolesArgs?;
          if (args == null) return const SecretRolesSetupScreen();
          return SecretRolesRevealScreen(args: args);
        },
        AppRoutes.secretRolesGame: (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as SecretRolesArgs?;
          if (args == null) return const SecretRolesSetupScreen();
          return SecretRolesGameScreen(args: args);
        },
        AppRoutes.secretRolesEnd: (context) {
          final args =
              ModalRoute.of(context)?.settings.arguments as SecretRolesArgs?;
          if (args == null) return const SecretRolesSetupScreen();
          return SecretRolesEndScreen(args: args);
        },
        AppRoutes.nightDna: (context) => const NightDnaScreen(),
      },
    );
  }
}
