import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/order.dart';

/// Small colored pill showing an [OrderStatus], reused across My Orders,
/// Project Details and Milestones — the Week 5 counterpart to
/// [ProposalStatusBadge].
class OrderStatusBadge extends StatelessWidget {
  const OrderStatusBadge({super.key, required this.status, this.large = false});

  final OrderStatus status;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = status.color;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppConstants.radiusSm),
        border: large ? Border.all(color: color.withValues(alpha: 0.4)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, size: large ? 18 : 13, color: color),
          SizedBox(width: large ? 6 : 4),
          Text(
            status.label,
            style: (large ? theme.textTheme.labelLarge : theme.textTheme.labelSmall)
                ?.copyWith(color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
