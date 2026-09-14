import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/formatters/upper_case_formatter.dart';
import '../../../core/utils/soft_keyboard.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/code_box.dart';
import '../controller/activation_controller.dart';

class ActivationScreen extends ConsumerStatefulWidget {
  const ActivationScreen({super.key});

  @override
  ConsumerState<ActivationScreen> createState() => _ActivationScreenState();
}

class _ActivationScreenState extends ConsumerState<ActivationScreen> {
  final FocusNode _keyFocus = FocusNode();

  final TextEditingController _keyController = TextEditingController();

  bool _isActivating = false;

  bool get _canActivate => !_isActivating && _keyController.text.trim().isNotEmpty;

  void _refresh(String _) => setState(() {});

  Future<void> _paste() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    final String text = data?.text?.trim().toUpperCase() ?? '';
    if (!mounted) return;
    if (text.isEmpty) {
      context.showErrorSnack('The clipboard is empty. Copy the activation key first, then tap Paste Key.');
      return;
    }
    setState(() => _keyController.text = text);
    await _activate();
  }

  Future<void> _activate() async {
    if (!_canActivate) return;
    SoftKeyboard.dismiss();
    setState(() => _isActivating = true);
    final ActivationController controller = ref.read(activationControllerProvider.notifier);
    final bool isActivated = await controller.activate(_keyController.text);
    if (!mounted) return;
    setState(() => _isActivating = false);
    if (!isActivated) {
      context.showErrorSnack('This key does not match this device. Check the key and try again.');
      return;
    }
    unawaited(Navigator.of(context).pushAndRemoveUntil(controller.isSetupComplete ? Routes.billing() : Routes.setup(), (Route<dynamic> route) => false));
  }

  @override
  void dispose() {
    _keyFocus.dispose();
    _keyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String deviceCode = ref.read(activationControllerProvider.notifier).deviceCode;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Activate Biller', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.sectionHeading),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      const Text('Send this device code to the developer. The activation key you get back works on this device only.', style: AppTextStyles.listSecondary),
                      const SizedBox(height: AppSpacing.xl),
                      CodeBox(code: deviceCode.isEmpty ? 'UNAVAILABLE' : deviceCode, copiedMessage: 'Device code copied to the clipboard. Send it to the developer.', label: 'DEVICE CODE'),
                      const SizedBox(height: AppSpacing.xl),
                      AppTextField(
                        controller: _keyController,
                        focusNode: _keyFocus,
                        inputFormatters: const <TextInputFormatter>[UpperCaseFormatter()],
                        isGrowable: true,
                        label: 'Activation Key',
                        onChanged: _refresh,
                        onSubmitted: (String _) => unawaited(_activate()),
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      OutlinedButton.icon(
                        icon: const Icon(Icons.content_paste_outlined, size: AppSpacing.iconButton),
                        label: const Text('Paste Key', maxLines: 1),
                        onPressed: _isActivating ? null : () => unawaited(_paste()),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(onPressed: _canActivate ? () => unawaited(_activate()) : null, child: const Text('Activate', maxLines: 1)),
            ],
          ),
        ),
      ),
    );
  }
}
