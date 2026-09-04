import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../core/state/app_store.dart';
import '../core/theme/app_theme.dart';
import '../data/mock_data.dart';
import 'routes.dart';

/// Root widget of the WORKLANCE app.
///
/// Wires together the theme, the global [AppStore] and the route table.
/// Tests may inject their own [store] to start with fresh state.
class WorklanceApp extends StatelessWidget {
  const WorklanceApp({super.key, this.store});

  final AppStore? store;

  @override
  Widget build(BuildContext context) {
    final appStore =
        store ??
        AppStore(
          favorites: FavoritesController(),
          user: UserController(MockData.currentUser),
        );

    return AppScope(
      store: appStore,
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRoutes.onGenerateRoute,
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Page not found')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No screen is registered for "${settings.name}".\n'
                      'If you just pulled new code, run a full "flutter '
                      'clean" + fresh "flutter run" (not just hot reload).',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => Navigator.of(
                        context,
                      ).pushReplacementNamed(AppRoutes.marketplace),
                      child: const Text('Go to Marketplace'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
