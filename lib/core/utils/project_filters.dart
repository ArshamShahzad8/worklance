import '../../models/project.dart';

/// How a list of projects/orders is ordered on screen.
enum ProjectSort {
  newest('Newest'),
  dueSoonest('Due soonest'),
  highestValue('Highest value'),
  mostProgress('Most progress');

  const ProjectSort(this.label);

  final String label;
}

/// Filters [projects] by free-text [query], [role] and [statuses].
List<Project> filterProjects({
  required List<Project> projects,
  String query = '',
  ProjectRole? role,
  Set<ProjectStatus> statuses = const {},
}) {
  final normalized = query.trim().toLowerCase();
  return projects.where((project) {
    if (role != null && project.role != role) return false;
    if (statuses.isNotEmpty && !statuses.contains(project.status)) {
      return false;
    }
    if (normalized.isEmpty) return true;
    final haystack = [
      project.title,
      project.description,
      project.category.name,
      project.counterpartyName,
      project.status.label,
    ].join(' ').toLowerCase();
    return haystack.contains(normalized);
  }).toList();
}

/// Returns a new list of [projects] ordered by [sort].
List<Project> sortProjects({
  required List<Project> projects,
  ProjectSort sort = ProjectSort.newest,
}) {
  final sorted = List<Project>.from(projects);
  switch (sort) {
    case ProjectSort.newest:
      sorted.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    case ProjectSort.dueSoonest:
      sorted.sort((a, b) {
        if (a.status.isOpen != b.status.isOpen) {
          return a.status.isOpen ? -1 : 1;
        }
        return a.dueDate.compareTo(b.dueDate);
      });
    case ProjectSort.highestValue:
      sorted.sort((a, b) => b.amount.compareTo(a.amount));
    case ProjectSort.mostProgress:
      sorted.sort((a, b) => b.progress.compareTo(a.progress));
  }
  return sorted;
}

/// The statuses a list should offer as filter chips.
List<ProjectStatus> filterChipsFor(Set<ProjectStatus> scope) =>
    ProjectStatus.values.where(scope.contains).toList();
