import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../data/repositories/service_repository.dart';
import '../../models/freelancer.dart';
import '../../models/service.dart';
import '../../widgets/freelancer_avatar.dart';
import '../../widgets/rating_widget.dart';
import '../../widgets/section_header.dart';
import '../../widgets/service_card.dart';

/// Freelancer Profile screen: shows detailed information about a freelancer
/// including their bio, skills, stats and list of services.
class FreelancerProfileScreen extends StatelessWidget {
  const FreelancerProfileScreen({super.key, required this.freelancer});

  final Freelancer freelancer;

  /// All services offered by this freelancer.
  List<Service> get _freelancerServices =>
      ServiceRepository.getByFreelancer(freelancer.id);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(freelancer.name)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Profile header ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: Column(
                children: [
                  FreelancerAvatar(
                    name: freelancer.name,
                    color: freelancer.avatarColor,
                    radius: 40,
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  Text(
                    freelancer.name,
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spaceXs),
                  Text(
                    freelancer.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.spaceSm),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        freelancer.location,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceSm),
                  RatingWidget(
                    rating: freelancer.rating,
                    reviewCount: freelancer.reviewCount,
                    size: 18,
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  // --- Stats row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _StatItem(
                        value: '${freelancer.completedJobs}',
                        label: 'Jobs Done',
                      ),
                      Container(width: 1, height: 32, color: AppColors.border),
                      _StatItem(
                        value: freelancer.rating.toStringAsFixed(1),
                        label: 'Rating',
                      ),
                      Container(width: 1, height: 32, color: AppColors.border),
                      _StatItem(
                        value: '${freelancer.reviewCount}',
                        label: 'Reviews',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // --- About ---
            Padding(
              padding: const EdgeInsets.all(AppConstants.spaceMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppConstants.spaceSm),
                  Text(
                    freelancer.bio,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceXs),
                  Text(
                    freelancer.memberSince,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),

            // --- Skills ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMd,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Skills', style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppConstants.spaceSm),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final skill in freelancer.skills)
                        Chip(label: Text(skill)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppConstants.spaceLg),

            // --- Freelancer's services ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMd,
              ),
              child: SectionHeader(
                title: 'Services',
                subtitle:
                    '${_freelancerServices.length} service${_freelancerServices.length == 1 ? '' : 's'} available',
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            for (final service in _freelancerServices)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppConstants.spaceMd,
                  0,
                  AppConstants.spaceMd,
                  AppConstants.spaceMd,
                ),
                child: ServiceCard(
                  service: service,
                  favorites: store.favorites,
                  onTap: () => Navigator.of(
                    context,
                  ).pushNamed(AppRoutes.serviceDetail, arguments: service),
                ),
              ),

            if (_freelancerServices.isEmpty)
              Padding(
                padding: const EdgeInsets.all(AppConstants.spaceLg),
                child: Center(
                  child: Text(
                    'No services listed yet.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: AppConstants.spaceXl),
          ],
        ),
      ),
    );
  }
}

/// A single stat item (number + label) in the profile header.
class _StatItem extends StatelessWidget {
  const _StatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
