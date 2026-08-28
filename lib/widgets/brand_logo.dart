import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// The WORKLANCE logo mark: a rounded square with a work icon.
///
/// Used on the Splash and Welcome screens. Set [light] to `true` when it
/// sits on top of a colored/gradient background.
class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.size = 88, this.light = false});

  final double size;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: light
            ? Colors.white.withValues(alpha: 0.14)
            : AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: light
            ? Border.all(
                color: Colors.white.withValues(alpha: 0.35),
                width: 1.5,
              )
            : null,
      ),
      child: Icon(
        Icons.work_rounded,
        size: size * 0.5,
        color: light ? Colors.white : AppColors.primary,
      ),
    );
  }
}
