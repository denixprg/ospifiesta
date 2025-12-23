import 'package:flutter/material.dart';

import '../screens/home_screen.dart';
import '../screens/play_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/blackjack_screen.dart';
// Si todavía NO tienes estas pantallas, comenta o borra los imports de abajo:
// import '../screens/spanish_duel_screen.dart';
// import '../screens/touch_selector_screen.dart';

class AppRoutes {
  static const String home = '/';
  static const String play = '/play';
  static const String settings = '/settings';
  static const String blackjack = '/blackjack';
  // static const String spanishDuel = '/spanish-duel';
  // static const String touchSelector = '/touch-selector';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(builder: (context) => const HomeScreen());
      case AppRoutes.play:
        return MaterialPageRoute(builder: (context) => const PlayScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (context) => SettingsScreen());
      case AppRoutes.blackjack:
        return MaterialPageRoute(builder: (context) => const BlackjackScreen());
      // Si más adelante añades estas pantallas, descomenta estos casos:
      /*
      case AppRoutes.spanishDuel:
        return MaterialPageRoute(
          builder: (context) => const SpanishDuelScreen(),
        );
      case AppRoutes.touchSelector:
        return MaterialPageRoute(
          builder: (context) => const TouchSelectorScreen(),
        );
      */
      default:
        return MaterialPageRoute(builder: (context) => const HomeScreen());
    }
  }
}
