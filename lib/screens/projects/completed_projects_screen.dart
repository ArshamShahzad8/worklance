import 'package:flutter/material.dart';

import '../../models/project.dart';
import 'project_list_view.dart';

/// Completed Projects: everything that has been closed out.
class CompletedProjectsScreen extends StatelessWidget {
  const CompletedProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Completed Projects')),
      body: const SafeArea(child: CompletedProjectsView()),
    );
  }
}

/// The Completed Projects list on its own, so the Work tab can show it.
class CompletedProjectsView extends StatelessWidget {
  const CompletedProjectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProjectListView(
      scope: {ProjectStatus.completed, ProjectStatus.cancelled},
      noun: 'Projects',
      showRoleFilter: true,
      emptyIcon: Icons.verified_outlined,
      emptyTitle: 'Nothing completed yet',
      emptyMessage:
          'Finished projects and approved orders are archived here, with '
          'their milestones and delivery history kept intact.',
    );
  }
}
