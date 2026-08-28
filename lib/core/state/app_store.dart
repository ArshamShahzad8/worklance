import 'package:flutter/widgets.dart';

import '../../models/user.dart';

/// In-memory favorite state for service cards.
///
/// Favorites live only for the current app session (no database), which is
/// exactly what the Week 1 UI foundation requires.
class FavoritesController extends ChangeNotifier {
  final Set<String> _ids = {};

  bool isFavorite(String serviceId) => _ids.contains(serviceId);
  int get count => _ids.length;

  void toggle(String serviceId) {
    if (!_ids.remove(serviceId)) _ids.add(serviceId);
    notifyListeners();
  }
}

/// Holds the current user profile so the greeting, profile screen and any
/// future screen all read from one central place.
class UserController extends ChangeNotifier {
  UserController(this._user);

  UserProfile _user;

  UserProfile get user => _user;

  void update({String? name, String? email}) {
    _user = UserProfile(
      name: name ?? _user.name,
      email: email ?? _user.email,
      title: _user.title,
      location: _user.location,
    );
    notifyListeners();
  }

  /// Applies the email used at login (simulated auth).
  ///
  /// If the email matches the current profile (e.g. the user registered in
  /// this session), the registered name is kept. Otherwise a display name is
  /// derived from the email's local part so the prototype never falls back to
  /// unrelated mock user data.
  void loginAs(String email) {
    final normalized = email.trim();
    final sameUser = _user.email.toLowerCase() == normalized.toLowerCase();
    _user = UserProfile(
      name: sameUser ? _user.name : _displayNameFromEmail(normalized),
      email: normalized,
      title: _user.title,
      location: _user.location,
    );
    notifyListeners();
  }

  /// "sarah.khan@example.com" -> "Sarah Khan".
  static String _displayNameFromEmail(String email) {
    final local = email.split('@').first;
    final parts = local.split(RegExp(r'[._\-+]'));
    final words = parts
        .where((part) => part.isNotEmpty)
        .map((part) => part[0].toUpperCase() + part.substring(1))
        .toList();
    return words.isEmpty ? local : words.join(' ');
  }
}

/// Combines the app's runtime state into one object so the UI has a single
/// place to read and update state.
class AppStore extends ChangeNotifier {
  AppStore({required this.favorites, required this.user}) {
    // Forward child notifications so widgets listening to the store itself
    // also rebuild when favorites or the user profile change.
    favorites.addListener(notifyListeners);
    user.addListener(notifyListeners);
  }

  final FavoritesController favorites;
  final UserController user;
}

/// Exposes the [AppStore] to the widget tree.
///
/// Any widget can call `AppScope.of(context)` to read the store and will
/// automatically rebuild when the store changes.
class AppScope extends InheritedNotifier<AppStore> {
  const AppScope({super.key, required AppStore store, required super.child})
    : super(notifier: store);

  static AppStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope was not found in the widget tree');
    return scope!.notifier!;
  }
}
