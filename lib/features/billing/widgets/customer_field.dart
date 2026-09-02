import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/formatters/upper_case_formatter.dart';
import '../../../core/widgets/app_text_field.dart';

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
        AppTextField(
          controller: nameController,
          focusNode: nameFocus,
          inputFormatters: const <TextInputFormatter>[UpperCaseFormatter()],
          keyboardType: TextInputType.text,
          label: 'Customer name',
          onChanged: onNameChanged,
          onSubmitted: (String _) => onNameSubmitted(),
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: phoneController,
          focusNode: phoneFocus,
          keyboardType: TextInputType.phone,
          label: 'Phone',
          onChanged: onPhoneChanged,
          textInputAction: TextInputAction.done,
        ),
      ],
    );
  }
}
