import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/state/app_store.dart';
import '../core/theme/app_colors.dart';
import '../models/freelancer.dart';
import 'freelancer_avatar.dart';
import 'rating_widget.dart';

/// Compact freelancer row used in vertical lists (search results, category
/// details). Mirrors [FreelancerCard] but stacks naturally in a `ListView`.
class FreelancerListTile extends StatelessWidget {
  const FreelancerListTile({
    super.key,
    required this.freelancer,
    required this.onTap,
    this.favorites,
  });

  final Freelancer freelancer;
  final VoidCallback onTap;

  /// When provided, a heart toggle is shown so the freelancer can be
  /// saved to/removed from favorites (Week 8).
  final FavoritesController? favorites;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          child: Row(
            children: [
              FreelancerAvatar(
                name: freelancer.name,
                color: freelancer.avatarColor,
                radius: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      freelancer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      freelancer.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    RatingWidget(
                      rating: freelancer.rating,
                      reviewCount: freelancer.reviewCount,
                      size: 14,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (favorites != null)
                ListenableBuilder(
                  listenable: favorites!,
                  builder: (context, _) {
                    final isFavorite = favorites!.isFavorite(freelancer.id);
                    return IconButton(
                      onPressed: () => favorites!.toggle(freelancer.id),
                      tooltip: isFavorite
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                      icon: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorite
                            ? AppColors.error
                            : AppColors.textMuted,
                      ),
                    );
                  },
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSm,
                      ),
                    ),
                    child: Text(
                      '${freelancer.completedJobs} jobs done',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.textMuted,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
