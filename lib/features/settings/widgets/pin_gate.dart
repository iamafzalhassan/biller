import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/pin_boxes.dart';

class PinGate extends StatefulWidget {
  const PinGate({super.key, required this.onSubmit, required this.onRecover});

  final Future<bool> Function(String) onSubmit;

  final VoidCallback onRecover;

  @override
  State<PinGate> createState() => _PinGateState();
}

class _PinGateState extends State<PinGate> {
  static const int attemptsBeforeLock = 5;
  static const int lockSeconds = 30;

  final TextEditingController _controller = TextEditingController();

  bool _hasError = false;

  int _attempts = 0;
  int _lockRemaining = 0;

  Timer? _lockTimer;

  bool get _isLocked => _lockRemaining > 0;

  Future<void> _submit(String value) async {
    if (_isLocked) {
      _controller.clear();
      return;
    }
    final bool isValid = await widget.onSubmit(value);
    if (!mounted || isValid) return;
    _attempts++;
    _controller.clear();
    unawaited(HapticFeedback.heavyImpact());
    if (_attempts >= attemptsBeforeLock) {
      _attempts = 0;
      _startLock();
      return;
    }
    setState(() => _hasError = true);
  }

  void _startLock() {
    _lockTimer?.cancel();
    setState(() {
      _hasError = false;
      _lockRemaining = lockSeconds;
    });
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (!mounted) return;
      setState(() => _lockRemaining--);
      if (_lockRemaining <= 0) timer.cancel();
    });
  }

  void _clearError(String _) {
    if (_hasError) setState(() => _hasError = false);
  }

  @override
  void dispose() {
    _lockTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.screenPadding),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Text('The PIN protects the settings screen only', style: AppTextStyles.listSecondary),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: PinBoxes(autofocus: true, controller: _controller, enabled: !_isLocked, hasError: _hasError, onChanged: _clearError, onCompleted: (String value) => unawaited(_submit(value))),
        ),
        if (_isLocked) const SizedBox(height: AppSpacing.md),
        if (_isLocked) Text('Too many wrong PINs. Try again in $_lockRemaining seconds, or use your recovery code.', style: AppTextStyles.listSecondary, textAlign: TextAlign.center),
        const Spacer(),
        OutlinedButton(onPressed: widget.onRecover, child: const Text('Use Recovery Code', maxLines: 1)),
      ],
    ),
  );
}
