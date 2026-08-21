import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/service_filters.dart';
import '../../data/mock_data.dart';
import '../../models/category.dart';
import '../../widgets/category_card.dart';

/// Categories tab: every WORKLANCE category in a responsive grid.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key, required this.onCategorySelected});

  final ValueChanged<Category> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            child: Text(
              'Categories',
              style: theme.textTheme.headlineMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceMd,
            ),
            child: Text(
              'Browse every WORKLANCE service category.',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth >= 600 ? 4 : 2;
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spaceMd,
                    AppConstants.spaceSm,
                    AppConstants.spaceMd,
                    AppConstants.spaceLg,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: AppConstants.spaceMd,
                    mainAxisSpacing: AppConstants.spaceMd,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: MockData.categories.length,
                  itemBuilder: (context, index) {
                    final category = MockData.categories[index];
                    return CategoryCard(
                      category: category,
                      serviceCount: countServicesInCategory(
                        MockData.services,
                        category.id,
                      ),
                      onTap: () => onCategorySelected(category),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
