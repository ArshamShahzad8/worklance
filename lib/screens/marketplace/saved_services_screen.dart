import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../data/repositories/service_repository.dart';
import '../../models/freelancer.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/service_card.dart';

/// Saved / Favourites screen: shows all services the user has marked as
/// favourites, with the ability to unfavourite and navigate to details.
class SavedServicesScreen extends StatelessWidget {
  const SavedServicesScreen({super.key, this.onFreelancerTap});

  final ValueChanged<Freelancer>? onFreelancerTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);

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
              'Saved Services',
              style: theme.textTheme.headlineMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceMd,
            ),
            child: Text(
              'Your favourite services',
              style: theme.textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Expanded(
            child: ListenableBuilder(
              listenable: store.favorites,
              builder: (context, _) {
                final favoriteServices = ServiceRepository.getAll()
                    .where((s) => store.favorites.isFavorite(s.id))
                    .toList();

                if (favoriteServices.isEmpty) {
                  return EmptyState(
                    title: 'No saved services yet',
                    message:
                        'Save services you like by tapping the heart icon, '
                        'and find them here.',
                    icon: Icons.favorite_border_rounded,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spaceMd,
                    AppConstants.spaceSm,
                    AppConstants.spaceMd,
                    AppConstants.spaceLg,
                  ),
                  itemCount: favoriteServices.length,
                  itemBuilder: (context, index) {
                    final service = favoriteServices[index];
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
                        onFreelancerTap: onFreelancerTap != null
                            ? () => onFreelancerTap!(service.freelancer)
                            : null,
                      ),
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
