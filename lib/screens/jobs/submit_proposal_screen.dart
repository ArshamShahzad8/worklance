import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../models/job.dart';
import '../../models/proposal.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

/// Submit Proposal screen.
///
/// Pre-fills relevant experience from the freelancer's own profile (bio +
/// skills) where possible, so the user isn't asked to re-type information
/// that already exists — per the Week 4 requirement.
class SubmitProposalScreen extends StatefulWidget {
  const SubmitProposalScreen({super.key, required this.job});

  final Job job;

  @override
  State<SubmitProposalScreen> createState() => _SubmitProposalScreenState();
}

class _SubmitProposalScreenState extends State<SubmitProposalScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _coverLetterController;
  late final TextEditingController _amountController;
  late final TextEditingController _durationController;
  bool _isSubmitting = false;
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    final user = AppScope.of(context).user.user;

    // Pre-fill a starting cover letter using the freelancer's own bio and
    // skills, so they aren't asked to re-enter information already on
    // their profile. It's fully editable before submitting.
    final skillsOverlap = widget.job.skills
        .where((skill) => user.skills.any((s) => s.toLowerCase() == skill.toLowerCase()))
        .toList();
    final buffer = StringBuffer();
    if (user.bio.trim().isNotEmpty) {
      buffer.writeln(user.bio.trim());
      buffer.writeln();
    }
    if (skillsOverlap.isNotEmpty) {
      buffer.writeln(
        "I have hands-on experience with ${skillsOverlap.join(', ')}, which "
        'lines up directly with what this job needs.',
      );
    }

    _coverLetterController = TextEditingController(text: buffer.toString().trim());
    _amountController = TextEditingController(
      text: widget.job.budgetMin == widget.job.budgetMax
          ? _formatAmount(widget.job.budgetMin)
          : '',
    );
    _durationController = TextEditingController(text: widget.job.duration);
  }

  String _formatAmount(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : '$value';

  // Once the user has attempted to submit at least once, switch on live
  // (as-you-type) validation so fixing one field doesn't require pressing
  // "Submit Proposal" again just to see whether it's valid now.
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _coverLetterController.dispose();
    _amountController.dispose();
    _durationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      // Previously this just returned here with no feedback: if the cover
      // letter (blank unless the user filled in a freelancer bio/skills) or
      // the amount (blank for hourly/range jobs) didn't meet validation, the
      // button looked like it "did nothing" when tapped. Now: turn on live
      // validation, scroll up so the errors are visible, and say so.
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
          content: Text('Please fill in all fields correctly before submitting.'),
        ),
      );
      return;
    }

    final store = AppScope.of(context);
    // Duplicate-submission protection: guard again right before submitting,
    // in case the user reached this screen from two places at once.
    if (store.proposals.hasAppliedToJob(widget.job.id)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You already submitted a proposal for this job.')),
      );
      Navigator.of(context).pop();
      return;
    }

    setState(() => _isSubmitting = true);
    // Simulate a network call; replaced by a real submit-proposal API call
    // once a backend is wired up.
    await Future<void>.delayed(AppConstants.authSimulatedDelay);
    if (!mounted) return;

    final proposal = Proposal(
      id: 'prop_${DateTime.now().millisecondsSinceEpoch}',
      job: widget.job,
      coverLetter: _coverLetterController.text.trim(),
      proposedAmount: double.parse(_amountController.text.trim()),
      estimatedDuration: _durationController.text.trim(),
      submittedAt: DateTime.now(),
    );

    store.proposals.add(proposal);
    store.jobs.incrementProposalsCount(widget.job.id);

    setState(() => _isSubmitting = false);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Proposal submitted!')),
    );
    Navigator.of(context).pushReplacementNamed(
      AppRoutes.proposalStatus,
      arguments: proposal,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final alreadyApplied = store.proposals.hasAppliedToJob(widget.job.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Submit Proposal')),
      body: SafeArea(
        child: alreadyApplied
            ? _AlreadyAppliedState(job: widget.job)
            : SingleChildScrollView(
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
                          Container(
                            padding: const EdgeInsets.all(AppConstants.spaceMd),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(
                                AppConstants.radiusMd,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.job.title,
                                  style: theme.textTheme.titleSmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${widget.job.budgetLabel} · ${widget.job.client.name}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppConstants.spaceLg),
                          AppTextField(
                            controller: _coverLetterController,
                            label: 'Cover letter',
                            hintText:
                                'Introduce yourself and explain why you are a '
                                'good fit for this job',
                            prefixIcon: Icons.edit_note_rounded,
                            maxLines: 8,
                            validator: validateCoverLetter,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: AnimatedBuilder(
                                animation: _coverLetterController,
                                builder: (context, _) => Text(
                                  '${_coverLetterController.text.length} / 2000',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppConstants.spaceMd),
                          AppTextField(
                            controller: _amountController,
                            label: widget.job.budgetType == BudgetType.hourly
                                ? 'Your hourly rate (${AppConstants.currencySymbol})'
                                : 'Your proposed budget (${AppConstants.currencySymbol})',
                            hintText: 'e.g. ${_formatAmount(widget.job.budgetMax)}',
                            prefixIcon: Icons.attach_money_rounded,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            textInputAction: TextInputAction.next,
                            validator: validatePrice,
                          ),
                          const SizedBox(height: AppConstants.spaceMd),
                          AppTextField(
                            controller: _durationController,
                            label: 'Estimated delivery / duration',
                            hintText: 'e.g. 3 weeks',
                            prefixIcon: Icons.schedule_rounded,
                            textInputAction: TextInputAction.done,
                            validator: validateDurationText,
                          ),
                          const SizedBox(height: AppConstants.spaceXl),
                          AppButton(
                            label: 'Submit Proposal',
                            icon: Icons.send_rounded,
                            loading: _isSubmitting,
                            onPressed: _handleSubmit,
                          ),
                          const SizedBox(height: AppConstants.spaceSm),
                          AppButton(
                            label: 'Cancel',
                            variant: AppButtonVariant.text,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

/// Shown if the user somehow reaches Submit Proposal for a job they've
/// already applied to (duplicate-submission protection).
class _AlreadyAppliedState extends StatelessWidget {
  const _AlreadyAppliedState({required this.job});

  final Job job;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final store = AppScope.of(context);
    final proposal = store.proposals.getByJobId(job.id);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceLg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 56, color: AppColors.success),
            const SizedBox(height: AppConstants.spaceMd),
            Text(
              'You already applied to this job',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Text(
              'Only one proposal per job is allowed.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),
            if (proposal != null)
              FilledButton(
                onPressed: () => Navigator.of(context).pushReplacementNamed(
                  AppRoutes.proposalStatus,
                  arguments: proposal,
                ),
                child: const Text('View Proposal'),
              ),
          ],
        ),
      ),
    );
  }
}
