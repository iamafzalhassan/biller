import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'sheet_frame.dart';

class TermEntrySheet extends StatefulWidget {
  const TermEntrySheet({super.key, required this.term, required this.onDelete, required this.onSave});

  final String? term;

  final void Function(String term, bool addAnother) onSave;

  final VoidCallback? onDelete;

  @override
  State<TermEntrySheet> createState() => _TermEntrySheetState();
}

class _TermEntrySheetState extends State<TermEntrySheet> {
  final FocusNode _focusNode = FocusNode();

  final TextEditingController _controller = TextEditingController();

  bool get _isEditing => widget.term != null;

  bool get _isValid => _controller.text.trim().isNotEmpty;

  void _save({required bool addAnother}) {
    if (!_isValid) return;
    widget.onSave(_controller.text.trim(), addAnother);
    if (!addAnother) {
      Navigator.of(context).pop();
      return;
    }
    _controller.clear();
    HapticFeedback.selectionClick();
    setState(() {});
    _focusNode.requestFocus();
  }

  @override
  void initState() {
    super.initState();
    _controller.text = widget.term ?? '';
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SheetFrame(
      title: _isEditing ? 'Edit condition' : 'Add condition',
      children: <Widget>[
        SizedBox(
          height: AppSpacing.fieldHeight,
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Condition'),
            focusNode: _focusNode,
            maxLines: 1,
            onChanged: (String _) => setState(() {}),
            onSubmitted: (String _) => _save(addAnother: !_isEditing),
            style: AppTextStyles.body,
            textAlignVertical: TextAlignVertical.center,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SheetActions(
          primary: FilledButton(
            onPressed: _isValid ? () => _save(addAnother: !_isEditing) : null,
            child: Text(_isEditing ? 'Save' : 'Save & add next', maxLines: 1),
          ),
          secondary: _isEditing
              ? OutlinedButton(
                  onPressed: widget.onDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  child: const Text('Delete', maxLines: 1),
                )
              : OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Done', maxLines: 1)),
        ),
      ],
    );
  }
}
