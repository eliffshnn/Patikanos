import 'package:flutter/material.dart';

import 'today_screen.dart';
import 'explore_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String _selectedActivity = 'Bisiklet';

  static const _exploreIndex = 1;

  final List<_NavItem> _navItems = const [
    _NavItem(label: 'Bugün', icon: Icons.wb_sunny_outlined, selectedIcon: Icons.wb_sunny_rounded),
    _NavItem(label: 'Keşfet', icon: Icons.explore_outlined, selectedIcon: Icons.explore_rounded),
    _NavItem(label: 'Favoriler', icon: Icons.favorite_border_rounded, selectedIcon: Icons.favorite_rounded),
    _NavItem(label: 'Profil', icon: Icons.person_outline_rounded, selectedIcon: Icons.person_rounded),
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onActivitySelected(String activity) {
    setState(() {
      _selectedActivity = activity;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      TodayScreen(
        selectedActivity: _selectedActivity,
        onActivitySelected: _onActivitySelected,
        onSeeAllRoutes: () => _onNavTapped(_exploreIndex),
      ),
      const ExploreScreen(),
      FavoritesScreen(onExplore: () => _onNavTapped(_exploreIndex)),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _selectedIndex, children: pages),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -2))],
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onNavTapped,
          destinations: _navItems
              .map(
                (item) => NavigationDestination(
                  icon: Icon(item.icon),
                  selectedIcon: Icon(item.selectedIcon),
                  label: item.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.label, required this.icon, required this.selectedIcon});

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
