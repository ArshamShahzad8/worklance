import '../../models/category.dart';
import '../../models/freelancer.dart';
import '../../models/job.dart';
import '../../models/service.dart';
import 'job_filters.dart';
import 'service_filters.dart';

/// Which marketplace entity types a marketplace search returns.
enum SearchScope {
  all('All'),
  services('Services'),
  freelancers('Freelancers'),
  jobs('Jobs'),
  categories('Categories');

  const SearchScope(this.label);

  final String label;
}

/// How search results are ordered.
///
/// Every option is available for every result type. Where a metric does not
/// exist for a type (e.g. a job has no delivery time) the closest available
/// proxy is used, so sorting stays predictable across the whole marketplace.
enum MarketplaceSort {
  relevance('Relevance'),
  lowestPrice('Lowest Price'),
  highestPrice('Highest Price'),
  highestRating('Highest Rating'),
  mostPopular('Most Popular');

  const MarketplaceSort(this.label);

  final String label;
}

/// The four result lists produced by [searchMarketplace].
///
/// Lists belonging to a [SearchScope] other than the requested one are empty,
/// so the screen can render whichever scope was selected without extra work.
class MarketplaceSearchResults {
  const MarketplaceSearchResults({
    required this.services,
    required this.freelancers,
    required this.jobs,
    required this.categories,
  });

  final List<Service> services;
  final List<Freelancer> freelancers;
  final List<Job> jobs;
  final List<Category> categories;

  int get totalCount =>
      services.length +
      freelancers.length +
      jobs.length +
      categories.length;

  bool get isEmpty => totalCount == 0;
}

/// Searches the local marketplace data across all four entity types and
/// returns filtered + sorted results for [scope].
///
/// Filtering uses the shared [ServiceFilter] so every criterion combines with
/// the free-text query (applied first, narrowing results as the user types):
///
/// * **Query** — matches services, freelancer profiles, jobs and categories
///   against their own text fields (case-insensitive).
/// * **Category** — services/jobs/categories by their category; a freelancer
///   matches when they offer at least one service in that category.
/// * **Price** — services by price, freelancers by their cheapest service,
///   jobs by their starting budget, categories when they contain a service
///   within the price cap.
/// * **Rating** — services/freelancers by rating, jobs by client rating,
///   categories when they contain a service at or above the rating.
/// * **Delivery time** — services and freelancers (fastest service); jobs and
///   categories are only narrowed when they contain a matching service.
///
/// [ServiceFilter.query] carries the search text — the caller keeps it in the
/// same filter object so search, filters and sort always apply together.
MarketplaceSearchResults searchMarketplace({
  required List<Service> services,
  required List<Freelancer> freelancers,
  required List<Job> jobs,
  required List<Category> categories,
  ServiceFilter filter = const ServiceFilter(),
  MarketplaceSort sort = MarketplaceSort.relevance,
  SearchScope scope = SearchScope.all,
}) {
  final wantServices =
      scope == SearchScope.all || scope == SearchScope.services;
  final wantFreelancers =
      scope == SearchScope.all || scope == SearchScope.freelancers;
  final wantJobs = scope == SearchScope.all || scope == SearchScope.jobs;
  final wantCategories =
      scope == SearchScope.all || scope == SearchScope.categories;

  final matchedServices = wantServices
      ? sortServices(
          filterServicesAdvanced(
            services: filterServices(
              services: services,
              query: filter.query,
            ),
            filter: filter,
          ),
          sort,
        )
      : const <Service>[];

  final matchedFreelancers = wantFreelancers
      ? sortFreelancers(
          _filterFreelancers(freelancers, services, filter),
          services,
          sort,
        )
      : const <Freelancer>[];

  final matchedJobs = wantJobs
      ? sortJobs(_filterJobs(jobs, filter), sort)
      : const <Job>[];

  final matchedCategories = wantCategories
      ? sortCategories(
          _filterCategories(categories, services, filter),
          services,
          sort,
        )
      : const <Category>[];

  return MarketplaceSearchResults(
    services: matchedServices,
    freelancers: matchedFreelancers,
    jobs: matchedJobs,
    categories: matchedCategories,
  );
}

/// Filters freelancers by query, category, rating, price and delivery time.
List<Freelancer> _filterFreelancers(
  List<Freelancer> freelancers,
  List<Service> services,
  ServiceFilter filter,
) {
  final normalized = filter.query.trim().toLowerCase();
  return freelancers.where((freelancer) {
    if (normalized.isNotEmpty) {
      final haystack = [
        freelancer.name,
        freelancer.title,
        freelancer.bio,
        freelancer.skills.join(' '),
        freelancer.location,
      ].join(' ').toLowerCase();
      if (!haystack.contains(normalized)) return false;
    }

    final own = services
        .where((s) => s.freelancer.id == freelancer.id)
        .toList(growable: false);

    if (filter.categoryId != null &&
        !own.any((s) => s.category.id == filter.categoryId)) {
      return false;
    }
    if (filter.minRating != null && freelancer.rating < filter.minRating!) {
      return false;
    }
    if (filter.maxPrice != null &&
        (own.isEmpty || own.every((s) => s.price > filter.maxPrice!))) {
      return false;
    }
    if (filter.maxDeliveryDays != null &&
        (own.isEmpty ||
            own.every((s) => s.deliveryDays > filter.maxDeliveryDays!))) {
      return false;
    }
    return true;
  }).toList();
}

/// Filters jobs by query, category, budget and client rating.
///
/// Delivery time is ignored for jobs — a posting has no delivery window.
List<Job> _filterJobs(List<Job> jobs, ServiceFilter filter) {
  final matched = filterJobs(jobs: jobs, query: filter.query);
  return matched.where((job) {
    if (filter.categoryId != null && job.category.id != filter.categoryId) {
      return false;
    }
    if (filter.maxPrice != null && job.budgetMin > filter.maxPrice!) {
      return false;
    }
    if (filter.minRating != null && job.client.rating < filter.minRating!) {
      return false;
    }
    return true;
  }).toList();
}

/// Filters categories by query/id, plus price/rating/delivery criteria
/// evaluated against the services each category contains.
List<Category> _filterCategories(
  List<Category> categories,
  List<Service> services,
  ServiceFilter filter,
) {
  final normalized = filter.query.trim().toLowerCase();
  final serviceCriteriaActive =
      filter.maxPrice != null ||
      filter.minRating != null ||
      filter.maxDeliveryDays != null;

  return categories.where((category) {
    if (filter.categoryId != null && category.id != filter.categoryId) {
      return false;
    }
    if (normalized.isNotEmpty) {
      final haystack =
          '${category.name} ${category.description}'.toLowerCase();
      if (!haystack.contains(normalized)) return false;
    }
    if (serviceCriteriaActive) {
      final inCategory = services
          .where((s) => s.category.id == category.id)
          .toList(growable: false);
      if (inCategory.isEmpty) return false;
      if (filterServicesAdvanced(services: inCategory, filter: filter)
          .isEmpty) {
        return false;
      }
    }
    return true;
  }).toList();
}

/// Orders [items] by [sort] for the services result list.
List<Service> sortServices(List<Service> items, MarketplaceSort sort) {
  final sorted = List<Service>.of(items);
  switch (sort) {
    case MarketplaceSort.relevance:
      sorted.sort((a, b) {
        if (a.featured != b.featured) return a.featured ? -1 : 1;
        return b.rating.compareTo(a.rating);
      });
    case MarketplaceSort.lowestPrice:
      sorted.sort((a, b) => a.price.compareTo(b.price));
    case MarketplaceSort.highestPrice:
      sorted.sort((a, b) => b.price.compareTo(a.price));
    case MarketplaceSort.highestRating:
      sorted.sort((a, b) {
        final cmp = b.rating.compareTo(a.rating);
        return cmp != 0 ? cmp : b.reviewCount.compareTo(a.reviewCount);
      });
    case MarketplaceSort.mostPopular:
      sorted.sort((a, b) {
        final cmp = b.reviewCount.compareTo(a.reviewCount);
        return cmp != 0 ? cmp : b.rating.compareTo(a.rating);
      });
  }
  return sorted;
}

/// Orders [items] by [sort] for the freelancers result list.
///
/// Price sorts use the freelancer's cheapest/most expensive service; freelancers
/// without services sort last.
List<Freelancer> sortFreelancers(
  List<Freelancer> items,
  List<Service> services,
  MarketplaceSort sort,
) {
  final sorted = List<Freelancer>.of(items);
  double minPrice(Freelancer f) {
    var value = double.infinity;
    for (final s in services) {
      if (s.freelancer.id == f.id && s.price < value) value = s.price;
    }
    return value;
  }

  double maxPrice(Freelancer f) {
    var value = double.negativeInfinity;
    for (final s in services) {
      if (s.freelancer.id == f.id && s.price > value) value = s.price;
    }
    return value;
  }

  switch (sort) {
    case MarketplaceSort.relevance:
      sorted.sort((a, b) {
        final cmp = b.rating.compareTo(a.rating);
        return cmp != 0 ? cmp : b.reviewCount.compareTo(a.reviewCount);
      });
    case MarketplaceSort.lowestPrice:
      sorted.sort((a, b) => minPrice(a).compareTo(minPrice(b)));
    case MarketplaceSort.highestPrice:
      sorted.sort((a, b) => maxPrice(b).compareTo(maxPrice(a)));
    case MarketplaceSort.highestRating:
      sorted.sort((a, b) {
        final cmp = b.rating.compareTo(a.rating);
        return cmp != 0 ? cmp : b.reviewCount.compareTo(a.reviewCount);
      });
    case MarketplaceSort.mostPopular:
      sorted.sort((a, b) {
        final cmp = b.reviewCount.compareTo(a.reviewCount);
        return cmp != 0 ? cmp : b.rating.compareTo(a.rating);
      });
  }
  return sorted;
}

/// Orders [items] by [sort] for the jobs result list.
List<Job> sortJobs(List<Job> items, MarketplaceSort sort) {
  final sorted = List<Job>.of(items);
  switch (sort) {
    case MarketplaceSort.relevance:
      sorted.sort((a, b) {
        if (a.featured != b.featured) return a.featured ? -1 : 1;
        return b.postedAt.compareTo(a.postedAt);
      });
    case MarketplaceSort.lowestPrice:
      sorted.sort((a, b) => a.budgetMin.compareTo(b.budgetMin));
    case MarketplaceSort.highestPrice:
      sorted.sort((a, b) => b.budgetMax.compareTo(a.budgetMax));
    case MarketplaceSort.highestRating:
      sorted.sort((a, b) => b.client.rating.compareTo(a.client.rating));
    case MarketplaceSort.mostPopular:
      sorted.sort((a, b) => b.proposalsCount.compareTo(a.proposalsCount));
  }
  return sorted;
}

/// Orders [items] by [sort] for the categories result list.
///
/// Price/rating sort on the average of the category's services; popularity on
/// how many services it contains. Categories without services sort last.
List<Category> sortCategories(
  List<Category> items,
  List<Service> services,
  MarketplaceSort sort,
) {
  final sorted = List<Category>.of(items);
  List<Service> inCategory(Category c) => services
      .where((s) => s.category.id == c.id)
      .toList(growable: false);

  double avgPrice(Category c) {
    final own = inCategory(c);
    if (own.isEmpty) return double.negativeInfinity;
    return own.fold(0.0, (sum, s) => sum + s.price) / own.length;
  }

  double avgPriceAscending(Category c) {
    final own = inCategory(c);
    if (own.isEmpty) return double.infinity;
    return own.fold(0.0, (sum, s) => sum + s.price) / own.length;
  }

  double avgRating(Category c) {
    final own = inCategory(c);
    if (own.isEmpty) return double.negativeInfinity;
    return own.fold(0.0, (sum, s) => sum + s.rating) / own.length;
  }

  switch (sort) {
    case MarketplaceSort.relevance:
      break;
    case MarketplaceSort.lowestPrice:
      sorted.sort((a, b) => avgPriceAscending(a).compareTo(avgPriceAscending(b)));
    case MarketplaceSort.highestPrice:
      sorted.sort((a, b) => avgPrice(b).compareTo(avgPrice(a)));
    case MarketplaceSort.highestRating:
      sorted.sort((a, b) => avgRating(b).compareTo(avgRating(a)));
    case MarketplaceSort.mostPopular:
      sorted.sort(
        (a, b) => inCategory(b).length.compareTo(inCategory(a).length),
      );
  }
  return sorted;
}
