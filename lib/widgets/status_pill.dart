import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

/// Small colored pill used for every status indicator in the app.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    this.large = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          Icon(icon, size: large ? 18 : 13, color: color),
          SizedBox(width: large ? 6 : 4),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  (large
                          ? theme.textTheme.labelLarge
                          : theme.textTheme.labelSmall)
                      ?.copyWith(color: color, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
