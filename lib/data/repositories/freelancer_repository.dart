import '../../models/freelancer.dart';
import '../mock_data.dart';

/// Provides access to freelancer data.
///
/// Currently returns local mock data; swap the implementation for an HTTP
/// client in a later week without changing any screen code.
abstract final class FreelancerRepository {
  /// Returns every freelancer.
  static List<Freelancer> getAll() => MockData.freelancers;

  /// Returns top freelancers sorted by rating (then review count).
  static List<Freelancer> getTop({int limit = 6}) {
    final sorted = List<Freelancer>.from(MockData.freelancers);
    sorted.sort((a, b) {
      final cmp = b.rating.compareTo(a.rating);
      if (cmp != 0) return cmp;
      return b.reviewCount.compareTo(a.reviewCount);
    });
    return sorted.take(limit).toList();
  }
}
