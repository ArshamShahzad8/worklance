import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/utils/service_filters.dart';
import '../../data/mock_data.dart';
import '../../models/service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/service_card.dart';

/// Services tab: search + category filtering over all services, with a
/// proper empty state when nothing matches.
class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key, this.categoryFilter});

  /// Category preselected by the Categories tab, if any.
  final String? categoryFilter;

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryFilter;
  }

  @override
  void didUpdateWidget(ServicesScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoryFilter != oldWidget.categoryFilter) {
      _selectedCategoryId = widget.categoryFilter;
      _query = '';
      _searchController.clear();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Service> get _filteredServices => filterServices(
        services: MockData.services,
        query: _query,
        categoryId: _selectedCategoryId,
      );

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = null;
      _query = '';
      _searchController.clear();
    });
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
              '${services.length} of ${MockData.services.length} services available',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
            child: AppSearchBar(
              key: const ValueKey('services_search'),
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm + 4),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
              itemCount: MockData.categories.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _FilterChip(
                    label: 'All',
                    selected: _selectedCategoryId == null,
                    onTap: () => setState(() => _selectedCategoryId = null),
                  );
                }
                final category = MockData.categories[index - 1];
                return _FilterChip(
                  label: category.name,
                  selected: _selectedCategoryId == category.id,
                  onTap: () => setState(
                    () => _selectedCategoryId = category.id,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Expanded(
            child: services.isEmpty
                ? EmptyState(
                    title: 'No services found',
                    message: _query.isNotEmpty
                        ? "We couldn't find anything matching your search. "
                            'Try a different keyword or category.'
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
                        padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
                        child: ServiceCard(
                          service: service,
                          favorites: store.favorites,
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.serviceDetail,
                            arguments: service,
                          ),
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
