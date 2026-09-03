import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/formatters/phone_formatter.dart';
import '../../../core/formatters/upper_case_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/terms_editor.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../models/business_profile.dart';
import '../widgets/pin_gate.dart';
import '../widgets/recovery_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final FocusNode _buildingFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _noFocus = FocusNode();
  final FocusNode _phone1Focus = FocusNode();
  final FocusNode _phone2Focus = FocusNode();
  final FocusNode _phone3Focus = FocusNode();
  final FocusNode _streetFocus = FocusNode();

  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noController = TextEditingController();
  final TextEditingController _phone1Controller = TextEditingController();
  final TextEditingController _phone2Controller = TextEditingController();
  final TextEditingController _phone3Controller = TextEditingController();
  final TextEditingController _retentionController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();

  bool _isEditingTerms = false;
  bool _isUnlocked = false;

  int _logoRevision = 0;

  String _appVersion = '';
  String _logoPath = '';

  List<String> _terms = BusinessProfile.defaultTerms;

  final FocusNode _currentPinFocus = FocusNode();
  final FocusNode _newPinFocus = FocusNode();

  final TextEditingController _currentPinController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();

  Future<bool> _unlock(String pin) async {
    final bool isValid = await ref.read(authRepositoryProvider).verifyPin(pin);
    if (isValid && mounted) setState(() => _isUnlocked = true);
    return isValid;
  }

  Future<void> _recoverPin() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => RecoverySheet(onSubmit: (String code, String newPin) => unawaited(_applyRecovery(code, newPin))),
      isScrollControlled: true,
      showDragHandle: true,
    );
  }

  Future<void> _applyRecovery(String code, String newPin) async {
    final bool isReset = await ref.read(authRepositoryProvider).resetPinWithRecoveryCode(code: code, newPin: newPin);
    if (!mounted) return;
    if (isReset) {
      context.showSuccessSnack('PIN reset. Use your new PIN the next time you open Settings.');
    } else {
      context.showErrorSnack('That recovery code did not match. Check the code you wrote down during setup.');
    }
    if (isReset) setState(() => _isUnlocked = true);
  }

  Future<void> _changePin() async {
    final String current = _currentPinController.text;
    final String next = _newPinController.text;
    if (current.length != 4 || next.length != 4) {
      context.showErrorSnack('Both PINs must be exactly 4 digits. Nothing has been changed yet.');
      return;
    }
    final bool isChanged = await ref.read(authRepositoryProvider).changePin(currentPin: current, newPin: next);
    if (!mounted) return;
    if (isChanged) {
      context.showSuccessSnack('PIN changed. Use the new PIN the next time you open Settings.');
    } else {
      context.showErrorSnack('Current PIN was incorrect. Your PIN has not been changed.');
    }
    if (!isChanged) return;
    _currentPinController.clear();
    _newPinController.clear();
  }

  List<String> get _phones => <String>[
    _phone1Controller.text,
    _phone2Controller.text,
    _phone3Controller.text,
  ].map((String phone) => phone.trim()).where((String phone) => phone.isNotEmpty).toList();

  int get _retentionDays => int.tryParse(_retentionController.text.trim()) ?? SettingsRepository.defaultRetentionDays;

  Future<void> _save() async {
    if (_phones.isEmpty || _phones.any((String phone) => !Validators.isValidPhone(phone))) {
      context.showErrorSnack('Enter at least one phone number, each 10 digits starting with 0. Nothing has been saved yet.');
      return;
    }
    if (!Validators.isValidEmail(_emailController.text)) {
      context.showErrorSnack('Enter a valid email address, like name@example.com. Nothing has been saved yet.');
      return;
    }
    final BusinessProfile existing = ref.read(settingsRepositoryProvider).profile;
    final BusinessProfile profile = BusinessProfile(
      addressBuilding: _buildingController.text.trim(),
      addressCity: _cityController.text.trim(),
      addressNo: _noController.text.trim(),
      addressStreet: _streetController.text.trim(),
      deviceId: existing.deviceId,
      invoicePrefix: existing.invoicePrefix,
      logoPath: _logoPath,
      name: _nameController.text.trim(),
      ownerEmail: _emailController.text.trim(),
      phones: _phones,
      terms: _terms,
    );
    await ref.read(settingsRepositoryProvider).saveRetentionDays(_retentionDays);
    await ref.read(settingsControllerProvider.notifier).save(profile);
    if (!mounted) return;
    ref.invalidate(recentControllerProvider);
    context.showSuccessSnack('Settings saved. The changes appear on the next receipt you print.');
    Navigator.of(context).pop();
  }

  Widget _field({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    bool isPhone = false,
    bool isUpper = true,
    int? maxLength,
    FocusNode? nextFocus,
    TextInputType? keyboardType,
  }) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      inputFormatters: isPhone
          ? const <TextInputFormatter>[SriLankaPhoneFormatter()]
          : isUpper
          ? const <TextInputFormatter>[UpperCaseFormatter()]
          : null,
      keyboardType: keyboardType,
      label: label,
      maxLength: maxLength,
      onSubmitted: (String _) => nextFocus == null ? FocusManager.instance.primaryFocus?.unfocus() : nextFocus.requestFocus(),
      textCapitalization: isUpper ? TextCapitalization.characters : TextCapitalization.none,
      textInputAction: nextFocus == null ? TextInputAction.done : TextInputAction.next,
    );
  }

  Widget _phoneField(TextEditingController controller, FocusNode focusNode, String label, {FocusNode? nextFocus}) => _field(
    controller: controller,
    focusNode: focusNode,
    isPhone: true,
    isUpper: false,
    keyboardType: TextInputType.phone,
    label: label,
    nextFocus: nextFocus,
  );

  Widget _retentionField() {
    return AppTextField(
      controller: _retentionController,
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      label: 'Days to keep invoices',
      maxLength: 3,
      onSubmitted: (String _) => FocusManager.instance.primaryFocus?.unfocus(),
      textInputAction: TextInputAction.done,
    );
  }

  Future<void> _resetSetup() async {
    await ref.read(settingsRepositoryProvider).resetSetup();
    await ref.read(authRepositoryProvider).clearCredentials();
    if (!mounted) return;
    ref.invalidate(billingControllerProvider);
    ref.invalidate(settingsControllerProvider);
    await Navigator.of(context).pushAndRemoveUntil(Routes.setup(), (Route<dynamic> route) => false);
  }

  Widget _sectionHeading(String label) => SectionHeader(label: label);

  Widget _changePinTile() {
    return ExpansionTile(
      leading: const Icon(Icons.lock_outline, size: 20),
      title: const Text('Change PIN', maxLines: 1, style: AppTextStyles.listPrimary),
      children: <Widget>[
        const SizedBox(height: AppSpacing.lg),
        _pinField(_currentPinController, _currentPinFocus, 'Current PIN', nextFocus: _newPinFocus),
        const SizedBox(height: AppSpacing.md),
        _pinField(_newPinController, _newPinFocus, 'New PIN'),
        const SizedBox(height: AppSpacing.lg),
        FilledButton(onPressed: () => unawaited(_changePin()), child: const Text('Update PIN', maxLines: 1)),
      ],
    );
  }

  Widget _resetTile() {
    return ExpansionTile(
      leading: const Icon(Icons.restart_alt, size: 20),
      title: const Text('Reset and run setup again', maxLines: 1, style: AppTextStyles.listPrimary),
      children: <Widget>[
        const SizedBox(height: AppSpacing.lg),
        const Text('Clears the business profile, PIN, invoice sequence and saved draft, then reopens the setup wizard.', style: AppTextStyles.listSecondary),
        const SizedBox(height: AppSpacing.lg),
        OutlinedButton(
          onPressed: () => unawaited(_resetSetup()),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.danger,
            side: const BorderSide(color: AppColors.danger),
          ),
          child: const Text('Reset Everything', maxLines: 1),
        ),
      ],
    );
  }

  Widget _pinField(TextEditingController controller, FocusNode focusNode, String label, {FocusNode? nextFocus}) {
    return AppTextField(
      controller: controller,
      focusNode: focusNode,
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      label: label,
      maxLength: 4,
      obscureText: true,
      onSubmitted: (String _) => nextFocus == null ? unawaited(_changePin()) : nextFocus.requestFocus(),
      textInputAction: nextFocus == null ? TextInputAction.done : TextInputAction.next,
    );
  }

  Future<void> _pickLogo() async {
    final XFile? picked = await ImagePicker().pickImage(imageQuality: 90, maxWidth: 600, source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    final Directory base = await getApplicationDocumentsDirectory();
    final File saved = await File(picked.path).copy('${base.path}${Platform.pathSeparator}logo.png');
    await FileImage(saved).evict();
    if (!mounted) return;
    setState(() {
      _logoPath = saved.path;
      _logoRevision++;
    });
    context.showSuccessSnack('Logo selected. Tap Save to start printing it on your receipts.');
  }

  void _removeLogo() => setState(() => _logoPath = '');

  Future<void> _loadVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _appVersion = 'Biller ${info.version} (${info.buildNumber})');
  }

  Widget _logoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _sectionHeading('RECEIPT LOGO'),
        Row(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(AppSpacing.radiusCard), color: AppColors.surfaceField),
              height: AppSpacing.logoPreview,
              width: AppSpacing.logoPreview,
              child: _logoPath.isEmpty
                  ? const Icon(Icons.image_outlined, color: AppColors.textTertiary, size: 24)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
                      child: Image.file(File(_logoPath), key: ValueKey<int>(_logoRevision), fit: BoxFit.cover),
                    ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                _logoPath.isEmpty ? 'No logo. It prints above the business name.' : 'Prints above the business name on every receipt.',
                style: AppTextStyles.listSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: <Widget>[
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.upload_outlined, size: 18),
                label: Text(_logoPath.isEmpty ? 'Upload Logo' : 'Replace Logo', maxLines: 1),
                onPressed: () => unawaited(_pickLogo()),
              ),
            ),
            if (_logoPath.isNotEmpty) const SizedBox(width: AppSpacing.md),
            if (_logoPath.isNotEmpty)
              Expanded(
                child: OutlinedButton(
                  onPressed: _removeLogo,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  child: const Text('Remove', maxLines: 1),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _termsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _sectionHeading('TERMS AND CONDITIONS'),
        TermsEditor(isEditable: _isEditingTerms, terms: _terms, onChanged: (List<String> terms) => _terms = terms),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          icon: Icon(_isEditingTerms ? Icons.check : Icons.edit_outlined, size: 18),
          label: Text(_isEditingTerms ? 'Done' : 'Edit Conditions', maxLines: 1),
          onPressed: () => setState(() => _isEditingTerms = !_isEditingTerms),
        ),
      ],
    );
  }

  Widget _form() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.xl),
      children: <Widget>[
        _logoSection(),
        const SizedBox(height: AppSpacing.xl),
        _sectionHeading('BUSINESS'),
        _field(controller: _nameController, focusNode: _nameFocus, label: 'Business name', nextFocus: _phone1Focus),
        const SizedBox(height: AppSpacing.md),
        _phoneField(_phone1Controller, _phone1Focus, 'Phone 1', nextFocus: _phone2Focus),
        const SizedBox(height: AppSpacing.md),
        _phoneField(_phone2Controller, _phone2Focus, 'Phone 2 (optional)', nextFocus: _phone3Focus),
        const SizedBox(height: AppSpacing.md),
        _phoneField(_phone3Controller, _phone3Focus, 'Phone 3 (optional)', nextFocus: _emailFocus),
        const SizedBox(height: AppSpacing.md),
        _field(
          controller: _emailController,
          focusNode: _emailFocus,
          isUpper: false,
          keyboardType: TextInputType.emailAddress,
          label: 'Email',
          nextFocus: _noFocus,
        ),
        const SizedBox(height: AppSpacing.xl),
        _sectionHeading('ADDRESS'),
        _field(controller: _noController, focusNode: _noFocus, label: 'No', nextFocus: _streetFocus),
        const SizedBox(height: AppSpacing.md),
        _field(controller: _streetController, focusNode: _streetFocus, label: 'Street', nextFocus: _cityFocus),
        const SizedBox(height: AppSpacing.md),
        _field(controller: _cityController, focusNode: _cityFocus, label: 'City', nextFocus: _buildingFocus),
        const SizedBox(height: AppSpacing.md),
        _field(controller: _buildingController, focusNode: _buildingFocus, label: 'Building (optional)'),
        const SizedBox(height: AppSpacing.xl),
        _termsSection(),
        const SizedBox(height: AppSpacing.xl),
        _sectionHeading('INVOICE HISTORY'),
        const Text(
          'Printed invoices stay in the Recent list for this many days, then drop off. Saved PDF files in Downloads are never deleted.',
          style: AppTextStyles.listSecondary,
        ),
        const SizedBox(height: AppSpacing.md),
        _retentionField(),
        const SizedBox(height: AppSpacing.xl),
        _sectionHeading('SECURITY'),
        _changePinTile(),
        if (kDebugMode) const SizedBox(height: AppSpacing.sm),
        if (kDebugMode) _resetTile(),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(onPressed: () => unawaited(_save()), child: const Text('Save', maxLines: 1)),
        const SizedBox(height: AppSpacing.xl),
        Text(_appVersion, style: AppTextStyles.listSecondary, textAlign: TextAlign.center),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final BusinessProfile profile = ref.read(settingsRepositoryProvider).profile;
    _buildingController.text = profile.addressBuilding;
    _cityController.text = profile.addressCity;
    _emailController.text = profile.ownerEmail;
    _nameController.text = profile.name;
    _noController.text = profile.addressNo;
    final List<String> phones = profile.printablePhones;
    _phone1Controller.text = phones.isNotEmpty ? phones[0] : '';
    _phone2Controller.text = phones.length > 1 ? phones[1] : '';
    _phone3Controller.text = phones.length > 2 ? phones[2] : '';
    _retentionController.text = '${ref.read(settingsRepositoryProvider).retentionDays}';
    _streetController.text = profile.addressStreet;
    _logoPath = profile.logoPath;
    _terms = profile.terms;
    unawaited(_loadVersion());
  }

  @override
  void dispose() {
    _buildingFocus.dispose();
    _cityFocus.dispose();
    _currentPinFocus.dispose();
    _emailFocus.dispose();
    _newPinFocus.dispose();
    _nameFocus.dispose();
    _noFocus.dispose();
    _phone1Focus.dispose();
    _phone2Focus.dispose();
    _phone3Focus.dispose();
    _streetFocus.dispose();
    _buildingController.dispose();
    _cityController.dispose();
    _currentPinController.dispose();
    _newPinController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _noController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _phone3Controller.dispose();
    _retentionController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isUnlocked ? 'Settings' : 'Enter PIN', maxLines: 1)),
      body: SafeArea(
        child: _isUnlocked ? _form() : PinGate(onRecover: () => unawaited(_recoverPin()), onSubmit: _unlock),
      ),
    );
  }
}
