import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_logo.dart';

/// Login screen.
///
/// Includes form validation, show/hide password, remember-me checkbox,
/// forgot-password and social-login placeholders, and a loading state.
/// No real authentication — any valid input navigates to the marketplace.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final store = AppScope.of(context);
    setState(() => _isLoading = true);
    // Simulate a network call; replaced by real auth in a later week.
    await Future<void>.delayed(AppConstants.authSimulatedDelay);
    if (!mounted) return;

    // Keep the local profile consistent with the email used to log in.
    store.user.loginAs(_emailController.text);

    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Welcome back to ${AppConstants.appName}!')),
    );
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.marketplace, (route) => false);
  }

  void _showPrototypeMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                            'Welcome back',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: AppConstants.spaceSm),
                          Text(
                            'Log in to find the right talent for your project.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppConstants.spaceXl),
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
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: true,
                            enableVisibilityToggle: true,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            validator: validateLoginPassword,
                            onFieldSubmitted: (_) => _handleLogin(),
                          ),
                          const SizedBox(height: AppConstants.spaceXs),
                          Row(
                            children: [
                              Checkbox(
                                value: _rememberMe,
                                onChanged: (value) => setState(
                                  () => _rememberMe = value ?? false,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  'Remember me',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              Flexible(
                                child: TextButton(
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  onPressed: () => Navigator.of(
                                    context,
                                  ).pushNamed(AppRoutes.forgotPassword),
                                  child: const Text(
                                    'Forgot password?',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spaceMd),
                          AppButton(
                            label: 'Log In',
                            icon: Icons.login_rounded,
                            loading: _isLoading,
                            onPressed: _handleLogin,
                          ),
                          const SizedBox(height: AppConstants.spaceLg),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppConstants.spaceMd,
                                ),
                                child: Text(
                                  'or continue with',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spaceMd),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showPrototypeMessage(
                                    'Google sign-in is a prototype '
                                    'placeholder.',
                                  ),
                                  icon: const Icon(Icons.g_mobiledata_rounded),
                                  label: const Text('Google'),
                                ),
                              ),
                              const SizedBox(width: AppConstants.spaceMd),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showPrototypeMessage(
                                    'Apple sign-in is a prototype '
                                    'placeholder.',
                                  ),
                                  icon: const Icon(Icons.apple_rounded),
                                  label: const Text('Apple'),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppConstants.spaceLg),
                          Wrap(
                            alignment: WrapAlignment.center,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                "Don't have an account?",
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(
                                  context,
                                ).pushReplacementNamed(AppRoutes.register),
                                child: const Text('Create one'),
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
