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
      ),
    );
  }
}
