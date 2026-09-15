import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/todo_page.dart';
import 'pages/stats_page.dart';
import 'pages/detail_page.dart';

// Konfigurasi GoRouter
final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // ShellRoute digunakan agar NavigationBar tetap tampil di seluruh halaman (tab)
    ShellRoute(
      builder: (context, state, child) {
        return ScaffoldWithNavBar(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const TodoPage(),
        ),
        GoRoute(
          path: '/stats',
          builder: (context, state) => const StatsPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/detail/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DetailPage(id: id);
      },
    ),
  ],
);

// Scaffold pembungkus yang memiliki NavigationBar di bawahnya
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child, // Ini akan diisi oleh TodoPage atau StatsPage
      bottomNavigationBar: NavigationBar(
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (int idx) => _onItemTapped(idx, context),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.check_box_outlined),
            selectedIcon: Icon(Icons.check_box),
            label: 'To Do',
          ),
          NavigationDestination(
            icon: Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics),
            label: 'Statistik',
          ),
        ],
      ),
    );
  }

  // Menentukan tab mana yang aktif berdasarkan rute saat ini
  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.startsWith('/stats')) {
      return 1;
    }
    return 0; // default ke / (To Do)
  }

  // Aksi ketika salah satu tab ditekan
  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/stats');
        break;
    }
  }
}
