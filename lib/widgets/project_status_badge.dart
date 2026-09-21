import 'package:flutter/material.dart';

import '../models/project.dart';
import 'status_pill.dart';

/// Small colored pill showing a [ProjectStatus].
class ProjectStatusBadge extends StatelessWidget {
  const ProjectStatusBadge({
    super.key,
    required this.status,
    this.large = false,
  });

  final ProjectStatus status;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return StatusPill(
      label: status.label,
      icon: status.icon,
      color: status.color,
      large: large,
    );
  }
}

/// Pill showing a single [MilestoneStatus].
class MilestoneStatusBadge extends StatelessWidget {
  const MilestoneStatusBadge({super.key, required this.status});

  final MilestoneStatus status;

  @override
  Widget build(BuildContext context) {
    return StatusPill(
      label: status.label,
      icon: status.icon,
      color: status.color,
    );
  }
}
