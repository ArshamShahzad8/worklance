import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/job_filters.dart';
import '../../data/repositories/category_repository.dart';
import '../../models/job.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/fade_slide_animation.dart';
import '../../widgets/job_card.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/search_bar.dart';

/// Find Jobs screen: search + category filtering + advanced filters + sort
/// over the job marketplace, for freelancers looking for work.
class FindJobsScreen extends StatefulWidget {
  const FindJobsScreen({super.key});

  @override
  State<FindJobsScreen> createState() => _FindJobsScreenState();
}

class _FindJobsScreenState extends State<FindJobsScreen> {
  final _searchController = TextEditingController();
  JobFilter _filter = const JobFilter();
  _JobSortOption _sortOption = _JobSortOption.recommended;

  /// Simulated initial load. The list is already local/in-memory, but the
  /// UI is built around a loading -> data/error flow so a real API fetch
  /// can be dropped in later without restructuring the screen.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Job> _visibleJobs(AppStore store) {
    final searched = filterJobs(jobs: store.jobs.getAll(), query: _filter.query);
    var result = filterJobsAdvanced(jobs: searched, filter: _filter);
    if (_filter.savedOnly) {
      result = result.where((j) => store.favorites.isFavorite(j.id)).toList();
    }

    switch (_sortOption) {
      case _JobSortOption.recommended:
        result.sort((a, b) {
          if (a.featured && !b.featured) return -1;
          if (!a.featured && b.featured) return 1;
          return b.postedAt.compareTo(a.postedAt);
        });
      case _JobSortOption.newest:
        result.sort((a, b) => b.postedAt.compareTo(a.postedAt));
      case _JobSortOption.highestBudget:
        result.sort((a, b) => b.budgetMax.compareTo(a.budgetMax));
      case _JobSortOption.fewestProposals:
        result.sort((a, b) => a.proposalsCount.compareTo(b.proposalsCount));
    }
    return result;
  }

  void _selectCategory(String? categoryId) => setState(() {
    _filter = _filter.copyWith(
      categoryId: categoryId,
      clearCategoryId: categoryId == null,
    );
  });

  void _clearFilters() {
    setState(() {
      _filter = const JobFilter();
      _sortOption = _JobSortOption.recommended;
      _searchController.clear();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _JobFilterBottomSheet(
        experienceLevel: _filter.experienceLevel,
        budgetType: _filter.budgetType,
        minBudget: _filter.minBudget,
        savedOnly: _filter.savedOnly,
        onApply: (experience, budgetType, minBudget, savedOnly) {
          setState(() {
            _filter = _filter.copyWith(
              experienceLevel: experience,
              clearExperienceLevel: experience == null,
              budgetType: budgetType,
              clearBudgetType: budgetType == null,
              minBudget: minBudget,
              clearMinBudget: minBudget == null,
              savedOnly: savedOnly,
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pushNamed(AppRoutes.postJob),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Post a Job'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const LoadingIndicator(label: 'Finding jobs for you...')
            : _buildContent(context, theme, store),
      ),
    );
  }

  Widget _buildContent(BuildContext context, ThemeData theme, AppStore store) {
    final jobs = _visibleJobs(store);
    final totalJobs = store.jobs.getAll().length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spaceMd,
            AppConstants.spaceMd,
            AppConstants.spaceMd,
            0,
          ),
          child: Text('Find Jobs', style: theme.textTheme.headlineMedium),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
          child: Text(
            '${jobs.length} of $totalJobs jobs available',
            style: theme.textTheme.bodySmall,
          ),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
          child: AppSearchBar(
            key: const ValueKey('jobs_search'),
            controller: _searchController,
            hintText: 'Search jobs, skills or categories...',
            onChanged: (value) =>
                setState(() => _filter = _filter.copyWith(query: value)),
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm + 4),
        // --- Category chips + filter button ---
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
            children: [
              _FilterChip(
                label: 'All',
                selected: _filter.categoryId == null,
                onTap: () => _selectCategory(null),
              ),
              for (final category in CategoryRepository.getAll()) ...[
                const SizedBox(width: 8),
                _FilterChip(
                  label: category.name,
                  selected: _filter.categoryId == category.id,
                  onTap: () => _selectCategory(category.id),
                ),
              ],
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _showFilterSheet,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: _filter.hasActiveFilter
                        ? AppColors.primary
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: _filter.hasActiveFilter
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        size: 18,
                        color: _filter.hasActiveFilter
                            ? Colors.white
                            : AppColors.primary,
                      ),
                      if (_filter.activeFilterCount > 0) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _filter.hasActiveFilter
                                ? Colors.white
                                : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${_filter.activeFilterCount}',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: _filter.hasActiveFilter
                                  ? AppColors.primary
                                  : Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // --- Sort bar ---
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd),
          child: Row(
            children: [
              Icon(Icons.sort_rounded, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 4),
              Text('Sort by:', style: theme.textTheme.bodySmall),
              const SizedBox(width: 8),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final option in _JobSortOption.values) ...[
                        GestureDetector(
                          onTap: () => setState(() => _sortOption = option),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _sortOption == option
                                  ? AppColors.primary
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              option.label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: _sortOption == option
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Expanded(
          child: jobs.isEmpty
              ? EmptyState(
                  icon: Icons.work_off_outlined,
                  title: 'No jobs found',
                  message: (_filter.query.isNotEmpty || _filter.hasActiveFilter)
                      ? "We couldn't find anything matching your search "
                            'and filters. Try adjusting your criteria.'
                      : 'There are no jobs in this category yet.',
                  actionLabel: 'Clear filters',
                  onAction: _clearFilters,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.spaceMd,
                    AppConstants.spaceSm,
                    AppConstants.spaceMd,
                    AppConstants.spaceXl * 2,
                  ),
                  itemCount: jobs.length,
                  itemBuilder: (context, index) {
                    final job = jobs[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
                      child: FadeSlideAnimation(
                        index: index,
                        child: JobCard(
                          job: job,
                          favorites: store.favorites,
                          onTap: () => Navigator.of(context).pushNamed(
                            AppRoutes.jobDetails,
                            arguments: job,
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
    );
  }
}

/// Bottom sheet for advanced job filtering: experience level, budget type,
/// minimum budget, and saved-only.
class _JobFilterBottomSheet extends StatefulWidget {
  const _JobFilterBottomSheet({
    this.experienceLevel,
    this.budgetType,
    this.minBudget,
    required this.savedOnly,
    required this.onApply,
  });

  final ExperienceLevel? experienceLevel;
  final BudgetType? budgetType;
  final double? minBudget;
  final bool savedOnly;
  final void Function(
    ExperienceLevel? experience,
    BudgetType? budgetType,
    double? minBudget,
    bool savedOnly,
  )
  onApply;

  @override
  State<_JobFilterBottomSheet> createState() => _JobFilterBottomSheetState();
}

class _JobFilterBottomSheetState extends State<_JobFilterBottomSheet> {
  late ExperienceLevel? _experience = widget.experienceLevel;
  late BudgetType? _budgetType = widget.budgetType;
  late double? _minBudget = widget.minBudget;
  late bool _savedOnly = widget.savedOnly;

  static final List<({double? value, String label})> _budgetOptions = [
    (value: null, label: 'Any'),
    (value: 500, label: r'$500+'),
    (value: 1500, label: r'$1,500+'),
    (value: 3000, label: r'$3,000+'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        AppConstants.spaceLg,
        AppConstants.spaceLg,
        MediaQuery.of(context).viewInsets.bottom + AppConstants.spaceLg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Filter Jobs', style: theme.textTheme.titleMedium),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),

          Text('Experience Level', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppConstants.spaceSm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Any'),
                selected: _experience == null,
                onSelected: (_) => setState(() => _experience = null),
              ),
              for (final level in ExperienceLevel.values)
                ChoiceChip(
                  label: Text(level.label),
                  selected: _experience == level,
                  onSelected: (_) => setState(() => _experience = level),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceLg),

          Text('Payment Type', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppConstants.spaceSm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Any'),
                selected: _budgetType == null,
                onSelected: (_) => setState(() => _budgetType = null),
              ),
              for (final type in BudgetType.values)
                ChoiceChip(
                  label: Text(type.label),
                  selected: _budgetType == type,
                  onSelected: (_) => setState(() => _budgetType = type),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceLg),

          Text('Minimum Budget', style: theme.textTheme.titleSmall),
          const SizedBox(height: AppConstants.spaceSm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _budgetOptions.map((option) {
              final isSelected = _minBudget == option.value;
              return ChoiceChip(
                label: Text(option.label),
                selected: isSelected,
                onSelected: (_) => setState(() => _minBudget = option.value),
              );
            }).toList(),
          ),
          const SizedBox(height: AppConstants.spaceLg),

          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Saved jobs only'),
            value: _savedOnly,
            onChanged: (value) => setState(() => _savedOnly = value),
          ),
          const SizedBox(height: AppConstants.spaceMd),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _experience = null;
                      _budgetType = null;
                      _minBudget = null;
                      _savedOnly = false;
                    });
                  },
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    widget.onApply(_experience, _budgetType, _minBudget, _savedOnly);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Sort options for the jobs listing.
enum _JobSortOption {
  recommended('Recommended'),
  newest('Newest'),
  highestBudget('Highest Budget'),
  fewestProposals('Fewest Proposals');

  const _JobSortOption(this.label);
  final String label;
}
