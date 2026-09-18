import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../formatters/phone_formatter.dart';
import '../formatters/upper_case_formatter.dart';
import 'app_text_field.dart';

class ProfileTextField extends StatelessWidget {
  const ProfileTextField({
    super.key,
    this.autofocus = false,
    this.isPhone = false,
    this.isUpperCase = true,
    this.maxLength,
    required this.label,
    required this.focusNode,
    this.nextFocus,
    required this.controller,
    this.keyboardType,
    this.onChanged,
    this.onDone,
  });

  const ProfileTextField.phone({super.key, this.autofocus = false, required this.label, required this.focusNode, this.nextFocus, required this.controller, this.onChanged, this.onDone})
    : isPhone = true,
      isUpperCase = false,
      keyboardType = TextInputType.phone,
      maxLength = null;

  final bool autofocus;
  final bool isPhone;
  final bool isUpperCase;

  final int? maxLength;

  final String label;

  final FocusNode focusNode;
  final FocusNode? nextFocus;

  final TextEditingController controller;

  final TextInputType? keyboardType;

  final ValueChanged<String>? onChanged;

  final VoidCallback? onDone;

  List<TextInputFormatter>? get _formatters {
    if (isPhone) return const <TextInputFormatter>[SriLankaPhoneFormatter()];
    return isUpperCase ? const <TextInputFormatter>[UpperCaseFormatter()] : null;
  }

  void _submit() => nextFocus == null ? onDone?.call() : nextFocus!.requestFocus();

  @override
  Widget build(BuildContext context) => AppTextField(
    autofocus: autofocus,
    controller: controller,
    focusNode: focusNode,
    inputFormatters: _formatters,
    keyboardType: keyboardType,
    label: label,
    maxLength: maxLength,
    onChanged: onChanged,
    onSubmitted: (String _) => _submit(),
    textCapitalization: isUpperCase ? TextCapitalization.characters : TextCapitalization.none,
    textInputAction: nextFocus == null ? TextInputAction.done : TextInputAction.next,
  );
}
