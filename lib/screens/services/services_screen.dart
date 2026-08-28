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
      builder: (context) => _FilterBottomSheet(
        maxPrice: _filter.maxPrice,
        minRating: _filter.minRating,
        maxDeliveryDays: _filter.maxDeliveryDays,
        onApply: (price, rating, delivery) {
          setState(() {
            _filter = _filter.copyWith(
              maxPrice: price,
              clearMaxPrice: price == null,
              minRating: rating,
              clearMinRating: rating == null,
              maxDeliveryDays: delivery,
              clearMaxDeliveryDays: delivery == null,
            );
          });
        },
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
                // Filter button
                GestureDetector(
                  onTap: _showFilterSheet,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: _hasActiveFilters
                          ? AppColors.primary
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: _hasActiveFilters
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.tune_rounded,
                          size: 18,
                          color: _hasActiveFilters
                              ? Colors.white
                              : AppColors.primary,
                        ),
                        if (_activeFilterCount > 0) ...[
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: _hasActiveFilters
                                  ? Colors.white
                                  : AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '$_activeFilterCount',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _hasActiveFilters
                                    ? AppColors.primary
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
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

/// Bottom sheet for advanced filtering: price range, minimum rating,
/// and maximum delivery days.
class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet({
    this.maxPrice,
    this.minRating,
    this.maxDeliveryDays,
    required this.onApply,
  });

  final double? maxPrice;
  final double? minRating;
  final int? maxDeliveryDays;
  final void Function(double? price, double? rating, int? delivery) onApply;

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late double? _maxPrice = widget.maxPrice;
  late double? _minRating = widget.minRating;
  late int? _maxDeliveryDays = widget.maxDeliveryDays;

  // Predefined price tiers for quick selection.
  static final List<({double? value, String label})> _priceOptions = [
    (value: null, label: 'Any'),
    (value: 100, label: 'Under \$100'),
    (value: 200, label: 'Under \$200'),
    (value: 300, label: 'Under \$300'),
    (value: 500, label: 'Under \$500'),
  ];

  // Rating tiers.
  static final List<({double? value, String label})> _ratingOptions = [
    (value: null, label: 'Any'),
    (value: 4.0, label: '4.0+'),
    (value: 4.5, label: '4.5+'),
    (value: 4.8, label: '4.8+'),
  ];

  // Delivery time tiers.
  static final List<({int? value, String label})> _deliveryOptions = [
    (value: null, label: 'Any'),
    (value: 5, label: 'Under 5 days'),
    (value: 10, label: 'Under 10 days'),
    (value: 14, label: 'Under 14 days'),
    (value: 21, label: 'Under 21 days'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        AppConstants.spaceLg,
        AppConstants.spaceLg,
        MediaQuery.of(context).viewInsets.bottom + AppConstants.spaceLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Filter Services',
                  style: theme.textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),

          // --- Price range ---
          Text('Price Range', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppConstants.spaceSm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _priceOptions.map((option) {
              final isSelected = _maxPrice == option.value;
              return ChoiceChip(
                label: Text(option.label),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _maxPrice = option.value);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.spaceLg),

          // --- Minimum rating ---
          Text('Minimum Rating', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppConstants.spaceSm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _ratingOptions.map((option) {
              final isSelected = _minRating == option.value;
              return ChoiceChip(
                avatar: option.value != null
                    ? Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.accent,
                      )
                    : null,
                label: Text(option.label),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _minRating = option.value);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.spaceLg),

          // --- Delivery time ---
          Text('Delivery Time', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppConstants.spaceSm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _deliveryOptions.map((option) {
              final isSelected = _maxDeliveryDays == option.value;
              return ChoiceChip(
                label: Text(option.label),
                selected: isSelected,
                onSelected: (_) {
                  setState(() => _maxDeliveryDays = option.value);
                },
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.spaceLg),

          // --- Actions ---
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _maxPrice = null;
                      _minRating = null;
                      _maxDeliveryDays = null;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    widget.onApply(_maxPrice, _minRating, _maxDeliveryDays);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sort options for the services listing.
enum _SortOption {
  recommended('Recommended'),
  highestRated('Highest Rated'),
  lowestPrice('Lowest Price'),
  highestPrice('Highest Price'),
  fastestDelivery('Fastest');

  const _SortOption(this.label);
  final String label;
}
