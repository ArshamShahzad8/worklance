import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../models/category.dart';
import '../../models/freelancer.dart';
import '../../widgets/app_bottom_navigation.dart';
import '../jobs/find_jobs_screen.dart';
import '../profile/profile_screen.dart';
import '../services/services_screen.dart';
import 'marketplace_screen.dart';
import 'saved_services_screen.dart';

/// The main app shell after login/registration: holds the bottom-navigation
/// tabs (Home, Services, Jobs, Saved, Profile) in an [IndexedStack].
///
/// The shell owns the selected tab and the category filter applied to the
/// Services tab, so the Home screen can hand off a selected category.
class MarketplaceShell extends StatefulWidget {
  const MarketplaceShell({super.key});

  @override
  State<MarketplaceShell> createState() => _MarketplaceShellState();
}

class _MarketplaceShellState extends State<MarketplaceShell> {
  int _tabIndex = 0;
  String? _servicesCategoryFilter;

  // Tab indices, named so nothing elsewhere has to guess a bare number.
  static const int _servicesTab = 1;
  static const int _jobsTab = 2;
  static const int _profileTab = 4;

  void _onTabSelected(int index) => setState(() => _tabIndex = index);

  /// Pushes the dedicated Categories screen. If the user picks a category
  /// there, it's applied as a filter and the Services tab is shown — same
  /// destination as tapping a category chip directly on Home.
  Future<void> _onSeeAllCategories() async {
    final result = await Navigator.of(context).pushNamed(AppRoutes.categories);
    if (result is Category) _onCategorySelected(result);
  }

  void _onCategorySelected(Category category) => setState(() {
    _servicesCategoryFilter = category.id;
    _tabIndex = _servicesTab;
  });

  void _onFreelancerTap(Freelancer freelancer) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.freelancerProfile, arguments: freelancer);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: [
          MarketplaceScreen(
            onSeeAllCategories: _onSeeAllCategories,
            onSeeAllServices: () => _onTabSelected(_servicesTab),
            onCategorySelected: _onCategorySelected,
            onProfileTap: () => _onTabSelected(_profileTab),
            onFreelancerTap: _onFreelancerTap,
            onFindJobs: () => _onTabSelected(_jobsTab),
            onPostJob: () => Navigator.of(context).pushNamed(AppRoutes.postJob),
          ),
          ServicesScreen(
            categoryFilter: _servicesCategoryFilter,
            onFreelancerTap: _onFreelancerTap,
          ),
          const FindJobsScreen(),
          SavedServicesScreen(onFreelancerTap: _onFreelancerTap),
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
