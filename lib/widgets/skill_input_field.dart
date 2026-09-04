import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../core/theme/app_colors.dart';

/// Reusable chip-based input for entering a short list of free-text skills
/// or tags (e.g. "Flutter", "REST APIs"). Used by both the freelancer
/// profile form and the Create Service form so skill entry looks and
/// behaves the same everywhere.
class SkillInputField extends StatefulWidget {
  const SkillInputField({
    super.key,
    required this.skills,
    required this.onChanged,
    this.label = 'Skills',
    this.hintText = 'e.g. Flutter, Figma, SEO',
    this.errorText,
    this.maxSkills = 10,
  });

  final List<String> skills;
  final ValueChanged<List<String>> onChanged;
  final String label;
  final String hintText;
  final String? errorText;
  final int maxSkills;

  @override
  State<SkillInputField> createState() => _SkillInputFieldState();
}

class _SkillInputFieldState extends State<SkillInputField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _addSkill(String raw) {
    final value = raw.trim();
    _controller.clear();
    if (value.isEmpty) return;
    if (widget.skills.length >= widget.maxSkills) return;
    if (widget.skills.any((s) => s.toLowerCase() == value.toLowerCase())) {
      return;
    }
    widget.onChanged([...widget.skills, value]);
  }

  void _removeSkill(String skill) {
    widget.onChanged(widget.skills.where((s) => s != skill).toList());
  }

  @override
  Widget build(BuildContext context) {
    final atLimit = widget.skills.length >= widget.maxSkills;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _controller,
          enabled: !atLimit,
          textInputAction: TextInputAction.done,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: atLimit
                ? 'Maximum ${widget.maxSkills} skills'
                : widget.hintText,
            errorText: widget.errorText,
            prefixIcon: const Icon(Icons.psychology_alt_outlined),
            suffixIcon: IconButton(
              tooltip: 'Add skill',
              icon: const Icon(Icons.add_circle_outline_rounded),
              onPressed: atLimit ? null : () => _addSkill(_controller.text),
            ),
          ),
          onSubmitted: _addSkill,
        ),
        if (widget.skills.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spaceSm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final skill in widget.skills)
                InputChip(
                  label: Text(skill),
                  onDeleted: () => _removeSkill(skill),
                  deleteIconColor: AppColors.textMuted,
                ),
            ],
          ),
        ],
      ],
    );
  }
}
