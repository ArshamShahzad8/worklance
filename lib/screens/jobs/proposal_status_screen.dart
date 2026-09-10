import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../models/proposal.dart';
import '../../widgets/fade_slide_animation.dart';
import '../../widgets/proposal_status_badge.dart';
import '../../widgets/status_timeline.dart';

/// Proposal Status screen: shows a proposal's current status, its full
/// timeline, job/proposal details, and (clearly labeled) local demo
/// controls to move the status forward since there is no real client
/// reviewing anything yet.
class ProposalStatusScreen extends StatelessWidget {
  const ProposalStatusScreen({super.key, required this.proposal});

  final Proposal proposal;

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _confirmWithdraw(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Withdraw proposal?'),
        content: const Text(
          'You will no longer be considered for this job. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Withdraw'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      AppScope.of(context).proposals.withdraw(proposal.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Proposal withdrawn')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Proposal Status')),
      body: ListenableBuilder(
        listenable: store.proposals,
        builder: (context, _) {
          // Always read the freshest copy so status changes reflect
          // immediately, even though the route was pushed with a snapshot.
          final current = store.proposals.getById(proposal.id) ?? proposal;
          final job = current.job;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            child: FadeSlideAnimation(
              index: 0,
              duration: const Duration(milliseconds: 350),
              slideOffset: 12.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: current.status.color.withValues(alpha: 0.08),
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spaceLg),
                      child: Column(
                        children: [
                          ProposalStatusBadge(status: current.status, large: true),
                          const SizedBox(height: AppConstants.spaceSm),
                          Text(
                            current.status.description,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),

                  Text('Job', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppConstants.spaceSm),
                  Card(
                    child: ListTile(
                      title: Text(job.title, maxLines: 2, overflow: TextOverflow.ellipsis),
                      subtitle: Text('${job.client.name} · ${job.budgetLabel}'),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => Navigator.of(context).pushNamed(
                        AppRoutes.jobDetails,
                        arguments: job,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),

                  Text('Your proposal', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppConstants.spaceSm),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spaceMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _DetailStat(
                                  label: 'Proposed amount',
                                  value: AppConstants.formatPrice(
                                    current.proposedAmount,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: _DetailStat(
                                  label: 'Submitted',
                                  value: _formatDate(current.submittedAt),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spaceSm),
                          _DetailStat(
                            label: 'Estimated duration',
                            value: current.estimatedDuration,
                          ),
                          const SizedBox(height: AppConstants.spaceMd),
                          const Divider(height: 1),
                          const SizedBox(height: AppConstants.spaceMd),
                          Text(
                            'Cover letter',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(current.coverLetter, style: theme.textTheme.bodyMedium),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),

                  Text('Status timeline', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppConstants.spaceMd),
                  StatusTimeline(events: current.statusHistory),

                  if (current.status.canWithdraw) ...[
                    const SizedBox(height: AppConstants.spaceSm),
                    OutlinedButton.icon(
                      onPressed: () => _confirmWithdraw(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.error,
                        side: const BorderSide(color: AppColors.error),
                      ),
                      icon: const Icon(Icons.undo_rounded),
                      label: const Text('Withdraw Proposal'),
                    ),
                  ],

                  if (!current.status.isFinal) ...[
                    const SizedBox(height: AppConstants.spaceLg),
                    _DemoControlsCard(proposal: current),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DetailStat extends StatelessWidget {
  const _DetailStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
        ),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.titleSmall),
      ],
    );
  }
}

/// Clearly-labeled local demo controls that let the user simulate a
/// client's response, since this app has no real client on the other end.
class _DemoControlsCard extends StatelessWidget {
  const _DemoControlsCard({required this.proposal});

  final Proposal proposal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);

    ProposalStatus? nextStep;
    switch (proposal.status) {
      case ProposalStatus.submitted:
        nextStep = ProposalStatus.underReview;
      case ProposalStatus.underReview:
        nextStep = ProposalStatus.shortlisted;
      case ProposalStatus.shortlisted:
      case ProposalStatus.accepted:
      case ProposalStatus.rejected:
      case ProposalStatus.withdrawn:
        nextStep = null;
    }

    return Card(
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
              'This is a local demo — no real client is reviewing this '
              'proposal. Use these buttons to simulate how a client '
              "response would update your proposal's status.",
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (nextStep != null)
                  FilledButton.icon(
                    onPressed: () => store.proposals.updateStatus(
                      proposal.id,
                      nextStep!,
                      note: 'Simulated: moved to ${nextStep.label} (demo only).',
                    ),
                    icon: Icon(nextStep.icon, size: 18),
                    label: Text('Simulate: ${nextStep.label}'),
                  ),
                if (proposal.status == ProposalStatus.shortlisted) ...[
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: AppColors.success),
                    onPressed: () => store.proposals.updateStatus(
                      proposal.id,
                      ProposalStatus.accepted,
                      note: 'Simulated: client accepted (demo only).',
                    ),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: const Text('Simulate: Accept'),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                    onPressed: () => store.proposals.updateStatus(
                      proposal.id,
                      ProposalStatus.rejected,
                      note: 'Simulated: client rejected (demo only).',
                    ),
                    icon: const Icon(Icons.close_rounded, size: 18),
                    label: const Text('Simulate: Reject'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
