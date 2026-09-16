import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../models/order.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_slide_animation.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/order_card.dart';

/// My Orders screen: every order/contract created from an accepted
/// proposal, split into an **Active Projects** tab and a **Completed
/// Projects** tab so the two states are always clearly distinguished.
///
/// This single screen intentionally covers both the "My Orders Screen" and
/// "Active Projects Screen" / "Completed Projects Section" requirements —
/// a client and a freelancer with a handful of contracts benefit from one
/// place to see everything, filtered by a tab, rather than three separate
/// screens showing overlapping data.
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Orders'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Active Projects'),
              Tab(text: 'Completed'),
            ],
          ),
        ),
        body: SafeArea(
          child: _isLoading
              ? const LoadingIndicator(label: 'Loading your orders...')
              : ListenableBuilder(
                  listenable: store.orders,
                  builder: (context, _) {
                    return TabBarView(
                      children: [
                        _OrderList(
                          orders: store.orders.getActive(),
                          emptyIcon: Icons.work_history_outlined,
                          emptyTitle: 'No active projects',
                          emptyMessage:
                              'Once a client accepts one of your proposals, '
                              'the new order will appear here.',
                        ),
                        _OrderList(
                          orders: store.orders.getCompleted(),
                          emptyIcon: Icons.task_alt_outlined,
                          emptyTitle: 'No completed projects yet',
                          emptyMessage:
                              'Projects move here once they are delivered '
                              'and marked complete.',
                        ),
                      ],
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _OrderList extends StatelessWidget {
  const _OrderList({
    required this.orders,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final List<Order> orders;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        message: emptyMessage,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceMd,
        AppConstants.spaceMd,
        AppConstants.spaceMd,
        AppConstants.spaceXl,
      ),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
          child: FadeSlideAnimation(
            index: index,
            child: OrderCard(
              order: order,
              onTap: () => Navigator.of(context).pushNamed(
                AppRoutes.orderDetails,
                arguments: order,
              ),
            ),
          ),
        );
      },
    );
  }
}
