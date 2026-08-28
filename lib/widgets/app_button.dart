import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';

enum AppButtonVariant { primary, outline, text, danger }

/// Reusable WORKLANCE button with built-in loading state.
///
/// Variants map to Material 3 button types; pass [loading] to show a spinner
/// and disable the button while an async action runs.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.loading = false,
    this.icon,
    this.expanded = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool loading;
  final IconData? icon;
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final Widget child;
    if (loading) {
      child = SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          color: _spinnerColor,
        ),
      );
    } else if (icon != null) {
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      );
    } else {
      child = Text(label, textAlign: TextAlign.center);
    }

    final sizeAndShape = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(expanded ? double.infinity : 0, 52),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
        ),
      ),
      textStyle: WidgetStatePropertyAll(
        Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
    );

    final Widget button = switch (variant) {
      AppButtonVariant.primary || AppButtonVariant.danger => FilledButton(
        onPressed: loading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: variant == AppButtonVariant.danger
              ? AppColors.error
              : AppColors.primary,
          foregroundColor: Colors.white,
        ).merge(sizeAndShape),
        child: child,
      ),
      AppButtonVariant.outline => OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.2),
        ).merge(sizeAndShape),
        child: child,
      ),
      AppButtonVariant.text => TextButton(
        onPressed: loading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: child,
      ),
    };

    return button;
  }

  Color get _spinnerColor {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.danger:
        return Colors.white;
      case AppButtonVariant.outline:
      case AppButtonVariant.text:
        return AppColors.primary;
    }
  }
}
