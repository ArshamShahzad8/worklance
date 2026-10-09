import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../data/repositories/freelancer_repository.dart';
import '../../data/repositories/service_repository.dart';
import '../../models/category.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/freelancer_list_tile.dart';
import '../../widgets/job_card.dart';
import '../../widgets/service_card.dart';

/// Category details (Week 7): everything related to one category —
/// its services, open jobs and the freelancers working in it — each row
/// navigating through to the existing detail screens.
class CategoryDetailsScreen extends StatelessWidget {
  const CategoryDetailsScreen({super.key, required this.category});

  final Category category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);

    final categoryServices = ServiceRepository.getAll()
        .where((s) => s.category.id == category.id)
        .toList(growable: false);
    final categoryJobs = store.jobs
        .getAll()
        .where((j) => j.category.id == category.id)
        .toList(growable: false);
    final categoryFreelancers = FreelancerRepository.getAll()
        .where(
          (f) => categoryServices.any((s) => s.freelancer.id == f.id),
        )
        .toList(growable: false);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(category.name),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Services (${categoryServices.length})'),
              Tab(text: 'Jobs (${categoryJobs.length})'),
              Tab(text: 'Freelancers (${categoryFreelancers.length})'),
            ],
          ),
        ),
        body: SafeArea(
          top: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Category header ---
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spaceMd,
                  AppConstants.spaceMd,
                  AppConstants.spaceMd,
                  0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusMd,
                        ),
                      ),
                      child: Icon(
                        category.icon,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        category.description,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Expanded(
                child: TabBarView(
                  children: [
                    // --- Services ---
                    categoryServices.isEmpty
                        ? const EmptyState(
                            title: 'No services yet',
                            message:
                                'Nothing is listed in this category right now.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              AppConstants.spaceMd,
                              AppConstants.spaceSm,
                              AppConstants.spaceMd,
                              AppConstants.spaceLg,
                            ),
                            itemCount: categoryServices.length,
                            itemBuilder: (context, index) {
                              final service = categoryServices[index];
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
                                  onFreelancerTap: () =>
                                      Navigator.of(context).pushNamed(
                                        AppRoutes.freelancerProfile,
                                        arguments: service.freelancer,
                                      ),
                                ),
                              );
                            },
                          ),

                    // --- Jobs ---
                    categoryJobs.isEmpty
                        ? const EmptyState(
                            icon: Icons.work_off_outlined,
                            title: 'No open jobs',
                            message:
                                'No jobs are posted in this category right now.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              AppConstants.spaceMd,
                              AppConstants.spaceSm,
                              AppConstants.spaceMd,
                              AppConstants.spaceLg,
                            ),
                            itemCount: categoryJobs.length,
                            itemBuilder: (context, index) {
                              final job = categoryJobs[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppConstants.spaceMd,
                                ),
                                child: JobCard(
                                  job: job,
                                  favorites: store.favorites,
                                  onTap: () => Navigator.of(context).pushNamed(
                                    AppRoutes.jobDetails,
                                    arguments: job,
                                  ),
                                ),
                              );
                            },
                          ),

                    // --- Freelancers ---
                    categoryFreelancers.isEmpty
                        ? const EmptyState(
                            icon: Icons.people_outline_rounded,
                            title: 'No freelancers yet',
                            message:
                                'No freelancers offer services in this category.',
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.fromLTRB(
                              AppConstants.spaceMd,
                              AppConstants.spaceSm,
                              AppConstants.spaceMd,
                              AppConstants.spaceLg,
                            ),
                            itemCount: categoryFreelancers.length,
                            itemBuilder: (context, index) {
                              final freelancer = categoryFreelancers[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppConstants.spaceMd,
                                ),
                                child: FreelancerListTile(
                                  freelancer: freelancer,
                                  favorites: store.favorites,
                                  onTap: () => Navigator.of(context).pushNamed(
                                    AppRoutes.freelancerProfile,
                                    arguments: freelancer,
                                  ),
                                ),
                              );
                            },
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
