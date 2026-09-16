import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../models/order.dart';
import '../../widgets/fade_slide_animation.dart';
import '../../widgets/freelancer_avatar.dart';
import '../../widgets/order_status_badge.dart';
import '../../widgets/project_progress_bar.dart';

/// Project Details screen: the full picture of one order/contract — who's
/// involved, the budget and deadline, its current status, an overall
/// progress section, and the actions available at each stage of the
/// Week 5 workflow (Start Project → Submit Delivery → Completed).
class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.order});

  final Order order;

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Project Details')),
      body: ListenableBuilder(
        listenable: store.orders,
        builder: (context, _) {
          // Always read the freshest copy so status/milestone changes made
          // on other screens (Milestones, Delivery) reflect immediately.
          final current = store.orders.getById(order.id) ?? order;
          final job = current.job;
          final client = job.client;

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
                          OrderStatusBadge(status: current.status, large: true),
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

                  Text(job.title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: AppConstants.spaceMd),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spaceMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Client', style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.textMuted,
                          )),
                          const SizedBox(height: AppConstants.spaceSm),
                          Row(
                            children: [
                              FreelancerAvatar(
                                name: client.name,
                                color: client.avatarColor,
                                radius: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(client.name, style: theme.textTheme.titleSmall),
                                    Text(
                                      client.location,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spaceMd),
                          const Divider(height: 1),
                          const SizedBox(height: AppConstants.spaceMd),
                          Text('Freelancer', style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.textMuted,
                          )),
                          const SizedBox(height: AppConstants.spaceSm),
                          Row(
                            children: [
                              FreelancerAvatar(
                                name: current.freelancerName,
                                color: current.freelancerAvatarColor,
                                radius: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  current.freelancerName,
                                  style: theme.textTheme.titleSmall,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceMd),

                  Row(
                    children: [
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.attach_money_rounded,
                          label: 'Budget',
                          value: AppConstants.formatPrice(current.budget),
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceMd),
                      Expanded(
                        child: _InfoCard(
                          icon: Icons.event_outlined,
                          label: 'Deadline',
                          value: _formatDate(current.deadline),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceLg),

                  Text('Progress', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppConstants.spaceSm),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spaceMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ProjectProgressBar(
                            progress: current.progress,
                            color: current.status.color,
                          ),
                          const SizedBox(height: AppConstants.spaceMd),
                          Row(
                            children: [
                              Icon(Icons.flag_outlined, size: 16, color: AppColors.textMuted),
                              const SizedBox(width: 6),
                              Text(
                                '${current.completedMilestonesCount} of '
                                '${current.milestones.length} milestones complete',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const Spacer(),
                              TextButton(
                                onPressed: () => Navigator.of(context).pushNamed(
                                  AppRoutes.milestones,
                                  arguments: current,
                                ),
                                child: const Text('View Milestones'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (current.deliveryNote != null) ...[
                    const SizedBox(height: AppConstants.spaceLg),
                    Text('Delivery', style: theme.textTheme.titleSmall),
                    const SizedBox(height: AppConstants.spaceSm),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppConstants.spaceMd),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (current.deliveredAt != null)
                              Text(
                                'Submitted ${_formatDate(current.deliveredAt!)}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.textMuted,
                                ),
                              ),
                            const SizedBox(height: 4),
                            Text(current.deliveryNote!, style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppConstants.spaceLg),
                  ..._buildActions(context, current),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, Order current) {
    final store = AppScope.of(context);

    switch (current.status) {
      case OrderStatus.accepted:
        return [
          FilledButton.icon(
            onPressed: () => store.orders.updateStatus(
              current.id,
              OrderStatus.active,
              note: 'Project started.',
            ),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start Project'),
          ),
        ];
      case OrderStatus.active:
        return [
          FilledButton.icon(
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.delivery,
              arguments: current,
            ),
            icon: const Icon(Icons.upload_file_rounded),
            label: const Text('Submit Delivery'),
          ),
        ];
      case OrderStatus.submitted:
        return [_DemoCompleteCard(order: current)];
      case OrderStatus.completed:
        return [];
    }
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 2),
            Text(value, style: theme.textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}

/// Clearly-labeled local demo control that lets the user simulate the
/// client approving delivered work, mirroring the pattern used on the
/// Proposal Status screen for simulating a client's response.
class _DemoCompleteCard extends StatelessWidget {
  const _DemoCompleteCard({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);

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
                  style: theme.textTheme.titleSmall?.copyWith(color: AppColors.onAccent),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'This is a local demo — no real client is reviewing this '
              'delivery. Use this button to simulate the client approving '
              'the work and closing out the project.',
              style: theme.textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: AppColors.success),
              onPressed: () => store.orders.updateStatus(
                order.id,
                OrderStatus.completed,
                note: 'Simulated: client approved delivery (demo only).',
              ),
              icon: const Icon(Icons.check_rounded, size: 18),
              label: const Text('Simulate: Client Approves & Completes'),
            ),
          ],
        ),
      ),
    );
  }
}
