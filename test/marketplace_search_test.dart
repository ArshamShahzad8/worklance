import 'package:flutter_test/flutter_test.dart';
import 'package:worklance/core/utils/marketplace_search.dart';
import 'package:worklance/core/utils/service_filters.dart';
import 'package:worklance/data/mock_data.dart';

MarketplaceSearchResults run({
  String query = '',
  ServiceFilter? filter,
  MarketplaceSort sort = MarketplaceSort.relevance,
  SearchScope scope = SearchScope.all,
}) {
  return searchMarketplace(
    services: MockData.services,
    freelancers: MockData.freelancers,
    jobs: MockData.jobs,
    categories: MockData.categories,
    filter: filter ?? ServiceFilter(query: query),
    sort: sort,
    scope: scope,
  );
}

void main() {
  group('Unified search across entity types', () {
    test('empty query with no filters returns everything', () {
      final results = run();
      expect(results.services.length, MockData.services.length);
      expect(results.freelancers.length, MockData.freelancers.length);
      expect(results.jobs.length, MockData.jobs.length);
      expect(results.categories.length, MockData.categories.length);
      expect(results.isEmpty, isFalse);
    });

    test('query matches services, freelancers, jobs and categories', () {
      final services = run(query: 'flutter', scope: SearchScope.services);
      expect(
        services.services.map((s) => s.title),
        contains('Flutter Mobile App Development'),
      );

      final freelancers = run(
        query: 'flutter',
        scope: SearchScope.freelancers,
      );
      expect(freelancers.freelancers.map((f) => f.name), contains('Ayesha Khan'));

      final jobs = run(query: 'banking', scope: SearchScope.jobs);
      expect(jobs.jobs, isNotEmpty);

      final categories = run(query: 'mobile', scope: SearchScope.categories);
      expect(
        categories.categories.map((c) => c.name),
        contains('Mobile Development'),
      );
    });

    test('query matches freelancers by skill', () {
      final results = run(query: 'figma', scope: SearchScope.freelancers);
      expect(results.freelancers.map((f) => f.name), contains('Daniel Costa'));
      expect(results.services, isEmpty);
      expect(results.jobs, isEmpty);
      expect(results.categories, isEmpty);
    });

    test('query matches categories by name', () {
      final results = run(query: 'marketing', scope: SearchScope.categories);
      expect(results.categories.map((c) => c.name), contains('Digital Marketing'));
      expect(results.freelancers, isEmpty);
    });

    test('no matches returns an empty result set', () {
      final results = run(query: 'quantum cryptography');
      expect(results.isEmpty, isTrue);
      expect(results.totalCount, 0);
    });

    test('scope limits results to the selected entity type', () {
      final jobsOnly = run(scope: SearchScope.jobs);
      expect(jobsOnly.jobs.length, MockData.jobs.length);
      expect(jobsOnly.services, isEmpty);
      expect(jobsOnly.freelancers, isEmpty);
      expect(jobsOnly.categories, isEmpty);

      final servicesOnly = run(scope: SearchScope.services);
      expect(servicesOnly.services.length, MockData.services.length);
      expect(servicesOnly.jobs, isEmpty);
    });
  });

  group('Filters combine with search', () {
    test('category filter applies to services, jobs and freelancers', () {
      final results = run(query: '', filter: const ServiceFilter(categoryId: 'c_web'));
      expect(results.services.every((s) => s.category.id == 'c_web'), isTrue);
      expect(results.jobs.every((j) => j.category.id == 'c_web'), isTrue);
      // Freelancers offering web services: Rohan, Liam, Omar.
      expect(
        results.freelancers.map((f) => f.id),
        containsAll(['f_rohan', 'f_liam', 'f_omar']),
      );
      expect(results.categories.map((c) => c.id), ['c_web']);
    });

    test('price cap filters services by price', () {
      final results = run(filter: const ServiceFilter(maxPrice: 150));
      expect(results.services, isNotEmpty);
      expect(results.services.every((s) => s.price <= 150), isTrue);
    });

    test('rating filter applies across types', () {
      final results = run(filter: const ServiceFilter(minRating: 4.8));
      expect(results.freelancers, isNotEmpty);
      expect(results.freelancers.every((f) => f.rating >= 4.8), isTrue);
      expect(results.services.every((s) => s.rating >= 4.8), isTrue);
    });

    test('delivery time filter narrows services', () {
      final results = run(filter: const ServiceFilter(maxDeliveryDays: 7));
      expect(results.services, isNotEmpty);
      expect(results.services.every((s) => s.deliveryDays <= 7), isTrue);
    });

    test('multiple filters AND together', () {
      final results = run(
        filter: const ServiceFilter(
          categoryId: 'c_web',
          maxPrice: 300,
          minRating: 4.5,
        ),
      );
      expect(results.services, isNotEmpty);
      for (final service in results.services) {
        expect(service.category.id, 'c_web');
        expect(service.price <= 300, isTrue);
        expect(service.rating >= 4.5, isTrue);
      }
    });

    test('filters combine with a text query', () {
      final results = run(
        filter: const ServiceFilter(query: 'next.js', categoryId: 'c_web'),
      );
      expect(results.services.map((s) => s.title), [
        'React Website Development',
      ]);
    });
  });

  group('Sorting combines with search and filters', () {
    test('lowest price sorts services ascending', () {
      final results = run(
        scope: SearchScope.services,
        sort: MarketplaceSort.lowestPrice,
      );
      final prices = results.services.map((s) => s.price).toList();
      final sorted = [...prices]..sort();
      expect(prices, sorted);
    });

    test('highest price sorts services descending', () {
      final results = run(
        scope: SearchScope.services,
        sort: MarketplaceSort.highestPrice,
      );
      final prices = results.services.map((s) => s.price).toList();
      expect(prices, [...prices]..sort((a, b) => b.compareTo(a)));
    });

    test('highest rating sorts freelancers descending', () {
      final results = run(
        scope: SearchScope.freelancers,
        sort: MarketplaceSort.highestRating,
      );
      final ratings = results.freelancers.map((f) => f.rating).toList();
      expect(ratings, [...ratings]..sort((a, b) => b.compareTo(a)));
    });

    test('most popular sorts services by review count descending', () {
      final results = run(
        scope: SearchScope.services,
        sort: MarketplaceSort.mostPopular,
      );
      final counts = results.services.map((s) => s.reviewCount).toList();
      expect(counts, [...counts]..sort((a, b) => b.compareTo(a)));
    });

    test('most popular sorts jobs by proposals descending', () {
      final results = run(
        scope: SearchScope.jobs,
        sort: MarketplaceSort.mostPopular,
      );
      final counts = results.jobs.map((j) => j.proposalsCount).toList();
      expect(counts, [...counts]..sort((a, b) => b.compareTo(a)));
    });

    test('sort applies after filtering', () {
      final results = run(
        filter: const ServiceFilter(maxPrice: 250),
        sort: MarketplaceSort.lowestPrice,
      );
      expect(results.services.every((s) => s.price <= 250), isTrue);
      final prices = results.services.map((s) => s.price).toList();
      expect(prices, [...prices]..sort());
    });
  });
}
