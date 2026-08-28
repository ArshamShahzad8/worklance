import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/password_strength.dart';

/// Live password strength feedback for the Registration screen:
/// a Weak/Medium/Strong meter plus a checklist of the requirements the
/// password must meet (mirroring `validateRegistrationPassword`).
class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({super.key, required this.password});

  final String password;

  List<({String label, bool met})> get _requirements => [
    (label: 'At least 8 characters', met: password.length >= 8),
    (label: 'One uppercase letter', met: RegExp(r'[A-Z]').hasMatch(password)),
    (label: 'One lowercase letter', met: RegExp(r'[a-z]').hasMatch(password)),
    (label: 'One number', met: RegExp(r'[0-9]').hasMatch(password)),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strength = passwordStrength(password);
    final color = switch (strength) {
      PasswordStrength.weak => AppColors.error,
      PasswordStrength.medium => AppColors.accent,
      PasswordStrength.strong => AppColors.success,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (password.isNotEmpty) ...[
          Row(
            children: [
              Expanded(
                child: _StrengthBar(level: strength.level, color: color),
              ),
              const SizedBox(width: 10),
              Text(
                strength.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceSm),
        ],
        for (final requirement in _requirements)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Icon(
                  requirement.met
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  size: 14,
                  color: requirement.met
                      ? AppColors.success
                      : AppColors.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    requirement.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: requirement.met
                          ? AppColors.textSecondary
                          : AppColors.textMuted,
                      fontWeight: requirement.met
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Three-segment meter; `level` of the segments are filled with [color].
class _StrengthBar extends StatelessWidget {
  const _StrengthBar({required this.level, required this.color});

  final int level;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: i < level ? color : AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          if (i < 2) const SizedBox(width: 6),
        ],
      ],
    );
  }
}
