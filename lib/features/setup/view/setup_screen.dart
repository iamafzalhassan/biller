import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/formatters/phone_formatter.dart';
import '../../../core/formatters/upper_case_formatter.dart';
import '../../../core/utils/mock_seed.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/pin_boxes.dart';
import '../../../core/widgets/recovery_code_box.dart';
import '../../../core/widgets/terms_editor.dart';
import '../../../models/business_profile.dart';
import '../controller/setup_controller.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  static const int lastFieldStep = 6;
  static const int totalSteps = 8;

  final FocusNode _stepFocus = FocusNode();

  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _deviceIdController = TextEditingController(text: 'A');
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _prefixController = TextEditingController(text: 'INV');
  final TextEditingController _streetController = TextEditingController();

  int _step = 0;

  String _recoveryCode = '';

  List<String> _terms = BusinessProfile.defaultTerms;

  String get _stepTitle {
    switch (_step) {
      case 0:
        return 'Business name';
      case 1:
        return 'Address';
      case 2:
        return 'Phone';
      case 3:
        return 'Owner email';
      case 4:
        return 'Terms and conditions';
      case 5:
        return 'Invoice numbering';
      case 6:
        return 'Set a 4-digit PIN';
      default:
        return 'Write this down';
    }
  }

  bool get _canAdvance {
    switch (_step) {
      case 0:
        return _nameController.text.trim().isNotEmpty;
      case 1:
        return _noController.text.trim().isNotEmpty && _streetController.text.trim().isNotEmpty && _cityController.text.trim().isNotEmpty;
      case 3:
        return Validators.isValidEmail(_emailController.text);
      case 5:
        return _prefixController.text.trim().isNotEmpty && Validators.isValidDeviceId(_deviceIdController.text.toUpperCase());
      case 6:
        return Validators.isValidPin(_pinController.text);
      default:
        return true;
    }
  }

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
    phone: _phoneController.text.trim(),
    terms: _terms,
  );

  void _focusStep() {
    WidgetsBinding.instance.addPostFrameCallback((Duration _) {
      if (mounted) _stepFocus.requestFocus();
    });
  }

  Future<void> _next() async {
    if (_step < lastFieldStep) {
      setState(() => _step++);
      _focusStep();
      return;
    }
    ref.read(setupControllerProvider.notifier).update(_profile);
    final String code = await ref.read(setupControllerProvider.notifier).finish(_pinController.text);
    if (!mounted) return;
    setState(() {
      _recoveryCode = code;
      _step++;
    });
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step--);
    _focusStep();
  }

  void _finish() => Navigator.of(context).pushAndRemoveUntil(Routes.billing(), (Route<dynamic> route) => false);

  Widget _body() {
    switch (_step) {
      case 0:
        return _step0();
      case 1:
        return _step1();
      case 2:
        return _step2();
      case 3:
        return _step3();
      case 4:
        return _step4();
      case 5:
        return _step5();
      case 6:
        return _step6();
      default:
        return _step7();
    }
  }

  Widget _step0() => _stepFrame(
    hint: 'Printed at the top of every receipt',
    children: <Widget>[_field(controller: _nameController, autofocus: true, label: 'Business name')],
  );

  Widget _step1() => _stepFrame(
    hint: 'Printed under the business name',
    children: <Widget>[
      _field(controller: _noController, autofocus: true, label: 'No'),
      const SizedBox(height: AppSpacing.md),
      _field(controller: _streetController, label: 'Street'),
      const SizedBox(height: AppSpacing.md),
      _field(controller: _cityController, label: 'City'),
      const SizedBox(height: AppSpacing.md),
      _field(controller: _buildingController, label: 'Building (optional)'),
    ],
  );

  Widget _step2() => _stepFrame(
    hint: 'Printed on the receipt header',
    children: <Widget>[_field(controller: _phoneController, autofocus: true, isPhone: true, isUpper: false, keyboardType: TextInputType.phone, label: 'Phone')],
  );

  Widget _step3() => _stepFrame(
    hint: 'Every receipt is emailed here',
    children: <Widget>[_field(controller: _emailController, autofocus: true, isUpper: false, keyboardType: TextInputType.emailAddress, label: 'Owner email')],
  );

  Widget _step4() => _stepFrame(
    hint: 'Printed at the foot of the receipt',
    children: <Widget>[TermsEditor(isEditable: true, terms: _terms, onChanged: (List<String> terms) => _terms = terms)],
  );

  Widget _step5() => _stepFrame(
    hint: 'Each device needs its own letter, so two counters never share a number',
    children: <Widget>[
      Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: _field(controller: _prefixController, label: 'Prefix'),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _field(controller: _deviceIdController, label: 'Device', maxLength: 1),
          ),
        ],
      ),
      const SizedBox(height: AppSpacing.md),
      Text(
        'Bills will be numbered ${_prefixController.text.toUpperCase()}-${_deviceIdController.text.toUpperCase()}-0001',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTextStyles.listSecondary,
      ),
    ],
  );

  Widget _step6() => _stepFrame(
    hint: 'The PIN protects the settings screen only',
    children: <Widget>[
      Center(
        child: PinBoxes(
          autofocus: true,
          controller: _pinController,
          hasError: false,
          onChanged: (String _) => setState(() {}),
          onCompleted: (String _) => setState(() {}),
        ),
      ),
    ],
  );

  Widget _step7() => _stepFrame(
    hint: 'The only way to reset a forgotten PIN. It is shown once and cannot be recovered later',
    children: <Widget>[RecoveryCodeBox(code: _recoveryCode)],
  );

  Widget _stepFrame({required String hint, required List<Widget> children}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(hint, style: AppTextStyles.listSecondary),
        const SizedBox(height: AppSpacing.xl),
        ...children,
      ],
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    bool autofocus = false,
    bool isPhone = false,
    bool isUpper = true,
    int? maxLength,
    TextInputType? keyboardType,
  }) {
    return AppTextField(
      controller: controller,
      focusNode: autofocus ? _stepFocus : null,
      inputFormatters: isPhone
          ? const <TextInputFormatter>[SriLankaPhoneFormatter()]
          : isUpper
          ? const <TextInputFormatter>[UpperCaseFormatter()]
          : null,
      keyboardType: keyboardType,
      label: label,
      maxLength: maxLength,
      onChanged: (String _) => setState(() {}),
      textCapitalization: isUpper ? TextCapitalization.characters : TextCapitalization.none,
    );
  }

  @override
  void initState() {
    super.initState();
    _focusStep();
    if (!kDebugMode) return;
    _buildingController.text = MockSeed.profile.addressBuilding;
    _cityController.text = MockSeed.profile.addressCity;
    _deviceIdController.text = MockSeed.profile.deviceId;
    _emailController.text = MockSeed.profile.ownerEmail;
    _nameController.text = MockSeed.profile.name;
    _noController.text = MockSeed.profile.addressNo;
    _phoneController.text = MockSeed.profile.phone;
    _pinController.text = MockSeed.pin;
    _prefixController.text = MockSeed.profile.invoicePrefix;
    _streetController.text = MockSeed.profile.addressStreet;
  }

  @override
  void dispose() {
    _stepFocus.dispose();
    _buildingController.dispose();
    _cityController.dispose();
    _deviceIdController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _noController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _prefixController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isRecoveryStep = _step > lastFieldStep;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: _step > 0 ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _back, tooltip: 'Back') : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(_stepTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: AppTextStyles.sectionHeading),
            const SizedBox(height: AppSpacing.xxs),
            Text('STEP ${_step + 1} OF $totalSteps', maxLines: 1, style: AppTextStyles.listSecondary),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.screenPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(child: SingleChildScrollView(child: _body())),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: isRecoveryStep
                    ? _finish
                    : _canAdvance
                    ? () => unawaited(_next())
                    : null,
                child: Text(isRecoveryStep ? 'Finish Setup' : 'Next', maxLines: 1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
