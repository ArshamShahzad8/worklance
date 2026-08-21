import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/service_filters.dart';
import '../../data/mock_data.dart';
import '../../models/category.dart';
import '../../models/service.dart';
import '../../widgets/category_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/freelancer_avatar.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/section_header.dart';
import '../../widgets/service_card.dart';

/// Home tab: the discovery/dashboard screen.
///
/// Unlike the Services tab (the full marketplace listing), Home shows a
/// personalized greeting, a search bar, a preview of popular categories and
/// a curated set of featured services. Tapping a category here opens the
/// Services tab already filtered to that category.
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({
    super.key,
    required this.onSeeAllCategories,
    required this.onSeeAllServices,
    required this.onCategorySelected,
    required this.onProfileTap,
  });

  final VoidCallback onSeeAllCategories;
  final VoidCallback onSeeAllServices;
  final ValueChanged<Category> onCategorySelected;
  final VoidCallback onProfileTap;

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  /// Subset of categories previewed on Home ("See All" opens the Categories
  /// tab which shows every category).
  static const Set<String> _popularCategoryIds = {
    'c_web',
    'c_mobile',
    'c_ux',
    'c_graphic',
  };

  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Category> get _popularCategories => MockData.categories
      .where((category) => _popularCategoryIds.contains(category.id))
      .toList();

  List<Service> get _featuredServices =>
      MockData.services.where((service) => service.featured).toList();

  bool get _isSearching => _query.trim().isNotEmpty;

  /// Featured services by default. Typing in the search bar switches Home
  /// into search mode across the whole marketplace so users can jump to any
  /// service, not just the featured few.
  List<Service> get _visibleServices {
    if (!_isSearching) return _featuredServices;
    return filterServices(services: MockData.services, query: _query);
  }

  void _clearSearch() {
    setState(() {
      _query = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final user = store.user.user;
    final greeting =
        '${AppConstants.greetingFor(DateTime.now())}, ${user.firstName}';

    return ListView(
      padding: const EdgeInsets.only(top: AppConstants.spaceSm, bottom: 32),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Find your next freelancer today.',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              _NotificationButton(),
              const SizedBox(width: 4),
              PopupMenuButton<String>(
                tooltip: 'Profile menu',
                onSelected: (value) {
                  if (value == 'profile') widget.onProfileTap();
                },
                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'profile',
                    child: Row(
                      children: [
                        const Icon(Icons.person_outline_rounded, size: 20),
                        const SizedBox(width: 10),
                        const Text('Your Profile'),
                      ],
                    ),
                  ),
                ],
                child: FreelancerAvatar(name: user.name, color: AppColors.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
          child: AppSearchBar(
            key: const ValueKey('home_search'),
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
          ),
        ),
        const SizedBox(height: AppConstants.spaceLg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
          child: SectionHeader(
            title: 'Categories',
            actionLabel: 'See All',
            onAction: widget.onSeeAllCategories,
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm + 4),
        SizedBox(
          height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
            itemCount: _popularCategories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final category = _popularCategories[index];
              return CategoryCard(
                compact: true,
                category: category,
                onTap: () => widget.onCategorySelected(category),
              );
            },
          ),
        ),
        const SizedBox(height: AppConstants.spaceLg),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
          child: SectionHeader(
            title: _isSearching ? 'Search results' : 'Featured services',
            subtitle:
                _isSearching ? null : 'Hand-picked for you',
            actionLabel: _isSearching ? 'Clear' : 'See All',
            onAction: _isSearching ? _clearSearch : widget.onSeeAllServices,
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm + 4),
        if (_visibleServices.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
            child: EmptyState(
              title: 'No services found',
              message: "We couldn't find anything matching your search. "
                  'Try a different keyword.',
              actionLabel: 'Clear search',
              onAction: _clearSearch,
            ),
          )
        else
          for (final service in _visibleServices)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spaceMd,
                0,
                AppConstants.spaceMd,
                AppConstants.spaceMd,
              ),
              child: ServiceCard(
                service: service,
                favorites: store.favorites,
                onTap: () => Navigator.of(context)
                    .pushNamed(AppRoutes.serviceDetail, arguments: service),
              ),
            ),
      ],
    );
  }
}

/// Notification bell with an unread badge.
class _NotificationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You have 3 new notifications (prototype).'),
              ),
            );
          },
          tooltip: 'Notifications',
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: AppColors.textPrimary,
          ),
        ),
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surface, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
