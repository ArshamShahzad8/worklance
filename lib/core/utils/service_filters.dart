import '../../models/service.dart';

/// Advanced filter options for the marketplace.
class ServiceFilter {
  const ServiceFilter({
    this.query = '',
    this.categoryId,
    this.maxPrice,
    this.minRating,
    this.maxDeliveryDays,
  });

  final String query;
  final String? categoryId;
  final double? maxPrice;
  final double? minRating;
  final int? maxDeliveryDays;

  bool get hasActiveFilter =>
      categoryId != null ||
      maxPrice != null ||
      minRating != null ||
      maxDeliveryDays != null;

  int get activeFilterCount {
    var count = 0;
    if (categoryId != null) count++;
    if (maxPrice != null) count++;
    if (minRating != null) count++;
    if (maxDeliveryDays != null) count++;
    return count;
  }

  ServiceFilter copyWith({
    String? query,
    String? categoryId,
    double? maxPrice,
    double? minRating,
    int? maxDeliveryDays,
    bool clearCategoryId = false,
    bool clearMaxPrice = false,
    bool clearMinRating = false,
    bool clearMaxDeliveryDays = false,
  }) {
    return ServiceFilter(
      query: query ?? this.query,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      maxPrice: clearMaxPrice ? null : (maxPrice ?? this.maxPrice),
      minRating: clearMinRating ? null : (minRating ?? this.minRating),
      maxDeliveryDays: clearMaxDeliveryDays
          ? null
          : (maxDeliveryDays ?? this.maxDeliveryDays),
    );
  }
}

/// Filters [services] by a free-text [query] and, when provided, a
/// [categoryId].
///
/// The query matches against the service title, freelancer name, freelancer
/// title, category name, skills and tags (case-insensitive). When [query] is
/// empty and [categoryId] is null, all services are returned.
List<Service> filterServices({
  required List<Service> services,
  String query = '',
  String? categoryId,
}) {
  final normalized = query.trim().toLowerCase();
  return services.where((service) {
    if (categoryId != null && service.category.id != categoryId) return false;
    if (normalized.isEmpty) return true;
    final haystack = [
      service.title,
      service.freelancer.name,
      service.freelancer.title,
      service.category.name,
      service.description,
      service.skills.join(' '),
    ].join(' ').toLowerCase();
    return haystack.contains(normalized);
  }).toList();
}

/// Filters services using the advanced [ServiceFilter].
List<Service> filterServicesAdvanced({
  required List<Service> services,
  required ServiceFilter filter,
}) {
  return services.where((service) {
    // Category filter.
    if (filter.categoryId != null && service.category.id != filter.categoryId) {
      return false;
    }
    // Price filter.
    if (filter.maxPrice != null && service.price > filter.maxPrice!) {
      return false;
    }
    // Rating filter.
    if (filter.minRating != null && service.rating < filter.minRating!) {
      return false;
    }
    // Delivery days filter.
    if (filter.maxDeliveryDays != null &&
        service.deliveryDays > filter.maxDeliveryDays!) {
      return false;
    }
    return true;
  }).toList();
}

/// Counts how many services belong to the given category.
int countServicesInCategory(List<Service> services, String categoryId) =>
    services.where((service) => service.category.id == categoryId).length;
