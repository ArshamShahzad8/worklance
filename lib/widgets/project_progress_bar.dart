import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';

/// Reusable visual progress section for a project/order: a labeled
/// percentage plus a rounded progress bar, used on both the My Orders list
/// and the Project Details screen so progress always looks the same.
class ProjectProgressBar extends StatelessWidget {
  const ProjectProgressBar({
    super.key,
    required this.progress,
    this.label = 'Project progress',
    this.color,
  });

  /// 0.0 to 1.0.
  final double progress;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final barColor = color ?? AppColors.primary;
    final percent = (progress.clamp(0, 1) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '$percent%',
              style: theme.textTheme.labelMedium?.copyWith(
                color: barColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceXs),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress.clamp(0, 1),
            minHeight: 8,
            backgroundColor: AppColors.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}
