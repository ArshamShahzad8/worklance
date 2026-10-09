import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/marketplace_search.dart';
import '../../core/utils/service_filters.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/freelancer_repository.dart';
import '../../data/repositories/service_repository.dart';
import '../../models/category.dart';
import '../../widgets/category_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../../widgets/freelancer_list_tile.dart';
import '../../widgets/job_card.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/section_header.dart';
import '../../widgets/service_card.dart';

/// Full-screen marketplace search (Week 7).
///
/// One place to search every entity type — services, freelancers, jobs and
/// categories — with combined filters (category, price, rating, delivery
/// time) and sorting that always applies to whatever the query + filters
/// produced. All data is local/mock; results update as the user types.
class MarketplaceSearchScreen extends StatefulWidget {
  const MarketplaceSearchScreen({super.key, this.initialQuery = ''});

  /// Query prefilled when the screen is opened from another search field.
  final String initialQuery;

  @override
  State<MarketplaceSearchScreen> createState() =>
      _MarketplaceSearchScreenState();
}

class _MarketplaceSearchScreenState extends State<MarketplaceSearchScreen> {
  late final TextEditingController _searchController = TextEditingController(
    text: widget.initialQuery,
  );

  /// Query lives inside the filter so search + filters always travel together.
  late ServiceFilter _filter = ServiceFilter(query: widget.initialQuery);
  MarketplaceSort _sort = MarketplaceSort.relevance;
  SearchScope _scope = SearchScope.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool get _hasActiveCriteria =>
      _filter.hasActiveFilter || _filter.query.trim().isNotEmpty;

  int get _activeFilterCount => _filter.activeFilterCount;

  void _clearAll() {
    setState(() {
      _filter = const ServiceFilter();
      _sort = MarketplaceSort.relevance;
      _searchController.clear();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        filter: _filter,
        categories: CategoryRepository.getAll(),
        title: 'Filter Marketplace',
        onApply: (filter) => setState(() => _filter = filter),
      ),
    );
  }

  void _selectScope(SearchScope scope) => setState(() => _scope = scope);

  MarketplaceSearchResults _results(AppStore store) => searchMarketplace(
    services: ServiceRepository.getAll(),
    freelancers: FreelancerRepository.getAll(),
    jobs: store.jobs.getAll(),
    categories: CategoryRepository.getAll(),
    filter: _filter,
    sort: _sort,
    scope: _scope,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final results = _results(store);

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Search field ---
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spaceMd,
                AppConstants.spaceMd,
                AppConstants.spaceMd,
                0,
              ),
              child: AppSearchBar(
                key: const ValueKey('marketplace_search'),
                controller: _searchController,
                hintText: 'Search services, freelancers, jobs...',
                onChanged: (value) =>
                    setState(() => _filter = _filter.copyWith(query: value)),
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm + 4),

            // --- Scope chips + filter button ---
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMd,
                ),
                children: [
                  for (final scope in SearchScope.values) ...[
                    ChoiceChip(
                      label: Text(scope.label),
                      selected: _scope == scope,
                      onSelected: (_) => _selectScope(scope),
                    ),
                    const SizedBox(width: 8),
                  ],
                  FilterButton(
                    active: _filter.hasActiveFilter,
                    filterCount: _activeFilterCount,
                    onPressed: _showFilterSheet,
                  ),
                ],
              ),
            ),

            // --- Sort bar ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMd,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.sort_rounded,
                    size: 16,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text('Sort by:', style: theme.textTheme.bodySmall),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          for (final option in MarketplaceSort.values) ...[
                            GestureDetector(
                              onTap: () => setState(() => _sort = option),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 180),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _sort == option
                                      ? AppColors.primary
                                      : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Text(
                                  option.label,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: _sort == option
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),

            // --- Results ---
            Expanded(
              child: results.isEmpty
                  ? EmptyState(
                      title: 'No results found',
                      message: _hasActiveCriteria
                          ? "We couldn't find anything matching your search "
                                'and filters. Try different criteria.'
                          : 'Nothing to show yet.',
                      actionLabel: 'Clear search & filters',
                      onAction: _clearAll,
                    )
                  : _buildResults(context, theme, store, results),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(
    BuildContext context,
    ThemeData theme,
    AppStore store,
    MarketplaceSearchResults results,
  ) {
    final children = <Widget>[];

    // Header row with the live result count + a quick clear action.
    children.add(
      Padding(
        padding: const EdgeInsets.fromLTRB(
          AppConstants.spaceMd,
          0,
          AppConstants.spaceMd,
          AppConstants.spaceSm,
        ),
        child: SectionHeader(
          title: 'Results',
          subtitle: '${results.totalCount} found',
          actionLabel: _hasActiveCriteria ? 'Clear' : null,
          onAction: _hasActiveCriteria ? _clearAll : null,
        ),
      ),
    );

    void section(
      String title,
      String subtitle,
      List<Widget> items, {
      bool showHeader = true,
    }) {
      if (items.isEmpty) return;
      if (showHeader) {
        children.add(
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceMd,
              AppConstants.spaceSm,
              AppConstants.spaceMd,
              AppConstants.spaceSm,
            ),
            child: SectionHeader(title: title, subtitle: subtitle),
          ),
        );
      }
      children.addAll(items);
    }

    section(
      'Categories',
      '${results.categories.length} categories',
      [
        for (final category in results.categories)
          _padded(
            SizedBox(
              height: 116,
              child: CategoryCard(
                category: category,
                serviceCount: countServicesInCategory(
                  ServiceRepository.getAll(),
                  category.id,
                ),
                onTap: () => _openCategory(category),
              ),
            ),
          ),
      ],
      showHeader: _scope == SearchScope.all,
    );

    section(
      'Freelancers',
      '${results.freelancers.length} freelancers',
      [
        for (final freelancer in results.freelancers)
          _padded(
            FreelancerListTile(
              freelancer: freelancer,
              favorites: store.favorites,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.freelancerProfile,
                arguments: freelancer,
              ),
            ),
          ),
      ],
      showHeader: _scope == SearchScope.all,
    );

    section(
      'Services',
      '${results.services.length} services',
      [
        for (final service in results.services)
          _padded(
            ServiceCard(
              service: service,
              favorites: store.favorites,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.serviceDetail,
                arguments: service,
              ),
              onFreelancerTap: () => Navigator.of(context).pushNamed(
                AppRoutes.freelancerProfile,
                arguments: service.freelancer,
              ),
            ),
          ),
      ],
      showHeader: _scope == SearchScope.all,
    );

    section(
      'Jobs',
      '${results.jobs.length} jobs',
      [
        for (final job in results.jobs)
          _padded(
            JobCard(
              job: job,
              favorites: store.favorites,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.jobDetails,
                arguments: job,
              ),
            ),
          ),
      ],
      showHeader: _scope == SearchScope.all,
    );

    children.add(const SizedBox(height: AppConstants.spaceXl));

    return ListView(children: children);
  }

  Widget _padded(Widget child) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppConstants.spaceMd,
      0,
      AppConstants.spaceMd,
      AppConstants.spaceMd,
    ),
    child: child,
  );

  void _openCategory(Category category) {
    Navigator.of(context).pushNamed(
      AppRoutes.categoryDetails,
      arguments: category,
    );
  }
}
