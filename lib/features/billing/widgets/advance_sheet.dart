import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/cents_formatting_ext.dart';
import '../../../core/formatters/upper_case_formatter.dart';
import '../../../core/widgets/sheet_frame.dart';

class AdvanceSheet extends StatefulWidget {
  const AdvanceSheet({super.key, required this.advanceCents, required this.onRemove, required this.onSave});

  final int advanceCents;

  final ValueChanged<int> onSave;

  final VoidCallback onRemove;

  @override
  State<AdvanceSheet> createState() => _AdvanceSheetState();
}

class _AdvanceSheetState extends State<AdvanceSheet> {
  final FocusNode _focusNode = FocusNode();

  final TextEditingController _controller = TextEditingController();

  int get _cents => _controller.text.asCentsOrNull ?? 0;

  void _save() {
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
    if (widget.advanceCents > 0) _controller.text = (widget.advanceCents / 100).toStringAsFixed(2);
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (!mounted) return;
      _focusNode.requestFocus();
      _controller.selection = TextSelection(baseOffset: 0, extentOffset: _controller.text.length);
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
      title: widget.advanceCents > 0 ? 'Edit advance' : 'Add advance',
      children: <Widget>[
        SizedBox(
          height: AppSpacing.fieldHeight,
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'Advance', prefixText: 'Rs. '),
            focusNode: _focusNode,
            inputFormatters: const <TextInputFormatter>[DecimalFormatter()],
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            maxLines: 1,
            onChanged: (String _) => setState(() {}),
            onSubmitted: (String _) => _save(),
            style: AppTextStyles.amount,
            textAlign: TextAlign.right,
            textAlignVertical: TextAlignVertical.center,
            textInputAction: TextInputAction.done,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        SheetActions(
          primary: FilledButton(onPressed: _cents > 0 ? _save : null, child: const Text('Save', maxLines: 1)),
          secondary: widget.advanceCents > 0
              ? OutlinedButton(
                  onPressed: _remove,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  child: const Text('Remove', maxLines: 1),
                )
              : OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel', maxLines: 1)),
        ),
      ],
    );
  }
}
