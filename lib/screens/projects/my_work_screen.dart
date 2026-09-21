import 'package:flutter/material.dart';

import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../models/project.dart';
import 'active_projects_screen.dart';
import 'completed_projects_screen.dart';
import 'my_orders_screen.dart';

/// The Work tab: orders, projects and completed work.
class MyWorkScreen extends StatelessWidget {
  const MyWorkScreen({super.key, this.onBrowseServices, this.onFindJobs});

  final VoidCallback? onBrowseServices;
  final VoidCallback? onFindJobs;

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Work'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: ListenableBuilder(
              listenable: store.projects,
              builder: (context, _) {
                final orders = store.projects.openCount(
                  role: ProjectRole.client,
                );
                final projects = store.projects.openCount(
                  role: ProjectRole.freelancer,
                );
                return TabBar(
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.textSecondary,
                  indicatorColor: AppColors.primary,
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: AppColors.border,
                  tabs: [
                    Tab(text: orders > 0 ? 'Orders ($orders)' : 'Orders'),
                    Tab(
                      text: projects > 0 ? 'Projects ($projects)' : 'Projects',
                    ),
                    const Tab(text: 'Completed'),
                  ],
                );
              },
            ),
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              MyOrdersView(onBrowseServices: onBrowseServices),
              ActiveProjectsView(onFindJobs: onFindJobs),
              const CompletedProjectsView(),
            ],
          ),
        ),
      ),
    );
  }
}
