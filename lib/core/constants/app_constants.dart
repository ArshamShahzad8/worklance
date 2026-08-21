/// App-wide constants for WORKLANCE: branding text, timing, spacing scale,
/// border radius scale and small formatting helpers.
///
/// Keeping these in one file avoids magic numbers scattered through the UI
/// and makes it easy to tweak the whole app in one place.
abstract final class AppConstants {
  // --- Branding ---
  static const String appName = 'WORKLANCE';
  static const String tagline = 'Find talent. Get things done.';
  static const String currencySymbol = r'$';

  // --- Timing ---
  /// How long the splash screen stays visible before auto-navigating.
  static const Duration splashDuration = Duration(milliseconds: 2400);
  /// Fake network delay used by the prototype auth flows.
  static const Duration authSimulatedDelay = Duration(milliseconds: 1200);

  // --- Spacing scale ---
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 16.0;
  static const double spaceLg = 24.0;
  static const double spaceXl = 32.0;

  // --- Border radius scale ---
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;

  /// Maximum content width on wide (tablet / desktop) screens so layouts
  /// stay readable and never stretch edge to edge.
  static const double maxContentWidth = 480.0;

  /// Formats a price with the app currency, e.g. `$350` or `$349.50`.
  static String formatPrice(double price) => price == price.roundToDouble()
      ? '$currencySymbol${price.toInt()}'
      : '$currencySymbol${price.toStringAsFixed(2)}';

  /// Returns a time-of-day greeting, e.g. `Good morning`.
  static String greetingFor(DateTime now) {
    final hour = now.hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }
}
