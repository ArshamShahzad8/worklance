import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/utils/service_filters.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/service_repository.dart';
import '../../models/category.dart';
import '../../widgets/category_card.dart';

/// Dedicated "Browse all categories" screen, reached from the Home screen's
/// Categories section via "See All". Every WORKLANCE category is shown in a
/// responsive grid with its live service count; tapping one hands the
/// selection back to the caller (see [AppRoutes.categories]) so it can be
/// applied as a filter on the Services tab.
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key, required this.onCategorySelected});

  final ValueChanged<Category> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      body: SafeArea(
        top: false,
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
                    itemCount: CategoryRepository.getAll().length,
                    itemBuilder: (context, index) {
                      final category = CategoryRepository.getAll()[index];
                      return CategoryCard(
                        category: category,
                        serviceCount: countServicesInCategory(
                          ServiceRepository.getAll(),
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
      ),
    );
  }
}
