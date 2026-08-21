import 'package:flutter_test/flutter_test.dart';
import 'package:worklance/core/state/app_store.dart';
import 'package:worklance/data/mock_data.dart';

void main() {
  group('UserController (local user profile state)', () {
    test('update stores the name and email entered at registration', () {
      final controller = UserController(MockData.currentUser);
      controller.update(name: 'Sarah Khan', email: 'sarah@gmail.com');

      expect(controller.user.name, 'Sarah Khan');
      expect(controller.user.email, 'sarah@gmail.com');
    });

    test('loginAs keeps the registered profile when the email matches', () {
      final controller = UserController(MockData.currentUser);
      controller.update(name: 'Sarah Khan', email: 'sarah@gmail.com');

      controller.loginAs('sarah@gmail.com');

      expect(controller.user.name, 'Sarah Khan');
      expect(controller.user.email, 'sarah@gmail.com');
    });

    test('loginAs derives a display name from a brand-new email', () {
      final controller = UserController(MockData.currentUser);

      controller.loginAs('sarah.khan@example.com');

      expect(controller.user.name, 'Sarah Khan');
      expect(controller.user.email, 'sarah.khan@example.com');
    });
  });
}
