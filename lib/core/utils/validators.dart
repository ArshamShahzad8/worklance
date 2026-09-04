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

/// Validates a freelancer bio: required and a minimum useful length.
String? validateBio(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Tell clients a bit about yourself';
  if (v.length < 20) return 'Bio must be at least 20 characters';
  return null;
}

/// Validates a service (or freelancer) title: required, 5-80 characters.
String? validateServiceTitle(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Please enter a title';
  if (v.length < 5) return 'Title must be at least 5 characters';
  if (v.length > 80) return 'Title must be under 80 characters';
  return null;
}

/// Validates a service description: required, at least 20 characters.
String? validateServiceDescription(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Please describe what you offer';
  if (v.length < 20) return 'Description must be at least 20 characters';
  return null;
}

/// Validates a service price: required, numeric and greater than zero.
String? validatePrice(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Please enter a price';
  final price = double.tryParse(v);
  if (price == null) return 'Enter a valid number';
  if (price <= 0) return 'Price must be greater than 0';
  if (price > 100000) return 'Price seems too high';
  return null;
}

/// Validates delivery days: required, whole number between 1 and 365.
String? validateDeliveryDays(String? value) {
  final v = value?.trim() ?? '';
  if (v.isEmpty) return 'Please enter delivery time';
  final days = int.tryParse(v);
  if (days == null) return 'Enter a whole number of days';
  if (days < 1) return 'Delivery must be at least 1 day';
  if (days > 365) return 'Delivery must be under 365 days';
  return null;
}

/// Validates a category selection.
String? validateCategorySelected(String? categoryId) =>
    categoryId == null ? 'Please choose a category' : null;

/// Validates the skills list built by [SkillInputField]: at least one, at
/// most ten, entered.
String? validateSkillsList(List<String>? skills) {
  final list = skills ?? const [];
  if (list.isEmpty) return 'Add at least one skill';
  if (list.length > 10) return 'Add up to 10 skills';
  return null;
}
