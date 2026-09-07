import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/formatters/phone_formatter.dart';
import '../../../core/formatters/upper_case_formatter.dart';
import '../../../core/widgets/app_text_field.dart';

class CustomerField extends StatelessWidget {
  const CustomerField({
    super.key,
    required this.hasPhoneError,
    required this.nameFocus,
    required this.phoneFocus,
    required this.nameController,
    required this.phoneController,
    required this.onNameChanged,
    required this.onPhoneChanged,
    required this.onNameSubmitted,
    required this.onPhoneSubmitted,
  });

  final bool hasPhoneError;

  final FocusNode nameFocus;
  final FocusNode phoneFocus;

  final TextEditingController nameController;
  final TextEditingController phoneController;

  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onPhoneChanged;

  final VoidCallback onNameSubmitted;
  final VoidCallback onPhoneSubmitted;

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
          label: 'Customer Name',
          onChanged: onNameChanged,
          onSubmitted: (String _) => onNameSubmitted(),
          textCapitalization: TextCapitalization.characters,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: AppSpacing.md),
        AppTextField(
          controller: phoneController,
          focusNode: phoneFocus,
          inputFormatters: const <TextInputFormatter>[SriLankaPhoneFormatter()],
          keyboardType: TextInputType.phone,
          label: 'Phone',
          onChanged: onPhoneChanged,
          onSubmitted: (String _) => onPhoneSubmitted(),
          textInputAction: TextInputAction.done,
        ),
        if (hasPhoneError) const SizedBox(height: AppSpacing.xs),
        if (hasPhoneError) const Text('Phone must be 10 digits starting with 0', maxLines: 1, style: AppTextStyles.errorHint),
      ],
    );
  }
}
