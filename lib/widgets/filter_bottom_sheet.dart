import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/service_filters.dart';
import '../models/category.dart';

/// Bottom sheet for advanced marketplace filtering: category, price range,
/// minimum rating, and maximum delivery days.
///
/// The sheet edits a copy of the current [ServiceFilter] locally and only
/// commits it through [onApply] when the user taps "Apply Filters", so
/// dismissing the sheet never changes the caller's state. "Reset" clears
/// every criterion inside the sheet (the caller still owns the final state
/// via [onApply]).
class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({
    super.key,
    this.filter = const ServiceFilter(),
    this.categories = const [],
    required this.onApply,
    this.title = 'Filter Services',
  });

  /// Current filter values used to preselect the sheet's chips.
  final ServiceFilter filter;

  /// Categories rendered as a chip row. When empty, no category section
  /// is shown (e.g. a screen that already has its own category chips).
  final List<Category> categories;

  /// Called with the edited filter when the user taps "Apply Filters".
  final ValueChanged<ServiceFilter> onApply;

  final String title;

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late String? _categoryId = widget.filter.categoryId;
  late double? _maxPrice = widget.filter.maxPrice;
  late double? _minRating = widget.filter.minRating;
  late int? _maxDeliveryDays = widget.filter.maxDeliveryDays;

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

  ServiceFilter get _edited => ServiceFilter(
    query: widget.filter.query,
    categoryId: _categoryId,
    maxPrice: _maxPrice,
    minRating: _minRating,
    maxDeliveryDays: _maxDeliveryDays,
  );

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
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(widget.title, style: theme.textTheme.titleMedium),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceMd),

            // --- Category ---
            if (widget.categories.isNotEmpty) ...[
              Text('Category', style: theme.textTheme.titleSmall),
              const SizedBox(height: AppConstants.spaceSm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('All'),
                    selected: _categoryId == null,
                    onSelected: (_) => setState(() => _categoryId = null),
                  ),
                  for (final category in widget.categories)
                    ChoiceChip(
                      label: Text(category.name),
                      selected: _categoryId == category.id,
                      onSelected: (_) => setState(
                        () => _categoryId = category.id,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppConstants.spaceLg),
            ],

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
                        // Only reset the category when this sheet owns that
                        // section — otherwise the caller's category chips
                        // would be cleared without any visible indication.
                        if (widget.categories.isNotEmpty) _categoryId = null;
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
                      widget.onApply(_edited);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Pill button that opens a [FilterBottomSheet] and shows a badge with the
/// number of active filters. Shared by the Services tab and the search screen
/// so both look and behave identically.
class FilterButton extends StatelessWidget {
  const FilterButton({
    super.key,
    required this.active,
    required this.filterCount,
    required this.onPressed,
  });

  /// Whether the filter styling should be highlighted (some filter active).
  final bool active;

  /// Number shown in the badge; hidden when 0.
  final int filterCount;

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.tune_rounded,
              size: 18,
              color: active ? Colors.white : AppColors.primary,
            ),
            if (filterCount > 0) ...[
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: active ? Colors.white : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$filterCount',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: active ? AppColors.primary : Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
