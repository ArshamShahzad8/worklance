import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../models/project.dart';
import '../../widgets/fade_slide_animation.dart';
import '../../widgets/freelancer_avatar.dart';
import '../../widgets/milestone_tile.dart';
import '../../widgets/project_progress_bar.dart';
import '../../widgets/project_status_badge.dart';
import '../../widgets/status_timeline.dart';

/// Project Details: the hub for one order or contract.
class ProjectDetailsScreen extends StatelessWidget {
  const ProjectDetailsScreen({super.key, required this.project});

  final Project project;

  void _snack(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _start(BuildContext context, Project current) {
    AppScope.of(context).projects.start(current.id);
    _snack(context, 'Project started — good luck!');
  }

  void _openMilestones(BuildContext context, Project current) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.projectMilestones, arguments: current);
  }

  void _openSubmitDelivery(BuildContext context, Project current) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.submitDelivery, arguments: current);
  }

  Future<void> _approve(BuildContext context, Project current) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Approve delivery?'),
        content: Text(
          'This closes the project, releases the remaining '
          '${AppConstants.formatPrice(current.amount - current.releasedAmount)} '
          'and moves it to Completed Projects.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Not yet'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Approve'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      AppScope.of(context).completeProject(current.id);
      _snack(context, 'Project completed. Payment released.');
    }
  }

  Future<void> _requestRevision(BuildContext context, Project current) async {
    final controller = TextEditingController();
    try {
      final note = await showDialog<String>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Request a revision'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tell the freelancer what still needs work. The project '
                'goes back to In Progress.',
              ),
              const SizedBox(height: AppConstants.spaceMd),
              TextField(
                controller: controller,
                autofocus: true,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: 'e.g. the logo needs more spacing',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(dialogContext).pop(controller.text.trim()),
              child: const Text('Send'),
            ),
          ],
        ),
      );

      if (note == null || !context.mounted) return;
      if (note.isEmpty) {
        _snack(context, 'Add a short note so the freelancer knows what to fix.');
        return;
      }
      AppScope.of(context).projects.requestRevision(current.id, note);
      _snack(context, 'Revision requested.');
    } finally {
      controller.dispose();
    }
  }

  Future<void> _cancel(BuildContext context, Project current) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel this project?'),
        content: const Text(
          'It moves to Completed Projects marked as cancelled. This cannot '
          'be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Keep it'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Cancel project'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      AppScope.of(context).projects.cancel(
        current.id,
        reason: current.role == ProjectRole.client
            ? 'Cancelled by the client.'
            : 'Cancelled by the freelancer.',
      );
      _snack(context, 'Project cancelled.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Project details'),
        actions: [
          ListenableBuilder(
            listenable: store.projects,
            builder: (context, _) {
              final current = store.projects.getById(project.id) ?? project;
              if (!current.status.canCancel) return const SizedBox.shrink();
              return PopupMenuButton<String>(
                tooltip: 'More',
                onSelected: (value) {
                  if (value == 'cancel') _cancel(context, current);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'cancel',
                    child: Text('Cancel project'),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: store.projects,
        builder: (context, _) {
          final current = store.projects.getById(project.id) ?? project;
          return _DetailBody(
            project: current,
            onViewMilestones: () => _openMilestones(context, current),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: store.projects,
          builder: (context, _) {
            final current = store.projects.getById(project.id) ?? project;
            return _ActionBar(
              project: current,
              onStart: () => _start(context, current),
              onSubmitDelivery: () => _openSubmitDelivery(context, current),
              onApprove: () => _approve(context, current),
              onRequestRevision: () => _requestRevision(context, current),
              onViewMilestones: () => _openMilestones(context, current),
            );
          },
        ),
      ),
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.project, required this.onViewMilestones});

  final Project project;
  final VoidCallback onViewMilestones;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewMilestones = project.milestones.take(3).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceMd,
        AppConstants.spaceMd,
        AppConstants.spaceMd,
        AppConstants.spaceXl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: AppConstants.maxListWidth,
          ),
          child: FadeSlideAnimation(
            index: 0,
            duration: const Duration(milliseconds: 350),
            slideOffset: 12.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatusCard(project: project),
                const SizedBox(height: AppConstants.spaceLg),

                Text(project.title, style: theme.textTheme.headlineSmall),
                const SizedBox(height: AppConstants.spaceSm),
                Row(
                  children: [
                    Icon(
                      project.category.icon,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        project.category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Icon(
                      project.source.icon,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        project.source.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceLg),

                _PartiesCard(project: project),
                const SizedBox(height: AppConstants.spaceLg),

                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Contract value',
                        value: AppConstants.formatPrice(project.amount),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.payments_outlined,
                        label: 'Released',
                        value: AppConstants.formatPrice(
                          project.releasedAmount,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceMd),
                Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.play_arrow_rounded,
                        label: 'Started',
                        value: AppConstants.formatShortDate(project.createdAt),
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.flag_outlined,
                        label: project.status == ProjectStatus.completed
                            ? 'Completed'
                            : 'Due',
                        value: project.status == ProjectStatus.completed &&
                                project.completedAt != null
                            ? AppConstants.formatShortDate(
                                project.completedAt!,
                              )
                            : AppConstants.formatShortDate(project.dueDate),
                        highlight: project.isOverdue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceLg),

                Text('Scope', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppConstants.spaceSm),
                Text(project.description, style: theme.textTheme.bodyMedium),
                const SizedBox(height: AppConstants.spaceLg),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Milestones',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    if (project.milestones.isNotEmpty)
                      TextButton(
                        onPressed: onViewMilestones,
                        child: const Text('View all'),
                      ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceSm),
                if (project.milestones.isEmpty)
                  _MutedNote(
                    icon: Icons.checklist_rtl_rounded,
                    text:
                        'This project has no milestone plan — progress '
                        'follows its status instead.',
                  )
                else
                  for (var i = 0; i < previewMilestones.length; i++)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.spaceSm,
                      ),
                      child: MilestoneTile(
                        milestone: previewMilestones[i],
                        index: i,
                        showDescription: false,
                      ),
                    ),
                const SizedBox(height: AppConstants.spaceLg),

                if (project.deliveries.isNotEmpty) ...[
                  Text('Deliveries', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppConstants.spaceSm),
                  for (final delivery in project.deliveries.reversed)
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppConstants.spaceSm,
                      ),
                      child: _DeliveryCard(delivery: delivery),
                    ),
                  const SizedBox(height: AppConstants.spaceLg),
                ],

                Text('Status timeline', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppConstants.spaceMd),
                StatusTimeline.fromProjectEvents(
                  events: project.statusHistory,
                ),

                _DemoControlsCard(project: project),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: project.status.color.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Column(
          children: [
            ProjectStatusBadge(status: project.status, large: true),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              project.status.description,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (project.status != ProjectStatus.cancelled) ...[
              const SizedBox(height: AppConstants.spaceLg),
              ProjectProgressBar(project: project),
              const SizedBox(height: AppConstants.spaceSm),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    project.isOverdue
                        ? Icons.warning_amber_rounded
                        : Icons.schedule_rounded,
                    size: 14,
                    color: project.isOverdue
                        ? AppColors.error
                        : AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    project.dueLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: project.isOverdue
                          ? AppColors.error
                          : AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PartiesCard extends StatelessWidget {
  const _PartiesCard({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final userIsClient = project.role == ProjectRole.client;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          children: [
            _PartyRow(
              name: userIsClient ? 'You' : project.clientName,
              roleLabel: 'Client',
              color: project.clientAvatarColor,
              isCurrentUser: userIsClient,
            ),
            const Divider(height: AppConstants.spaceLg),
            _PartyRow(
              name: userIsClient ? project.freelancerName : 'You',
              roleLabel: userIsClient ? project.freelancerTitle : 'Freelancer',
              color: project.freelancerAvatarColor,
              isCurrentUser: !userIsClient,
            ),
          ],
        ),
      ),
    );
  }
}

class _PartyRow extends StatelessWidget {
  const _PartyRow({
    required this.name,
    required this.roleLabel,
    required this.color,
    required this.isCurrentUser,
  });

  final String name;
  final String roleLabel;
  final Color color;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        FreelancerAvatar(name: name, color: color, radius: 18),
        const SizedBox(width: AppConstants.spaceSm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
              Text(
                roleLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
        if (isCurrentUser)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              'You',
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  const _DeliveryCard({required this.delivery});

  final ProjectDelivery delivery;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.upload_file_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    delivery.isRevision
                        ? 'Revision ${delivery.revisionNumber - 1}'
                        : 'Initial delivery',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                Text(
                  AppConstants.formatShortDate(delivery.submittedAt),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(delivery.message, style: theme.textTheme.bodyMedium),
            if (delivery.attachments.isNotEmpty) ...[
              const SizedBox(height: AppConstants.spaceSm),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final attachment in delivery.attachments)
                    Chip(
                      avatar: const Icon(Icons.attach_file_rounded, size: 14),
                      label: Text(attachment),
                    ),
                ],
              ),
            ],
            if (delivery.revisionNote != null) ...[
              const SizedBox(height: AppConstants.spaceSm),
              Container(
                padding: const EdgeInsets.all(AppConstants.spaceSm),
                decoration: BoxDecoration(
                  color: AppColors.accentContainer,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.feedback_outlined, size: 15, color: AppColors.onAccent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Revision requested: ${delivery.revisionNote}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MutedNote extends StatelessWidget {
  const _MutedNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Text(
              text,
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

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              color: highlight ? AppColors.error : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.project,
    required this.onStart,
    required this.onSubmitDelivery,
    required this.onApprove,
    required this.onRequestRevision,
    required this.onViewMilestones,
  });

  final Project project;
  final VoidCallback onStart;
  final VoidCallback onSubmitDelivery;
  final VoidCallback onApprove;
  final VoidCallback onRequestRevision;
  final VoidCallback onViewMilestones;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFreelancer = project.role == ProjectRole.freelancer;

    final Widget content = switch (project.status) {
      ProjectStatus.pending => isFreelancer
            ? FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Start Project'),
              )
            : _WaitingNote(
                icon: Icons.schedule_rounded,
                text:
                    '${project.freelancerName} has not started this order yet.',
              ),
      ProjectStatus.active => isFreelancer
            ? Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewMilestones,
                      icon: const Icon(Icons.checklist_rounded, size: 18),
                      label: const Text('Milestones'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceMd),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onSubmitDelivery,
                      icon: const Icon(Icons.upload_rounded, size: 18),
                      label: const Text('Deliver'),
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewMilestones,
                      icon: const Icon(Icons.checklist_rounded, size: 18),
                      label: const Text('Milestones'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceMd),
                  Expanded(
                    child: _WaitingNote(
                      icon: Icons.hourglass_bottom_rounded,
                      text: 'Work in progress.',
                    ),
                  ),
                ],
              ),
      ProjectStatus.submitted => isFreelancer
            ? _WaitingNote(
                icon: Icons.hourglass_bottom_rounded,
                text:
                    'Delivered. Waiting for ${project.clientName} to review.',
              )
            : Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: onRequestRevision,
                      child: const Text('Request revision'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceMd),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                      ),
                      onPressed: onApprove,
                      child: const Text('Approve'),
                    ),
                  ),
                ],
              ),
      ProjectStatus.completed => Row(
          children: [
            Icon(Icons.verified_rounded, size: 20, color: AppColors.success),
            const SizedBox(width: AppConstants.spaceSm),
            Expanded(
              child: Text(
                'Completed — ${AppConstants.formatPrice(project.amount)} released.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ProjectStatus.cancelled => _WaitingNote(
          icon: Icons.cancel_outlined,
          text: 'This project was cancelled.',
        ),
    };

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: content,
    );
  }
}

class _WaitingNote extends StatelessWidget {
  const _WaitingNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: AppConstants.spaceSm),
        Expanded(
          child: Text(
            text,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _DemoControlsCard extends StatelessWidget {
  const _DemoControlsCard({required this.project});

  final Project project;

  void _simulate(BuildContext context, VoidCallback action, String message) {
    action();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final isFreelancer = project.role == ProjectRole.freelancer;

    final buttons = <Widget>[];

    if (!isFreelancer && project.status == ProjectStatus.pending) {
      buttons.add(
        FilledButton.icon(
          onPressed: () => _simulate(
            context,
            () => store.projects.start(
              project.id,
              note: 'Simulated: the freelancer started work (demo only).',
            ),
            '${project.freelancerName} started the work.',
          ),
          icon: const Icon(Icons.play_arrow_rounded, size: 18),
          label: const Text('Simulate: freelancer starts'),
        ),
      );
    }

    if (!isFreelancer && project.status == ProjectStatus.active) {
      buttons.add(
        FilledButton.icon(
          onPressed: () => _simulate(
            context,
            () => store.projects.submitDelivery(
              project.id,
              message:
                  'Simulated delivery (demo only) — the finished files for '
                  '"${project.title}" are attached for your review.',
              attachments: const ['delivery-files.zip'],
            ),
            'Delivery received — review and approve it.',
          ),
          icon: const Icon(Icons.upload_rounded, size: 18),
          label: const Text('Simulate: freelancer delivers'),
        ),
      );
    }

    if (isFreelancer && project.status == ProjectStatus.submitted) {
      buttons.addAll([
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: AppColors.success),
          onPressed: () => _simulate(
            context,
            () => store.completeProject(
              project.id,
              note: 'Simulated: the client approved the delivery (demo only).',
            ),
            'Client approved — project completed.',
          ),
          icon: const Icon(Icons.check_rounded, size: 18),
          label: const Text('Simulate: client approves'),
        ),
        OutlinedButton.icon(
          onPressed: () => _simulate(
            context,
            () => store.projects.requestRevision(
              project.id,
              'Simulated client feedback (demo only) — please tighten up '
              'the final pass.',
            ),
            'Client asked for a revision.',
          ),
          icon: const Icon(Icons.replay_rounded, size: 18),
          label: const Text('Simulate: revision request'),
        ),
      ]);
    }

    if (buttons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppConstants.spaceMd),
      child: Card(
        color: AppColors.accentContainer,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.science_outlined, size: 18, color: AppColors.onAccent),
                  const SizedBox(width: 6),
                  Text(
                    'Demo Controls',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: AppColors.onAccent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'This is a local demo — there is no real '
                '${isFreelancer ? 'client' : 'freelancer'} on the other end. '
                'Use these buttons to play out their side of the workflow.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              Wrap(spacing: 8, runSpacing: 8, children: buttons),
            ],
          ),
        ),
      ),
    );
  }
}
