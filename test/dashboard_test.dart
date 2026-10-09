import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:worklance/core/utils/dashboard_stats.dart';
import 'package:worklance/models/category.dart';
import 'package:worklance/models/project.dart';
import 'package:worklance/models/user.dart';
import 'package:worklance/screens/dashboard/freelancer_dashboard_screen.dart';

import 'widget_test.dart' show login, navLabel;

/// The dashboard's scrollable (its ListView builds sections lazily).
Finder dashboardScrollable() => find
    .descendant(
      of: find.byType(FreelancerDashboardScreen),
      matching: find.byType(Scrollable),
    )
    .first;

/// Drags the dashboard down until [target] is built (lazy ListView).
Future<void> scrollDashboardUntil(
  WidgetTester tester,
  Finder target,
) async {
  final scrollable = dashboardScrollable();
  for (var i = 0; i < 25 && target.evaluate().isEmpty; i++) {
    await tester.drag(scrollable, const Offset(0, -240));
    await tester.pumpAndSettle();
  }
}

Project makeProject({
  required String id,
  required ProjectRole role,
  ProjectStatus status = ProjectStatus.active,
  DateTime? createdAt,
}) => Project(
  id: id,
  title: 'Title $id',
  description: 'Description $id',
  role: role,
  source: ProjectSource.serviceOrder,
  category: const Category(
    id: 'c_web',
    name: 'Web Development',
    icon: Icons.code_rounded,
    description: 'Web work',
  ),
  amount: 100,
  createdAt: createdAt ?? DateTime(2026, 1, 1),
  dueDate: DateTime(2026, 3, 1),
  freelancerName: 'Freelancer $id',
  freelancerTitle: 'Developer',
  freelancerAvatarColor: Colors.indigo,
  clientName: 'Client $id',
  clientAvatarColor: Colors.blue,
  status: status,
);

const testUser = UserProfile(
  name: 'Test User',
  email: 'test@worklance.app',
  rating: 4.5,
  reviewCount: 12,
);

/// Dashboard-scoped finder — the shell's NavigationBar and the Profile
/// screen below the pushed route contain colliding texts.
Finder inDashboard(Finder matching) => find.descendant(
  of: find.byType(FreelancerDashboardScreen),
  matching: matching,
);

void main() {
  group('computeDashboardStats', () {
    test('splits active/completed projects and orders by role', () {
      final projects = [
        makeProject(id: 'p1', role: ProjectRole.freelancer),
        makeProject(
          id: 'p2',
          role: ProjectRole.freelancer,
          status: ProjectStatus.submitted,
        ),
        makeProject(
          id: 'p3',
          role: ProjectRole.freelancer,
          status: ProjectStatus.completed,
        ),
        makeProject(
          id: 'p4',
          role: ProjectRole.freelancer,
          status: ProjectStatus.cancelled,
        ),
        makeProject(id: 'o1', role: ProjectRole.client),
        makeProject(
          id: 'o2',
          role: ProjectRole.client,
          status: ProjectStatus.completed,
        ),
      ];

      final stats = computeDashboardStats(
        projects: projects,
        user: testUser,
        serviceCount: 3,
      );

      expect(stats.activeProjects, 2); // p1 + p2 (cancelled excluded)
      expect(stats.completedProjects, 1);
      expect(stats.activeOrders, 1);
      expect(stats.completedOrders, 1);
      expect(stats.totalProjects, 3);
      expect(stats.totalOrders, 2);
      expect(stats.averageRating, 4.5);
      expect(stats.totalReviews, 12);
      expect(stats.serviceCount, 3);
    });

    test('uses the user profile for rating and review totals', () {
      const user = UserProfile(
        name: 'No Reviews',
        email: 'a@b.co',
        rating: 5.0,
        reviewCount: 0,
      );
      final stats = computeDashboardStats(projects: const [], user: user);

      expect(stats.averageRating, 5.0);
      expect(stats.totalReviews, 0);
      expect(stats.activeProjects, 0);
      expect(stats.completedProjects, 0);
      expect(stats.activeOrders, 0);
      expect(stats.completedOrders, 0);
    });
  });

  group('dashboardMessages', () {
    test('only includes open projects, newest first, capped at 6', () {
      final projects = [
        makeProject(
          id: 'old',
          role: ProjectRole.client,
          createdAt: DateTime(2026, 1, 1),
        ),
        makeProject(
          id: 'done',
          role: ProjectRole.freelancer,
          status: ProjectStatus.completed,
          createdAt: DateTime(2026, 1, 5),
        ),
        makeProject(
          id: 'new',
          role: ProjectRole.freelancer,
          createdAt: DateTime(2026, 1, 10),
        ),
      ];

      final messages = dashboardMessages(projects);

      expect(messages, hasLength(2));
      expect(messages.first.project.id, 'new');
      expect(messages.last.project.id, 'old');
      expect(messages.first.name, 'Client new');
      expect(messages.first.roleLabel, 'Client');
    });
  });

  group('dashboardNotifications', () {
    test('maps project status to notification copy and sorts newest first', () {
      final projects = [
        makeProject(
          id: 'finished',
          role: ProjectRole.freelancer,
          status: ProjectStatus.completed,
          createdAt: DateTime(2026, 1, 1),
        ),
        makeProject(
          id: 'running',
          role: ProjectRole.freelancer,
          createdAt: DateTime(2026, 1, 8),
        ),
      ];

      final notifications = dashboardNotifications(projects);

      expect(notifications, hasLength(2));
      expect(notifications.first.title, 'Work in progress');
      expect(notifications.first.body, 'Title running');
      expect(notifications.last.title, 'Payment released');
      expect(notifications.last.project?.id, 'finished');
    });

    test('respects the entry limit', () {
      final projects = [
        for (var i = 0; i < 12; i++)
          makeProject(
            id: 'p$i',
            role: ProjectRole.freelancer,
            createdAt: DateTime(2026, 1, i + 1),
          ),
      ];

      expect(dashboardNotifications(projects), hasLength(8));
      expect(dashboardNotifications(projects, limit: 3), hasLength(3));
    });
  });

  group('Freelancer Dashboard', () {
    testWidgets('shows statistics and quick actions', (tester) async {
      await login(tester);

      await tester.tap(navLabel('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Freelancer Dashboard'));
      await tester.pumpAndSettle();

      expect(find.byType(FreelancerDashboardScreen), findsOneWidget);

      // The six required statistics.
      expect(find.text('Active projects'), findsOneWidget);
      expect(find.text('Completed projects'), findsOneWidget);
      expect(find.text('Active orders'), findsOneWidget);
      expect(find.text('Completed orders'), findsOneWidget);
      expect(find.text('Average rating'), findsOneWidget);
      expect(find.text('Total reviews'), findsOneWidget);

      // Required dashboard sections (below the fold — scroll to build them).
      await scrollDashboardUntil(tester, find.text('Quick Actions'));
      expect(inDashboard(find.text('Quick Actions')), findsOneWidget);

      await scrollDashboardUntil(tester, find.text('Reviews & Rating'));
      expect(inDashboard(find.text('Reviews & Rating')), findsOneWidget);

      await scrollDashboardUntil(tester, find.text('Notifications'));
      expect(inDashboard(find.text('Notifications')), findsOneWidget);
      expect(inDashboard(find.text('Messages')), findsWidgets);
    });

    testWidgets('quick actions navigate to the existing screens', (
      tester,
    ) async {
      await login(tester);

      await tester.tap(navLabel('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Freelancer Dashboard'));
      await tester.pumpAndSettle();

      // Quick actions start below the fold.
      await scrollDashboardUntil(tester, inDashboard(find.text('Orders')));
      await tester.tap(inDashboard(find.text('Orders')));
      await tester.pumpAndSettle();
      expect(find.text('My Orders'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Dashboard → Services (scope past the shell's nav-bar label).
      await scrollDashboardUntil(tester, inDashboard(find.text('Services')));
      await tester.tap(inDashboard(find.text('Services')));
      await tester.pumpAndSettle();
      expect(find.text('My Services'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Dashboard → Projects.
      await scrollDashboardUntil(tester, inDashboard(find.text('Projects')));
      await tester.tap(inDashboard(find.text('Projects')));
      await tester.pumpAndSettle();
      expect(find.text('My Work'), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();

      expect(find.byType(FreelancerDashboardScreen), findsOneWidget);
    });

    testWidgets('message items open the project details screen', (
      tester,
    ) async {
      await login(tester);

      await tester.tap(navLabel('Profile'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Freelancer Dashboard'));
      await tester.pumpAndSettle();

      // Mock data seeds open projects, so message/notification rows exist
      // once the lazy sections are scrolled into view.
      final rows = inDashboard(find.byType(ListTile));
      await scrollDashboardUntil(tester, rows);
      expect(rows, findsWidgets);

      final messageTile = rows.first;
      await tester.ensureVisible(messageTile);
      await tester.pumpAndSettle();
      await tester.tap(messageTile);
      await tester.pumpAndSettle();

      // The tapped item pushed the existing project details screen.
      expect(find.text('Project details'), findsOneWidget);
    });
  });
}
