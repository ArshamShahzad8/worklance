import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../models/project.dart';
import 'freelancer_avatar.dart';
import 'project_progress_bar.dart';
import 'project_status_badge.dart';

/// A project/order summary card, shared by My Orders, Active Projects and
/// Completed Projects.
class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project, required this.onTap});

  final Project project;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final showProgress = project.status != ProjectStatus.cancelled;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  ProjectStatusBadge(status: project.status),
                ],
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Row(
                children: [
                  FreelancerAvatar(
                    name: project.counterpartyName,
                    color: project.counterpartyAvatarColor,
                    radius: 12,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${project.counterpartyRoleLabel} · ${project.counterpartyName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              if (showProgress) ...[
                const SizedBox(height: AppConstants.spaceMd),
                ProjectProgressBar(project: project, compact: true),
              ],
              const SizedBox(height: AppConstants.spaceMd),
              Row(
                children: [
                  Icon(
                    Icons.attach_money_rounded,
                    size: 14,
                    color: AppColors.primary,
                  ),
                  Text(
                    AppConstants.formatPrice(project.amount),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceMd),
                  Icon(
                    project.isOverdue
                        ? Icons.warning_amber_rounded
                        : Icons.schedule_rounded,
                    size: 13,
                    color: project.isOverdue
                        ? AppColors.error
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      project.dueLabel,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: project.isOverdue
                            ? AppColors.error
                            : AppColors.textMuted,
                        fontWeight: project.isOverdue
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceSm),
                  Icon(
                    project.source.icon,
                    size: 13,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
