import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/service_filters.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/service_repository.dart';
import '../../models/freelancer.dart';
import '../../models/service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/service_card.dart';

/// Services tab: search + category filtering over all services, with a
/// proper empty state when nothing matches.
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key, this.categoryFilter, this.onFreelancerTap});

  /// Category preselected by the Categories tab, if any.
  final String? categoryFilter;

  /// Callback to navigate to a freelancer's profile.
  final ValueChanged<Freelancer>? onFreelancerTap;

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _searchController = TextEditingController();

  /// All search/category/price/rating/delivery filtering lives in one
  /// [ServiceFilter], shared with the reusable [filterServicesAdvanced]
  /// utility so this screen never re-implements filtering logic itself.
  ServiceFilter _filter = const ServiceFilter();
  _SortOption _sortOption = _SortOption.recommended;

  @override
  void initState() {
    super.initState();
    _filter = _filter.copyWith(categoryId: widget.categoryFilter);
  }

  @override
  void didUpdateWidget(ServicesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoryFilter != oldWidget.categoryFilter) {
      _filter = ServiceFilter(categoryId: widget.categoryFilter);
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Service> get _filteredServices {
    // Text search runs first (title, freelancer, category, skills, ...),
    // then the reusable advanced filter narrows by category/price/rating/
    // delivery time.
    final searched = filterServices(
      services: ServiceRepository.getAll(),
      query: _filter.query,
    );
    final result = filterServicesAdvanced(services: searched, filter: _filter);

    switch (_sortOption) {
      case _SortOption.recommended:
        // Featured first, then by rating.
        result.sort((a, b) {
          if (a.featured && !b.featured) return -1;
          if (!a.featured && b.featured) return 1;
          return b.rating.compareTo(a.rating);
        });
      case _SortOption.highestRated:
        result.sort((a, b) => b.rating.compareTo(a.rating));
      case _SortOption.lowestPrice:
        result.sort((a, b) => a.price.compareTo(b.price));
      case _SortOption.highestPrice:
        result.sort((a, b) => b.price.compareTo(a.price));
      case _SortOption.fastestDelivery:
        result.sort((a, b) => a.deliveryDays.compareTo(b.deliveryDays));
      case _SortOption.mostPopular:
        // Popularity = how many reviews the service's freelancer has earned.
        result.sort((a, b) {
          final cmp = b.reviewCount.compareTo(a.reviewCount);
          return cmp != 0 ? cmp : b.rating.compareTo(a.rating);
        });
    }
    return result;
  }

  /// Whether the advanced (price/rating/delivery) filter sheet has any
  /// selection applied. Category is tracked separately via its own chip row
  /// so it isn't counted toward this badge.
  bool get _hasActiveFilters =>
      _filter.maxPrice != null ||
      _filter.minRating != null ||
      _filter.maxDeliveryDays != null;

  int get _activeFilterCount {
    var count = 0;
    if (_filter.maxPrice != null) count++;
    if (_filter.minRating != null) count++;
    if (_filter.maxDeliveryDays != null) count++;
    return count;
  }

  void _selectCategory(String? categoryId) => setState(() {
    _filter = _filter.copyWith(
      categoryId: categoryId,
      clearCategoryId: categoryId == null,
    );
  });

  void _clearFilters() {
    setState(() {
      _filter = const ServiceFilter();
      _sortOption = _SortOption.recommended;
      _searchController.clear();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => FilterBottomSheet(
        filter: _filter,
        // Category selection stays on the chip row above, so the sheet
        // only edits price/rating/delivery.
        categories: const [],
        onApply: (filter) => setState(() => _filter = filter),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final services = _filteredServices;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceMd,
              AppConstants.spaceMd,
              AppConstants.spaceMd,
              0,
            ),
            child: Text('Services', style: theme.textTheme.headlineMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceMd,
            ),
            child: Text(
              '${services.length} of ${ServiceRepository.getAll().length} services available',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceMd,
            ),
            child: AppSearchBar(
              key: const ValueKey('services_search'),
              controller: _searchController,
              onChanged: (value) =>
                  setState(() => _filter = _filter.copyWith(query: value)),
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm + 4),
          // --- Category chips + filter button ---
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMd,
              ),
              children: [
                _FilterChip(
                  label: 'All',
                  selected: _filter.categoryId == null,
                  onTap: () => _selectCategory(null),
                ),
                for (final category in CategoryRepository.getAll()) ...[
                  const SizedBox(width: 8),
                  _FilterChip(
                    label: category.name,
                    selected: _filter.categoryId == category.id,
                    onTap: () => _selectCategory(category.id),
                  ),
                ],
                const SizedBox(width: 8),
                // Filter button (shared widget, Week 7).
                FilterButton(
                  active: _hasActiveFilters,
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
                Icon(Icons.sort_rounded, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 4),
                Text('Sort by:', style: theme.textTheme.bodySmall),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final option in _SortOption.values) ...[
                          GestureDetector(
                            onTap: () => setState(() => _sortOption = option),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _sortOption == option
                                    ? AppColors.primary
                                    : AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                option.label,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _sortOption == option
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
          Expanded(
            child: services.isEmpty
                ? EmptyState(
                    title: 'No services found',
                    message: (_filter.query.isNotEmpty || _hasActiveFilters)
                        ? "We couldn't find anything matching your search "
                              'and filters. Try adjusting your criteria.'
                        : 'There are no services in this category yet.',
                    actionLabel: 'Clear filters',
                    onAction: _clearFilters,
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.spaceMd,
                      AppConstants.spaceSm,
                      AppConstants.spaceMd,
                      AppConstants.spaceLg,
                    ),
                    itemCount: services.length,
                    itemBuilder: (context, index) {
                      final service = services[index];
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppConstants.spaceMd,
                        ),
                        child: ServiceCard(
                          service: service,
                          favorites: store.favorites,
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.serviceDetail,
                            arguments: service,
                          ),
                          onFreelancerTap: widget.onFreelancerTap != null
                              ? () =>
                                    widget.onFreelancerTap!(service.freelancer)
                              : null,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

/// Sort options for the services listing.
enum _SortOption {
  recommended('Recommended'),
  highestRated('Highest Rated'),
  lowestPrice('Lowest Price'),
  highestPrice('Highest Price'),
  mostPopular('Most Popular'),
  fastestDelivery('Fastest');

  const _SortOption(this.label);
  final String label;
}
