import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/formatters/upper_case_formatter.dart';

class CustomerField extends StatelessWidget {
  const CustomerField({
    super.key,
    required this.nameController,
    required this.nameFocus,
    required this.onNameChanged,
    required this.onNameSubmitted,
    required this.onPhoneChanged,
    required this.phoneController,
    required this.phoneFocus,
  });

  final FocusNode nameFocus;
  final FocusNode phoneFocus;

  final TextEditingController nameController;
  final TextEditingController phoneController;

  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onPhoneChanged;

  final VoidCallback onNameSubmitted;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: AppSpacing.fieldHeight,
          child: TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Customer name'),
            focusNode: nameFocus,
            inputFormatters: const <TextInputFormatter>[UpperCaseFormatter()],
            keyboardType: TextInputType.text,
            maxLines: 1,
            onChanged: onNameChanged,
            onSubmitted: (String _) => onNameSubmitted(),
            textCapitalization: TextCapitalization.characters,
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: AppSpacing.fieldHeight,
          child: TextField(
            controller: phoneController,
            decoration: const InputDecoration(labelText: 'Phone'),
            focusNode: phoneFocus,
            keyboardType: TextInputType.phone,
            maxLines: 1,
            onChanged: onPhoneChanged,
            textInputAction: TextInputAction.done,
          ),
        ),
      ],
    );
  }
}
