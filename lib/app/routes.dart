import 'package:flutter/material.dart';
import '../models/service.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/registration_screen.dart';
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
      default:
        return null;
    }
  }
}
