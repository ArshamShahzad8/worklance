import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/freelancer_avatar.dart';
import '../../widgets/skill_input_field.dart';

/// Edit Freelancer Profile screen.
///
/// Collects (or updates) the freelancer-facing title, bio and skills. On
/// first save this marks the user as a freelancer, unlocking My Services
/// and Create Service.
class EditFreelancerProfileScreen extends StatefulWidget {
  const EditFreelancerProfileScreen({super.key});

  @override
  State<EditFreelancerProfileScreen> createState() =>
      _EditFreelancerProfileScreenState();
}

class _EditFreelancerProfileScreenState
    extends State<EditFreelancerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bioController;
  List<String> _skills = [];
  bool _isSaving = false;
  bool _skillsTouched = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bioController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = AppScope.of(context).user.user;
    // Only initialise controllers once (on first call) so user edits
    // are not overwritten when the widget rebuilds.
    if (_titleController.text.isEmpty && _bioController.text.isEmpty) {
      _titleController.text = user.isFreelancer ? user.title : '';
      _bioController.text = user.bio;
      _skills = List<String>.from(user.skills);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final formValid = _formKey.currentState!.validate();
    setState(() => _skillsTouched = true);
    final skillsError = validateSkillsList(_skills);
    if (!formValid || skillsError != null) return;

    setState(() => _isSaving = true);
    // Simulate a network call; replaced by a real profile-update API call
    // once a backend is wired up.
    await Future<void>.delayed(AppConstants.authSimulatedDelay);
    if (!mounted) return;

    final store = AppScope.of(context);
    store.user.update(title: _titleController.text.trim());
    store.user.updateFreelancerProfile(
      bio: _bioController.text.trim(),
      skills: _skills,
    );

    setState(() => _isSaving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Freelancer profile saved')));
    if (Navigator.of(context).canPop()) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final user = store.user.user;
    final isFirstTime = !user.isFreelancer;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isFirstTime ? 'Become a Freelancer' : 'Edit Freelancer Profile',
        ),
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
                    Center(
                      child: FreelancerAvatar(
                        name: user.name,
                        color: user.avatarColor,
                        radius: 40,
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    if (isFirstTime) ...[
                      Text(
                        'Set up your freelancer profile',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: AppConstants.spaceSm),
                      Text(
                        'Tell clients what you do best. This appears on '
                        'your public Freelancer Profile alongside your '
                        'services.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppConstants.spaceLg),
                    ],
                    AppTextField(
                      controller: _titleController,
                      label: 'Professional title',
                      hintText: 'e.g. Flutter Developer',
                      prefixIcon: Icons.work_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: validateServiceTitle,
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    AppTextField(
                      controller: _bioController,
                      label: 'Bio',
                      hintText:
                          'Introduce yourself and highlight your experience',
                      prefixIcon: Icons.info_outline_rounded,
                      maxLines: 5,
                      validator: validateBio,
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    SkillInputField(
                      skills: _skills,
                      onChanged: (skills) => setState(() => _skills = skills),
                      errorText: _skillsTouched
                          ? validateSkillsList(_skills)
                          : null,
                    ),
                    const SizedBox(height: AppConstants.spaceXl),
                    AppButton(
                      label: isFirstTime ? 'Save & Continue' : 'Save Changes',
                      icon: Icons.check_rounded,
                      loading: _isSaving,
                      onPressed: _handleSave,
                    ),
                    if (!isFirstTime) ...[
                      const SizedBox(height: AppConstants.spaceSm),
                      AppButton(
                        label: 'Cancel',
                        variant: AppButtonVariant.text,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
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
