import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/soft_keyboard.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/pin_boxes.dart';
import '../../../core/widgets/profile_text_field.dart';
import '../../../core/widgets/recovery_code_box.dart';
import '../../../core/widgets/terms_editor.dart';
import '../../../models/business_profile.dart';
import '../controller/setup_step.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final FocusNode _buildingFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _deviceIdFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _noFocus = FocusNode();
  final FocusNode _phone1Focus = FocusNode();
  final FocusNode _phone2Focus = FocusNode();
  final FocusNode _phone3Focus = FocusNode();
  final FocusNode _prefixFocus = FocusNode();
  final FocusNode _streetFocus = FocusNode();

  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _deviceIdController = TextEditingController(text: 'A');
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noController = TextEditingController();
  final TextEditingController _phone1Controller = TextEditingController();
  final TextEditingController _phone2Controller = TextEditingController();
  final TextEditingController _phone3Controller = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _prefixController = TextEditingController(text: 'INV');
  final TextEditingController _streetController = TextEditingController();

  String _recoveryCode = '';

  List<String> _terms = BusinessProfile.defaultTerms;

  SetupStep _step = SetupStep.first;

  bool get _canAdvance => switch (_step) {
    SetupStep.businessName => _nameController.text.trim().isNotEmpty,
    SetupStep.address => _noController.text.trim().isNotEmpty && _streetController.text.trim().isNotEmpty && _cityController.text.trim().isNotEmpty,
    SetupStep.phones => _phone1Controller.text.trim().isNotEmpty && !_hasPhoneError,
    SetupStep.email => Validators.isValidEmail(_emailController.text),
    SetupStep.numbering => _prefixController.text.trim().isNotEmpty && Validators.isValidDeviceId(_deviceIdController.text.toUpperCase()),
    SetupStep.pin => Validators.isValidPin(_pinController.text),
    SetupStep.terms || SetupStep.recoveryCode => true,
  };

  bool get _hasEmailError => _emailController.text.trim().isNotEmpty && !Validators.isValidEmail(_emailController.text);

  bool get _hasPhoneError => <TextEditingController>[_phone1Controller, _phone2Controller, _phone3Controller].any((TextEditingController controller) => !Validators.isValidPhone(controller.text));

  List<String> get _phones => <String>[_phone1Controller.text, _phone2Controller.text, _phone3Controller.text].map((String phone) => phone.trim()).where((String phone) => phone.isNotEmpty).toList();

  BusinessProfile get _profile => BusinessProfile(
    addressBuilding: _buildingController.text.trim(),
    addressCity: _cityController.text.trim(),
    addressNo: _noController.text.trim(),
    addressStreet: _streetController.text.trim(),
    deviceId: _deviceIdController.text.trim().toUpperCase(),
    invoicePrefix: _prefixController.text.trim().toUpperCase(),
    logoPath: '',
    name: _nameController.text.trim(),
    ownerEmail: _emailController.text.trim(),
    phones: _phones,
    terms: _terms,
  );

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
    ref.read(setupControllerProvider.notifier).update(_profile);
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
    children: <Widget>[_field(autofocus: true, controller: _nameController, focusNode: _nameFocus, label: 'Business Name')],
  );

  Widget _addressStep() => _stepFrame(
    hint: 'Printed under the business name',
    children: <Widget>[
      _field(autofocus: true, controller: _noController, focusNode: _noFocus, label: 'No', nextFocus: _streetFocus),
      const SizedBox(height: AppSpacing.md),
      _field(controller: _streetController, focusNode: _streetFocus, label: 'Street', nextFocus: _cityFocus),
      const SizedBox(height: AppSpacing.md),
      _field(controller: _cityController, focusNode: _cityFocus, label: 'City', nextFocus: _buildingFocus),
      const SizedBox(height: AppSpacing.md),
      _field(controller: _buildingController, focusNode: _buildingFocus, label: 'Building (Optional)'),
    ],
  );

  Widget _phonesStep() => _stepFrame(
    hint: 'Up to three lines, printed side by side on the receipt header',
    children: <Widget>[
      _phoneField(_phone1Controller, _phone1Focus, 'Phone 1', autofocus: true, nextFocus: _phone2Focus),
      const SizedBox(height: AppSpacing.md),
      _phoneField(_phone2Controller, _phone2Focus, 'Phone 2 (Optional)', nextFocus: _phone3Focus),
      const SizedBox(height: AppSpacing.md),
      _phoneField(_phone3Controller, _phone3Focus, 'Phone 3 (Optional)'),
      if (_hasPhoneError) const SizedBox(height: AppSpacing.sm),
      if (_hasPhoneError) const Text('Each phone must be 10 digits starting with 0', maxLines: 1, style: AppTextStyles.errorHint),
    ],
  );

  Widget _emailStep() => _stepFrame(
    hint: 'Kept on file as the owner contact',
    children: <Widget>[
      _field(autofocus: true, controller: _emailController, focusNode: _emailFocus, isUpperCase: false, keyboardType: TextInputType.emailAddress, label: 'Email'),
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
            child: _field(autofocus: true, controller: _prefixController, focusNode: _prefixFocus, label: 'Prefix', nextFocus: _deviceIdFocus),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _field(controller: _deviceIdController, focusNode: _deviceIdFocus, label: 'Device', maxLength: 1),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      Text('Bills will be numbered ${_prefixController.text.toUpperCase()}-${_deviceIdController.text.toUpperCase()}-0001', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.listSecondary),
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
    children: <Widget>[RecoveryCodeBox(code: _recoveryCode)],
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
    unawaited(SoftKeyboard.openFor(_nameFocus, () => mounted && _step == SetupStep.businessName));
  }

  @override
  void dispose() {
    _buildingFocus.dispose();
    _cityFocus.dispose();
    _deviceIdFocus.dispose();
    _emailFocus.dispose();
    _nameFocus.dispose();
    _noFocus.dispose();
    _phone1Focus.dispose();
    _phone2Focus.dispose();
    _phone3Focus.dispose();
    _prefixFocus.dispose();
    _streetFocus.dispose();
    _buildingController.dispose();
    _cityController.dispose();
    _deviceIdController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _noController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _phone3Controller.dispose();
    _pinController.dispose();
    _prefixController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
}
