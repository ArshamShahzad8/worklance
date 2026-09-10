import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'job.dart';

/// Status of a submitted [Proposal].
///
/// All status changes in this app happen locally (see `ProposalsController`)
/// — there is no real client reviewing anything yet. Screens must make that
/// clear to the user rather than implying a real response was received.
enum ProposalStatus {
  submitted(
    'Submitted',
    'Your proposal has been sent and is waiting to be opened.',
    Icons.send_rounded,
  ),
  underReview(
    'Under Review',
    'The client has opened your proposal and is reviewing it.',
    Icons.visibility_outlined,
  ),
  shortlisted(
    'Shortlisted',
    "You're on the client's shortlist for this job.",
    Icons.star_outline_rounded,
  ),
  accepted(
    'Accepted',
    'Congratulations — your proposal was accepted!',
    Icons.check_circle_outline_rounded,
  ),
  rejected(
    'Rejected',
    'The client chose a different freelancer for this job.',
    Icons.cancel_outlined,
  ),
  withdrawn(
    'Withdrawn',
    'You withdrew this proposal.',
    Icons.undo_rounded,
  );

  const ProposalStatus(this.label, this.description, this.icon);

  final String label;
  final String description;
  final IconData icon;

  /// Color used for badges, timelines and status text.
  Color get color {
    switch (this) {
      case ProposalStatus.submitted:
        return AppColors.info;
      case ProposalStatus.underReview:
        return AppColors.accent;
      case ProposalStatus.shortlisted:
        return AppColors.primary;
      case ProposalStatus.accepted:
        return AppColors.success;
      case ProposalStatus.rejected:
        return AppColors.error;
      case ProposalStatus.withdrawn:
        return AppColors.textMuted;
    }
  }

  /// Whether the freelancer can still withdraw a proposal in this status.
  bool get canWithdraw =>
      this == ProposalStatus.submitted ||
      this == ProposalStatus.underReview ||
      this == ProposalStatus.shortlisted;

  /// Whether this is a final state (no further status changes expected).
  bool get isFinal =>
      this == ProposalStatus.accepted ||
      this == ProposalStatus.rejected ||
      this == ProposalStatus.withdrawn;
}

/// One entry in a proposal's status timeline.
class ProposalStatusEvent {
  const ProposalStatusEvent({
    required this.status,
    required this.timestamp,
    this.note,
  });

  final ProposalStatus status;
  final DateTime timestamp;
  final String? note;
}

/// A freelancer's proposal submitted against a [Job].
class Proposal {
  Proposal({
    required this.id,
    required this.job,
    required this.coverLetter,
    required this.proposedAmount,
    required this.estimatedDuration,
    required this.submittedAt,
    this.status = ProposalStatus.submitted,
    List<ProposalStatusEvent>? statusHistory,
  }) : statusHistory =
           statusHistory ??
           [ProposalStatusEvent(status: status, timestamp: submittedAt)];

  final String id;
  final Job job;
  final String coverLetter;
  final double proposedAmount;
  final String estimatedDuration;
  final DateTime submittedAt;
  final ProposalStatus status;
  final List<ProposalStatusEvent> statusHistory;

  Proposal copyWithStatus(ProposalStatus newStatus, {String? note}) {
    return Proposal(
      id: id,
      job: job,
      coverLetter: coverLetter,
      proposedAmount: proposedAmount,
      estimatedDuration: estimatedDuration,
      submittedAt: submittedAt,
      status: newStatus,
      statusHistory: [
        ...statusHistory,
        ProposalStatusEvent(
          status: newStatus,
          timestamp: DateTime.now(),
          note: note,
        ),
      ],
    );
  }
}
