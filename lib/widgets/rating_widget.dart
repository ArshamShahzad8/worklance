import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Compact star rating with an optional review count.
class RatingWidget extends StatelessWidget {
  const RatingWidget({
    super.key,
    required this.rating,
    this.reviewCount,
    this.showCount = true,
    this.size = 16,
  });

  final double rating;
  final int? reviewCount;
  final bool showCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, color: AppColors.accent, size: size),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            rating.toStringAsFixed(1),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (showCount && reviewCount != null) ...[
          const SizedBox(width: 2),
          Flexible(
            child: Text(
              '($reviewCount)',
              style: theme.textTheme.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ],
    );
  }
}
