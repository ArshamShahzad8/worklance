import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../core/state/app_store.dart';
import '../../core/theme/app_colors.dart';
import '../../models/order.dart';
import '../../widgets/app_button.dart';
import '../../widgets/fade_slide_animation.dart';

/// Delivery/Submission screen: where the freelancer submits/delivers their
/// work for a project. This is UI-only/local — there is no file storage or
/// real client on the other end, and the screen says so, matching the way
/// the rest of the app is honest about its demo controls.
class DeliveryScreen extends StatefulWidget {
  const DeliveryScreen({super.key, required this.order});

  final Order order;

  @override
  State<DeliveryScreen> createState() => _DeliveryScreenState();
}

class _DeliveryScreenState extends State<DeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _noteController = TextEditingController();
  final List<String> _attachedFiles = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _addSampleAttachment() {
    setState(() {
      _attachedFiles.add('final_deliverable_${_attachedFiles.length + 1}.zip');
    });
  }

  void _removeAttachment(int index) {
    setState(() => _attachedFiles.removeAt(index));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    AppScope.of(context).orders.submitDelivery(
      widget.order.id,
      _noteController.text.trim(),
    );

    setState(() => _isSubmitting = false);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Work submitted for client review')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Submit Delivery')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          child: FadeSlideAnimation(
            index: 0,
            duration: const Duration(milliseconds: 350),
            slideOffset: 12.0,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    color: AppColors.accentContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(AppConstants.spaceMd),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline_rounded, color: AppColors.onAccent),
                          const SizedBox(width: AppConstants.spaceSm),
                          Expanded(
                            child: Text(
                              'This is a local demo submission — files stay '
                              'on this screen and are not actually uploaded '
                              'anywhere.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),

                  Text(widget.order.job.title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppConstants.spaceXs),
                  Text(
                    'Delivering to ${widget.order.job.client.name}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceLg),

                  Text('Delivery notes', style: theme.textTheme.titleSmall),
                  const SizedBox(height: AppConstants.spaceSm),
                  TextFormField(
                    controller: _noteController,
                    maxLines: 5,
                    decoration: const InputDecoration(
                      hintText:
                          'Summarize what you are delivering and any notes '
                          'the client should know before reviewing it...',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => (value == null || value.trim().isEmpty)
                        ? 'Please add a short delivery note'
                        : null,
                  ),
                  const SizedBox(height: AppConstants.spaceLg),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Attachments', style: theme.textTheme.titleSmall),
                      TextButton.icon(
                        onPressed: _addSampleAttachment,
                        icon: const Icon(Icons.attach_file_rounded, size: 18),
                        label: const Text('Add file'),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.spaceSm),
                  if (_attachedFiles.isEmpty)
                    Text(
                      'No files attached yet.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    )
                  else
                    Card(
                      child: Column(
                        children: [
                          for (var i = 0; i < _attachedFiles.length; i++) ...[
                            if (i != 0) const Divider(height: 1),
                            ListTile(
                              leading: const Icon(Icons.insert_drive_file_outlined),
                              title: Text(_attachedFiles[i]),
                              trailing: IconButton(
                                icon: const Icon(Icons.close_rounded),
                                onPressed: () => _removeAttachment(i),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: AppConstants.spaceXl),

                  AppButton(
                    label: 'Submit Delivery',
                    icon: Icons.upload_file_rounded,
                    loading: _isSubmitting,
                    onPressed: _isSubmitting ? null : _submit,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
