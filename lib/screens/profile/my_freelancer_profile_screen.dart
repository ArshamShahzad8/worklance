import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/state/app_store.dart';
import '../marketplace/freelancer_profile_screen.dart';
import 'edit_freelancer_profile_screen.dart';

/// Shows the logged-in user's own freelancer profile.
///
/// If the user hasn't completed their freelancer profile yet (no bio/skills
/// saved), this jumps straight to [EditFreelancerProfileScreen] so there's
/// always something meaningful to show. Otherwise it reuses
/// [FreelancerProfileScreen] in "own profile" mode, live-updating whenever
/// the user's profile changes.
class MyFreelancerProfileScreen extends StatelessWidget {
  const MyFreelancerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    return ListenableBuilder(
      listenable: store.user,
      builder: (context, _) {
        final user = store.user.user;

        if (!user.isFreelancer) {
          return const EditFreelancerProfileScreen();
        }

        return FreelancerProfileScreen(
          freelancer: store.user.asFreelancer,
          isOwnProfile: true,
          onEditProfile: () =>
              Navigator.of(context).pushNamed(AppRoutes.editFreelancerProfile),
          onManageServices: () =>
              Navigator.of(context).pushNamed(AppRoutes.myServices),
        );
      },
    );
  }
}
