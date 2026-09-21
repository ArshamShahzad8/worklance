import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/project.dart';
import '../models/proposal.dart';

/// One dot on a [StatusTimeline], independent of which status enum it came from.
class TimelineEntry {
  const TimelineEntry({
    required this.label,
    required this.color,
    required this.timestamp,
    this.note,
  });

  final String label;
  final Color color;
  final DateTime timestamp;
  final String? note;
}

/// Vertical timeline of status changes, newest first.
class StatusTimeline extends StatelessWidget {
  /// Renders a proposal's status history (Week 4).
  StatusTimeline({super.key, required List<ProposalStatusEvent> events})
      : entries = [
          for (final event in events)
            TimelineEntry(
              label: event.status.label,
              color: event.status.color,
              timestamp: event.timestamp,
              note: event.note,
            ),
        ];

  /// Renders a project's status history (Week 5).
  StatusTimeline.fromProjectEvents({
    super.key,
    required List<ProjectEvent> events,
  }) : entries = [
          for (final event in events)
            TimelineEntry(
              label: event.status.label,
              color: event.status.color,
              timestamp: event.timestamp,
              note: event.note,
            ),
        ];

  final List<TimelineEntry> entries;

  String _formatTimestamp(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '${months[date.month - 1]} ${date.day}, $hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reversed = entries.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < reversed.length; i++)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      margin: const EdgeInsets.only(top: 2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == 0
                            ? reversed[i].color
                            : reversed[i].color.withValues(alpha: 0.35),
                      ),
                    ),
                    if (i != reversed.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppColors.border,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reversed[i].label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: i == 0
                                ? AppColors.textPrimary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatTimestamp(reversed[i].timestamp),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                        if (reversed[i].note != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            reversed[i].note!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
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
