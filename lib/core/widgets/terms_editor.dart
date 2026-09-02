import 'package:flutter/material.dart';

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
  final TextEditingController _controller = TextEditingController();

  void _publish(String value) => widget.onChanged(value.split('\n').map((String term) => term.trim()).where((String term) => term.isNotEmpty).toList());

  @override
  void initState() {
    super.initState();
    _controller.text = widget.terms.join('\n');
  }

  @override
  void didUpdateWidget(covariant TermsEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isEditable == widget.isEditable) return;
    _controller.text = widget.terms.join('\n');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEditable) return Text(widget.terms.join('\n'), style: AppTextStyles.body);
    return AppTextField(
      controller: _controller,
      isGrowable: true,
      keyboardType: TextInputType.multiline,
      label: 'One condition per line',
      onChanged: _publish,
      textCapitalization: TextCapitalization.sentences,
    );
  }
}
