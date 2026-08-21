import 'package:flutter_test/flutter_test.dart';
import 'package:worklance/core/utils/service_filters.dart';
import 'package:worklance/data/mock_data.dart';

void main() {
  test('empty query and no category returns all services', () {
    final result = filterServices(services: MockData.services);
    expect(result.length, MockData.services.length);
  });

  test('search matches service title (case-insensitive)', () {
    final result = filterServices(
      services: MockData.services,
      query: 'flutter',
    );
    expect(result.map((s) => s.title), contains('Flutter Mobile App Development'));
    expect(result.length, 1);
  });

  test('search matches freelancer name', () {
    final result = filterServices(
      services: MockData.services,
      query: 'rohan',
    );
    expect(result.map((s) => s.freelancer.name), everyElement('Rohan Mehta'));
    expect(result.length, 1);
  });

  test('search matches category name', () {
    final result = filterServices(
      services: MockData.services,
      query: 'marketing',
    );
    expect(result, isNotEmpty);
    expect(
      result.every((s) => s.category.id == 'c_marketing'),
      isTrue,
    );
  });

  test('category filter returns only services of that category', () {
    final result = filterServices(
      services: MockData.services,
      categoryId: 'c_web',
    );
    expect(result, isNotEmpty);
    expect(result.every((s) => s.category.id == 'c_web'), isTrue);
  });

  test('query and category combine', () {
    final result = filterServices(
      services: MockData.services,
      query: 'react',
      categoryId: 'c_web',
    );
    expect(result.length, 1);
    expect(result.first.title, 'React Website Development');
  });

  test('no matches returns an empty list', () {
    final result = filterServices(
      services: MockData.services,
      query: 'quantum cryptography',
    );
    expect(result, isEmpty);
  });

  test('countServicesInCategory counts correctly', () {
    expect(countServicesInCategory(MockData.services, 'c_web'), 3);
    expect(countServicesInCategory(MockData.services, 'c_mobile'), 1);
    expect(countServicesInCategory(MockData.services, 'c_marketing'), 3);
  });
}
