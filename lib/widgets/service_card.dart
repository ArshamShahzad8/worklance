import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/state/app_store.dart';
import '../core/theme/app_colors.dart';
import '../models/service.dart';
import 'freelancer_avatar.dart';
import 'rating_widget.dart';

/// A marketplace service card.
///
/// Fully reusable: pass any [Service], a tap callback and (optionally) the
/// [FavoritesController] to enable the bookmark button.
class ServiceCard extends StatelessWidget {
  const ServiceCard({
    super.key,
    required this.service,
    required this.onTap,
    this.favorites,
    this.onFreelancerTap,
  });

  final Service service;
  final VoidCallback onTap;
  final FavoritesController? favorites;
  final VoidCallback? onFreelancerTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final freelancer = service.freelancer;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: onFreelancerTap,
                    child: FreelancerAvatar(
                      name: freelancer.name,
                      color: freelancer.avatarColor,
                      radius: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: onFreelancerTap,
                          child: Text(
                            freelancer.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          freelancer.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  if (favorites != null)
                    _FavoriteButton(
                      favorites: favorites!,
                      serviceId: service.id,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                service.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                service.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      '${service.deliveryDays} days delivery',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.location_on_outlined,
                    size: 14,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      freelancer.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Flexible(
                    child: Container(
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
                        service.category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    child: RatingWidget(
                      rating: service.rating,
                      reviewCount: service.reviewCount,
                    ),
                  ),
                  const Spacer(),
                  Flexible(
                    child: Text(
                      'From ${AppConstants.formatPrice(service.price)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              // --- Skills tags ---
              if (service.skills.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    for (final skill in service.skills.take(4))
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(
                            AppConstants.radiusSm,
                          ),
                        ),
                        child: Text(
                          skill,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatefulWidget {
  const _FavoriteButton({required this.favorites, required this.serviceId});

  final FavoritesController favorites;
  final String serviceId;

  @override
  State<_FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<_FavoriteButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    widget.favorites.toggle(widget.serviceId);
    _controller.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.favorites,
      builder: (context, _) {
        final isFavorite = widget.favorites.isFavorite(widget.serviceId);
        return ScaleTransition(
          scale: _scaleAnimation,
          child: IconButton(
            onPressed: _toggle,
            tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite ? AppColors.error : AppColors.textMuted,
            ),
          ),
        );
      },
    );
  }
}
