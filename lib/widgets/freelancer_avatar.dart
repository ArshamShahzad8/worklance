import 'package:flutter/material.dart';

/// Renders a colored initials avatar for a person.
///
/// WORKLANCE uses initials avatars instead of image assets, so no image
/// files can go missing and every profile looks consistent.
class FreelancerAvatar extends StatelessWidget {
  const FreelancerAvatar({
    super.key,
    required this.name,
    required this.color,
    this.radius = 22,
  });

  final String name;
  final Color color;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text(
        _initials,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: radius * 0.75,
        ),
      ),
    );
  }

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    final first = parts.first[0];
    final last = parts.length > 1 ? parts.last[0] : '';
    return (first + last).toUpperCase();
  }
}
