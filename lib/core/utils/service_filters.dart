import '../../models/service.dart';

/// Filters [services] by a free-text [query] and, when provided, a
/// [categoryId].
///
/// The query matches against the service title, freelancer name, freelancer
/// title and category name (case-insensitive). When [query] is empty and
/// [categoryId] is null, all services are returned.
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
    ].join(' ').toLowerCase();
    return haystack.contains(normalized);
  }).toList();
}

/// Counts how many services belong to the given category.
int countServicesInCategory(List<Service> services, String categoryId) =>
    services.where((service) => service.category.id == categoryId).length;
