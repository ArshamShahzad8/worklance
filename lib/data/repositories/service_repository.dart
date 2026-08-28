import '../../models/service.dart';
import '../mock_data.dart';

/// Provides access to service data.
///
/// Currently returns local mock data; swap the implementation for an HTTP
/// client in a later week without changing any screen code.
abstract final class ServiceRepository {
  /// Returns every service in the catalogue.
  static List<Service> getAll() => MockData.services;

  /// Returns only the services marked as [featured].
  static List<Service> getFeatured() =>
      MockData.services.where((s) => s.featured).toList();

  /// Returns services offered by a specific freelancer.
  static List<Service> getByFreelancer(String freelancerId) =>
      MockData.services.where((s) => s.freelancer.id == freelancerId).toList();
}
