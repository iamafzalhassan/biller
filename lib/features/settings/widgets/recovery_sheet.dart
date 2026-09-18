import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app/app_theme.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/sheet_frame.dart';

class RecoverySheet extends StatefulWidget {
  const RecoverySheet({super.key, required this.onSubmit});

  final void Function(String code, String newPin) onSubmit;

  @override
  State<RecoverySheet> createState() => _RecoverySheetState();
}

class _RecoverySheetState extends State<RecoverySheet> {
  final FocusNode _codeFocus = FocusNode();
  final FocusNode _pinFocus = FocusNode();

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  bool get _isValid => _codeController.text.trim().isNotEmpty && _pinController.text.length == 4;

  void _submit() {
    if (!_isValid) return;
    widget.onSubmit(_codeController.text.trim(), _pinController.text);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _codeController.dispose();
    _pinController.dispose();
    _codeFocus.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SheetFrame(
    title: 'Use Recovery Code',
    children: <Widget>[
      const Text('The code shown once during setup. Entering it sets a new PIN.', style: AppTextStyles.listSecondary),
      const SizedBox(height: AppSpacing.lg),
      AppTextField(
        autofocus: true,
        controller: _codeController,
        focusNode: _codeFocus,
        label: 'Recovery Code',
        onChanged: (String _) => setState(() {}),
        onSubmitted: (String _) => _pinFocus.requestFocus(),
        textCapitalization: TextCapitalization.characters,
        textInputAction: TextInputAction.next,
      ),
      const SizedBox(height: AppSpacing.md),
      AppTextField(
        controller: _pinController,
        focusNode: _pinFocus,
        inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
        keyboardType: TextInputType.number,
        label: 'New 4-Digit PIN',
        maxLength: 4,
        obscureText: true,
        onChanged: (String _) => setState(() {}),
        onSubmitted: (String _) => _submit(),
        textInputAction: TextInputAction.done,
      ),
      const SizedBox(height: AppSpacing.lg),
      SheetActions(
        primary: FilledButton(onPressed: _isValid ? _submit : null, child: const Text('Reset PIN', maxLines: 1)),
        secondary: OutlinedButton(onPressed: Navigator.of(context).pop, style: AppTheme.dangerButton, child: const Text('Cancel', maxLines: 1)),
      ),
    ],
  );
}
