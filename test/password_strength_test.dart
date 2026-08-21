import 'package:flutter_test/flutter_test.dart';
import 'package:worklance/core/utils/password_strength.dart';

void main() {
  group('passwordStrength', () {
    test('classifies the documented examples', () {
      expect(passwordStrength('abc'), PasswordStrength.weak);
      expect(passwordStrength('abc12345'), PasswordStrength.medium);
      expect(passwordStrength('Abc12345'), PasswordStrength.strong);
    });

    test('empty and very short passwords are weak', () {
      expect(passwordStrength(''), PasswordStrength.weak);
      expect(passwordStrength('A1'), PasswordStrength.weak);
      expect(passwordStrength('abcdefgh'), PasswordStrength.weak);
    });

    test('length alone is not enough to be strong', () {
      // 12 lowercase characters: long but only one character class.
      expect(passwordStrength('abcdefghijkl'), PasswordStrength.medium);
    });

    test('all character classes plus length is strong', () {
      expect(passwordStrength('Abc12345!'), PasswordStrength.strong);
      expect(passwordStrength('Password1'), PasswordStrength.strong);
    });
  });
}
