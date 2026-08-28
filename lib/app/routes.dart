import 'package:flutter/material.dart';
import '../models/freelancer.dart';
import '../models/service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/registration_screen.dart';
import '../screens/categories/categories_screen.dart';
import '../screens/marketplace/freelancer_profile_screen.dart';
import '../screens/marketplace/marketplace_shell.dart';
import '../screens/marketplace/service_detail_screen.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/welcome/welcome_screen.dart';

/// All navigation routes
abstract final class AppRoutes {
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String marketplace = '/marketplace';
  static const String serviceDetail = '/service-detail';
  static const String freelancerProfile = '/freelancer-profile';
  static const String categories = '/categories';

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
      default:
        return null;
    }
  }
}
