import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../data/repositories/category_repository.dart';
import '../../models/category.dart';
import '../../models/service.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/skill_input_field.dart';

/// Create Service screen.
///
/// Pass [existingService] to switch the form into edit mode: fields are
/// pre-filled and saving updates the listing instead of creating a new one.
class CreateServiceScreen extends StatefulWidget {
  const CreateServiceScreen({super.key, this.existingService});

  final Service? existingService;

  @override
  State<CreateServiceScreen> createState() => _CreateServiceScreenState();
}

class _CreateServiceScreenState extends State<CreateServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _deliveryController;
  Category? _category;
  List<String> _skills = [];
  bool _isSaving = false;
  bool _categoryTouched = false;
  bool _skillsTouched = false;

  bool get _isEditing => widget.existingService != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existingService;
    _titleController = TextEditingController(text: existing?.title ?? '');
    _descriptionController = TextEditingController(
      text: existing?.description ?? '',
    );
    _priceController = TextEditingController(
      text: existing != null ? _formatPriceInput(existing.price) : '',
    );
    _deliveryController = TextEditingController(
      text: existing != null ? '${existing.deliveryDays}' : '',
    );
    _category = existing?.category;
    _skills = existing != null ? List<String>.from(existing.skills) : [];
  }

  String _formatPriceInput(double price) =>
      price == price.roundToDouble() ? price.toInt().toString() : '$price';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _deliveryController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final formValid = _formKey.currentState!.validate();
    setState(() {
      _categoryTouched = true;
      _skillsTouched = true;
    });
    final categoryError = validateCategorySelected(_category?.id);
    final skillsError = validateSkillsList(_skills);
    if (!formValid || categoryError != null || skillsError != null) return;

    setState(() => _isSaving = true);
    // Simulate a network call; replaced by a real create/update API call
    // once a backend is wired up.
    await Future<void>.delayed(AppConstants.authSimulatedDelay);
    if (!mounted) return;

    final store = AppScope.of(context);
    final existing = widget.existingService;
    final service = Service(
      id: existing?.id ?? 'svc_${DateTime.now().millisecondsSinceEpoch}',
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _category!,
      freelancer: store.user.asFreelancer,
      price: double.parse(_priceController.text.trim()),
      deliveryDays: int.parse(_deliveryController.text.trim()),
      skills: _skills,
      featured: existing?.featured ?? false,
    );

    if (existing != null) {
      store.services.update(service);
    } else {
      store.services.add(service);
    }

    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEditing ? 'Service updated' : 'Service created'),
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _handleDelete() async {
    final existing = widget.existingService;
    if (existing == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete service?'),
        content: Text('"${existing.title}" will be removed permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      AppScope.of(context).services.remove(existing.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = CategoryRepository.getAll();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Service' : 'Create Service'),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: 'Delete service',
              onPressed: _handleDelete,
              icon: const Icon(Icons.delete_outline_rounded),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxContentWidth,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      _isEditing ? 'Update your listing' : 'List a new service',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: AppConstants.spaceSm),
                    Text(
                      'Describe what you offer clearly so clients know '
                      'exactly what they are hiring you for.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceLg),
                    AppTextField(
                      controller: _titleController,
                      label: 'Service title',
                      hintText: 'e.g. Flutter Mobile App Development',
                      prefixIcon: Icons.title_rounded,
                      textInputAction: TextInputAction.next,
                      validator: validateServiceTitle,
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    AppTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hintText: 'What will you deliver? What makes it great?',
                      prefixIcon: Icons.description_outlined,
                      maxLines: 4,
                      validator: validateServiceDescription,
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    DropdownButtonFormField<Category>(
                      initialValue: _category,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        prefixIcon: const Icon(Icons.category_outlined),
                        errorText: _categoryTouched
                            ? validateCategorySelected(_category?.id)
                            : null,
                      ),
                      items: [
                        for (final category in categories)
                          DropdownMenuItem(
                            value: category,
                            child: Text(category.name),
                          ),
                      ],
                      onChanged: (value) => setState(() {
                        _category = value;
                        _categoryTouched = true;
                      }),
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: AppTextField(
                            controller: _priceController,
                            label: 'Price (${AppConstants.currencySymbol})',
                            hintText: 'e.g. 250',
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
                            controller: _deliveryController,
                            label: 'Delivery (days)',
                            hintText: 'e.g. 7',
                            prefixIcon: Icons.schedule_rounded,
                            keyboardType: TextInputType.number,
                            textInputAction: TextInputAction.done,
                            validator: validateDeliveryDays,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    SkillInputField(
                      label: 'Skills covered',
                      skills: _skills,
                      onChanged: (skills) => setState(() => _skills = skills),
                      errorText: _skillsTouched
                          ? validateSkillsList(_skills)
                          : null,
                    ),
                    const SizedBox(height: AppConstants.spaceXl),
                    AppButton(
                      label: _isEditing ? 'Save Changes' : 'Publish Service',
                      icon: Icons.check_rounded,
                      loading: _isSaving,
                      onPressed: _handleSave,
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
