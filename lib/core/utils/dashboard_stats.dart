import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../models/user.dart';
import '../theme/app_colors.dart';

/// Headline statistics for the Freelancer Dashboard.
///
/// All numbers are computed from the app's local (mock) project data and
/// the current [UserProfile] — there is no backend to ask.
class DashboardStats {
  const DashboardStats({
    required this.activeProjects,
    required this.completedProjects,
    required this.activeOrders,
    required this.completedOrders,
    required this.averageRating,
    required this.totalReviews,
    required this.serviceCount,
  });

  /// Freelancer-role projects that are still open (pending/active/delivered).
  final int activeProjects;

  /// Freelancer-role projects with status `completed`.
  final int completedProjects;

  /// Client-role orders that are still open.
  final int activeOrders;

  /// Client-role orders with status `completed`.
  final int completedOrders;

  /// Average rating from the user profile (no per-review data exists locally).
  final double averageRating;

  /// Total reviews from the user profile.
  final int totalReviews;

  /// Services the user has listed.
  final int serviceCount;

  int get totalProjects => activeProjects + completedProjects;
  int get totalOrders => activeOrders + completedOrders;
}

/// Calculates [DashboardStats] from [projects] (any role/status mix) and
/// the logged-in [user].
DashboardStats computeDashboardStats({
  required List<Project> projects,
  required UserProfile user,
  int serviceCount = 0,
}) {
  var activeProjects = 0;
  var completedProjects = 0;
  var activeOrders = 0;
  var completedOrders = 0;

  for (final project in projects) {
    final isOrder = project.role == ProjectRole.client;
    if (project.status.isOpen) {
      if (isOrder) {
        activeOrders++;
      } else {
        activeProjects++;
      }
    } else if (project.status == ProjectStatus.completed) {
      if (isOrder) {
        completedOrders++;
      } else {
        completedProjects++;
      }
    }
  }

  return DashboardStats(
    activeProjects: activeProjects,
    completedProjects: completedProjects,
    activeOrders: activeOrders,
    completedOrders: completedOrders,
    averageRating: user.rating,
    totalReviews: user.reviewCount,
    serviceCount: serviceCount,
  );
}

/// One conversation on the dashboard, derived from an open project.
///
/// Messaging is not implemented yet (it lands in a later week), so the
/// dashboard shows a conversation per active project/order instead — this
/// keeps the item meaningful using only local data.
class DashboardMessage {
  const DashboardMessage({
    required this.name,
    required this.roleLabel,
    required this.preview,
    required this.project,
  });

  final String name;
  final String roleLabel;
  final String preview;
  final Project project;
}

/// Recent conversations for open projects, newest first.
List<DashboardMessage> dashboardMessages(List<Project> projects) {
  final open = projects.where((p) => p.status.isOpen).toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  return [
    for (final project in open.take(6))
      DashboardMessage(
        name: project.counterpartyName,
        roleLabel: project.counterpartyRoleLabel,
        preview: project.title,
        project: project,
      ),
  ];
}

/// One notification on the dashboard, derived from project state changes.
class DashboardNotification {
  const DashboardNotification({
    required this.title,
    required this.body,
    required this.icon,
    required this.color,
    required this.timestamp,
    this.project,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color color;
  final DateTime timestamp;
  final Project? project;
}

/// Notifications derived from every project's current status, most recent
/// status change first. Returns at most [limit] entries.
List<DashboardNotification> dashboardNotifications(
  List<Project> projects, {
  int limit = 8,
}) {
  final entries = <DashboardNotification>[];

  for (final project in projects) {
    final (title, icon, color) = switch (project.status) {
      ProjectStatus.completed => (
        'Payment released',
        Icons.verified_rounded,
        AppColors.success,
      ),
      ProjectStatus.submitted => (
        project.role == ProjectRole.freelancer
            ? 'Delivery awaiting review'
            : 'Delivery ready to review',
        Icons.local_shipping_outlined,
        AppColors.primary,
      ),
      ProjectStatus.active => (
        'Work in progress',
        Icons.play_circle_outline_rounded,
        AppColors.info,
      ),
      ProjectStatus.pending => (
        'Waiting to start',
        Icons.schedule_rounded,
        AppColors.accent,
      ),
      ProjectStatus.cancelled => (
        'Project cancelled',
        Icons.cancel_outlined,
        AppColors.textMuted,
      ),
    };

    entries.add(
      DashboardNotification(
        title: title,
        body: project.title,
        icon: icon,
        color: color,
        timestamp: project.statusHistory.last.timestamp,
        project: project,
      ),
    );
  }

  entries.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return entries.take(limit).toList();
}
