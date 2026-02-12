import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../l10n/app_localizations.dart';

import '../home/home_screen.dart';
import '../sebha/sebha_screen.dart';
import '../athkar/athkar_screen.dart';
import '../quran/presentation/screens/quran_screen.dart';
import '../services/presentation/screens/services_screen.dart';
import '../adhan/services/adhan_scheduling_service.dart';
import '../../core/services/native_scheduler_service.dart';
import '../quran/presentation/widgets/mini_audio_player.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);
final navigationBarVisibilityProvider = StateProvider<bool>((ref) => true);

class MainLayoutScreen extends ConsumerStatefulWidget {
  const MainLayoutScreen({super.key});

  @override
  ConsumerState<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends ConsumerState<MainLayoutScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule Adhan on startup
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(adhanSchedulingServiceProvider).scheduleAdhans(force: false);
      _checkLaunchPayload();
    });
  }

  Future<void> _checkLaunchPayload() async {
    final scheduler = NativeSchedulerService();
    // Use the getLaunchPayload we added (if it exists)
    // Wait, the instance method is separate from static? No, it's instance.
    // I need to make sure I call it correctly.
    final route = await scheduler.getLaunchPayload();
    if (route != null && route.isNotEmpty) {
      debugPrint("Deep Link Received: $route");
      if (route == "/adhan") {
        ref.read(navigationIndexProvider.notifier).state = 0; // Home
      } else if (route == "quran" || route == "/mushaf") {
        ref.read(navigationIndexProvider.notifier).state = 3; // Quran
      } else if (route == "/location_settings") {
        ref.read(navigationIndexProvider.notifier).state = 0;
      } else if (route.contains("athkar")) {
        ref.read(navigationIndexProvider.notifier).state = 2; // Athkar
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final index = ref.watch(navigationIndexProvider);
    final isNavBarVisible = ref.watch(navigationBarVisibilityProvider);
    final l10n = AppLocalizations.of(context)!;

    final screens = const [
      HomeScreen(),
      SebhaScreen(),
      AthkarScreen(),
      QuranScreen(),
      ServicesScreen(),
    ];

    return PopScope(
      canPop: index == 0,
      onPopInvoked: (didPop) {
        if (didPop) return;
        ref.read(navigationIndexProvider.notifier).state = 0;
        ref.read(navigationBarVisibilityProvider.notifier).state = true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            IndexedStack(index: index, children: screens),
            const Align(
              alignment: Alignment.bottomCenter,
              child: MiniAudioPlayer(),
            ),
          ],
        ),
        bottomNavigationBar: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOutCubic,
          height: isNavBarVisible ? null : 0,
          child: isNavBarVisible
              ? NavigationBar(
                  selectedIndex: index,
                  onDestinationSelected: (value) {
                    ref.read(navigationIndexProvider.notifier).state = value;
                    ref.read(navigationBarVisibilityProvider.notifier).state =
                        true;
                  },
                  destinations: [
                    NavigationDestination(
                      icon: const Icon(Icons.home_outlined),
                      selectedIcon: const Icon(Icons.home),
                      label: l10n.home,
                    ),
                    NavigationDestination(
                      icon: const ImageIcon(
                        AssetImage("assets/images/sebha_outlined.png"),
                        size: 24,
                      ),
                      selectedIcon: const ImageIcon(
                        AssetImage("assets/images/sebha_filled.png"),
                        size: 24,
                      ),
                      label: l10n.sebha,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.menu_book_outlined),
                      selectedIcon: const Icon(Icons.menu_book),
                      label: l10n.athkar,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.book_outlined),
                      selectedIcon: const Icon(Icons.book),
                      label: l10n.quran,
                    ),
                    NavigationDestination(
                      icon: const Icon(Icons.grid_view),
                      selectedIcon: const Icon(Icons.grid_view_rounded),
                      label: l10n.services,
                    ),
                  ],
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
