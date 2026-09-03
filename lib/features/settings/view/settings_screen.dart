import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/formatters/upper_case_formatter.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/terms_editor.dart';
import '../../../models/business_profile.dart';
import '../widgets/pin_gate.dart';
import '../widgets/recovery_sheet.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();

  bool _isEditingTerms = false;
  bool _isUnlocked = false;

  List<String> _terms = BusinessProfile.defaultTerms;

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
    context.showBriefSnack(isReset ? 'PIN reset' : 'That recovery code did not match');
    if (isReset) setState(() => _isUnlocked = true);
  }

  Future<void> _changePin() async {
    final String current = _currentPinController.text;
    final String next = _newPinController.text;
    if (current.length != 4 || next.length != 4) {
      context.showBriefSnack('Both PINs must be 4 digits');
      return;
    }
    final bool isChanged = await ref.read(authRepositoryProvider).changePin(currentPin: current, newPin: next);
    if (!mounted) return;
    context.showBriefSnack(isChanged ? 'PIN changed' : 'Current PIN was incorrect');
    if (!isChanged) return;
    _currentPinController.clear();
    _newPinController.clear();
  }

  Future<void> _save() async {
    final BusinessProfile existing = ref.read(settingsRepositoryProvider).profile;
    final BusinessProfile profile = BusinessProfile(
      addressBuilding: _buildingController.text.trim(),
      addressCity: _cityController.text.trim(),
      addressNo: _noController.text.trim(),
      addressStreet: _streetController.text.trim(),
      deviceId: existing.deviceId,
      invoicePrefix: existing.invoicePrefix,
      name: _nameController.text.trim(),
      ownerEmail: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      terms: _terms,
    );
    await ref.read(settingsControllerProvider.notifier).save(profile);
    if (!mounted) return;
    context.showBriefSnack('Settings saved');
    Navigator.of(context).pop();
  }

  Widget _field({required TextEditingController controller, required String label, bool isUpper = true, int? maxLength, TextInputType? keyboardType}) {
    return AppTextField(
      controller: controller,
      inputFormatters: isUpper ? const <TextInputFormatter>[UpperCaseFormatter()] : null,
      keyboardType: keyboardType,
      label: label,
      maxLength: maxLength,
      textCapitalization: isUpper ? TextCapitalization.characters : TextCapitalization.none,
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
        _pinField(_currentPinController, 'Current PIN'),
        const SizedBox(height: AppSpacing.md),
        _pinField(_newPinController, 'New PIN'),
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
          child: const Text('Reset everything', maxLines: 1),
        ),
      ],
    );
  }

  Widget _pinField(TextEditingController controller, String label) {
    return AppTextField(
      controller: controller,
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      label: label,
      maxLength: 4,
      obscureText: true,
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
          label: Text(_isEditingTerms ? 'Done editing' : 'Edit conditions', maxLines: 1),
          onPressed: () => setState(() => _isEditingTerms = !_isEditingTerms),
        ),
      ],
    );
  }

  Widget _form() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.xl),
      children: <Widget>[
        _sectionHeading('BUSINESS'),
        _field(controller: _nameController, label: 'Business name'),
        const SizedBox(height: AppSpacing.md),
        _field(controller: _phoneController, isUpper: false, keyboardType: TextInputType.phone, label: 'Phone'),
        const SizedBox(height: AppSpacing.md),
        _field(controller: _emailController, isUpper: false, keyboardType: TextInputType.emailAddress, label: 'Owner email'),
        const SizedBox(height: AppSpacing.xl),
        _sectionHeading('ADDRESS'),
        _field(controller: _noController, label: 'No'),
        const SizedBox(height: AppSpacing.md),
        _field(controller: _streetController, label: 'Street'),
        const SizedBox(height: AppSpacing.md),
        _field(controller: _cityController, label: 'City'),
        const SizedBox(height: AppSpacing.md),
        _field(controller: _buildingController, label: 'Building (optional)'),
        const SizedBox(height: AppSpacing.xl),
        _termsSection(),
        const SizedBox(height: AppSpacing.xl),
        _sectionHeading('SECURITY'),
        _changePinTile(),
        if (kDebugMode) const SizedBox(height: AppSpacing.sm),
        if (kDebugMode) _resetTile(),
        const SizedBox(height: AppSpacing.xl),
        FilledButton(onPressed: () => unawaited(_save()), child: const Text('Save', maxLines: 1)),
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
    _phoneController.text = profile.phone;
    _streetController.text = profile.addressStreet;
    _terms = profile.terms;
  }

  @override
  void dispose() {
    _buildingController.dispose();
    _cityController.dispose();
    _currentPinController.dispose();
    _newPinController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _noController.dispose();
    _phoneController.dispose();
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
