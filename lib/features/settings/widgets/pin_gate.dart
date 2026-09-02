import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/pin_boxes.dart';

class PinGate extends StatefulWidget {
  const PinGate({super.key, required this.onRecover, required this.onSubmit});

  final Future<bool> Function(String) onSubmit;

  final VoidCallback onRecover;

  @override
  State<PinGate> createState() => _PinGateState();
}

class _PinGateState extends State<PinGate> {
  final TextEditingController _controller = TextEditingController();

  bool _hasError = false;

  Future<void> _submit(String value) async {
    final bool isValid = await widget.onSubmit(value);
    if (!mounted || isValid) return;
    setState(() => _hasError = true);
    _controller.clear();
    unawaited(HapticFeedback.heavyImpact());
  }

  void _clearError(String _) {
    if (_hasError) setState(() => _hasError = false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.lock_outline, color: AppColors.textTertiary, size: 32),
            const SizedBox(height: AppSpacing.lg),
            const Text('ENTER PIN', maxLines: 1, style: AppTextStyles.overline, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.xl),
            PinBoxes(
              autofocus: true,
              controller: _controller,
              hasError: _hasError,
              onChanged: _clearError,
              onCompleted: (String value) => unawaited(_submit(value)),
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              height: AppSpacing.touchTarget,
              child: TextButton(onPressed: widget.onRecover, child: const Text('Use recovery code', maxLines: 1)),
            ),
          ],
        ),
      ),
    );
  }
}
