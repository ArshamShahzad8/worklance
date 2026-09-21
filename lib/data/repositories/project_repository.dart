import '../../models/project.dart';
import '../mock_data.dart';

/// Provides access to project/order data.
abstract final class ProjectRepository {
  static List<Project> getAll() => MockData.projects;
}
