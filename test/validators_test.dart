import 'package:flutter_test/flutter_test.dart';
import 'package:worklance/core/utils/validators.dart';

void main() {
  group('validateName', () {
    test('rejects empty name', () {
      expect(validateName(''), isNotNull);
      expect(validateName('   '), isNotNull);
      expect(validateName(null), isNotNull);
    });

    test('rejects names shorter than 3 characters', () {
      expect(validateName('Al'), isNotNull);
    });

    test('accepts a valid name', () {
      expect(validateName('Ali Khan'), isNull);
    });
  });

  group('validateEmail', () {
    test('rejects empty email', () {
      expect(validateEmail(''), isNotNull);
      expect(validateEmail(null), isNotNull);
    });

    test('rejects invalid formats', () {
      expect(validateEmail('not-an-email'), isNotNull);
      expect(validateEmail('abc'), isNotNull);
      expect(validateEmail('abc@'), isNotNull);
      expect(validateEmail('abc@gmail'), isNotNull);
      expect(validateEmail('@gmail.com'), isNotNull);
      expect(validateEmail('user@'), isNotNull);
      expect(validateEmail('user@.com'), isNotNull);
      expect(validateEmail('a@b'), isNotNull);
      expect(validateEmail('a@b.c'), isNotNull);
      expect(validateEmail('a b@c.com'), isNotNull);
    });

    test('accepts valid emails', () {
      expect(validateEmail('user@gmail.com'), isNull);
      expect(validateEmail('student@example.com'), isNull);
      expect(validateEmail('name.lastname@domain.com'), isNull);
      expect(validateEmail('first.last@sub.domain.co'), isNull);
    });
  });

  group('validateLoginPassword', () {
    test('rejects empty password', () {
      expect(validateLoginPassword(''), isNotNull);
      expect(validateLoginPassword(null), isNotNull);
    });

    test('accepts any non-empty password (prototype)', () {
      expect(validateLoginPassword('anything'), isNull);
    });
  });

  group('validateRegistrationPassword', () {
    test('rejects empty password', () {
      expect(validateRegistrationPassword(''), isNotNull);
    });

    test('rejects short passwords', () {
      expect(validateRegistrationPassword('Ab1'), isNotNull);
    });

    test('requires an uppercase letter', () {
      expect(validateRegistrationPassword('12345678'), isNotNull);
      expect(validateRegistrationPassword('abcdefgh1'), isNotNull);
    });

    test('requires a lowercase letter', () {
      expect(validateRegistrationPassword('ABCDEFGH1'), isNotNull);
    });

    test('requires a number', () {
      expect(validateRegistrationPassword('Abcdefgh'), isNotNull);
    });

    test('accepts a strong password', () {
      expect(validateRegistrationPassword('Password1'), isNull);
      expect(validateRegistrationPassword('Hunter2k24'), isNull);
    });
  });

  group('validateConfirmPassword', () {
    test('rejects empty confirmation', () {
      expect(validateConfirmPassword('', 'Password1'), isNotNull);
    });

    test('rejects mismatch', () {
      expect(validateConfirmPassword('Different1', 'Password1'), isNotNull);
    });

    test('accepts matching passwords', () {
      expect(validateConfirmPassword('Password1', 'Password1'), isNull);
    });
  });

  group('validateTermsAccepted', () {
    test('rejects unaccepted terms', () {
      expect(validateTermsAccepted(false), isNotNull);
      expect(validateTermsAccepted(null), isNotNull);
    });

    test('accepts accepted terms', () {
      expect(validateTermsAccepted(true), isNull);
    });
  });
}
