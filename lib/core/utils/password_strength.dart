/// Pure password-strength logic, kept separate from the UI so it can be
/// unit-tested and reused by any screen.
library;

enum PasswordStrength {
  weak('Weak', 1),
  medium('Medium', 2),
  strong('Strong', 3);

  const PasswordStrength(this.label, this.level);

  /// Human-readable label, e.g. "Weak".
  final String label;

  /// Number of filled segments in the strength meter (1-3).
  final int level;
}

/// Scores a password on a simple, understandable scale:
/// +1 for 8+ characters, +1 more for 12+ characters, then +1 for each
/// character class present (uppercase, lowercase, digit, symbol).
///
/// Examples: `abc` -> weak, `abc12345` -> medium, `Abc12345` -> strong.
PasswordStrength passwordStrength(String password) {
  var score = 0;
  if (password.length >= 8) score++;
  if (password.length >= 12) score++;
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'[a-z]').hasMatch(password)) score++;
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) score++;

  if (score <= 2) return PasswordStrength.weak;
  if (score == 3) return PasswordStrength.medium;
  return PasswordStrength.strong;
}
