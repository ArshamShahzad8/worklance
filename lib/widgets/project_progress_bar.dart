import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../models/project.dart';

/// Progress bar for a [Project], colored by its current status.
class ProjectProgressBar extends StatelessWidget {
  const ProjectProgressBar({
    super.key,
    required this.project,
    this.showLabel = true,
    this.compact = false,
  });

  final Project project;
  final bool showLabel;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = project.status.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel) ...[
          Row(
            children: [
              Expanded(
                child: Text(
                  project.totalMilestones == 0
                      ? 'Progress'
                      : '${project.completedMilestones} of ${project.totalMilestones} milestones',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (compact
                              ? theme.textTheme.labelSmall
                              : theme.textTheme.labelMedium)
                          ?.copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: AppConstants.spaceSm),
              Text(
                '${project.progressPercent}%',
                style:
                    (compact
                            ? theme.textTheme.labelSmall
                            : theme.textTheme.labelMedium)
                        ?.copyWith(color: color, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: compact ? 4 : AppConstants.spaceSm),
        ],
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: project.progress,
            minHeight: compact ? 5 : 8,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
