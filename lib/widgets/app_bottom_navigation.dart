import 'package:flutter/material.dart';

/// WORKLANCE bottom navigation (Material 3 NavigationBar).
///
/// Tabs: Home, Services, Saved, Profile. The parent owns the selected
/// index so tab state lives in one place.
class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  static const List<({IconData icon, IconData selectedIcon, String label})>
  _destinations = [
    (
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    (
      icon: Icons.work_outline,
      selectedIcon: Icons.work_rounded,
      label: 'Services',
    ),
    (
      icon: Icons.favorite_border_rounded,
      selectedIcon: Icons.favorite_rounded,
      label: 'Saved',
    ),
    (
      icon: Icons.person_outline,
      selectedIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        for (final destination in _destinations)
          NavigationDestination(
            icon: Icon(destination.icon),
            selectedIcon: Icon(destination.selectedIcon),
            label: destination.label,
          ),
      ],
    );
  }
}
