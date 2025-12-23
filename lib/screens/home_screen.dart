import 'package:flutter/material.dart';

import '../models/game_mode.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  int _currentPage = 0;

  final List<GameMode> _gameModes = const [
    GameMode(
      id: GameModeId.classic,
      title: 'Retos clasicos',
      description:
          'Elige un reto aleatorio y cumple o bebe. Perfecto para arrancar.',
      icon: Icons.local_fire_department_rounded,
      primaryColor: Color(0xFF6D0D88),
      accentColor: Color(0xFFFF2D92),
    ),
    GameMode(
      id: GameModeId.quick,
      title: 'Retos rapidos',
      description: 'Rondas express para no parar. Ritmo rapido y risas.',
      icon: Icons.flash_on_rounded,
      primaryColor: Color(0xFF004E92),
      accentColor: Color(0xFF00F5A0),
    ),
    GameMode(
      id: GameModeId.duel,
      title: 'Duelo ⚔️',
      description: 'Uno contra uno. El perdedor bebe.',
      icon: Icons.sports_mma_rounded,
      primaryColor: Color(0xFF2C0A3A),
      accentColor: Color(0xFFFF7A00),
    ),
    GameMode(
      id: GameModeId.yoNunca,
      title: 'Yo nunca',
      description: 'El clásico. Si lo has hecho, bebes. Sin mentir.',
      icon: Icons.local_bar_rounded,
      primaryColor: Color(0xFF7B0F67),
      accentColor: Color(0xFFFF3B6E),
    ),
    GameMode(
      id: GameModeId.juez,
      title: 'El Juez',
      description: 'Vota al culpable. El mas votado bebe.',
      icon: Icons.gavel_rounded,
      primaryColor: Color(0xFF2B0B3D),
      accentColor: Color(0xFFFF7A00),
    ),
    GameMode(
      id: GameModeId.bomb,
      title: '🧨 Bomba de tiempo',
      description: 'Pasala antes de que explote.',
      icon: Icons.timer_rounded,
      primaryColor: Color(0xFF1C0B1F),
      accentColor: Color(0xFFFF5F52),
    ),
    GameMode(
      id: GameModeId.thoughtYouWouldntSay,
      title: '🧠 Pensé que no ibas a decir eso',
      description: 'Responde rápido… o bebe',
      icon: Icons.psychology_alt_rounded,
      primaryColor: Color(0xFF0F1A2F),
      accentColor: Color(0xFF00E5FF),
    ),
    GameMode(
      id: GameModeId.mirror,
      title: '🪞 El Espejo',
      description: 'Imita o bebe',
      icon: Icons.visibility_rounded,
      primaryColor: Color(0xFF1A0D2C),
      accentColor: Color(0xFF9C27B0),
    ),
    GameMode(
      id: GameModeId.drunkMath,
      title: '🧮 Matemáticas borrachas',
      description: 'Responde rápido o bebes',
      icon: Icons.calculate_rounded,
      primaryColor: Color(0xFF0D1F2D),
      accentColor: Color(0xFFFFC857),
    ),
    GameMode(
      id: GameModeId.sacrificado,
      title: '🪦 El Sacrificado',
      description: 'Uno se la juega por todos',
      icon: Icons.warning_rounded,
      primaryColor: Color(0xFF1B0E1F),
      accentColor: Color(0xFFE91E63),
    ),
    GameMode(
      id: GameModeId.multas,
      title: '🧾 Multas arbitrarias',
      description: 'Reglas injustas que se acumulan',
      icon: Icons.rule_rounded,
      primaryColor: Color(0xFF0D1729),
      accentColor: Color(0xFFFF6F61),
    ),
    GameMode(
      id: GameModeId.horseRace,
      title: '🐎 Carrera de caballos',
      description: 'Azar puro. El último bebe.',
      icon: Icons.sports_score_rounded,
      primaryColor: Color(0xFF0B1A2F),
      accentColor: Color(0xFFFFD166),
    ),
    GameMode(
      id: GameModeId.favorite,
      title: '👑 El Favorito',
      description: 'Uno manda… sin que lo sepáis',
      icon: Icons.workspace_premium_rounded,
      primaryColor: Color(0xFF1A0F2A),
      accentColor: Color(0xFFFFC400),
    ),
    GameMode(
      id: GameModeId.openMic,
      title: '🎤 Micrófono abierto',
      description: 'Di algo… y que el grupo juzgue',
      icon: Icons.mic_rounded,
      primaryColor: Color(0xFF0D0B2A),
      accentColor: Color(0xFFFF5D8F),
    ),
    GameMode(
      id: GameModeId.falseMemory,
      title: '🧠 Recuerdo falso',
      description: 'Convéncelos… o bebes',
      icon: Icons.psychology_alt_rounded,
      primaryColor: Color(0xFF0E0B24),
      accentColor: Color(0xFF7C4DFF),
    ),
    GameMode(
      id: GameModeId.mole,
      title: '🕵️ El Topo',
      description: 'Hay un traidor. Descúbrelo.',
      icon: Icons.visibility_off_rounded,
      primaryColor: Color(0xFF0E1529),
      accentColor: Color(0xFFFF8C42),
    ),
    GameMode(
      id: GameModeId.vampire,
      title: '🧛 Vampiro',
      description: 'Infecta en secreto. Bandos y caos.',
      icon: Icons.bloodtype_rounded,
      primaryColor: Color(0xFF120A2A),
      accentColor: Color(0xFFFF4D6D),
    ),
    GameMode(
      id: GameModeId.secretRoles,
      title: '🎭 Personaje secreto',
      description: 'Actúa y que no te pillen',
      icon: Icons.theater_comedy_rounded,
      primaryColor: Color(0xFF1A0C2F),
      accentColor: Color(0xFFFF8FB1),
    ),
    GameMode(
      id: GameModeId.blackjack,
      title: 'Blackjack borracho',
      description:
          'Una vuelta fiestera al blackjack. Barajas, tragos y locura.',
      icon: Icons.casino_rounded,
      primaryColor: Color(0xFF0F172A),
      accentColor: Color(0xFF8A2DFF),
    ),
    GameMode(
      id: GameModeId.spanishDuel,
      title: 'Duelo de cartas',
      description:
          'Baraja espanola, 2 jugadores frente a frente. El numero mas alto gana la ronda.',
      icon: Icons.sports_martial_arts_rounded,
      primaryColor: Color(0xFF102030),
      accentColor: Color(0xFF00F5A0),
    ),
    GameMode(
      id: GameModeId.touchSelector,
      title: 'El elegido',
      description:
          'Pon tus dedos en la pantalla y deja que el movil elija quien bebe.',
      icon: Icons.touch_app_rounded,
      primaryColor: Color(0xFF1B0F3A),
      accentColor: Color(0xFFFFC857),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToMode(GameMode mode) {
    switch (mode.id) {
      case GameModeId.blackjack:
        Navigator.pushNamed(context, AppRoutes.blackjack);
        break;
      case GameModeId.spanishDuel:
        Navigator.pushNamed(context, AppRoutes.spanishDuel);
        break;
      case GameModeId.touchSelector:
        Navigator.pushNamed(context, AppRoutes.touchSelector);
        break;
      case GameModeId.yoNunca:
        Navigator.pushNamed(context, AppRoutes.yoNuncaSetup);
        break;
      case GameModeId.duel:
        Navigator.pushNamed(context, AppRoutes.duel);
        break;
      case GameModeId.juez:
        Navigator.pushNamed(context, AppRoutes.juez);
        break;
      case GameModeId.bomb:
        Navigator.pushNamed(context, AppRoutes.bombSetup);
        break;
      case GameModeId.thoughtYouWouldntSay:
        Navigator.pushNamed(context, AppRoutes.thoughtYouWouldntSay);
        break;
      case GameModeId.mirror:
        Navigator.pushNamed(context, AppRoutes.mirror);
        break;
      case GameModeId.drunkMath:
        Navigator.pushNamed(context, AppRoutes.drunkMath);
        break;
      case GameModeId.sacrificado:
        Navigator.pushNamed(context, AppRoutes.sacrificadoSetup);
        break;
      case GameModeId.multas:
        Navigator.pushNamed(context, AppRoutes.multas);
        break;
      case GameModeId.horseRace:
        Navigator.pushNamed(context, AppRoutes.horseRaceSetup);
        break;
      case GameModeId.favorite:
        Navigator.pushNamed(context, AppRoutes.favoriteSetup);
        break;
      case GameModeId.openMic:
        Navigator.pushNamed(context, AppRoutes.openMic);
        break;
      case GameModeId.falseMemory:
        Navigator.pushNamed(context, AppRoutes.falseMemory);
        break;
      case GameModeId.mole:
        Navigator.pushNamed(context, AppRoutes.moleSetup);
        break;
      case GameModeId.vampire:
        Navigator.pushNamed(context, AppRoutes.vampireSetup);
        break;
      case GameModeId.secretRoles:
        Navigator.pushNamed(context, AppRoutes.secretRolesSetup);
        break;
      case GameModeId.classic:
      case GameModeId.quick:
        Navigator.pushNamed(context, AppRoutes.challengeSetup);
        break;
    }
  }

  void _openContactPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contacto en construccion')),
    );
  }

  void _openNightDna() {
    Navigator.pushNamed(context, AppRoutes.nightDna);
  }

  void _openSettings() {
    Navigator.pushNamed(context, AppRoutes.settings);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF050016),
              Color(0xFF2D0A4D),
              Color(0xFF550B78),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _openContactPlaceholder,
                      icon: const Icon(Icons.mail_outline_rounded, color: Colors.white),
                    ),
                    IconButton(
                      onPressed: _openNightDna,
                      icon: const Icon(Icons.bubble_chart_rounded, color: Colors.white),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          'OSPIFIESTA',
                          style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                                color: AppTheme.accent,
                                fontSize: 36,
                                shadows: [
                                  Shadow(
                                    color: AppTheme.primary.withOpacity(0.7),
                                    blurRadius: 18,
                                  ),
                                ],
                              ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _openSettings,
                      icon: const Icon(Icons.settings_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Desliza y elige tu modo',
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _gameModes.length,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  itemBuilder: (context, index) {
                    final mode = _gameModes[index];
                    return _GameModeCard(
                      mode: mode,
                      isActive: _currentPage == index,
                      onStart: () => _goToMode(mode),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_gameModes.length, (index) {
                    final bool isActive = index == _currentPage;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      height: 8,
                      width: isActive ? 26 : 10,
                      decoration: BoxDecoration(
                        color: isActive ? Colors.white : Colors.white.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameModeCard extends StatelessWidget {
  final GameMode mode;
  final bool isActive;
  final VoidCallback onStart;

  const _GameModeCard({
    required this.mode,
    required this.onStart,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color start = mode.primaryColor ?? AppTheme.secondary;
    final Color end = mode.accentColor ?? AppTheme.accent;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: isActive ? 0 : 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [start, end],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: end.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Icon(mode.icon, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              mode.title,
              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              mode.description,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
            ),
            const Spacer(),
            PrimaryButton(
              text: 'Empezar',
              icon: Icons.play_arrow_rounded,
              onPressed: onStart,
            ),
          ],
        ),
      ),
    );
  }
}
