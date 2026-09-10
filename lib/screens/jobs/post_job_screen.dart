import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/category_repository.dart';
import '../../models/category.dart';
import '../../models/job.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/skill_input_field.dart';

/// Post a Job screen: a client-facing form to publish a new job to the
/// marketplace. The posted job is added to `JobsController` so it's
/// immediately visible in Find Jobs — no separate "sync" step needed.
class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minBudgetController = TextEditingController();
  final _maxBudgetController = TextEditingController();
  final _requirementsController = TextEditingController();

  Category? _category;
  List<String> _skills = [];
  BudgetType _budgetType = BudgetType.fixed;
  ExperienceLevel _experienceLevel = ExperienceLevel.intermediate;
  String _duration = _durationOptions.first;
  bool _isSubmitting = false;
  bool _categoryTouched = false;
  bool _skillsTouched = false;

  static const _durationOptions = [
    'Less than 1 month',
    '1 to 3 months',
    '3 to 6 months',
    'More than 6 months',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    _requirementsController.dispose();
    super.dispose();
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _titleController.clear();
    _descriptionController.clear();
    _minBudgetController.clear();
    _maxBudgetController.clear();
    _requirementsController.clear();
    setState(() {
      _category = null;
      _skills = [];
      _budgetType = BudgetType.fixed;
      _experienceLevel = ExperienceLevel.intermediate;
      _duration = _durationOptions.first;
      _categoryTouched = false;
      _skillsTouched = false;
    });
  }

  Future<void> _handleSubmit() async {
    final formValid = _formKey.currentState!.validate();
    setState(() {
      _categoryTouched = true;
      _skillsTouched = true;
    });
    final categoryError = validateCategorySelected(_category?.id);
    final skillsError = validateSkillsList(_skills);
    final min = double.tryParse(_minBudgetController.text.trim());
    final max = double.tryParse(_maxBudgetController.text.trim());
    final rangeError = validateBudgetRange(min, max);
    if (!formValid || categoryError != null || skillsError != null || rangeError != null) {
      if (rangeError != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(rangeError)));
      }
      return;
    }

    setState(() => _isSubmitting = true);
    // Simulate a network call; replaced by a real create-job API call once
    // a backend is wired up.
    await Future<void>.delayed(AppConstants.authSimulatedDelay);
    if (!mounted) return;

    final store = AppScope.of(context);
    var description = _descriptionController.text.trim();
    if (_requirementsController.text.trim().isNotEmpty) {
      description =
          '$description\n\nAdditional requirements:\n'
          '${_requirementsController.text.trim()}';
    }

    final job = Job(
      id: 'job_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: description,
      category: _category!,
      skills: _skills,
      budgetType: _budgetType,
      budgetMin: min!,
      budgetMax: max!,
      experienceLevel: _experienceLevel,
      duration: _duration,
      postedAt: DateTime.now(),
      proposalsCount: 0,
      client: store.user.asClient,
    );

    store.jobs.add(job);
    store.user.recordJobPosted();

    setState(() => _isSubmitting = false);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Job posted! It is now live in Find Jobs.')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = CategoryRepository.getAll();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Post a Job'),
        actions: [
          IconButton(
            tooltip: 'Reset form',
            onPressed: _resetForm,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: AppConstants.maxContentWidth),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Tell freelancers what you need', style: theme.textTheme.headlineSmall),
                    const SizedBox(height: AppConstants.spaceSm),
                    Text(
                      'A clear, detailed job post attracts stronger '
                      'proposals from the right freelancers.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceLg),
                    AppTextField(
                      controller: _titleController,
                      label: 'Job title',
                      hintText: 'e.g. Flutter Developer for Fitness App',
                      prefixIcon: Icons.title_rounded,
                      textInputAction: TextInputAction.next,
                      validator: validateServiceTitle,
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    AppTextField(
                      controller: _descriptionController,
                      label: 'Job description',
                      hintText: 'Describe the project, goals and deliverables',
                      prefixIcon: Icons.description_outlined,
                      maxLines: 5,
                      validator: validateServiceDescription,
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    DropdownButtonFormField<Category>(
                      value: _category,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        prefixIcon: const Icon(Icons.category_outlined),
                        errorText: _categoryTouched
                            ? validateCategorySelected(_category?.id)
                            : null,
                      ),
                      items: [
                        for (final category in categories)
                          DropdownMenuItem(value: category, child: Text(category.name)),
                      ],
                      onChanged: (value) => setState(() {
                        _category = value;
                        _categoryTouched = true;
                      }),
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    SkillInputField(
                      label: 'Required skills',
                      skills: _skills,
                      onChanged: (skills) => setState(() => _skills = skills),
                      errorText: _skillsTouched ? validateSkillsList(_skills) : null,
                    ),
                    const SizedBox(height: AppConstants.spaceLg),
                    Text('Budget type', style: theme.textTheme.titleSmall),
                    const SizedBox(height: AppConstants.spaceSm),
                    SegmentedButton<BudgetType>(
                      segments: [
                        for (final type in BudgetType.values)
                          ButtonSegment(value: type, label: Text(type.label)),
                      ],
                      selected: {_budgetType},
                      onSelectionChanged: (selection) =>
                          setState(() => _budgetType = selection.first),
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _minBudgetController,
                            label: _budgetType == BudgetType.hourly
                                ? 'Min rate (${AppConstants.currencySymbol}/hr)'
                                : 'Min budget (${AppConstants.currencySymbol})',
                            hintText: 'e.g. 500',
                            prefixIcon: Icons.attach_money_rounded,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: validatePrice,
                          ),
                        ),
                        const SizedBox(width: AppConstants.spaceMd),
                        Expanded(
                          child: AppTextField(
                            controller: _maxBudgetController,
                            label: _budgetType == BudgetType.hourly
                                ? 'Max rate (${AppConstants.currencySymbol}/hr)'
                                : 'Max budget (${AppConstants.currencySymbol})',
                            hintText: 'e.g. 1200',
                            prefixIcon: Icons.attach_money_rounded,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: validatePrice,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spaceLg),
                    Text('Experience level', style: theme.textTheme.titleSmall),
                    const SizedBox(height: AppConstants.spaceSm),
                    SegmentedButton<ExperienceLevel>(
                      segments: [
                        for (final level in ExperienceLevel.values)
                          ButtonSegment(value: level, label: Text(level.label)),
                      ],
                      selected: {_experienceLevel},
                      onSelectionChanged: (selection) =>
                          setState(() => _experienceLevel = selection.first),
                    ),
                    const SizedBox(height: AppConstants.spaceLg),
                    DropdownButtonFormField<String>(
                      value: _duration,
                      decoration: const InputDecoration(
                        labelText: 'Project duration',
                        prefixIcon: Icon(Icons.calendar_month_outlined),
                      ),
                      items: [
                        for (final option in _durationOptions)
                          DropdownMenuItem(value: option, child: Text(option)),
                      ],
                      onChanged: (value) =>
                          setState(() => _duration = value ?? _duration),
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    AppTextField(
                      controller: _requirementsController,
                      label: 'Additional requirements (optional)',
                      hintText: 'Timezone overlap, tools you use, etc.',
                      prefixIcon: Icons.notes_rounded,
                      maxLines: 3,
                    ),
                    const SizedBox(height: AppConstants.spaceXl),
                    AppButton(
                      label: 'Post Job',
                      icon: Icons.check_rounded,
                      loading: _isSubmitting,
                      onPressed: _handleSubmit,
                    ),
                    const SizedBox(height: AppConstants.spaceSm),
                    AppButton(
                      label: 'Cancel',
                      variant: AppButtonVariant.text,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
