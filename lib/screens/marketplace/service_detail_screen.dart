import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../models/service.dart';
import '../../widgets/fade_slide_animation.dart';
import '../../widgets/freelancer_avatar.dart';
import '../../widgets/rating_widget.dart';

/// Service Detail screen: full listing info, freelancer card, skills,
/// delivery and price, plus Contact / Order Now actions (prototype).
class ServiceDetailScreen extends StatefulWidget {
  const ServiceDetailScreen({super.key, required this.service});

  final Service service;

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _favController;
  late final Animation<double> _favScale;

  @override
  void initState() {
    super.initState();
    _favController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _favScale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _favController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _favController.dispose();
    super.dispose();
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final service = widget.service;
    final freelancer = service.freelancer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Service details'),
        actions: [
          ListenableBuilder(
            listenable: store.favorites,
            builder: (context, _) {
              final isFavorite = store.favorites.isFavorite(service.id);
              return ScaleTransition(
                scale: _favScale,
                child: IconButton(
                  onPressed: () {
                    store.favorites.toggle(service.id);
                    _favController.forward(from: 0.0);
                  },
                  tooltip: isFavorite
                      ? 'Remove from favorites'
                      : 'Add to favorites',
                  icon: Icon(
                    isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: isFavorite ? AppColors.error : null,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 120),
        child: FadeSlideAnimation(
          index: 0,
          duration: const Duration(milliseconds: 400),
          slideOffset: 12.0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spaceMd,
                  AppConstants.spaceMd,
                  AppConstants.spaceMd,
                  0,
                ),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.freelancerProfile,
                    arguments: freelancer,
                  ),
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
                              style: theme.textTheme.titleMedium,
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
                      const SizedBox(width: 8),
                      RatingWidget(
                        rating: service.rating,
                        reviewCount: service.reviewCount,
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMuted,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMd,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        service.category.icon,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        service.category.name,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMd,
                ),
                child: Text(
                  service.title,
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMd,
                ),
                child: Row(
                  children: [
                    RatingWidget(rating: service.rating, showCount: false),
                    const SizedBox(width: 4),
                    Text(
                      '${service.reviewCount} reviews',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Icon(
                      Icons.schedule_rounded,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${service.deliveryDays} days delivery',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spaceLg),
              _Section(
                title: 'About this service',
                child: Text(
                  service.description,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
              const SizedBox(height: AppConstants.spaceLg),
              _Section(
                title: 'Skills & tools',
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final skill in service.skills)
                      Chip(label: Text(skill)),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spaceLg),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMd,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.schedule_rounded,
                        label: 'Delivery',
                        value: '${service.deliveryDays} days',
                      ),
                    ),
                    const SizedBox(width: AppConstants.spaceMd),
                    Expanded(
                      child: _InfoCard(
                        icon: Icons.attach_money_rounded,
                        label: 'Starting at',
                        value: AppConstants.formatPrice(service.price),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppConstants.spaceLg),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceMd,
                ),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed(
                    AppRoutes.freelancerProfile,
                    arguments: freelancer,
                  ),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spaceMd),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              FreelancerAvatar(
                                name: freelancer.name,
                                color: freelancer.avatarColor,
                                radius: 22,
                              ),
                              const SizedBox(width: 10),
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
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spaceMd,
            AppConstants.spaceMd,
            AppConstants.spaceMd,
            AppConstants.spaceMd,
          ),
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showMessage(
                    context,
                    'Contact request sent to ${freelancer.name} (prototype).',
                  ),
                  child: const Text('Contact'),
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: FilledButton(
                  onPressed: () => _showMessage(
                    context,
                    'Order placed for "${service.title}" — prototype only.',
                  ),
                  child: const Text('Order Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Title + child block used for the detail sections.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppConstants.spaceSm),
          child,
        ],
      ),
    );
  }
}

/// Compact info tile (delivery / price).
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(label, style: theme.textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
