import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';

class SecuritySection extends StatelessWidget {
  const SecuritySection({
    super.key,
    required this.isResettable,
    required this.currentPinFocus,
    required this.newPinFocus,
    required this.currentPinController,
    required this.newPinController,
    required this.onChangePin,
    required this.onReset,
  });

  final bool isResettable;

  final FocusNode currentPinFocus;
  final FocusNode newPinFocus;

  final TextEditingController currentPinController;
  final TextEditingController newPinController;

  final VoidCallback onChangePin;
  final VoidCallback onReset;

  Widget _pinField(TextEditingController controller, FocusNode focusNode, String label, {FocusNode? nextFocus}) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      label: label,
      maxLength: Validators.pinLength,
      obscureText: true,
      onSubmitted: (String _) => nextFocus == null ? onChangePin() : nextFocus.requestFocus(),
      textInputAction: nextFocus == null ? TextInputAction.done : TextInputAction.next,
    );
  }

  Widget _changePinTile() {
    return ExpansionTile(
      leading: const Icon(Icons.lock_outline, size: AppSpacing.iconTile),
      title: const Text('Change PIN', maxLines: 1, style: AppTextStyles.listPrimary),
      children: <Widget>[
        const SizedBox(height: AppSpacing.lg),
        _pinField(currentPinController, currentPinFocus, 'Current PIN', nextFocus: newPinFocus),
        const SizedBox(height: AppSpacing.md),
        _pinField(newPinController, newPinFocus, 'New PIN'),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(onPressed: onChangePin, child: const Text('Update PIN', maxLines: 1)),
      ],
    );
  }

  Widget _resetTile() {
    return ExpansionTile(
      leading: const Icon(Icons.restart_alt, size: AppSpacing.iconTile),
      title: const Text('Reset and run setup again', maxLines: 1, style: AppTextStyles.listPrimary),
      children: <Widget>[
        const SizedBox(height: AppSpacing.lg),
        const Text('Clears the business profile, PIN, invoice sequence and saved draft, then reopens the setup wizard.', style: AppTextStyles.listSecondary),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton(
          onPressed: onReset,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger),
          ),
          child: const Text('Reset Everything', maxLines: 1),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _changePinTile(),
        if (isResettable) const SizedBox(height: AppSpacing.sm),
        if (isResettable) _resetTile(),
      ],
    );
  }
}
