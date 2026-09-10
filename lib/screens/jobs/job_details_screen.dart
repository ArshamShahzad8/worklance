import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../models/job.dart';
import '../../widgets/fade_slide_animation.dart';
import '../../widgets/freelancer_avatar.dart';
import '../../widgets/proposal_status_badge.dart';
import '../../widgets/save_toggle_button.dart';

/// Job Details screen: everything a freelancer needs to decide whether to
/// apply, plus the Submit Proposal action (or an already-applied state).
class JobDetailsScreen extends StatelessWidget {
  const JobDetailsScreen({super.key, required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final client = job.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job details'),
        actions: [
          SaveToggleButton(
            favorites: store.favorites,
            itemId: job.id,
            savedTooltip: 'Remove from saved jobs',
            unsavedTooltip: 'Save job',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: store.proposals,
        builder: (context, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 120),
            child: FadeSlideAnimation(
              index: 0,
              duration: const Duration(milliseconds: 400),
              slideOffset: 12.0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppConstants.spaceMd,
                      AppConstants.spaceMd,
                      AppConstants.spaceMd,
                      0,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(
                              AppConstants.radiusSm,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                job.category.icon,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                job.category.name,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          AppConstants.timeAgo(job.postedAt),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceMd,
                    ),
                    child: Text(job.title, style: theme.textTheme.headlineSmall),
                  ),
                  const SizedBox(height: AppConstants.spaceSm),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceMd,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(job.location, style: theme.textTheme.bodySmall),
                        const SizedBox(width: AppConstants.spaceMd),
                        Icon(
                          Icons.description_outlined,
                          size: 15,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${job.proposalsCount} proposals',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceMd,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.payments_outlined,
                            label: job.budgetType.label,
                            value: job.budgetLabel,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceMd),
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.schedule_rounded,
                            label: 'Duration',
                            value: job.duration,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceMd,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.bar_chart_rounded,
                            label: 'Experience',
                            value: job.experienceLevel.label,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceMd),
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.people_outline_rounded,
                            label: 'Proposals',
                            value: '${job.proposalsCount}',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),
                  _Section(
                    title: 'Job description',
                    child: Text(job.description, style: theme.textTheme.bodyLarge),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),
                  _Section(
                    title: 'Skills & expertise',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final skill in job.skills) Chip(label: Text(skill)),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceMd,
                    ),
                    child: Text('About the client', style: theme.textTheme.titleMedium),
                  ),
                  const SizedBox(height: AppConstants.spaceSm),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.spaceMd,
                    ),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spaceMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                FreelancerAvatar(
                                  name: client.name,
                                  color: client.avatarColor,
                                  radius: 22,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              client.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: theme.textTheme.titleSmall,
                                            ),
                                          ),
                                          if (client.paymentVerified) ...[
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.verified_rounded,
                                              size: 15,
                                              color: AppColors.info,
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        client.location,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.spaceMd),
                            const Divider(height: 1),
                            const SizedBox(height: AppConstants.spaceMd),
                            Row(
                              children: [
                                Expanded(
                                  child: _ClientStat(
                                    icon: Icons.star_rounded,
                                    value: client.rating.toStringAsFixed(1),
                                    label: '${client.reviewCount} reviews',
                                  ),
                                ),
                                Expanded(
                                  child: _ClientStat(
                                    icon: Icons.work_outline_rounded,
                                    value: '${client.jobsPosted}',
                                    label: 'jobs posted',
                                  ),
                                ),
                                Expanded(
                                  child: _ClientStat(
                                    icon: Icons.account_balance_wallet_outlined,
                                    value: AppConstants.formatPrice(client.totalSpent),
                                    label: 'total spent',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppConstants.spaceSm),
                            Text(
                              client.memberSince,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: ListenableBuilder(
          listenable: store.proposals,
          builder: (context, _) {
            final existingProposal = store.proposals.getByJobId(job.id);
            return Container(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: existingProposal == null
                  ? FilledButton.icon(
                      onPressed: () => Navigator.of(context).pushNamed(
                        AppRoutes.submitProposal,
                        arguments: job,
                      ),
                      icon: const Icon(Icons.send_rounded),
                      label: const Text('Submit Proposal'),
                    )
                  : Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.success,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'You already applied to this job',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ProposalStatusBadge(status: existingProposal.status),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () => Navigator.of(context).pushNamed(
                            AppRoutes.proposalStatus,
                            arguments: existingProposal,
                          ),
                          child: const Text('View'),
                        ),
                      ],
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppConstants.spaceSm),
          child,
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

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
            style: theme.textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}

class _ClientStat extends StatelessWidget {
  const _ClientStat({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 16, color: AppColors.accent),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
