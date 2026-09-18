import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/soft_keyboard.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/code_box.dart';
import '../../../core/widgets/pin_boxes.dart';
import '../../../core/widgets/profile_fields.dart';

import '../../../core/widgets/profile_text_field.dart';
import '../../../core/widgets/terms_editor.dart';
import '../../../models/business_profile.dart';
import '../controller/setup_step.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final ProfileFields _fields = ProfileFields(BusinessProfile.empty);

  final TextEditingController _pinController = TextEditingController();

  String _recoveryCode = '';

  List<String> _terms = BusinessProfile.defaultTerms;

  SetupStep _step = SetupStep.first;

  bool get _canAdvance => switch (_step) {
    SetupStep.businessName => _fields.nameController.text.trim().isNotEmpty,
    SetupStep.address => _fields.noController.text.trim().isNotEmpty && _fields.streetController.text.trim().isNotEmpty && _fields.cityController.text.trim().isNotEmpty,
    SetupStep.phones => _fields.phone1Controller.text.trim().isNotEmpty && !_hasPhoneError,
    SetupStep.email => Validators.isValidEmail(_fields.emailController.text),
    SetupStep.numbering => _fields.prefixController.text.trim().isNotEmpty && Validators.isValidDeviceId(_fields.deviceIdController.text.toUpperCase()),
    SetupStep.pin => Validators.isValidPin(_pinController.text),
    SetupStep.terms || SetupStep.recoveryCode => true,
  };

  bool get _hasEmailError => _fields.emailController.text.trim().isNotEmpty && !Validators.isValidEmail(_fields.emailController.text);

  bool get _hasPhoneError => _fields.phoneControllers.any((TextEditingController controller) => !Validators.isValidPhone(controller.text));

  void _refresh(String _) => setState(() {});

  void _submitStep() {
    if (_canAdvance) unawaited(_next());
  }

  Future<void> _next() async {
    if (_step != SetupStep.pin) {
      _goTo(_step.next);
      return;
    }
    SoftKeyboard.dismiss();
    ref.read(setupControllerProvider.notifier).update(_fields.toProfile(logoPath: '', terms: _terms));
    final String code = await ref.read(setupControllerProvider.notifier).finish(_pinController.text);
    if (!mounted) return;
    setState(() {
      _recoveryCode = code;
      _step = SetupStep.recoveryCode;
    });
  }

  void _back() => _goTo(_step.previous);

  void _goTo(SetupStep step) {
    if (step == _step) return;
    if (!step.opensKeyboard) SoftKeyboard.dismiss();
    setState(() => _step = step);
  }

  void _finish() {
    SoftKeyboard.dismiss();
    unawaited(Navigator.of(context).pushAndRemoveUntil(Routes.billing(), (Route<dynamic> route) => false));
  }

  ProfileTextField _field({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    bool autofocus = false,
    bool isUpperCase = true,
    int? maxLength,
    FocusNode? nextFocus,
    TextInputType? keyboardType,
  }) {
    return ProfileTextField(
      autofocus: autofocus,
      controller: controller,
      focusNode: focusNode,
      isUpperCase: isUpperCase,
      keyboardType: keyboardType,
      label: label,
      maxLength: maxLength,
      nextFocus: nextFocus,
      onChanged: _refresh,
      onDone: _submitStep,
    );
  }

  ProfileTextField _phoneField(TextEditingController controller, FocusNode focusNode, String label, {bool autofocus = false, FocusNode? nextFocus}) {
    return ProfileTextField.phone(autofocus: autofocus, controller: controller, focusNode: focusNode, label: label, nextFocus: nextFocus, onChanged: _refresh, onDone: _submitStep);
  }

  Widget _stepFrame({required String hint, required List<Widget> children}) {
    return Column(
      key: ValueKey<SetupStep>(_step),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(hint, style: AppTextStyles.listSecondary),
        const SizedBox(height: AppSpacing.xl),
        ...children,
      ],
    );
  }

  Widget _businessNameStep() => _stepFrame(
    hint: 'Printed at the top of every receipt',
    children: <Widget>[_field(autofocus: true, controller: _fields.nameController, focusNode: _fields.nameFocus, label: 'Business Name')],
  );

  Widget _addressStep() => _stepFrame(
    hint: 'Printed under the business name',
    children: <Widget>[
      _field(autofocus: true, controller: _fields.noController, focusNode: _fields.noFocus, label: 'No', nextFocus: _fields.streetFocus),
      const SizedBox(height: AppSpacing.md),
      _field(controller: _fields.streetController, focusNode: _fields.streetFocus, label: 'Street', nextFocus: _fields.cityFocus),
      const SizedBox(height: AppSpacing.md),
      _field(controller: _fields.cityController, focusNode: _fields.cityFocus, label: 'City', nextFocus: _fields.buildingFocus),
      const SizedBox(height: AppSpacing.md),
      _field(controller: _fields.buildingController, focusNode: _fields.buildingFocus, label: 'Building (Optional)'),
    ],
  );

  Widget _phonesStep() => _stepFrame(
    hint: 'Up to three lines, printed side by side on the receipt header',
    children: <Widget>[
      _phoneField(_fields.phone1Controller, _fields.phone1Focus, 'Phone 1', autofocus: true, nextFocus: _fields.phone2Focus),
      const SizedBox(height: AppSpacing.md),
      _phoneField(_fields.phone2Controller, _fields.phone2Focus, 'Phone 2 (Optional)', nextFocus: _fields.phone3Focus),
      const SizedBox(height: AppSpacing.md),
      _phoneField(_fields.phone3Controller, _fields.phone3Focus, 'Phone 3 (Optional)'),
      if (_hasPhoneError) const SizedBox(height: AppSpacing.sm),
      if (_hasPhoneError) const Text('Each phone must be 10 digits starting with 0', maxLines: 1, style: AppTextStyles.errorHint),
    ],
  );

  Widget _emailStep() => _stepFrame(
    hint: 'Kept on file as the owner contact',
    children: <Widget>[
      _field(autofocus: true, controller: _fields.emailController, focusNode: _fields.emailFocus, isUpperCase: false, keyboardType: TextInputType.emailAddress, label: 'Email'),
      if (_hasEmailError) const SizedBox(height: AppSpacing.sm),
      if (_hasEmailError) const Text('Enter a valid email address, like name@example.com', maxLines: 1, style: AppTextStyles.errorHint),
    ],
  );

  Widget _termsStep() => _stepFrame(
    hint: 'Printed at the foot of the receipt',
    children: <Widget>[TermsEditor(isEditable: true, terms: _terms, onChanged: (List<String> terms) => _terms = terms)],
  );

  Widget _numberingStep() => _stepFrame(
    hint: 'Each device needs its own letter, so two counters never share a number',
    children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: _field(autofocus: true, controller: _fields.prefixController, focusNode: _fields.prefixFocus, label: 'Prefix', nextFocus: _fields.deviceIdFocus),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _field(controller: _fields.deviceIdController, focusNode: _fields.deviceIdFocus, label: 'Device', maxLength: 1),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      Text('Bills will be numbered ${_fields.invoiceNumber(1)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.listSecondary),
    ],
  );

  Widget _pinStep() => _stepFrame(
    hint: 'The PIN protects the settings screen only',
    children: <Widget>[
      Center(
        child: PinBoxes(autofocus: true, controller: _pinController, hasError: false, onChanged: _refresh, onCompleted: _refresh),
      ),
    ],
  );

  Widget _recoveryCodeStep() => _stepFrame(
    hint: 'The only way to reset a forgotten PIN. It is shown once and cannot be recovered later',
    children: <Widget>[CodeBox(code: _recoveryCode, copiedMessage: 'Recovery code copied to the clipboard. Keep it somewhere safe outside this phone.', label: 'RECOVERY CODE')],
  );

  Widget _body() => switch (_step) {
    SetupStep.businessName => _businessNameStep(),
    SetupStep.address => _addressStep(),
    SetupStep.phones => _phonesStep(),
    SetupStep.email => _emailStep(),
    SetupStep.terms => _termsStep(),
    SetupStep.numbering => _numberingStep(),
    SetupStep.pin => _pinStep(),
    SetupStep.recoveryCode => _recoveryCodeStep(),
  };

  @override
  void initState() {
    super.initState();
    unawaited(SoftKeyboard.openFor(_fields.nameFocus, () => mounted && _step == SetupStep.businessName));
  }

  @override
  void dispose() {
    _fields.dispose();
    _pinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      automaticallyImplyLeading: false,
      leading: _step.isFirst ? null : IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back, tooltip: 'Back'),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(_step.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.sectionHeading),
          const SizedBox(height: AppSpacing.xxs),
          Text('STEP ${_step.position} OF ${SetupStep.count}', maxLines: 1, style: AppTextStyles.listSecondary),
        ],
      ),
    ),
    body: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: SingleChildScrollView(keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag, child: _body()),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: _step.isLast
                  ? _finish
                  : _canAdvance
                  ? () => unawaited(_next())
                  : null,
              child: Text(_step.isLast ? 'Finish Setup' : 'Next', maxLines: 1),
            ),
          ],
        ),
      ),
    ),
  );
}
