import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/state/app_store.dart';
import '../core/theme/app_colors.dart';
import '../models/freelancer.dart';
import 'freelancer_avatar.dart';
import 'rating_widget.dart';

/// A compact freelancer card used in the horizontal Top Freelancers
/// section on the Marketplace home screen.
class FreelancerCard extends StatelessWidget {
  const FreelancerCard({
    super.key,
    required this.freelancer,
    required this.onTap,
    this.favorites,
  });

  final Freelancer freelancer;
  final VoidCallback onTap;

  /// When provided, a heart button overlays the card so the freelancer can
  /// be saved to/removed from favorites directly (Week 8).
  final FavoritesController? favorites;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 160,
      height: 200,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Stack(
            children: [
              Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FreelancerAvatar(
                  name: freelancer.name,
                  color: freelancer.avatarColor,
                  radius: 24,
                ),
                const SizedBox(height: 8),
                Text(
                  freelancer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                Text(
                  freelancer.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                RatingWidget(
                  rating: freelancer.rating,
                  reviewCount: freelancer.reviewCount,
                  size: 14,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  child: Text(
                    '${freelancer.completedJobs} jobs done',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (favorites != null)
            Positioned(
                top: 4,
                right: 4,
                child: ListenableBuilder(
                  listenable: favorites!,
                  builder: (context, _) {
                    final isFavorite = favorites!.isFavorite(freelancer.id);
                    return IconButton(
                      onPressed: () => favorites!.toggle(freelancer.id),
                      tooltip: isFavorite
                          ? 'Remove from favorites'
                          : 'Add to favorites',
                      iconSize: 20,
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
