import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/freelancer_avatar.dart';

/// Edit Profile screen: full-screen form for name, email, title and
/// location, with live avatar/initials preview, validation, and a loading +
/// success flow. Replaces the Week 2 inline dialog with a dedicated screen
/// so the flow matches Login/Registration and supports a proper transition.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _titleController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = AppScope.of(context).user.user;
    // Only populate controllers on first build so user edits aren't lost.
    if (_nameController.text.isEmpty && _emailController.text.isEmpty) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _titleController.text = user.title;
      _locationController.text = user.location;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _titleController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    // Simulate a network call; replaced by a real profile-update API call
    // once a backend is wired up.
    await Future<void>.delayed(AppConstants.authSimulatedDelay);
    if (!mounted) return;

    AppScope.of(context).user.update(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      title: _titleController.text.trim(),
      location: _locationController.text.trim(),
    );

    setState(() => _isSaving = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
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
                      child: AnimatedBuilder(
                        animation: _nameController,
                        builder: (context, _) => FreelancerAvatar(
                          name: _nameController.text.isEmpty
                              ? ' '
                              : _nameController.text,
                          color: AppScope.of(context).user.user.avatarColor,
                          radius: 44,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceSm),
                    Center(
                      child: Text(
                        'Tap fields below to update your details',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppConstants.spaceLg),
                    AppTextField(
                      controller: _nameController,
                      label: 'Full name',
                      prefixIcon: Icons.person_outline_rounded,
                      textInputAction: TextInputAction.next,
                      validator: validateName,
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    AppTextField(
                      controller: _emailController,
                      label: 'Email address',
                      prefixIcon: Icons.mail_outline_rounded,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: validateEmail,
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    AppTextField(
                      controller: _titleController,
                      label: 'Title',
                      hintText: 'e.g. Client, Product Designer',
                      prefixIcon: Icons.badge_outlined,
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppConstants.spaceMd),
                    AppTextField(
                      controller: _locationController,
                      label: 'Location',
                      hintText: 'e.g. Rawalpindi, Pakistan',
                      prefixIcon: Icons.location_on_outlined,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleSave(),
                    ),
                    const SizedBox(height: AppConstants.spaceXl),
                    AppButton(
                      label: 'Save Changes',
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
