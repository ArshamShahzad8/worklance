import '../../models/job.dart';

/// Advanced filter options for the job marketplace.
class JobFilter {
  const JobFilter({
    this.query = '',
    this.categoryId,
    this.experienceLevel,
    this.budgetType,
    this.minBudget,
    this.savedOnly = false,
  });

  final String query;
  final String? categoryId;
  final ExperienceLevel? experienceLevel;
  final BudgetType? budgetType;

  /// Only show jobs whose budget max is at least this amount.
  final double? minBudget;

  /// Only show jobs the user has saved (checked against `FavoritesController`
  /// by the screen, since saved-state itself isn't part of the [Job] model).
  final bool savedOnly;

  bool get hasActiveFilter =>
      categoryId != null ||
      experienceLevel != null ||
      budgetType != null ||
      minBudget != null ||
      savedOnly;

  int get activeFilterCount {
    var count = 0;
    if (categoryId != null) count++;
    if (experienceLevel != null) count++;
    if (budgetType != null) count++;
    if (minBudget != null) count++;
    if (savedOnly) count++;
    return count;
  }

  JobFilter copyWith({
    String? query,
    String? categoryId,
    ExperienceLevel? experienceLevel,
    BudgetType? budgetType,
    double? minBudget,
    bool? savedOnly,
    bool clearCategoryId = false,
    bool clearExperienceLevel = false,
    bool clearBudgetType = false,
    bool clearMinBudget = false,
  }) {
    return JobFilter(
      query: query ?? this.query,
      categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
      experienceLevel: clearExperienceLevel
          ? null
          : (experienceLevel ?? this.experienceLevel),
      budgetType: clearBudgetType ? null : (budgetType ?? this.budgetType),
      minBudget: clearMinBudget ? null : (minBudget ?? this.minBudget),
      savedOnly: savedOnly ?? this.savedOnly,
    );
  }
}

/// Filters [jobs] by a free-text [query] and, when provided, a [categoryId].
///
/// The query matches against the job title, description, category name and
/// skills (case-insensitive). When [query] is empty and [categoryId] is
/// null, all jobs are returned.
List<Job> filterJobs({
  required List<Job> jobs,
  String query = '',
  String? categoryId,
}) {
  final normalized = query.trim().toLowerCase();
  return jobs.where((job) {
    if (categoryId != null && job.category.id != categoryId) return false;
    if (normalized.isEmpty) return true;
    final haystack = [
      job.title,
      job.description,
      job.category.name,
      job.skills.join(' '),
      job.client.name,
    ].join(' ').toLowerCase();
    return haystack.contains(normalized);
  }).toList();
}

/// Filters jobs using the advanced [JobFilter]. Does not apply [savedOnly] —
/// that requires the caller's `FavoritesController`, so the screen applies
/// it separately.
List<Job> filterJobsAdvanced({
  required List<Job> jobs,
  required JobFilter filter,
}) {
  return jobs.where((job) {
    if (filter.categoryId != null && job.category.id != filter.categoryId) {
      return false;
    }
    if (filter.experienceLevel != null &&
        job.experienceLevel != filter.experienceLevel) {
      return false;
    }
    if (filter.budgetType != null && job.budgetType != filter.budgetType) {
      return false;
    }
    if (filter.minBudget != null && job.budgetMax < filter.minBudget!) {
      return false;
    }
    return true;
  }).toList();
}
