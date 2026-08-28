import 'package:flutter_test/flutter_test.dart';
import 'package:worklance/data/mock_data.dart';

void main() {
  test('has at least 7 categories', () {
    expect(MockData.categories.length, greaterThanOrEqualTo(7));
  });

  test('has at least 15 services and multiple freelancers', () {
    expect(MockData.services.length, greaterThanOrEqualTo(15));
    expect(MockData.freelancers.length, greaterThanOrEqualTo(5));
  });

  test('category ids are unique', () {
    final ids = MockData.categories.map((c) => c.id).toSet();
    expect(ids.length, MockData.categories.length);
  });

  test('service ids are unique', () {
    final ids = MockData.services.map((s) => s.id).toSet();
    expect(ids.length, MockData.services.length);
  });

  test('every service references a known category and freelancer', () {
    final categoryIds = MockData.categories.map((c) => c.id).toSet();
    final freelancerIds = MockData.freelancers.map((f) => f.id).toSet();
    for (final service in MockData.services) {
      expect(
        categoryIds,
        contains(service.category.id),
        reason: 'Service ${service.id} has unknown category',
      );
      expect(
        freelancerIds,
        contains(service.freelancer.id),
        reason: 'Service ${service.id} has unknown freelancer',
      );
    }
  });

  test('services have positive prices and sane ratings', () {
    for (final service in MockData.services) {
      expect(service.price, greaterThan(0));
      expect(service.rating, inInclusiveRange(0, 5));
      expect(service.deliveryDays, greaterThan(0));
      expect(service.skills, isNotEmpty);
    }
  });

  test('all seven required categories are present', () {
    final names = MockData.categories.map((c) => c.name).toSet();
    for (final required in [
      'Web Development',
      'Mobile Development',
      'UI/UX Design',
      'Graphic Design',
      'Digital Marketing',
      'Content Writing',
      'Video Editing',
    ]) {
      expect(names, contains(required));
    }
  });

  test('current user is set for personalized greeting', () {
    expect(MockData.currentUser.name, isNotEmpty);
    expect(MockData.currentUser.email, contains('@'));
  });

  test('has a featured selection for the Home discovery feed', () {
    final featured = MockData.services
        .where((service) => service.featured)
        .toList();
    expect(featured.length, greaterThanOrEqualTo(3));
  });

  test('freelancers have mock locations for the cards', () {
    for (final freelancer in MockData.freelancers) {
      expect(
        freelancer.location.trim(),
        isNotEmpty,
        reason: '${freelancer.name} is missing a location',
      );
    }
  });
}
