import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';

/// Status of a single [Milestone] within an [Order].
///
/// Like [ProposalStatus], every transition here happens locally — the
/// freelancer moves their own milestones forward (there is no backend), and
/// screens should keep presenting that honestly.
enum MilestoneStatus {
  pending(
    'Pending',
    'Not started yet.',
    Icons.schedule_rounded,
  ),
  inProgress(
    'In Progress',
    'Work on this milestone is underway.',
    Icons.autorenew_rounded,
  ),
  submitted(
    'Submitted',
    'Delivered and waiting for approval.',
    Icons.upload_rounded,
  ),
  completed(
    'Completed',
    'Approved and marked complete.',
    Icons.check_circle_rounded,
  );

  const MilestoneStatus(this.label, this.description, this.icon);

  final String label;
  final String description;
  final IconData icon;

  Color get color {
    switch (this) {
      case MilestoneStatus.pending:
        return AppColors.textMuted;
      case MilestoneStatus.inProgress:
        return AppColors.info;
      case MilestoneStatus.submitted:
        return AppColors.accent;
      case MilestoneStatus.completed:
        return AppColors.success;
    }
  }

  /// The next status in the simple linear flow, or null if this is final.
  MilestoneStatus? get next {
    switch (this) {
      case MilestoneStatus.pending:
        return MilestoneStatus.inProgress;
      case MilestoneStatus.inProgress:
        return MilestoneStatus.submitted;
      case MilestoneStatus.submitted:
        return MilestoneStatus.completed;
      case MilestoneStatus.completed:
        return null;
    }
  }

  bool get isFinal => this == MilestoneStatus.completed;
}

/// One deliverable milestone inside an [Order]'s contract.
class Milestone {
  Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.dueDate,
    this.status = MilestoneStatus.pending,
  });

  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime dueDate;
  final MilestoneStatus status;

  Milestone copyWithStatus(MilestoneStatus newStatus) {
    return Milestone(
      id: id,
      title: title,
      description: description,
      amount: amount,
      dueDate: dueDate,
      status: newStatus,
    );
  }
}
