import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../models/service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_slide_animation.dart';
import '../../widgets/service_card.dart';

/// My Services screen: the freelancer-facing list of the current user's own
/// service listings, with edit/delete actions and a shortcut to create a
/// new one.
class MyServicesScreen extends StatelessWidget {
  const MyServicesScreen({super.key});

  Future<void> _confirmDelete(BuildContext context, Service service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete service?'),
        content: Text(
          '"${service.title}" will be removed from your services. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      AppScope.of(context).services.remove(service.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Deleted "${service.title}"')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final user = store.user.user;

    // Guard: freelancer profile must exist before listing services.
    if (!user.isFreelancer) {
      return Scaffold(
        appBar: AppBar(title: const Text('My Services')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.spaceLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storefront_outlined,
                  size: 56,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: AppConstants.spaceMd),
                Text(
                  'Set up your freelancer profile first',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: AppConstants.spaceSm),
                Text(
                  'Add a title, bio and skills so clients know who they '
                  "are hiring before you list a service.",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                AppButton(
                  label: 'Set Up Freelancer Profile',
                  expanded: false,
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.editFreelancerProfile),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Services')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () =>
            Navigator.of(context).pushNamed(AppRoutes.createService),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Service'),
      ),
      body: ListenableBuilder(
        listenable: store.services,
        builder: (context, _) {
          final services = store.services.getAll();

          if (services.isEmpty) {
            return EmptyState(
              icon: Icons.storefront_outlined,
              title: 'No services yet',
              message:
                  'Create your first service listing so clients can find '
                  'and hire you.',
              actionLabel: 'Create Service',
              onAction: () =>
                  Navigator.of(context).pushNamed(AppRoutes.createService),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spaceMd,
              AppConstants.spaceMd,
              AppConstants.spaceMd,
              AppConstants.spaceXl * 2,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return FadeSlideAnimation(
                index: index,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
                  child: Stack(
                    children: [
                      ServiceCard(
                        service: service,
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRoutes.createService,
                          arguments: service,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: Material(
                          color: AppColors.surface,
                          shape: const CircleBorder(),
                          child: PopupMenuButton<String>(
                            icon: const Icon(Icons.more_vert_rounded, size: 20),
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.of(context).pushNamed(
                                  AppRoutes.createService,
                                  arguments: service,
                                );
                              } else if (value == 'delete') {
                                _confirmDelete(context, service);
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Row(
                                  children: [
                                    Icon(Icons.edit_outlined, size: 18),
                                    SizedBox(width: 8),
                                    Text('Edit'),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: AppColors.error,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
