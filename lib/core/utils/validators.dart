/// Pure form-validation helpers, shared by the Login and Registration
/// screens (and the Edit Profile dialog).
///
/// Keeping validation out of the widgets makes the rules easy to read,
/// unit-test and reuse.
library;

/// Local part: letters, digits and common specials (no leading @ or space).
/// Domain: dot-separated labels ending in a 2+ letter TLD.
/// This rejects clearly invalid formats such as `abc`, `abc@`, `abc@gmail`
/// and `@gmail.com` without any real email verification (out of scope).
final RegExp _emailPattern = RegExp(
  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*\.[a-zA-Z]{2,}$',
);

/// Validates a full name: required and at least 3 characters.
String? validateName(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Please enter your full name';
  if (v.length < 3) return 'Name must be at least 3 characters';
  return null;
}

/// Validates an email address: required and a sensible format.
String? validateEmail(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Please enter your email address';
  if (!_emailPattern.hasMatch(v)) return 'Please enter a valid email address';
  return null;
}

/// Login password rule: required (real auth is out of scope for Week 1).
String? validateLoginPassword(String? value) {
  final v = value ?? '';
  if (v.isEmpty) return 'Please enter your password';
  return null;
}

/// Registration password rule: 8+ characters with at least one uppercase
/// letter, one lowercase letter and one number.
String? validateRegistrationPassword(String? value) {
  final v = value ?? '';
  if (v.isEmpty) return 'Please create a password';
  if (v.length < 8) return 'Password must be at least 8 characters';
  if (!RegExp(r'[A-Z]').hasMatch(v)) {
    return 'Password must contain an uppercase letter';
  }
  if (!RegExp(r'[a-z]').hasMatch(v)) {
    return 'Password must contain a lowercase letter';
  }
  if (!RegExp(r'[0-9]').hasMatch(v)) {
    return 'Password must contain a number';
  }
  return null;
}

/// Confirms the second password matches the first.
String? validateConfirmPassword(String? value, String password) {
  final v = value ?? '';
  if (v.isEmpty) return 'Please confirm your password';
  if (v != password) return 'Passwords do not match';
  return null;
}

/// Terms & Conditions checkbox must be accepted to register.
String? validateTermsAccepted(bool? accepted) => accepted == true
    ? null
    : 'Please accept the Terms & Conditions to continue';
