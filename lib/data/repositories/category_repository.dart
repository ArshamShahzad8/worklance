import '../../models/category.dart';
import '../mock_data.dart';

/// Provides access to category data.
///
/// Currently returns local mock data; swap the implementation for an HTTP
/// client in a later week without changing any screen code.
abstract final class CategoryRepository {
  /// Returns every marketplace category.
  static List<Category> getAll() => MockData.categories;
}
