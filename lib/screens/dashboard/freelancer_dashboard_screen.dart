import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/dashboard_stats.dart';
import '../../models/project.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/freelancer_avatar.dart';
import '../../widgets/rating_widget.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';

/// Freelancer Dashboard (Week 8): headline statistics, quick actions into
/// the existing screens, and Reviews, Messages and Notifications sections.
///
/// Everything is computed from local (mock) data via [computeDashboardStats]
/// / [dashboardMessages] / [dashboardNotifications] — there is no backend.
class FreelancerDashboardScreen extends StatefulWidget {
  const FreelancerDashboardScreen({super.key});

  @override
  State<FreelancerDashboardScreen> createState() =>
      _FreelancerDashboardScreenState();
}

class _FreelancerDashboardScreenState extends State<FreelancerDashboardScreen> {
  // Keys stay stable across rebuilds so section scrolling keeps working.
  final GlobalKey _reviewsKey = GlobalKey();
  final GlobalKey _messagesKey = GlobalKey();
  final GlobalKey _notificationsKey = GlobalKey();

  void _push(String route) => Navigator.of(context).pushNamed(route);

  void _scrollTo(GlobalKey key) {
    final targetContext = key.currentContext;
    if (targetContext == null) return;
    Scrollable.ensureVisible(
      targetContext,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  void _openProject(Project project) => Navigator.of(
    context,
  ).pushNamed(AppRoutes.projectDetails, arguments: project);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final user = store.user.user;

    final stats = computeDashboardStats(
      projects: store.projects.getAll(),
      user: user,
      serviceCount: store.services.getAll().length,
    );
    final messages = dashboardMessages(store.projects.getAll());
    final notifications = dashboardNotifications(store.projects.getAll());

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxListWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              children: [
                // ─── Header: identity + rating ─────────────────────────
                Container(
                  padding: const EdgeInsets.all(AppConstants.spaceMd),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppConstants.radiusLg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      FreelancerAvatar(
                        name: user.name,
                        color: user.avatarColor,
                        radius: 30,
                      ),
                      const SizedBox(width: AppConstants.spaceMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppConstants.spaceXs),
                            InkWell(
                              onTap: () =>
                                  _push(AppRoutes.myFreelancerProfile),
                              child: RatingWidget(
                                rating: stats.averageRating,
                                reviewCount: stats.totalReviews,
                                size: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMuted,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),

                // ─── Statistics ───────────────────────────────────────
                SectionHeader(title: 'Overview'),
                const SizedBox(height: AppConstants.spaceSm),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppConstants.spaceSm,
                  crossAxisSpacing: AppConstants.spaceSm,
                  childAspectRatio: 1.9,
                  children: [
                    StatCard(
                      icon: Icons.timelapse_rounded,
                      value: '${stats.activeProjects}',
                      label: 'Active projects',
                      color: AppColors.info,
                    ),
                    StatCard(
                      icon: Icons.verified_rounded,
                      value: '${stats.completedProjects}',
                      label: 'Completed projects',
                      color: AppColors.success,
                    ),
                    StatCard(
                      icon: Icons.receipt_long_outlined,
                      value: '${stats.activeOrders}',
                      label: 'Active orders',
                      color: AppColors.accent,
                    ),
                    StatCard(
                      icon: Icons.shopping_bag_outlined,
                      value: '${stats.completedOrders}',
                      label: 'Completed orders',
                      color: AppColors.primary,
                    ),
                    StatCard(
                      icon: Icons.star_rounded,
                      value: stats.averageRating.toStringAsFixed(1),
                      label: 'Average rating',
                      color: AppColors.accent,
                    ),
                    StatCard(
                      icon: Icons.rate_review_outlined,
                      value: '${stats.totalReviews}',
                      label: 'Total reviews',
                      color: AppColors.primaryLight,
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceLg),

                // ─── Quick actions ────────────────────────────────────
                SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: AppConstants.spaceSm),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppConstants.spaceSm,
                  crossAxisSpacing: AppConstants.spaceSm,
                  childAspectRatio: 1.05,
                  children: [
                    _QuickActionTile(
                      icon: Icons.storefront_outlined,
                      label: 'Services',
                      count: stats.serviceCount,
                      onTap: () => _push(AppRoutes.myServices),
                    ),
                    _QuickActionTile(
                      icon: Icons.receipt_long_outlined,
                      label: 'Orders',
                      count: stats.totalOrders,
                      onTap: () => _push(AppRoutes.myOrders),
                    ),
                    _QuickActionTile(
                      icon: Icons.folder_open_rounded,
                      label: 'Projects',
                      count: stats.totalProjects,
                      onTap: () => _push(AppRoutes.myWork),
                    ),
                    _QuickActionTile(
                      icon: Icons.star_outline_rounded,
                      label: 'Reviews',
                      count: stats.totalReviews,
                      onTap: () => _scrollTo(_reviewsKey),
                    ),
                    _QuickActionTile(
                      icon: Icons.chat_bubble_outline_rounded,
                      label: 'Messages',
                      count: messages.length,
                      onTap: () => _scrollTo(_messagesKey),
                    ),
                    _QuickActionTile(
                      icon: Icons.notifications_none_rounded,
                      label: 'Notifications',
                      count: notifications.length,
                      onTap: () => _scrollTo(_notificationsKey),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spaceLg),

                // ─── Reviews & rating ─────────────────────────────────
                KeyedSubtree(
                  key: _reviewsKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'Reviews & Rating'),
                      const SizedBox(height: AppConstants.spaceSm),
                      if (stats.totalReviews == 0)
                        const EmptyState(
                          icon: Icons.star_border_rounded,
                          title: 'No reviews yet',
                          message:
                              'Your average rating shows here as soon as '
                              'clients review your delivered work.',
                        )
                      else
                        Card(
                          margin: EdgeInsets.zero,
                          child: Padding(
                            padding: const EdgeInsets.all(
                              AppConstants.spaceMd,
                            ),
                            child: Row(
                              children: [
                                RatingWidget(
                                  rating: stats.averageRating,
                                  reviewCount: stats.totalReviews,
                                  size: 20,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),

                // ─── Messages ─────────────────────────────────────────
                KeyedSubtree(
                  key: _messagesKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(
                        title: 'Messages',
                        subtitle: 'From your active projects and orders',
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
                      if (messages.isEmpty)
                        const EmptyState(
                          icon: Icons.chat_bubble_outline_rounded,
                          title: 'No messages yet',
                          message:
                              'Start an order or project and the '
                              'conversation with your client shows up here.',
                        )
                      else
                        Card(
                          margin: EdgeInsets.zero,
                          child: Column(
                            children: [
                              for (var i = 0; i < messages.length; i++) ...[
                                if (i > 0) const Divider(height: 1),
                                ListTile(
                                  leading: FreelancerAvatar(
                                    name: messages[i].name,
                                    color: messages[i]
                                        .project
                                        .counterpartyAvatarColor,
                                    radius: 20,
                                  ),
                                  title: Text(
                                    messages[i].name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${messages[i].roleLabel} • '
                                    '${messages[i].preview}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  trailing: const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.textMuted,
                                  ),
                                  onTap: () =>
                                      _openProject(messages[i].project),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spaceLg),

                // ─── Notifications ────────────────────────────────────
                KeyedSubtree(
                  key: _notificationsKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionHeader(title: 'Notifications'),
                      const SizedBox(height: AppConstants.spaceSm),
                      if (notifications.isEmpty)
                        const EmptyState(
                          icon: Icons.notifications_none_rounded,
                          title: 'No notifications',
                          message:
                              'Updates about your orders, projects and '
                              'payments appear here.',
                        )
                      else
                        Card(
                          margin: EdgeInsets.zero,
                          child: Column(
                            children: [
                              for (var i = 0;
                                  i < notifications.length;
                                  i++) ...[
                                if (i > 0) const Divider(height: 1),
                                ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(
                                      AppConstants.spaceSm,
                                    ),
                                    decoration: BoxDecoration(
                                      color: notifications[i]
                                          .color
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(
                                        AppConstants.radiusSm,
                                      ),
                                    ),
                                    child: Icon(
                                      notifications[i].icon,
                                      size: 20,
                                      color: notifications[i].color,
                                    ),
                                  ),
                                  title: Text(
                                    notifications[i].title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${notifications[i].body} • '
                                    '${AppConstants.timeAgo(notifications[i].timestamp)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  onTap: notifications[i].project == null
                                      ? null
                                      : () => _openProject(
                                            notifications[i].project!,
                                          ),
                                ),
                              ],
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.spaceXl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small tappable tile in the Quick Actions grid: icon, label and a count.
class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceSm),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 24, color: AppColors.primary),
              const SizedBox(height: AppConstants.spaceXs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium,
              ),
              Text(
                '$count',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
