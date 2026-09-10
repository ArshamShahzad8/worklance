import '../../models/job.dart';
import '../mock_data.dart';

/// Provides access to job data.
///
/// Currently returns local mock data; swap the implementation for an HTTP
/// client in a later week without changing any screen code. `JobsController`
/// (in `core/state/app_store.dart`) seeds its runtime list from this
/// repository and layers in client-posted jobs for the current session.
abstract final class JobRepository {
  /// Returns every job posting in the catalogue.
  static List<Job> getAll() => MockData.jobs;

  /// Returns only the jobs marked as [Job.featured].
  static List<Job> getFeatured() =>
      MockData.jobs.where((j) => j.featured).toList();
}
