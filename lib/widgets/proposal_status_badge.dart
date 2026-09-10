import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../models/proposal.dart';

/// Small colored pill showing a [ProposalStatus], reused across My
/// Proposals, Proposal Status, and Job Details.
class ProposalStatusBadge extends StatelessWidget {
  const ProposalStatusBadge({super.key, required this.status, this.large = false});

  final ProposalStatus status;
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
