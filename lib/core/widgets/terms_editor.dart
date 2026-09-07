import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';
import 'app_text_field.dart';

class TermsEditor extends StatefulWidget {
  const TermsEditor({super.key, required this.isEditable, required this.terms, required this.onChanged});

  final bool isEditable;

  final List<String> terms;

  final ValueChanged<List<String>> onChanged;

  @override
  State<TermsEditor> createState() => _TermsEditorState();
}

class _TermsEditorState extends State<TermsEditor> {
  static const String _separator = '\n\n';

  static final RegExp _breakPattern = RegExp(r'\n[ \t]*\n');

  final TextEditingController _controller = TextEditingController();

  void _publish(String value) => widget.onChanged(value.split(_breakPattern).map((String term) => term.trim()).where((String term) => term.isNotEmpty).toList());

  Widget _numberedTerms() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int index = 0; index < widget.terms.length; index++)
          Padding(
            padding: EdgeInsets.only(top: index == 0 ? 0 : AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  width: AppSpacing.indexColumn,
                  child: Text('${index + 1}.', style: AppTextStyles.body),
                ),
                Expanded(child: Text(widget.terms[index], style: AppTextStyles.body)),
              ],
            ),
          ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.text = widget.terms.join(_separator);
  }

  @override
  void didUpdateWidget(covariant TermsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEditable == widget.isEditable) return;
    _controller.text = widget.terms.join(_separator);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEditable) return _numberedTerms();
    return AppTextField(controller: _controller, isGrowable: true, keyboardType: TextInputType.multiline, label: 'Conditions (Blank Line Between Each)', onChanged: _publish, textCapitalization: TextCapitalization.sentences);
  }
}
