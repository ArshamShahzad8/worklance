import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import 'category.dart';
import 'freelancer.dart';
import 'proposal.dart';
import 'service.dart';

/// Which side of an engagement the current user is on.
enum ProjectRole {
  client('Client', 'You ordered this'),
  freelancer('Freelancer', 'You are delivering this');

  const ProjectRole(this.label, this.description);

  final String label;
  final String description;
}

/// Where a [Project] came from.
enum ProjectSource {
  serviceOrder('Service order', Icons.shopping_bag_outlined),
  jobContract('Job contract', Icons.handshake_outlined);

  const ProjectSource(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Lifecycle state of a project/order.
enum ProjectStatus {
  pending(
    'Pending',
    'Waiting to start. Confirm the brief and kick the work off.',
    Icons.schedule_rounded,
  ),
  active(
    'In Progress',
    'Work is underway. Track milestones as they are completed.',
    Icons.play_circle_outline_rounded,
  ),
  submitted(
    'Delivered',
    'The work has been submitted and is waiting for client review.',
    Icons.local_shipping_outlined,
  ),
  completed(
    'Completed',
    'This project is finished and closed.',
    Icons.verified_rounded,
  ),
  cancelled(
    'Cancelled',
    'This project was cancelled before delivery.',
    Icons.cancel_outlined,
  );

  const ProjectStatus(this.label, this.description, this.icon);

  final String label;
  final String description;
  final IconData icon;

  Color get color {
    switch (this) {
      case ProjectStatus.pending:
        return AppColors.accent;
      case ProjectStatus.active:
        return AppColors.info;
      case ProjectStatus.submitted:
        return AppColors.primary;
      case ProjectStatus.completed:
        return AppColors.success;
      case ProjectStatus.cancelled:
        return AppColors.textMuted;
    }
  }

  bool get isOpen =>
      this == ProjectStatus.pending ||
      this == ProjectStatus.active ||
      this == ProjectStatus.submitted;

  bool get isFinal =>
      this == ProjectStatus.completed || this == ProjectStatus.cancelled;

  bool get canCancel =>
      this == ProjectStatus.pending || this == ProjectStatus.active;
}

/// Progress state of a single [Milestone].
enum MilestoneStatus {
  pending('Pending', Icons.radio_button_unchecked_rounded),
  inProgress('In Progress', Icons.timelapse_rounded),
  completed('Completed', Icons.check_circle_rounded);

  const MilestoneStatus(this.label, this.icon);

  final String label;
  final IconData icon;

  Color get color {
    switch (this) {
      case MilestoneStatus.pending:
        return AppColors.textMuted;
      case MilestoneStatus.inProgress:
        return AppColors.info;
      case MilestoneStatus.completed:
        return AppColors.success;
    }
  }

  double get progressWeight {
    switch (this) {
      case MilestoneStatus.pending:
        return 0.0;
      case MilestoneStatus.inProgress:
        return 0.5;
      case MilestoneStatus.completed:
        return 1.0;
    }
  }
}

/// One deliverable step inside a [Project].
class Milestone {
  const Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.dueDate,
    this.status = MilestoneStatus.pending,
    this.completedAt,
  });

  final String id;
  final String title;
  final String description;
  final double amount;
  final DateTime dueDate;
  final MilestoneStatus status;
  final DateTime? completedAt;

  bool get isCompleted => status == MilestoneStatus.completed;
  bool get isOverdue => !isCompleted && dueDate.isBefore(DateTime.now());

  Milestone copyWith({
    MilestoneStatus? status,
    DateTime? completedAt,
    bool clearCompletedAt = false,
  }) {
    return Milestone(
      id: id,
      title: title,
      description: description,
      amount: amount,
      dueDate: dueDate,
      status: status ?? this.status,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
    );
  }
}

/// A delivery (submission) made by the freelancer against a [Project].
class ProjectDelivery {
  const ProjectDelivery({
    required this.id,
    required this.message,
    required this.submittedAt,
    this.attachments = const [],
    this.revisionNumber = 1,
    this.revisionNote,
  });

  final String id;
  final String message;
  final DateTime submittedAt;
  final List<String> attachments;
  final int revisionNumber;
  final String? revisionNote;

  bool get isRevision => revisionNumber > 1;

  ProjectDelivery copyWith({String? revisionNote}) {
    return ProjectDelivery(
      id: id,
      message: message,
      submittedAt: submittedAt,
      attachments: attachments,
      revisionNumber: revisionNumber,
      revisionNote: revisionNote ?? this.revisionNote,
    );
  }
}

/// One entry in a project's status history.
class ProjectEvent {
  const ProjectEvent({
    required this.status,
    required this.timestamp,
    this.note,
  });

  final ProjectStatus status;
  final DateTime timestamp;
  final String? note;
}

/// An active piece of work: either a service order or a job contract.
class Project {
  Project({
    required this.id,
    required this.title,
    required this.description,
    required this.role,
    required this.source,
    required this.category,
    required this.amount,
    required this.createdAt,
    required this.dueDate,
    required this.freelancerName,
    required this.freelancerTitle,
    required this.freelancerAvatarColor,
    required this.clientName,
    required this.clientAvatarColor,
    this.status = ProjectStatus.pending,
    this.serviceId,
    this.jobId,
    this.proposalId,
    this.completedAt,
    List<Milestone>? milestones,
    List<ProjectDelivery>? deliveries,
    List<ProjectEvent>? statusHistory,
  })  : milestones = List<Milestone>.unmodifiable(milestones ?? const []),
        deliveries = List<ProjectDelivery>.unmodifiable(
          deliveries ?? const [],
        ),
        statusHistory = List<ProjectEvent>.unmodifiable(
          statusHistory ??
              [ProjectEvent(status: status, timestamp: createdAt)],
        );

  final String id;
  final String title;
  final String description;
  final ProjectRole role;
  final ProjectSource source;
  final Category category;
  final double amount;
  final DateTime createdAt;
  final DateTime dueDate;
  final DateTime? completedAt;
  final ProjectStatus status;
  final String? serviceId;
  final String? jobId;
  final String? proposalId;
  final String freelancerName;
  final String freelancerTitle;
  final Color freelancerAvatarColor;
  final String clientName;
  final Color clientAvatarColor;
  final List<Milestone> milestones;
  final List<ProjectDelivery> deliveries;
  final List<ProjectEvent> statusHistory;

  String get counterpartyName =>
      role == ProjectRole.client ? freelancerName : clientName;

  Color get counterpartyAvatarColor =>
      role == ProjectRole.client ? freelancerAvatarColor : clientAvatarColor;

  String get counterpartyRoleLabel =>
      role == ProjectRole.client ? 'Freelancer' : 'Client';

  int get completedMilestones =>
      milestones.where((m) => m.isCompleted).length;

  int get totalMilestones => milestones.length;

  double get progress {
    if (status == ProjectStatus.completed) return 1.0;
    if (status == ProjectStatus.cancelled) return 0.0;
    if (milestones.isEmpty) {
      return status == ProjectStatus.submitted ? 0.9 : 0.0;
    }
    final earned = milestones.fold<double>(
      0,
      (sum, m) => sum + m.status.progressWeight,
    );
    final ratio = earned / milestones.length;
    return ratio.clamp(0.0, 1.0).toDouble();
  }

  int get progressPercent => (progress * 100).round();

  double get releasedAmount => milestones
      .where((m) => m.isCompleted)
      .fold<double>(0, (sum, m) => sum + m.amount);

  ProjectDelivery? get latestDelivery =>
      deliveries.isEmpty ? null : deliveries.last;

  Milestone? get nextMilestone {
    for (final milestone in milestones) {
      if (!milestone.isCompleted) return milestone;
    }
    return null;
  }

  int get daysRemaining {
    final now = DateTime.now();
    final due = DateTime(dueDate.year, dueDate.month, dueDate.day);
    final today = DateTime(now.year, now.month, now.day);
    return due.difference(today).inDays;
  }

  bool get isOverdue => status.isOpen && daysRemaining < 0;

  String get dueLabel {
    if (status == ProjectStatus.completed) return 'Delivered';
    if (status == ProjectStatus.cancelled) return 'Cancelled';
    final days = daysRemaining;
    if (days < 0) return '${-days}d overdue';
    if (days == 0) return 'Due today';
    if (days == 1) return '1 day left';
    return '$days days left';
  }

  Project copyWith({
    ProjectStatus? status,
    DateTime? completedAt,
    List<Milestone>? milestones,
    List<ProjectDelivery>? deliveries,
    List<ProjectEvent>? statusHistory,
  }) {
    return Project(
      id: id,
      title: title,
      description: description,
      role: role,
      source: source,
      category: category,
      amount: amount,
      createdAt: createdAt,
      dueDate: dueDate,
      freelancerName: freelancerName,
      freelancerTitle: freelancerTitle,
      freelancerAvatarColor: freelancerAvatarColor,
      clientName: clientName,
      clientAvatarColor: clientAvatarColor,
      status: status ?? this.status,
      serviceId: serviceId,
      jobId: jobId,
      proposalId: proposalId,
      completedAt: completedAt ?? this.completedAt,
      milestones: milestones ?? this.milestones,
      deliveries: deliveries ?? this.deliveries,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }

  Project copyWithStatus(ProjectStatus newStatus, {String? note}) {
    return copyWith(
      status: newStatus,
      completedAt: newStatus == ProjectStatus.completed
          ? DateTime.now()
          : completedAt,
      statusHistory: [
        ...statusHistory,
        ProjectEvent(
          status: newStatus,
          timestamp: DateTime.now(),
          note: note,
        ),
      ],
    );
  }

  // --- Factories ---

  factory Project.fromServiceOrder({
    required Service service,
    required String clientName,
    required Color clientAvatarColor,
    DateTime? placedAt,
  }) {
    final now = placedAt ?? DateTime.now();
    final due = now.add(Duration(days: service.deliveryDays));
    final id = 'order_${now.millisecondsSinceEpoch}';
    return Project(
      id: id,
      title: service.title,
      description: service.description,
      role: ProjectRole.client,
      source: ProjectSource.serviceOrder,
      category: service.category,
      amount: service.price,
      createdAt: now,
      dueDate: due,
      freelancerName: service.freelancer.name,
      freelancerTitle: service.freelancer.title,
      freelancerAvatarColor: service.freelancer.avatarColor,
      clientName: clientName,
      clientAvatarColor: clientAvatarColor,
      serviceId: service.id,
      milestones: defaultMilestones(
        projectId: id,
        total: service.price,
        start: now,
        end: due,
      ),
      statusHistory: [
        ProjectEvent(
          status: ProjectStatus.pending,
          timestamp: now,
          note: 'Order placed with ${service.freelancer.name}.',
        ),
      ],
    );
  }

  factory Project.fromAcceptedProposal({
    required Proposal proposal,
    required Freelancer freelancer,
    DateTime? acceptedAt,
  }) {
    final now = acceptedAt ?? DateTime.now();
    final job = proposal.job;
    final due = now.add(Duration(days: _estimateDays(proposal.estimatedDuration)));
    final id = 'project_${now.millisecondsSinceEpoch}';
    return Project(
      id: id,
      title: job.title,
      description: job.description,
      role: ProjectRole.freelancer,
      source: ProjectSource.jobContract,
      category: job.category,
      amount: proposal.proposedAmount,
      createdAt: now,
      dueDate: due,
      freelancerName: freelancer.name,
      freelancerTitle: freelancer.title,
      freelancerAvatarColor: freelancer.avatarColor,
      clientName: job.client.name,
      clientAvatarColor: job.client.avatarColor,
      jobId: job.id,
      proposalId: proposal.id,
      milestones: defaultMilestones(
        projectId: id,
        total: proposal.proposedAmount,
        start: now,
        end: due,
      ),
      statusHistory: [
        ProjectEvent(
          status: ProjectStatus.pending,
          timestamp: now,
          note: '${job.client.name} accepted your proposal.',
        ),
      ],
    );
  }

  static List<Milestone> defaultMilestones({
    required String projectId,
    required double total,
    required DateTime start,
    required DateTime end,
  }) {
    final span = end.difference(start).inDays.clamp(3, 365).toInt();
    const shares = <double>[0.2, 0.5, 0.3];
    const titles = <String>[
      'Kickoff & requirements',
      'Core build',
      'Final delivery',
    ];
    const descriptions = <String>[
      'Align on scope, share references and confirm the plan.',
      'The main body of the work, reviewed as it progresses.',
      'Final files handed over, revisions applied and wrapped up.',
    ];

    return [
      for (var i = 0; i < shares.length; i++)
        Milestone(
          id: '${projectId}_m${i + 1}',
          title: titles[i],
          description: descriptions[i],
          amount: total * shares[i],
          dueDate: start.add(
            Duration(days: ((span * (i + 1)) / shares.length).round()),
          ),
        ),
    ];
  }

  static int _estimateDays(String duration) {
    final text = duration.toLowerCase();
    final match = RegExp(r'\d+').firstMatch(text);
    final value = match == null ? 1 : int.tryParse(match.group(0)!) ?? 1;
    if (text.contains('month')) return (value * 30).clamp(7, 365).toInt();
    if (text.contains('week')) return (value * 7).clamp(3, 365).toInt();
    if (text.contains('day')) return value.clamp(1, 365).toInt();
    if (text.contains('hour')) return 1;
    return 30;
  }
}
