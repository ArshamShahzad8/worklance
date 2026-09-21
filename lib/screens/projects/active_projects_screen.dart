import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/utils/project_filters.dart';
import '../../models/project.dart';
import 'project_list_view.dart';

/// Active Projects: contracts the current user is delivering as a freelancer.
class ActiveProjectsScreen extends StatelessWidget {
  const ActiveProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Active Projects'),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.completedProjects),
            child: const Text('Completed'),
          ),
        ],
      ),
      body: const SafeArea(child: ActiveProjectsView()),
    );
  }
}

/// The Active Projects list on its own, so the Work tab can show it.
class ActiveProjectsView extends StatelessWidget {
  const ActiveProjectsView({super.key, this.onFindJobs});

  final VoidCallback? onFindJobs;

  @override
  Widget build(BuildContext context) {
    return ProjectListView(
      role: ProjectRole.freelancer,
      scope: const {
        ProjectStatus.pending,
        ProjectStatus.active,
        ProjectStatus.submitted,
      },
      noun: 'Projects',
      initialSort: ProjectSort.dueSoonest,
      emptyIcon: Icons.rocket_launch_outlined,
      emptyTitle: 'No active projects',
      emptyMessage:
          'When a client accepts one of your proposals, the project opens '
          'here with its milestones ready to track.',
      emptyActionLabel: 'Find jobs',
      onEmptyAction:
          onFindJobs ??
          () => Navigator.of(context).pushNamed(AppRoutes.findJobs),
    );
  }
}
