/// The logged-in user profile shown across the app (greeting, profile tab).
class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    this.title = 'Client',
    this.location = 'Remote',
  });

  final String name;
  final String email;
  final String title;
  final String location;

  /// First word of the name, used for the personalized greeting.
  String get firstName {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.isEmpty || parts.first.isEmpty ? name : parts.first;
  }

  /// Initials used for the avatar.
  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}
