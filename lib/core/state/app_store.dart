import 'package:flutter/widgets.dart';

import '../../models/freelancer.dart';
import '../../models/service.dart';
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

/// Holds the current user profile so the greeting, profile screen, the
/// freelancer profile screen and any future screen all read from one
/// central place.
class UserController extends ChangeNotifier {
  UserController(this._user);

  UserProfile _user;

  UserProfile get user => _user;

  /// The id used for services this user creates as a freelancer, and for
  /// matching the user's own listings in [ServicesController].
  static const String selfFreelancerId = 'me';

  /// Represents the current user as a [Freelancer], so the existing
  /// Freelancer Profile screen (built in Week 1 for browsing other
  /// freelancers) can be reused unmodified for the user's own profile.
  Freelancer get asFreelancer => Freelancer(
    id: selfFreelancerId,
    name: _user.name,
    title: _user.title,
    avatarColor: _user.avatarColor,
    rating: _user.rating,
    reviewCount: _user.reviewCount,
    bio: _user.bio,
    skills: _user.skills,
    location: _user.location,
    memberSince: _user.memberSince,
    completedJobs: _user.completedJobs,
  );

  /// Generic profile update. Used by Registration and the Edit Profile
  /// screen. Any argument left null keeps the current value.
  void update({String? name, String? email, String? title, String? location}) {
    _user = _user.copyWith(
      name: name,
      email: email,
      title: title,
      location: location,
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
    _user = _user.copyWith(
      name: sameUser ? _user.name : _displayNameFromEmail(normalized),
      email: normalized,
    );
    notifyListeners();
  }

  /// Saves the freelancer-facing fields (bio + skills), marking the user as
  /// a freelancer so the My Services / Create Service screens unlock.
  void updateFreelancerProfile({
    required String bio,
    required List<String> skills,
  }) {
    _user = _user.copyWith(bio: bio, skills: skills, isFreelancer: true);
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

/// Holds the services the current user offers as a freelancer.
///
/// Lives only for the current app session (no database yet — this is the
/// Week 3 UI foundation for My Services / Create Service; a real API-backed
/// repository can replace this controller later without touching the UI).
class ServicesController extends ChangeNotifier {
  ServicesController([List<Service> initial = const []])
    : _services = List<Service>.from(initial);

  final List<Service> _services;

  List<Service> getAll() => List.unmodifiable(_services);

  Service? getById(String id) {
    for (final service in _services) {
      if (service.id == id) return service;
    }
    return null;
  }

  void add(Service service) {
    _services.insert(0, service);
    notifyListeners();
  }

  void update(Service service) {
    final index = _services.indexWhere((s) => s.id == service.id);
    if (index == -1) return;
    _services[index] = service;
    notifyListeners();
  }

  void remove(String id) {
    _services.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}

/// Combines the app's runtime state into one object so the UI has a single
/// place to read and update state.
class AppStore extends ChangeNotifier {
  AppStore({
    required this.favorites,
    required this.user,
    ServicesController? services,
  }) : services = services ?? ServicesController() {
    // Forward child notifications so widgets listening to the store itself
    // also rebuild when favorites, the user profile, or services change.
    favorites.addListener(notifyListeners);
    user.addListener(notifyListeners);
    this.services.addListener(notifyListeners);
  }

  final FavoritesController favorites;
  final UserController user;
  final ServicesController services;
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
