import 'package:flutter/material.dart';

import '../../models/category.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../categories/categories_screen.dart';
import '../profile/profile_screen.dart';
import '../services/services_screen.dart';
import 'marketplace_screen.dart';

/// The main app shell after login/registration: holds the four bottom-navigation
/// tabs (Home, Categories, Services, Profile) in an [IndexedStack].
///
/// The shell owns the selected tab and the category filter applied to the
/// Services tab, so the Categories screen can hand off a selected category.
class MarketplaceShell extends StatefulWidget {
  const MarketplaceShell({super.key});

  @override
  State<MarketplaceShell> createState() => _MarketplaceShellState();
}

class _MarketplaceShellState extends State<MarketplaceShell> {
  int _tabIndex = 0;
  String? _servicesCategoryFilter;

  void _onTabSelected(int index) => setState(() => _tabIndex = index);

  void _onSeeAllCategories() => setState(() => _tabIndex = 1);

  void _onCategorySelected(Category category) => setState(() {
        _servicesCategoryFilter = category.id;
        _tabIndex = 2;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: [
          MarketplaceScreen(
            onSeeAllCategories: _onSeeAllCategories,
            onSeeAllServices: () => _onTabSelected(2),
            onCategorySelected: _onCategorySelected,
            onProfileTap: () => _onTabSelected(3),
          ),
          CategoriesScreen(onCategorySelected: _onCategorySelected),
          ServicesScreen(categoryFilter: _servicesCategoryFilter),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: AppBottomNavigation(
        currentIndex: _tabIndex,
        onDestinationSelected: _onTabSelected,
      ),
    );
  }
}
