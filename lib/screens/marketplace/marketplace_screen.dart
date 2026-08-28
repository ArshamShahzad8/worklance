import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/service_filters.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/freelancer_repository.dart';
import '../../data/repositories/service_repository.dart';
import '../../models/category.dart';
import '../../models/freelancer.dart';
import '../../models/service.dart';
import '../../widgets/category_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_slide_animation.dart';
import '../../widgets/freelancer_card.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/section_header.dart';
import '../../widgets/service_card.dart';

/// Home / Marketplace tab: a polished marketplace discovery screen.
///
/// Shows a hero header, prominent search, category grid, top freelancers
/// horizontal row, and featured services — designed to look and feel like
/// a real freelancing marketplace.
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({
    super.key,
    required this.onSeeAllCategories,
    required this.onSeeAllServices,
    required this.onCategorySelected,
    required this.onProfileTap,
    required this.onFreelancerTap,
  });

  final VoidCallback onSeeAllCategories;
  final VoidCallback onSeeAllServices;
  final ValueChanged<Category> onCategorySelected;
  final VoidCallback onProfileTap;
  final ValueChanged<Freelancer> onFreelancerTap;

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _isSearching => _query.trim().isNotEmpty;

  /// Featured services by default. Typing in the search bar switches Home
  /// into search mode across the whole marketplace.
  List<Service> get _visibleServices {
    if (!_isSearching) {
      return ServiceRepository.getFeatured();
    }
    return filterServices(services: ServiceRepository.getAll(), query: _query);
  }

  /// Top freelancers sorted by rating then review count.
  List<Freelancer> get _topFreelancers => FreelancerRepository.getTop();

  void _clearSearch() {
    setState(() {
      _query = '';
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);
    final user = store.user.user;

    return CustomScrollView(
      slivers: [
        // ─── Hero header ─────────────────────────────────────────────
        SliverToBoxAdapter(
          child: _HeroHeader(user: user, onProfileTap: widget.onProfileTap),
        ),

        // ─── Stats cards ─────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spaceMd,
            AppConstants.spaceMd,
            AppConstants.spaceMd,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: Row(
              children: [
                _StatCard(
                  value: '${ServiceRepository.getAll().length}',
                  label: 'Services',
                  icon: Icons.work_outline_rounded,
                ),
                const SizedBox(width: AppConstants.spaceSm),
                _StatCard(
                  value: '${FreelancerRepository.getAll().length}',
                  label: 'Freelancers',
                  icon: Icons.people_outline_rounded,
                ),
                const SizedBox(width: AppConstants.spaceSm),
                _StatCard(
                  value: '${CategoryRepository.getAll().length}',
                  label: 'Categories',
                  icon: Icons.category_outlined,
                ),
              ],
            ),
          ),
        ),

        // ─── Search bar ──────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spaceMd,
            AppConstants.spaceMd,
            AppConstants.spaceMd,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: AppSearchBar(
              key: const ValueKey('home_search'),
              controller: _searchController,
              hintText: 'Search for services, skills or freelancers...',
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
        ),

        // ─── Categories section ──────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spaceMd,
            AppConstants.spaceLg,
            AppConstants.spaceMd,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Categories',
              actionLabel: 'See All',
              onAction: widget.onSeeAllCategories,
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.only(top: AppConstants.spaceSm + 4),
          sliver: SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMd,
                ),
                itemCount: CategoryRepository.getAll().length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = CategoryRepository.getAll()[index];
                  return CategoryCard(
                    compact: true,
                    category: category,
                    onTap: () => widget.onCategorySelected(category),
                  );
                },
              ),
            ),
          ),
        ),

        // ─── Top Freelancers section ─────────────────────────────────
        if (!_isSearching) ...[
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceMd,
              AppConstants.spaceLg,
              AppConstants.spaceMd,
              0,
            ),
            sliver: SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Top Freelancers',
                subtitle: 'Rated by clients worldwide',
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.only(
              top: AppConstants.spaceSm + 4,
              bottom: AppConstants.spaceSm,
            ),
            sliver: SliverToBoxAdapter(
              child: SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceMd,
                  ),
                  itemCount: _topFreelancers.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final freelancer = _topFreelancers[index];
                    return FreelancerCard(
                      freelancer: freelancer,
                      onTap: () => widget.onFreelancerTap(freelancer),
                    );
                  },
                ),
              ),
            ),
          ),
        ],

        // ─── Featured / Search results section ───────────────────────
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spaceMd,
            AppConstants.spaceSm,
            AppConstants.spaceMd,
            0,
          ),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(
              title: _isSearching ? 'Search results' : 'Popular Services',
              subtitle: _isSearching
                  ? '${_visibleServices.length} services found'
                  : 'Recommended for you',
              actionLabel: _isSearching ? 'Clear' : 'See All',
              onAction: _isSearching ? _clearSearch : widget.onSeeAllServices,
            ),
          ),
        ),
        if (_visibleServices.isEmpty)
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceMd,
            ),
            sliver: SliverToBoxAdapter(
              child: EmptyState(
                title: 'No services found',
                message:
                    "We couldn't find anything matching your search. "
                    'Try a different keyword.',
                actionLabel: 'Clear search',
                onAction: _clearSearch,
              ),
            ),
          )
        else
          for (final entry in _visibleServices.asMap().entries)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spaceMd,
                0,
                AppConstants.spaceMd,
                AppConstants.spaceMd,
              ),
              sliver: SliverToBoxAdapter(
                child: FadeSlideAnimation(
                  index: entry.key,
                  child: ServiceCard(
                    service: entry.value,
                    favorites: store.favorites,
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.serviceDetail,
                      arguments: entry.value,
                    ),
                    onFreelancerTap: () =>
                        widget.onFreelancerTap(entry.value.freelancer),
                  ),
                ),
              ),
            ),
        const SliverPadding(
          padding: EdgeInsets.only(bottom: AppConstants.spaceXl),
        ),
      ],
    );
  }
}

/// Prominent hero header with marketplace branding, stats, and profile avatar.
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.user, required this.onProfileTap});

  final dynamic user;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spaceMd,
            AppConstants.spaceMd,
            AppConstants.spaceMd,
            AppConstants.spaceLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: app name + notification + avatar
              Row(
                children: [
                  Text(
                    AppConstants.appName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(),
                  _HeaderIconButton(
                    icon: Icons.notifications_none_rounded,
                    badgeCount: 3,
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'You have 3 new notifications (prototype).',
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: onProfileTap,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        user.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceSm),
              // Personalized greeting
              Text(
                '${AppConstants.greetingFor(DateTime.now())}, ${user.firstName}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              // Main heading
              Text(
                'Find the right\nfreelancer for your\nnext project',
                style: theme.textTheme.headlineLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// An equally-sized stat card below the hero header.
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.spaceMd,
          horizontal: AppConstants.spaceSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: AppColors.primary),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceXs),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon button with an optional badge in the hero header.
class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onPressed,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onPressed,
          tooltip: 'Notifications',
          icon: Icon(icon, color: Colors.white, size: 24),
        ),
        if (badgeCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.error,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
