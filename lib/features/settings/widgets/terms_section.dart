import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/widgets/terms_editor.dart';

class TermsSection extends StatelessWidget {
  const TermsSection({super.key, required this.isEditing, required this.terms, required this.onChanged, required this.onToggle});

  final bool isEditing;

  final List<String> terms;

  final ValueChanged<List<String>> onChanged;

  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TermsEditor(isEditable: isEditing, terms: terms, onChanged: onChanged),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          icon: Icon(isEditing ? Icons.check : Icons.edit_outlined, size: AppSpacing.iconButton),
          label: Text(isEditing ? 'Done' : 'Edit Conditions', maxLines: 1),
          onPressed: onToggle,
        ),
      ],
    );
  }
}
