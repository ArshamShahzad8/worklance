import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../models/project.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_slide_animation.dart';
import '../../widgets/milestone_tile.dart';
import '../../widgets/project_progress_bar.dart';

/// Milestones screen: the full milestone plan for one project.
class ProjectMilestonesScreen extends StatelessWidget {
  const ProjectMilestonesScreen({super.key, required this.project});

  final Project project;

  void _updateMilestone(
    BuildContext context,
    Project current,
    Milestone milestone,
    MilestoneStatus status,
  ) {
    AppScope.of(
      context,
    ).projects.setMilestoneStatus(current.id, milestone.id, status);

    if (status == MilestoneStatus.completed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('"${milestone.title}" marked complete.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Milestones')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store.projects,
          builder: (context, _) {
            final current = store.projects.getById(project.id) ?? project;

            if (current.milestones.isEmpty) {
              return EmptyState(
                icon: Icons.checklist_rtl_rounded,
                title: 'No milestones',
                message:
                    'This project does not have a milestone plan. Its '
                    'progress follows the overall status instead.',
                actionLabel: 'Back to project',
                onAction: () => Navigator.of(context).pop(),
              );
            }

            final canEdit =
                current.role == ProjectRole.freelancer &&
                current.status.isOpen;
            final allDone =
                current.completedMilestones == current.totalMilestones;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: AppConstants.maxListWidth,
                ),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spaceMd,
                    AppConstants.spaceMd,
                    AppConstants.spaceMd,
                    AppConstants.spaceXl,
                  ),
                  children: [
                    _ProgressHeader(project: current),
                    const SizedBox(height: AppConstants.spaceLg),
                    if (!canEdit)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppConstants.spaceMd,
                        ),
                        child: _ReadOnlyNote(project: current),
                      ),
                    for (var i = 0; i < current.milestones.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppConstants.spaceMd,
                        ),
                        child: FadeSlideAnimation(
                          index: i,
                          child: MilestoneTile(
                            milestone: current.milestones[i],
                            index: i,
                            onStatusChanged: canEdit
                                ? (status) => _updateMilestone(
                                    context,
                                    current,
                                    current.milestones[i],
                                    status,
                                  )
                                : null,
                          ),
                        ),
                      ),
                    if (canEdit &&
                        allDone &&
                        current.status == ProjectStatus.active) ...[
                      const SizedBox(height: AppConstants.spaceSm),
                      FilledButton.icon(
                        onPressed: () => Navigator.of(context).pushNamed(
                          AppRoutes.submitDelivery,
                          arguments: current,
                        ),
                        icon: const Icon(Icons.upload_rounded),
                        label: const Text('All done — Submit Delivery'),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            ProjectProgressBar(project: project),
            const SizedBox(height: AppConstants.spaceMd),
            Row(
              children: [
                Expanded(
                  child: _HeaderStat(
                    label: 'Released',
                    value: AppConstants.formatPrice(project.releasedAmount),
                  ),
                ),
                Expanded(
                  child: _HeaderStat(
                    label: 'Contract value',
                    value: AppConstants.formatPrice(project.amount),
                  ),
                ),
                Expanded(
                  child: _HeaderStat(
                    label: 'Deadline',
                    value: project.dueLabel,
                    highlight: project.isOverdue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            color: highlight ? AppColors.error : null,
          ),
        ),
      ],
    );
  }
}

class _ReadOnlyNote extends StatelessWidget {
  const _ReadOnlyNote({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = project.status.isFinal
        ? 'This project is closed, so its milestones are read-only.'
        : '${project.freelancerName} updates these milestones as the work '
              'progresses.';

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.visibility_outlined, size: 18, color: AppColors.textMuted),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
