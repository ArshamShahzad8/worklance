import 'package:flutter/material.dart';

import '../../models/project.dart';
import 'project_list_view.dart';

/// My Orders: every service the current user has ordered as a client.
class MyOrdersScreen extends StatelessWidget {
  const MyOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: const SafeArea(child: MyOrdersView()),
    );
  }
}

/// The My Orders list on its own, so the Work tab can show it without a
/// nested app bar.
class MyOrdersView extends StatelessWidget {
  const MyOrdersView({super.key, this.onBrowseServices});

  final VoidCallback? onBrowseServices;

  @override
  Widget build(BuildContext context) {
    return ProjectListView(
      role: ProjectRole.client,
      scope: ProjectStatus.values.toSet(),
      noun: 'Orders',
      emptyIcon: Icons.receipt_long_outlined,
      emptyTitle: 'No orders yet',
      emptyMessage:
          'Order a service from the marketplace and it will appear here so '
          'you can follow its progress through to delivery.',
      emptyActionLabel: 'Browse services',
      onEmptyAction: onBrowseServices,
    );
  }
}
