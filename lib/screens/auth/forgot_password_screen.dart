import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/brand_logo.dart';

/// Forgot Password screen.
///
/// Collects an email address, validates it, then sends a real
/// password-reset email through Firebase Auth and shows a confirmation
/// state with a resend option.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _emailSent = true;
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      // Firebase returns the same message for user-not-found and
      // invalid-email to prevent account enumeration.
      final message = switch (e.code) {
        'user-not-found' || 'invalid-email' =>
          'If an account exists for that email, a reset link has been sent.',
        _ => 'Something went wrong. Please try again later.',
      };

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      // If Firebase was never initialized (e.g. the app was hot-reloaded
      // after main.dart changed, or init failed at startup) the call above
      // throws a generic error — show a helpful hint instead of a
      // misleading "check your connection" message.
      final firebaseReady = Firebase.apps.isNotEmpty;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            firebaseReady
                ? 'Could not send reset email. Check your connection and try again.'
                : "Firebase isn't ready — fully restart the app and try again.",
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) =>
                              FadeTransition(
                                opacity: animation,
                                child: SlideTransition(
                                  position:
                                      Tween<Offset>(
                                        begin: const Offset(0, 0.05),
                                        end: Offset.zero,
                                      ).animate(
                                        CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOut,
                                        ),
                                      ),
                                  child: child,
                                ),
                              ),
                          child: _emailSent
                              ? _SuccessContent(
                                  key: const ValueKey('success'),
                                  email: _emailController.text.trim(),
                                  onResend: _handleSubmit,
                                  isResending: _isLoading,
                                )
                              : _FormContent(
                                  key: const ValueKey('form'),
                                  formKey: _formKey,
                                  emailController: _emailController,
                                  isLoading: _isLoading,
                                  onSubmit: _handleSubmit,
                                ),
                        ),
                      ],
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

class _FormContent extends StatelessWidget {
  const _FormContent({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Forgot password?',
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppConstants.spaceSm),
          Text(
            "No worries — enter the email on your account and we'll send "
            'you a link to reset your password.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXl),
          AppTextField(
            controller: emailController,
            label: 'Email address',
            hintText: 'you@example.com',
            prefixIcon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            validator: validateEmail,
            onFieldSubmitted: (_) => onSubmit(),
          ),
          const SizedBox(height: AppConstants.spaceLg),
          AppButton(
            label: 'Send Reset Link',
            icon: Icons.send_rounded,
            loading: isLoading,
            onPressed: onSubmit,
          ),
          const SizedBox(height: AppConstants.spaceMd),
          AppButton(
            label: 'Back to Login',
            variant: AppButtonVariant.text,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({
    super.key,
    required this.email,
    required this.onResend,
    required this.isResending,
  });

  final String email;
  final VoidCallback onResend;
  final bool isResending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              color: AppColors.primary,
              size: 36,
            ),
          ),
        ),
        const SizedBox(height: AppConstants.spaceLg),
        Text(
          'Check your email',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Text(
          'If an account exists for $email, a password-reset link is on '
          "its way. It can take a minute or two — don't forget to check "
          'spam.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.spaceXl),
        AppButton(
          label: 'Back to Login',
          icon: Icons.login_rounded,
          onPressed: () => Navigator.of(context).pop(),
        ),
        const SizedBox(height: AppConstants.spaceMd),
        AppButton(
          label: "Didn't get it? Resend",
          variant: AppButtonVariant.text,
          loading: isResending,
          onPressed: onResend,
        ),
      ],
    );
  }
}
