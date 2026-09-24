import 'package:flutter/material.dart';

import '../../main.dart';
import '../theme.dart';
import 'help_screen.dart';
import 'home_screen.dart';
import 'map_screen.dart';
import 'reports_screen.dart';
import 'welcome_screen.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    if (!store.signedIn) return const WelcomeScreen();
    return const AppShell();
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final pages = const [
      HomeScreen(),
      ReportsScreen(),
      MapScreen(),
      HelpScreen(),
    ];
    return Scaffold(
      body: pages[store.tab],
      bottomNavigationBar: NavigationBar(
        height: 68,
        backgroundColor: Colors.white,
        indicatorColor: Colors.transparent,
        selectedIndex: store.tab,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? AppColors.teal : AppColors.muted,
          );
        }),
        onDestinationSelected: store.setTab,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded, color: AppColors.teal), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.assignment_outlined), selectedIcon: Icon(Icons.assignment, color: AppColors.teal), label: 'Reports'),
          NavigationDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map_rounded, color: AppColors.teal), label: 'Map'),
          NavigationDestination(icon: Icon(Icons.help_outline), selectedIcon: Icon(Icons.help, color: AppColors.teal), label: 'Help'),
        ],
      ),
    );
  }
}
