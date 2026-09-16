import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'job.dart';
import 'milestone.dart';

/// Status of an [Order] (the active contract created once a proposal is
/// accepted), separate from [ProposalStatus] which only tracks the
/// proposal's own review process.
enum OrderStatus {
  accepted(
    'Accepted',
    'The proposal was accepted and the contract has started.',
    Icons.handshake_outlined,
  ),
  active(
    'Active',
    'Work is currently in progress.',
    Icons.play_circle_outline_rounded,
  ),
  submitted(
    'Submitted',
    'Work has been delivered and is awaiting review.',
    Icons.upload_file_rounded,
  ),
  completed(
    'Completed',
    'The project has been completed.',
    Icons.task_alt_rounded,
  );

  const OrderStatus(this.label, this.description, this.icon);

  final String label;
  final String description;
  final IconData icon;

  Color get color {
    switch (this) {
      case OrderStatus.accepted:
        return AppColors.info;
      case OrderStatus.active:
        return AppColors.primary;
      case OrderStatus.submitted:
        return AppColors.accent;
      case OrderStatus.completed:
        return AppColors.success;
    }
  }

  bool get isFinal => this == OrderStatus.completed;
}

/// One entry in an order's status timeline (mirrors [ProposalStatusEvent]).
class OrderStatusEvent {
  const OrderStatusEvent({
    required this.status,
    required this.timestamp,
    this.note,
  });

  final OrderStatus status;
  final DateTime timestamp;
  final String? note;
}

/// An active order/contract created once a client accepts a freelancer's
/// [Proposal] for a [Job].
///
/// This is the Week 5 continuation of the Week 4 proposal workflow:
/// Proposal → Accepted → Order/Contract → Project Progress. Lives only for
/// the current app session (see `OrdersController`), the same as every
/// other controller in this prototype.
class Order {
  Order({
    required this.id,
    required this.proposalId,
    required this.job,
    required this.freelancerName,
    required this.freelancerAvatarColor,
    required this.budget,
    required this.deadline,
    required this.createdAt,
    required this.milestones,
    this.status = OrderStatus.accepted,
    List<OrderStatusEvent>? statusHistory,
    this.deliveryNote,
    this.deliveredAt,
  }) : statusHistory =
           statusHistory ??
           [OrderStatusEvent(status: status, timestamp: createdAt)];

  final String id;

  /// The [Proposal.id] this order was created from.
  final String proposalId;
  final Job job;
  final String freelancerName;
  final Color freelancerAvatarColor;

  /// The agreed contract value (the freelancer's proposed amount).
  final double budget;
  final DateTime deadline;
  final DateTime createdAt;
  final List<Milestone> milestones;
  final OrderStatus status;
  final List<OrderStatusEvent> statusHistory;

  /// Notes the freelancer submitted with their delivery, if any.
  final String? deliveryNote;
  final DateTime? deliveredAt;

  /// Overall project progress from 0.0 to 1.0, based on completed
  /// milestones (or the order status itself if there are no milestones).
  double get progress {
    if (milestones.isEmpty) {
      return status == OrderStatus.completed ? 1 : 0;
    }
    return completedMilestonesCount / milestones.length;
  }

  int get completedMilestonesCount =>
      milestones.where((m) => m.status.isFinal).length;

  Order copyWith({
    OrderStatus? status,
    List<Milestone>? milestones,
    String? deliveryNote,
    DateTime? deliveredAt,
    String? note,
  }) {
    final newStatus = status ?? this.status;
    final statusChanged = status != null && status != this.status;
    return Order(
      id: id,
      proposalId: proposalId,
      job: job,
      freelancerName: freelancerName,
      freelancerAvatarColor: freelancerAvatarColor,
      budget: budget,
      deadline: deadline,
      createdAt: createdAt,
      milestones: milestones ?? this.milestones,
      status: newStatus,
      statusHistory: statusChanged
          ? [
              ...statusHistory,
              OrderStatusEvent(
                status: newStatus,
                timestamp: DateTime.now(),
                note: note,
              ),
            ]
          : statusHistory,
      deliveryNote: deliveryNote ?? this.deliveryNote,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }
}
