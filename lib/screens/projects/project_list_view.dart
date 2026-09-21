import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/project_filters.dart';
import '../../models/project.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_slide_animation.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/project_card.dart';

/// The shared body behind My Orders, Active Projects and Completed Projects.
class ProjectListView extends StatefulWidget {
  const ProjectListView({
    super.key,
    required this.scope,
    required this.noun,
    required this.emptyTitle,
    required this.emptyMessage,
    this.role,
    this.emptyIcon = Icons.work_outline_rounded,
    this.emptyActionLabel,
    this.onEmptyAction,
    this.showStatusFilter = true,
    this.showRoleFilter = false,
    this.initialSort = ProjectSort.newest,
  });

  final ProjectRole? role;
  final Set<ProjectStatus> scope;
  final String noun;
  final String emptyTitle;
  final String emptyMessage;
  final IconData emptyIcon;
  final String? emptyActionLabel;
  final VoidCallback? onEmptyAction;
  final bool showStatusFilter;
  final bool showRoleFilter;
  final ProjectSort initialSort;

  @override
  State<ProjectListView> createState() => _ProjectListViewState();
}

class _ProjectListViewState extends State<ProjectListView> {
  bool _isLoading = true;
  ProjectStatus? _statusFilter;
  ProjectRole? _roleFilter;
  late ProjectSort _sort = widget.initialSort;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  bool get _hasActiveFilter => _statusFilter != null || _roleFilter != null;

  void _clearFilters() => setState(() {
        _statusFilter = null;
        _roleFilter = null;
      });

  void _openProject(Project project) {
    Navigator.of(
      context,
    ).pushNamed(AppRoutes.projectDetails, arguments: project);
  }

  @override
  Widget build(BuildContext context) {
    final store = AppScope.of(context);

    if (_isLoading) {
      return LoadingIndicator(
        label: 'Loading your ${widget.noun.toLowerCase()}...',
      );
    }

    return ListenableBuilder(
      listenable: store.projects,
      builder: (context, _) {
        final scoped = filterProjects(
          projects: store.projects.getAll(),
          role: widget.role,
          statuses: widget.scope,
        );

        if (scoped.isEmpty) {
          return EmptyState(
            icon: widget.emptyIcon,
            title: widget.emptyTitle,
            message: widget.emptyMessage,
            actionLabel:
                widget.onEmptyAction == null ? null : widget.emptyActionLabel,
            onAction: widget.onEmptyAction,
          );
        }

        final visible = sortProjects(
          projects: filterProjects(
            projects: scoped,
            role: _roleFilter,
            statuses: _statusFilter == null ? const {} : {_statusFilter!},
          ),
          sort: _sort,
        );

        final header = _ListHeader(
          scoped: scoped,
          noun: widget.noun,
          statuses: widget.showStatusFilter
              ? filterChipsFor(widget.scope)
              : const [],
          selectedStatus: _statusFilter,
          onStatusSelected: (status) => setState(() => _statusFilter = status),
          showRoleFilter: widget.showRoleFilter,
          selectedRole: _roleFilter,
          onRoleSelected: (role) => setState(() => _roleFilter = role),
          sort: _sort,
          onSortChanged: (sort) => setState(() => _sort = sort),
        );

        return Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxListWidth,
            ),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.spaceMd,
                AppConstants.spaceMd,
                AppConstants.spaceMd,
                AppConstants.spaceXl,
              ),
              itemCount: visible.isEmpty ? 2 : visible.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) return header;

                if (visible.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: AppConstants.spaceXl),
                    child: EmptyState(
                      icon: Icons.filter_alt_off_rounded,
                      title: 'No ${widget.noun.toLowerCase()} match',
                      message:
                          'Nothing here with the filters you picked. '
                          'Clear them to see everything again.',
                      actionLabel:
                          _hasActiveFilter ? 'Clear filters' : null,
                      onAction: _hasActiveFilter ? _clearFilters : null,
                    ),
                  );
                }

                final project = visible[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
                  child: FadeSlideAnimation(
                    index: index - 1,
                    child: ProjectCard(
                      project: project,
                      onTap: () => _openProject(project),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _ListHeader extends StatelessWidget {
  const _ListHeader({
    required this.scoped,
    required this.noun,
    required this.statuses,
    required this.selectedStatus,
    required this.onStatusSelected,
    required this.showRoleFilter,
    required this.selectedRole,
    required this.onRoleSelected,
    required this.sort,
    required this.onSortChanged,
  });

  final List<Project> scoped;
  final String noun;
  final List<ProjectStatus> statuses;
  final ProjectStatus? selectedStatus;
  final ValueChanged<ProjectStatus?> onStatusSelected;
  final bool showRoleFilter;
  final ProjectRole? selectedRole;
  final ValueChanged<ProjectRole?> onRoleSelected;
  final ProjectSort sort;
  final ValueChanged<ProjectSort> onSortChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final openCount = scoped.where((p) => p.status.isOpen).length;
    final closedCount = scoped.length - openCount;
    final totalValue = scoped.fold<double>(0, (sum, p) => sum + p.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _SummaryTile(
              value: '${scoped.length}',
              label: noun,
              icon: Icons.folder_open_rounded,
            ),
            const SizedBox(width: AppConstants.spaceSm),
            _SummaryTile(
              value: openCount > 0 ? '$openCount' : '$closedCount',
              label: openCount > 0 ? 'In progress' : 'Closed',
              icon: openCount > 0
                  ? Icons.timelapse_rounded
                  : Icons.verified_rounded,
            ),
            const SizedBox(width: AppConstants.spaceSm),
            _SummaryTile(
              value: AppConstants.formatPrice(totalValue),
              label: 'Total value',
              icon: Icons.account_balance_wallet_outlined,
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceMd),
        Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (statuses.isNotEmpty) ...[
                      FilterChip(
                        label: const Text('All'),
                        selected: selectedStatus == null,
                        onSelected: (_) => onStatusSelected(null),
                      ),
                      for (final status in statuses) ...[
                        const SizedBox(width: AppConstants.spaceSm),
                        FilterChip(
                          avatar: Icon(
                            status.icon,
                            size: 15,
                            color: selectedStatus == status
                                ? status.color
                                : AppColors.textSecondary,
                          ),
                          label: Text(status.label),
                          selected: selectedStatus == status,
                          onSelected: (selected) =>
                              onStatusSelected(selected ? status : null),
                        ),
                      ],
                    ],
                    if (showRoleFilter) ...[
                      if (statuses.isNotEmpty)
                        const SizedBox(width: AppConstants.spaceMd),
                      FilterChip(
                        label: const Text('As freelancer'),
                        selected: selectedRole == ProjectRole.freelancer,
                        onSelected: (selected) => onRoleSelected(
                          selected ? ProjectRole.freelancer : null,
                        ),
                      ),
                      const SizedBox(width: AppConstants.spaceSm),
                      FilterChip(
                        label: const Text('As client'),
                        selected: selectedRole == ProjectRole.client,
                        onSelected: (selected) =>
                            onRoleSelected(selected ? ProjectRole.client : null),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            PopupMenuButton<ProjectSort>(
              tooltip: 'Sort',
              icon: const Icon(Icons.sort_rounded),
              initialValue: sort,
              onSelected: onSortChanged,
              itemBuilder: (context) => [
                for (final option in ProjectSort.values)
                  PopupMenuItem(value: option, child: Text(option.label)),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppConstants.spaceXs),
        Text(
          'Sorted by ${sort.label.toLowerCase()}',
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceSm),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(height: 6),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
