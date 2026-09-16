import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../models/order.dart';
import '../../widgets/fade_slide_animation.dart';
import '../../widgets/milestone_card.dart';
import '../../widgets/project_progress_bar.dart';

/// Milestones screen: every milestone for one order, with a progress
/// summary up top and a button on each card to move it to its next status
/// (Pending → In Progress → Submitted → Completed).
class MilestonesScreen extends StatelessWidget {
  const MilestonesScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Milestones')),
      body: ListenableBuilder(
        listenable: store.orders,
        builder: (context, _) {
          final current = store.orders.getById(order.id) ?? order;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            child: FadeSlideAnimation(
              index: 0,
              duration: const Duration(milliseconds: 350),
              slideOffset: 12.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(current.job.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppConstants.spaceSm),
                  Text(
                    '${current.completedMilestonesCount} of '
                    '${current.milestones.length} milestones complete',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceSm),
                  ProjectProgressBar(
                    progress: current.progress,
                    color: current.status.color,
                    label: 'Overall progress',
                  ),
                  const SizedBox(height: AppConstants.spaceLg),
                  for (var i = 0; i < current.milestones.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
                      child: FadeSlideAnimation(
                        index: i,
                        child: MilestoneCard(
                          milestone: current.milestones[i],
                          index: i,
                          onAdvance: current.status == OrderStatus.completed
                              ? null
                              : () {
                                  final next = current.milestones[i].status.next;
                                  if (next == null) return;
                                  store.orders.updateMilestoneStatus(
                                    current.id,
                                    current.milestones[i].id,
                                    next,
                                  );
                                },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
