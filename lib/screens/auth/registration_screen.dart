import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/password_strength_indicator.dart';

/// Registration screen.
///
/// Validates name, email, password rules, confirm-password match and the
/// Terms & Conditions checkbox, then navigates to the marketplace. No real
/// account creation in this Week 1 build.
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final store = AppScope.of(context);
    setState(() => _isLoading = true);
    // Simulate a network call; replaced by real auth in a later week.
    await Future<void>.delayed(AppConstants.authSimulatedDelay);
    if (!mounted) return;

    // Store the entered user locally so the greeting and Profile screen show
    // exactly what was registered (no mock user after registration).
    store.user.update(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
    );

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Account created. Welcome to ${AppConstants.appName}!')),
    );
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.marketplace,
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceLg,
                vertical: AppConstants.spaceMd,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - AppConstants.spaceXl,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppConstants.maxContentWidth,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              tooltip: 'Back',
                              icon: const Icon(Icons.arrow_back_rounded),
                            ),
                          ),
                          const Center(child: BrandLogo(size: 64)),
                          const SizedBox(height: AppConstants.spaceMd),
                          Text(
                            'Create your account',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppConstants.spaceSm),
                          Text(
                            'Join WORKLANCE and start hiring top freelancers.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spaceXl),
                          AppTextField(
                            controller: _nameController,
                            label: 'Full name',
                            hintText: 'e.g. Aarsham Shahzad',
                            prefixIcon: Icons.person_outline_rounded,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                            validator: validateName,
                          ),
                          const SizedBox(height: AppConstants.spaceMd),
                          AppTextField(
                            controller: _emailController,
                            label: 'Email address',
                            hintText: 'you@example.com',
                            prefixIcon: Icons.mail_outline_rounded,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            validator: validateEmail,
                          ),
                          const SizedBox(height: AppConstants.spaceMd),
                          AppTextField(
                            controller: _passwordController,
                            label: 'Password',
                            hintText: 'At least 8 characters',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            enableVisibilityToggle: true,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.newPassword],
                            validator: validateRegistrationPassword,
                          ),
                          const SizedBox(height: AppConstants.spaceSm),
                          ValueListenableBuilder<TextEditingValue>(
                            valueListenable: _passwordController,
                            builder: (context, value, _) =>
                                PasswordStrengthIndicator(password: value.text),
                          ),
                          const SizedBox(height: AppConstants.spaceMd),
                          AppTextField(
                            controller: _confirmPasswordController,
                            label: 'Confirm password',
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            enableVisibilityToggle: true,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleRegister(),
                            validator: (value) => validateConfirmPassword(
                              value,
                              _passwordController.text,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spaceSm),
                          FormField<bool>(
                            validator: validateTermsAccepted,
                            builder: (state) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        height: 40,
                                        child: Checkbox(
                                          value: state.value ?? false,
                                          onChanged: (value) =>
                                              state.didChange(value ?? false),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          'I agree to the Terms & Conditions '
                                          'and Privacy Policy',
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (state.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: AppConstants.spaceMd,
                                        top: AppConstants.spaceXs,
                                      ),
                                      child: Text(
                                        state.errorText!,
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(color: AppColors.error),
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: AppConstants.spaceMd),
                          AppButton(
                            label: 'Create Account',
                            icon: Icons.person_add_alt_1_rounded,
                            loading: _isLoading,
                            onPressed: _handleRegister,
                          ),
                          const SizedBox(height: AppConstants.spaceLg),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                'Already have an account?',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context)
                                    .pushReplacementNamed(AppRoutes.login),
                                child: const Text('Login'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
