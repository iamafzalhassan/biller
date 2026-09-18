import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_theme.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/cents_formatting_ext.dart';
import '../../../core/formatters/thousands_formatter.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/sheet_frame.dart';

class AdvanceSheet extends StatefulWidget {
  const AdvanceSheet({super.key, required this.advanceCents, required this.totalCents, required this.onSave, required this.onRemove});

  final int advanceCents;
  final int totalCents;

  final ValueChanged<int> onSave;

  final VoidCallback onRemove;

  @override
  State<AdvanceSheet> createState() => _AdvanceSheetState();
}

class _AdvanceSheetState extends State<AdvanceSheet> {
  final FocusNode _focusNode = FocusNode();

  final TextEditingController _controller = TextEditingController();

  int get _cents => _controller.text.asCentsOrNull ?? 0;

  bool get _isOverTotal => _cents > widget.totalCents;

  bool get _isValid => _cents > 0 && _cents <= widget.totalCents;

  void _save() {
    if (!_isValid) return;
    widget.onSave(_cents);
    Navigator.of(context).pop();
  }

  void _remove() {
    widget.onRemove();
    Navigator.of(context).pop();
  }

  @override
  void initState() {
    super.initState();
    if (widget.advanceCents > 0) _controller.text = widget.advanceCents.asAmount;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SheetFrame(
    title: widget.advanceCents > 0 ? 'Edit Advance' : 'Add Advance',
    children: <Widget>[
      AppTextField(
        autofocus: true,
        controller: _controller,
        focusNode: _focusNode,
        inputFormatters: const <TextInputFormatter>[ThousandsFormatter()],
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        label: 'Advance',
        onChanged: (String _) => setState(() {}),
        onSubmitted: (String _) => _save(),
        selectAllOnFocus: true,
        textAlign: TextAlign.right,
        textInputAction: TextInputAction.done,
      ),
      if (_isOverTotal) const SizedBox(height: AppSpacing.sm),
      if (_isOverTotal) Text('Advance cannot exceed the total of ${widget.totalCents.asLkr}', style: AppTextStyles.errorHint),
      const SizedBox(height: AppSpacing.lg),
      SheetActions(
        primary: FilledButton(onPressed: _isValid ? _save : null, child: const Text('Add Advance', maxLines: 1)),
        secondary: OutlinedButton(onPressed: widget.advanceCents > 0 ? _remove : Navigator.of(context).pop, style: AppTheme.dangerButton, child: Text(widget.advanceCents > 0 ? 'Remove' : 'Cancel', maxLines: 1)),
      ),
    ],
  );
}
