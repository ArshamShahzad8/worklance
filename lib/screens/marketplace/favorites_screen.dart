import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../data/repositories/freelancer_repository.dart';
import '../../data/repositories/service_repository.dart';
import '../../models/freelancer.dart';
import '../../models/service.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/freelancer_list_tile.dart';
import '../../widgets/service_card.dart';

/// Favorites screen: everything the user has saved, split into
/// [Services] and [Freelancers] tabs.
///
/// Backed by the shared [FavoritesController], so toggling a heart anywhere
/// in the app instantly shows up here (and vice versa).
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key, this.onFreelancerTap});

  /// Called when a freelancer row is tapped; the shell uses it to push the
  /// profile route. Falls back to pushing the route directly when null.
  final ValueChanged<Freelancer>? onFreelancerTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);

    return SafeArea(
      child: DefaultTabController(
        length: 2,
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
              child: Text('Favorites', style: theme.textTheme.headlineMedium),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMd,
              ),
              child: Text(
                'Services and freelancers you saved',
                style: theme.textTheme.bodySmall,
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            ListenableBuilder(
              listenable: store.favorites,
              builder: (context, _) {
                final favoriteServices = _favoriteServices(store);
                final favoriteFreelancers = _favoriteFreelancers(store);
                return TabBar(
                  tabs: [
                    Tab(
                      text:
                          'Services (${favoriteServices.length})',
                    ),
                    Tab(
                      text:
                          'Freelancers (${favoriteFreelancers.length})',
                    ),
                  ],
                );
              },
            ),
            Expanded(
              child: ListenableBuilder(
                listenable: store.favorites,
                builder: (context, _) => TabBarView(
                  children: [
                    _ServicesTab(
                      services: _favoriteServices(store),
                      store: store,
                    ),
                    _FreelancersTab(
                      freelancers: _favoriteFreelancers(store),
                      store: store,
                      onFreelancerTap: onFreelancerTap,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<Service> _favoriteServices(AppStore store) =>
      ServiceRepository.getAll()
          .where((s) => store.favorites.isFavorite(s.id))
          .toList();

  static List<Freelancer> _favoriteFreelancers(AppStore store) =>
      FreelancerRepository.getAll()
          .where((f) => store.favorites.isFavorite(f.id))
          .toList();
}

/// Favorite services list.
class _ServicesTab extends StatelessWidget {
  const _ServicesTab({required this.services, required this.store});

  final List<Service> services;
  final AppStore store;

  @override
  Widget build(BuildContext context) {
    if (services.isEmpty) {
      return const EmptyState(
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
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
          child: ServiceCard(
            service: service,
            favorites: store.favorites,
            onTap: () => Navigator.of(
              context,
            ).pushNamed(AppRoutes.serviceDetail, arguments: service),
            onFreelancerTap: () => Navigator.of(context).pushNamed(
              AppRoutes.freelancerProfile,
              arguments: service.freelancer,
            ),
          ),
        );
      },
    );
  }
}

/// Favorite freelancers list.
class _FreelancersTab extends StatelessWidget {
  const _FreelancersTab({
    required this.freelancers,
    required this.store,
    this.onFreelancerTap,
  });

  final List<Freelancer> freelancers;
  final AppStore store;
  final ValueChanged<Freelancer>? onFreelancerTap;

  void _openProfile(BuildContext context, Freelancer freelancer) {
    if (onFreelancerTap != null) {
      onFreelancerTap!(freelancer);
      return;
    }
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.freelancerProfile, arguments: freelancer);
  }

  @override
  Widget build(BuildContext context) {
    if (freelancers.isEmpty) {
      return const EmptyState(
        title: 'No saved freelancers yet',
        message:
            'Save freelancers you like by tapping the heart icon, '
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
      itemCount: freelancers.length,
      itemBuilder: (context, index) {
        final freelancer = freelancers[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
          child: FreelancerListTile(
            freelancer: freelancer,
            favorites: store.favorites,
            onTap: () => _openProfile(context, freelancer),
          ),
        );
      },
    );
  }
}
