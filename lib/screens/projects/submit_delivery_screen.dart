import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../models/project.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/skill_input_field.dart';

/// Submit Delivery: the freelancer hands the finished work over for review.
class SubmitDeliveryScreen extends StatefulWidget {
  const SubmitDeliveryScreen({super.key, required this.project});

  final Project project;

  @override
  State<SubmitDeliveryScreen> createState() => _SubmitDeliveryScreenState();
}

class _SubmitDeliveryScreenState extends State<SubmitDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  List<String> _attachments = [];
  bool _isSubmitting = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? _validateMessage(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Describe what you are delivering';
    if (v.length < 20) {
      return 'Add a little more detail (at least 20 characters)';
    }
    return null;
  }

  Future<void> _handleSubmit(Project current) async {
    if (!_formKey.currentState!.validate()) {
      setState(() => _autovalidateMode = AutovalidateMode.onUserInteraction);
      if (_scrollController.hasClients) {
        await _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Add a delivery note before submitting.'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future<void>.delayed(AppConstants.authSimulatedDelay);
    if (!mounted) return;

    final delivery = AppScope.of(context).projects.submitDelivery(
      current.id,
      message: _messageController.text.trim(),
      attachments: _attachments,
    );

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    if (delivery == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This project can no longer receive a delivery.'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          delivery.isRevision
              ? 'Revision ${delivery.revisionNumber - 1} submitted.'
              : 'Delivery submitted — waiting for client review.',
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Submit Delivery')),
      body: SafeArea(
        child: ListenableBuilder(
          listenable: store.projects,
          builder: (context, _) {
            final current =
                store.projects.getById(widget.project.id) ?? widget.project;

            if (!current.status.isOpen ||
                current.status == ProjectStatus.submitted) {
              return EmptyState(
                icon: Icons.task_alt_rounded,
                title: current.status == ProjectStatus.submitted
                    ? 'Already delivered'
                    : 'Nothing to deliver',
                message: current.status.description,
                actionLabel: 'Back to project',
                onAction: () => Navigator.of(context).pop(),
              );
            }

            final isRevision = current.deliveries.isNotEmpty;

            return SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(AppConstants.spaceLg),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppConstants.maxContentWidth,
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: _autovalidateMode,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _ProjectSummary(project: current),
                        const SizedBox(height: AppConstants.spaceLg),

                        Text(
                          isRevision
                              ? 'Submit a revision'
                              : 'Submit your delivery',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppConstants.spaceXs),
                        Text(
                          'Tell ${current.clientName} what is included. They '
                          'will review it and either approve the work or ask '
                          'for changes.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppConstants.spaceMd),

                        AppTextField(
                          label: 'Delivery note',
                          hintText:
                              'What is included, what changed, anything the '
                              'client should look at first...',
                          controller: _messageController,
                          maxLines: 6,
                          validator: _validateMessage,
                          enabled: !_isSubmitting,
                        ),
                        const SizedBox(height: AppConstants.spaceMd),

                        SkillInputField(
                          label: 'Attachments & links (optional)',
                          hintText: 'e.g. final-designs.zip',
                          skills: _attachments,
                          onChanged: (values) =>
                              setState(() => _attachments = values),
                        ),
                        const SizedBox(height: AppConstants.spaceLg),

                        if (current.nextMilestone != null)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppConstants.spaceMd,
                            ),
                            child: _OpenMilestonesNote(project: current),
                          ),

                        AppButton(
                          label: isRevision
                              ? 'Submit Revision'
                              : 'Submit Delivery',
                          icon: Icons.upload_rounded,
                          loading: _isSubmitting,
                          onPressed: () => _handleSubmit(current),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ProjectSummary extends StatelessWidget {
  const _ProjectSummary({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            project.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${project.clientName} · '
            '${AppConstants.formatPrice(project.amount)} · '
            '${project.dueLabel}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenMilestonesNote extends StatelessWidget {
  const _OpenMilestonesNote({required this.project});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.accentContainer,
        borderRadius: BorderRadius.circular(AppConstants.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, size: 18, color: AppColors.onAccent),
          const SizedBox(width: AppConstants.spaceSm),
          Expanded(
            child: Text(
              '${project.totalMilestones - project.completedMilestones} '
              'milestone(s) are still open. You can still deliver — they '
              'are released when the client approves.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
