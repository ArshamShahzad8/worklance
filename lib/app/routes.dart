import 'package:flutter/material.dart';
import '../models/freelancer.dart';
import '../models/job.dart';
import '../models/proposal.dart';
import '../models/service.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/registration_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/marketplace/freelancer_profile_screen.dart';
import '../screens/marketplace/marketplace_shell.dart';
import '../screens/marketplace/service_detail_screen.dart';
import '../screens/profile/edit_freelancer_profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/profile/my_freelancer_profile_screen.dart';
import '../screens/jobs/find_jobs_screen.dart';
import '../screens/jobs/job_details_screen.dart';
import '../screens/jobs/my_proposals_screen.dart';
import '../screens/jobs/post_job_screen.dart';
import '../screens/jobs/proposal_status_screen.dart';
import '../screens/jobs/submit_proposal_screen.dart';
import '../screens/services/create_service_screen.dart';
import '../screens/services/my_services_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/welcome/welcome_screen.dart';

/// All navigation routes
abstract final class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String marketplace = '/marketplace';
  static const String serviceDetail = '/service-detail';
  static const String freelancerProfile = '/freelancer-profile';
  static const String categories = '/categories';
  static const String editProfile = '/edit-profile';
  static const String myFreelancerProfile = '/my-freelancer-profile';
  static const String editFreelancerProfile = '/edit-freelancer-profile';
  static const String myServices = '/my-services';
  static const String createService = '/create-service';
  static const String findJobs = '/find-jobs';
  static const String jobDetails = '/job-details';
  static const String postJob = '/post-job';
  static const String submitProposal = '/submit-proposal';
  static const String myProposals = '/my-proposals';
  static const String proposalStatus = '/proposal-status';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case welcome:
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegistrationScreen());
      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordScreen(),
        );
      case marketplace:
        return MaterialPageRoute(builder: (_) => const MarketplaceShell());
      case serviceDetail:
        final service = settings.arguments as Service;
        return MaterialPageRoute(
          builder: (_) => ServiceDetailScreen(service: service),
        );
      case freelancerProfile:
        final freelancer = settings.arguments as Freelancer;
        return MaterialPageRoute(
          builder: (_) => FreelancerProfileScreen(freelancer: freelancer),
        );
      case categories:
        return MaterialPageRoute(
          builder: (context) => CategoriesScreen(
            // Selecting a category pops this screen and hands the choice
            // back to whoever pushed it (see MarketplaceShell).
            onCategorySelected: (category) =>
                Navigator.of(context).pop(category),
          ),
        );
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());
      case myFreelancerProfile:
        return MaterialPageRoute(
          builder: (_) => const MyFreelancerProfileScreen(),
        );
      case editFreelancerProfile:
        return MaterialPageRoute(
          builder: (_) => const EditFreelancerProfileScreen(),
        );
      case myServices:
        return MaterialPageRoute(builder: (_) => const MyServicesScreen());
      case createService:
        final existingService = settings.arguments as Service?;
        return MaterialPageRoute(
          builder: (_) => CreateServiceScreen(existingService: existingService),
        );
      case findJobs:
        return MaterialPageRoute(builder: (_) => const FindJobsScreen());
      case jobDetails:
        final job = settings.arguments as Job;
        return MaterialPageRoute(builder: (_) => JobDetailsScreen(job: job));
      case postJob:
        return MaterialPageRoute(builder: (_) => const PostJobScreen());
      case submitProposal:
        final job = settings.arguments as Job;
        return MaterialPageRoute(
          builder: (_) => SubmitProposalScreen(job: job),
        );
      case myProposals:
        return MaterialPageRoute(builder: (_) => const MyProposalsScreen());
      case proposalStatus:
        final proposal = settings.arguments as Proposal;
        return MaterialPageRoute(
          builder: (_) => ProposalStatusScreen(proposal: proposal),
        );
      default:
        return null;
    }
  }
}
