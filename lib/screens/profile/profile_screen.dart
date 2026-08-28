import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/freelancer_avatar.dart';

/// Profile tab: avatar, name, email, edit profile, settings placeholders
/// and logout (returns to the Welcome screen).
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  Future<void> _editProfile() async {
    final store = AppScope.of(context);
    final nameController = TextEditingController(text: store.user.user.name);
    final emailController = TextEditingController(text: store.user.user.email);
    final formKey = GlobalKey<FormState>();

    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                controller: nameController,
                label: 'Full name',
                validator: validateName,
              ),
              const SizedBox(height: AppConstants.spaceMd),
              AppTextField(
                controller: emailController,
                label: 'Email address',
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(true);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (saved == true && mounted) {
      store.user.update(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    }
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will return to the WORKLANCE welcome screen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.welcome, (route) => false);
    }
  }

  void _showPrototypeMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final user = store.user.user;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        children: [
          const SizedBox(height: AppConstants.spaceSm),
          Center(
            child: FreelancerAvatar(
              name: user.name,
              color: AppColors.primary,
              radius: 44,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Center(child: Text(user.name, style: theme.textTheme.titleLarge)),
          const SizedBox(height: AppConstants.spaceXs),
          Center(
            child: Text(
              user.email,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(user.location, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'WORKLANCE member',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          AppButton(
            label: 'Edit Profile',
            variant: AppButtonVariant.outline,
            icon: Icons.edit_outlined,
            onPressed: _editProfile,
          ),
          const SizedBox(height: AppConstants.spaceLg),
          Text('Settings', style: theme.textTheme.titleMedium),
          const SizedBox(height: AppConstants.spaceSm),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Notifications'),
                  subtitle: const Text('Service updates & offers'),
                  value: _notificationsEnabled,
                  onChanged: (value) =>
                      setState(() => _notificationsEnabled = value),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.lock_outline_rounded),
                  title: const Text('Privacy & Security'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showPrototypeMessage(
                    'Privacy settings are a prototype placeholder.',
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded),
                  title: const Text('Help & Support'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showPrototypeMessage(
                    'Help & Support is a prototype placeholder.',
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: const Text('About WORKLANCE'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => _showPrototypeMessage(
                    '${AppConstants.appName} v1.0.0 — '
                    'Marketplace browsing & freelancer profiles.',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          AppButton(
            label: 'Log Out',
            variant: AppButtonVariant.danger,
            icon: Icons.logout_rounded,
            onPressed: _confirmLogout,
          ),
          const SizedBox(height: AppConstants.spaceLg),
        ],
      ),
    );
  }
}
