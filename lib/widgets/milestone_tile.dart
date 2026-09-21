import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../models/project.dart';
import 'project_status_badge.dart';

/// One milestone row, used on Project Details and Milestones screens.
class MilestoneTile extends StatelessWidget {
  const MilestoneTile({
    super.key,
    required this.milestone,
    required this.index,
    this.onStatusChanged,
    this.showDescription = true,
  });

  final Milestone milestone;
  final int index;
  final ValueChanged<MilestoneStatus>? onStatusChanged;
  final bool showDescription;

  MilestoneStatus? get _nextStatus {
    switch (milestone.status) {
      case MilestoneStatus.pending:
        return MilestoneStatus.inProgress;
      case MilestoneStatus.inProgress:
        return MilestoneStatus.completed;
      case MilestoneStatus.completed:
        return null;
    }
  }

  String get _nextActionLabel {
    switch (milestone.status) {
      case MilestoneStatus.pending:
        return 'Start';
      case MilestoneStatus.inProgress:
        return 'Mark complete';
      case MilestoneStatus.completed:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = milestone.status.color;
    final next = _nextStatus;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.14),
                  ),
                  child: milestone.isCompleted
                      ? Icon(Icons.check_rounded, size: 16, color: color)
                      : Text(
                          '${index + 1}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
                const SizedBox(width: AppConstants.spaceSm),
                Expanded(
                  child: Text(
                    milestone.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      decoration: milestone.isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                      decorationColor: AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSm),
                MilestoneStatusBadge(status: milestone.status),
              ],
            ),
            if (showDescription) ...[
              const SizedBox(height: AppConstants.spaceSm),
              Text(
                milestone.description,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: AppConstants.spaceSm),
            Wrap(
              spacing: AppConstants.spaceMd,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _MetaChip(
                  icon: Icons.attach_money_rounded,
                  label: AppConstants.formatPrice(milestone.amount),
                  color: AppColors.primary,
                ),
                _MetaChip(
                  icon: Icons.event_outlined,
                  label: milestone.isCompleted && milestone.completedAt != null
                      ? 'Done ${AppConstants.formatShortDate(milestone.completedAt!)}'
                      : 'Due ${AppConstants.formatShortDate(milestone.dueDate)}',
                  color:
                      milestone.isOverdue ? AppColors.error : AppColors.textMuted,
                ),
              ],
            ),
            if (onStatusChanged != null && next != null) ...[
              const SizedBox(height: AppConstants.spaceSm),
              Row(
                children: [
                  FilledButton.tonalIcon(
                    onPressed: () => onStatusChanged!(next),
                    icon: Icon(next.icon, size: 16),
                    label: Text(_nextActionLabel),
                  ),
                  if (milestone.status == MilestoneStatus.inProgress) ...[
                    const SizedBox(width: AppConstants.spaceSm),
                    TextButton(
                      onPressed: () =>
                          onStatusChanged!(MilestoneStatus.pending),
                      child: const Text('Reset'),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
