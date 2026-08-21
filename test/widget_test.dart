import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:worklance/app/app.dart';
import 'package:worklance/core/constants/app_constants.dart';
import 'package:worklance/core/state/app_store.dart';
import 'package:worklance/core/theme/app_theme.dart';
import 'package:worklance/data/mock_data.dart';
import 'package:worklance/screens/categories/categories_screen.dart';
import 'package:worklance/screens/marketplace/marketplace_screen.dart';
import 'package:worklance/screens/marketplace/service_detail_screen.dart';
import 'package:worklance/screens/profile/profile_screen.dart';
import 'package:worklance/screens/services/services_screen.dart';

/// Wraps a single screen with the app store + theme for standalone tests.
Widget wrap(Widget child) {
  return AppScope(
    store: AppStore(
      favorites: FavoritesController(),
      user: UserController(MockData.currentUser),
    ),
    child: MaterialApp(
      theme: buildAppTheme(),
      home: Scaffold(body: child),
    ),
  );
}

/// Pumps the full app and lets the splash auto-navigate to Welcome.
Future<void> pumpToWelcome(WidgetTester tester) async {
  await tester.pumpWidget(const WorklanceApp());
  await tester.pump();
  await tester.pump(
    AppConstants.splashDuration + const Duration(milliseconds: 400),
  );
  await tester.pumpAndSettle();
}

/// Logs in through the UI (valid credentials) and lands on the marketplace.
Future<void> login(WidgetTester tester) async {
  await pumpToWelcome(tester);
  await tester.ensureVisible(find.text('Login'));
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();

  await tester.enterText(find.byType(TextFormField).at(0), 'aarsham@worklance.app');
  await tester.enterText(find.byType(TextFormField).at(1), 'password');
  await tester.ensureVisible(find.text('Log In'));
  await tester.tap(find.text('Log In'));
  await tester.pump();
  await tester.pump(
    AppConstants.authSimulatedDelay + const Duration(milliseconds: 200),
  );
  await tester.pumpAndSettle();

  // Let the "welcome back" snackbar dismiss so it never blocks taps.
  await tester.pump(const Duration(seconds: 4));
  await tester.pumpAndSettle();
}

/// Finders scoped to a tab, because IndexedStack keeps every tab mounted.
Finder inHome(Finder matching) =>
    find.descendant(of: find.byType(MarketplaceScreen), matching: matching);
Finder inServicesTab(Finder matching) =>
    find.descendant(of: find.byType(ServicesScreen), matching: matching);
Finder navLabel(String label) => find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(label),
    );

void main() {
  group('Splash & Welcome', () {
    testWidgets('splash shows branding then auto-navigates to welcome',
        (tester) async {
      await tester.pumpWidget(const WorklanceApp());
      await tester.pump();

      expect(find.text(AppConstants.appName), findsOneWidget);
      expect(find.text(AppConstants.tagline), findsOneWidget);

      await tester.pump(
        AppConstants.splashDuration + const Duration(milliseconds: 400),
      );
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
      expect(find.text('Find the right talent for every project.'),
          findsOneWidget);
    });

    testWidgets('welcome navigates to login and registration', (tester) async {
      await pumpToWelcome(tester);

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();
      expect(find.text('Welcome back'), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });
  });

  group('Login', () {
    testWidgets('shows validation errors for empty and invalid input',
        (tester) async {
      await pumpToWelcome(tester);
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log In'));
      await tester.pump();
      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).first, 'invalid');
      await tester.tap(find.text('Log In'));
      await tester.pump();
      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('valid login navigates to the marketplace', (tester) async {
      await login(tester);

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(inHome(find.textContaining('Aarsham')), findsWidgets);
      expect(inHome(find.text('Find your next freelancer today.')),
          findsOneWidget);
    });
  });

  group('Registration', () {
    testWidgets('shows validation errors for empty form and terms',
        (tester) async {
      await pumpToWelcome(tester);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Create Account'));
      await tester.tap(find.text('Create Account'));
      await tester.pump();

      expect(find.text('Please enter your full name'), findsOneWidget);
      expect(find.text('Please enter your email address'), findsOneWidget);
      expect(find.text('Please create a password'), findsOneWidget);
      expect(find.text('Please confirm your password'), findsOneWidget);
      expect(
        find.text('Please accept the Terms & Conditions to continue'),
        findsOneWidget,
      );
    });

    testWidgets('valid registration navigates to the marketplace',
        (tester) async {
      await pumpToWelcome(tester);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Aarsham Shahzad');
      await tester.enterText(fields.at(1), 'aarsham@worklance.app');
      await tester.enterText(fields.at(2), 'Password1');
      await tester.enterText(fields.at(3), 'Password1');
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      await tester.ensureVisible(find.text('Create Account'));
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      await tester.pump(
        AppConstants.authSimulatedDelay + const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
    });

    testWidgets('registration name and email appear on the profile screen',
        (tester) async {
      await pumpToWelcome(tester);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.ensureVisible(fields.at(0));
      await tester.enterText(fields.at(0), 'Sarah Khan');
      await tester.ensureVisible(fields.at(1));
      await tester.enterText(fields.at(1), 'sarah@gmail.com');
      await tester.ensureVisible(fields.at(2));
      await tester.enterText(fields.at(2), 'Abc12345');
      await tester.ensureVisible(fields.at(3));
      await tester.enterText(fields.at(3), 'Abc12345');
      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pump();

      await tester.ensureVisible(find.text('Create Account'));
      await tester.tap(find.text('Create Account'));
      await tester.pump();
      await tester.pump(
        AppConstants.authSimulatedDelay + const Duration(milliseconds: 200),
      );
      await tester.pumpAndSettle();
      // Dismiss the "account created" snackbar before further taps.
      await tester.pump(const Duration(seconds: 4));
      await tester.pumpAndSettle();

      await tester.tap(navLabel('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Sarah Khan'), findsOneWidget);
      expect(find.text('sarah@gmail.com'), findsOneWidget);

      // The Home greeting reflects the registered user too.
      await tester.tap(navLabel('Home'));
      await tester.pumpAndSettle();
      expect(inHome(find.textContaining('Sarah')), findsWidgets);
    });

    testWidgets('confirm password mismatch is rejected', (tester) async {
      await pumpToWelcome(tester);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Sarah Khan');
      await tester.enterText(fields.at(1), 'sarah@gmail.com');
      await tester.enterText(fields.at(2), 'Abc12345');
      await tester.enterText(fields.at(3), 'Abc1234');
      await tester.ensureVisible(find.text('Create Account'));
      await tester.tap(find.text('Create Account'));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
    });

    testWidgets('registration rejects a weak password', (tester) async {
      await pumpToWelcome(tester);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'Sarah Khan');
      await tester.enterText(fields.at(1), 'sarah@gmail.com');
      await tester.enterText(fields.at(2), 'abc12345');
      await tester.enterText(fields.at(3), 'abc12345');
      await tester.ensureVisible(find.text('Create Account'));
      await tester.tap(find.text('Create Account'));
      await tester.pump();

      expect(
        find.text('Password must contain an uppercase letter'),
        findsOneWidget,
      );
    });

    testWidgets('password strength indicator updates while typing',
        (tester) async {
      await pumpToWelcome(tester);
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      final passwordField = find.byType(TextFormField).at(2);
      await tester.ensureVisible(passwordField);
      await tester.enterText(passwordField, 'abc');
      await tester.pump();
      expect(find.text('Weak'), findsOneWidget);

      await tester.enterText(passwordField, 'abc12345');
      await tester.pump();
      expect(find.text('Medium'), findsOneWidget);

      await tester.enterText(passwordField, 'Abc12345');
      await tester.pump();
      expect(find.text('Strong'), findsOneWidget);
    });
  });

  group('Marketplace', () {
    testWidgets('home category opens services filtered by that category',
        (tester) async {
      await login(tester);

      // The featured feed is what Home shows.
      expect(inHome(find.text('Full Stack Web Development')), findsOneWidget);

      // Tapping a popular category on Home opens the Services tab filtered.
      await tester.tap(inHome(find.text('Mobile Development')).first);
      await tester.pumpAndSettle();

      expect(inServicesTab(find.text('Flutter Mobile App Development')),
          findsOneWidget);
      expect(inServicesTab(find.text('Full Stack Web Development')),
          findsNothing);
    });

    testWidgets('home search filters services', (tester) async {
      await login(tester);

      await tester.enterText(
        find.byKey(const ValueKey('home_search')),
        'seo',
      );
      await tester.pumpAndSettle();

      expect(inHome(find.text('SEO Services & Search Ranking')), findsOneWidget);
      expect(inHome(find.text('Full Stack Web Development')), findsNothing);
    });

    testWidgets('favorite toggle changes the icon state', (tester) async {
      await login(tester);

      expect(inHome(find.byIcon(Icons.favorite_border_rounded)), findsWidgets);
      expect(inHome(find.byIcon(Icons.favorite_rounded)), findsNothing);

      await tester.tap(inHome(find.byIcon(Icons.favorite_border_rounded)).first);
      await tester.pumpAndSettle();

      expect(inHome(find.byIcon(Icons.favorite_rounded)), findsOneWidget);
    });

    testWidgets('categories page opens services with the selected filter',
        (tester) async {
      await login(tester);

      await tester.tap(navLabel('Categories'));
      await tester.pumpAndSettle();

      await tester.tap(find.descendant(
        of: find.byType(CategoriesScreen),
        matching: find.text('Web Development'),
      ));
      await tester.pumpAndSettle();

      expect(inServicesTab(find.text('Full Stack Web Development')),
          findsOneWidget);
      expect(inServicesTab(find.text('Flutter Mobile App Development')),
          findsNothing);
    });

    testWidgets('clearing the services filter restores all services',
        (tester) async {
      await tester.pumpWidget(wrap(const ServicesScreen()));
      await tester.pump();

      expect(find.text('12 of 12 services available'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Mobile Development'));
      await tester.pumpAndSettle();
      expect(find.text('1 of 12 services available'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'All'));
      await tester.pumpAndSettle();
      expect(find.text('12 of 12 services available'), findsOneWidget);
      expect(find.text('Full Stack Web Development'), findsOneWidget);
    });

    testWidgets('services tab filters by category and shows empty state',
        (tester) async {
      await tester.pumpWidget(wrap(const ServicesScreen()));
      await tester.pump();

      expect(find.text('Flutter Mobile App Development'), findsOneWidget);

      await tester.tap(find.widgetWithText(ChoiceChip, 'Mobile Development'));
      await tester.pumpAndSettle();

      expect(find.text('Flutter Mobile App Development'), findsOneWidget);
      expect(find.text('Full Stack Web Development'), findsNothing);

      await tester.enterText(
        find.byKey(const ValueKey('services_search')),
        'zzz-no-match',
      );
      await tester.pumpAndSettle();

      expect(find.text('No services found'), findsOneWidget);
    });

    testWidgets('service detail shows info and order feedback', (tester) async {
      final service = MockData.services.first;
      await tester.pumpWidget(wrap(ServiceDetailScreen(service: service)));
      await tester.pump();

      expect(find.text('Service details'), findsOneWidget);
      expect(find.text(service.title), findsOneWidget);
      expect(find.text(service.freelancer.name), findsWidgets);
      expect(find.text('Order Now'), findsOneWidget);
      expect(find.text('Contact'), findsOneWidget);

      await tester.tap(find.text('Order Now'));
      await tester.pump();

      expect(find.textContaining('prototype'), findsWidgets);
    });
  });

  group('Profile', () {
    testWidgets('logout returns to the welcome screen', (tester) async {
      await login(tester);

      await tester.tap(navLabel('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Profile'), findsOneWidget);

      final profileScrollable = find
          .descendant(
            of: find.byType(ProfileScreen),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('Log Out'),
        150,
        scrollable: profileScrollable,
      );
      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();

      await tester.tap(
        find.descendant(
          of: find.byType(AlertDialog),
          matching: find.text('Log Out'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Get Started'), findsOneWidget);
    });
  });

  group('Responsive layout', () {
    testWidgets('marketplace renders without overflow on small and large '
        'screens', (tester) async {
      tester.view.devicePixelRatio = 3.0;
      tester.view.physicalSize = const Size(320 * 3, 568 * 3);
      addTearDown(tester.view.reset);

      await login(tester);
      expect(find.byType(NavigationBar), findsOneWidget);

      await tester.tap(navLabel('Services'));
      await tester.pumpAndSettle();
      await tester.tap(navLabel('Categories'));
      await tester.pumpAndSettle();
      await tester.tap(navLabel('Profile'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Profile'), findsOneWidget);

      // Large tablet-like surface.
      tester.view.physicalSize = const Size(1024 * 2, 1366 * 2);
      await tester.pumpAndSettle();
      await tester.tap(navLabel('Home'));
      await tester.pumpAndSettle();
      expect(inHome(find.text('Full Stack Web Development')), findsOneWidget);
    });
  });
}
