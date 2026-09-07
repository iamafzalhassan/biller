import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../core/utils/invoice_number_gen.dart';
import '../../../core/utils/soft_keyboard.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/profile_text_field.dart';
import '../../../core/widgets/section_header.dart';
import '../../../data/repositories/settings_repository.dart';
import '../../../models/business_profile.dart';
import '../../../models/printer_settings.dart';
import '../../../models/thermal_paper.dart';
import '../widgets/logo_section.dart';
import '../widgets/numbering_section.dart';
import '../widgets/pin_gate.dart';
import '../widgets/printer_section.dart';
import '../widgets/recovery_sheet.dart';
import '../widgets/security_section.dart';
import '../widgets/terms_section.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const int logoMaxWidth = 600;
  static const int logoQuality = 90;
  static const int retentionMaxDigits = 3;

  final FocusNode _buildingFocus = FocusNode();
  final FocusNode _cityFocus = FocusNode();
  final FocusNode _currentPinFocus = FocusNode();
  final FocusNode _deviceIdFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _newPinFocus = FocusNode();
  final FocusNode _noFocus = FocusNode();
  final FocusNode _phone1Focus = FocusNode();
  final FocusNode _phone2Focus = FocusNode();
  final FocusNode _phone3Focus = FocusNode();
  final FocusNode _prefixFocus = FocusNode();
  final FocusNode _streetFocus = FocusNode();

  final TextEditingController _buildingController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _currentPinController = TextEditingController();
  final TextEditingController _deviceIdController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _newPinController = TextEditingController();
  final TextEditingController _noController = TextEditingController();
  final TextEditingController _phone1Controller = TextEditingController();
  final TextEditingController _phone2Controller = TextEditingController();
  final TextEditingController _phone3Controller = TextEditingController();
  final TextEditingController _prefixController = TextEditingController();
  final TextEditingController _retentionController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();

  bool _isEditingTerms = false;
  bool _isLoadingDevices = false;
  bool _isUnlocked = false;

  String _appVersion = '';
  String _logoPath = '';

  List<BluetoothInfo> _devices = <BluetoothInfo>[];

  List<String> _terms = BusinessProfile.defaultTerms;

  PrinterSettings _printer = PrinterSettings.empty;

  String get _nextInvoiceNumber => InvoiceNumberGen.build(sequence: ref.read(settingsRepositoryProvider).nextSequence, deviceId: _deviceIdController.text.trim().toUpperCase(), prefix: _prefixController.text.trim().toUpperCase());

  List<String> get _phones => <String>[_phone1Controller.text, _phone2Controller.text, _phone3Controller.text].map((String phone) => phone.trim()).where((String phone) => phone.isNotEmpty).toList();

  int get _retentionDays => int.tryParse(_retentionController.text.trim()) ?? SettingsRepository.defaultRetentionDays;

  Future<void> _loadVersion() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    if (!mounted) return;
    setState(() => _appVersion = 'Biller ${info.version} (${info.buildNumber})');
  }

  void _refresh(String _) => setState(() {});

  Future<bool> _unlock(String pin) async {
    final bool isValid = await ref.read(authRepositoryProvider).verifyPin(pin);
    if (!isValid || !mounted) return isValid;
    SoftKeyboard.dismiss();
    setState(() => _isUnlocked = true);
    return true;
  }

  Future<void> _recoverPin() async {
    SoftKeyboard.release();
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => RecoverySheet(onSubmit: (String code, String newPin) => unawaited(_applyRecovery(code, newPin))),
      isScrollControlled: true,
      showDragHandle: true,
    );
    SoftKeyboard.dismiss();
  }

  Future<void> _applyRecovery(String code, String newPin) async {
    final bool isReset = await ref.read(authRepositoryProvider).resetPinWithRecoveryCode(code: code, newPin: newPin);
    if (!mounted) return;
    if (isReset) {
      context.showSuccessSnack('PIN reset. Use your new PIN the next time you open Settings.');
      setState(() => _isUnlocked = true);
      return;
    }
    context.showErrorSnack('That recovery code did not match. Check the code you wrote down during setup.');
  }

  Future<void> _changePin() async {
    SoftKeyboard.dismiss();
    final String current = _currentPinController.text;
    final String next = _newPinController.text;
    if (!Validators.isValidPin(current) || !Validators.isValidPin(next)) {
      context.showErrorSnack('Both PINs must be exactly ${Validators.pinLength} digits. Nothing has been changed yet.');
      return;
    }
    final bool isChanged = await ref.read(authRepositoryProvider).changePin(currentPin: current, newPin: next);
    if (!mounted) return;
    if (!isChanged) {
      context.showErrorSnack('Current PIN was incorrect. Your PIN has not been changed.');
      return;
    }
    context.showSuccessSnack('PIN changed. Use the new PIN the next time you open Settings.');
    _currentPinController.clear();
    _newPinController.clear();
  }

  Future<void> _pickLogo() async {
    SoftKeyboard.dismiss();
    final XFile? picked = await ImagePicker().pickImage(imageQuality: logoQuality, maxWidth: logoMaxWidth.toDouble(), source: ImageSource.gallery);
    if (picked == null || !mounted) return;
    final Directory base = await getApplicationDocumentsDirectory();
    final String stamp = '${DateTime.now().millisecondsSinceEpoch}';
    final File saved = await File(picked.path).copy('${base.path}${Platform.pathSeparator}logo_$stamp.png');
    final String replaced = _logoPath;
    if (!mounted) return;
    setState(() => _logoPath = saved.path);
    await _deleteUnsavedLogo(replaced);
    if (!mounted) return;
    context.showSuccessSnack('Logo selected. Tap Save to start printing it on your receipts.');
  }

  void _removeLogo() => setState(() => _logoPath = '');

  Future<void> _deleteUnsavedLogo(String path) async {
    if (path.isEmpty || path == ref.read(settingsRepositoryProvider).profile.logoPath) return;
    await _deleteLogoFile(path);
  }

  Future<void> _deleteLogoFile(String path) async {
    try {
      final File file = File(path);
      if (file.existsSync()) await file.delete();
    } catch (_) {
      return;
    }
  }

  Future<void> _loadPrinters() async {
    setState(() => _isLoadingDevices = true);
    final bool isReady = await ref.read(printerRepositoryProvider).isBluetoothReady();
    final List<BluetoothInfo> devices = isReady ? await ref.read(printerRepositoryProvider).pairedDevices() : <BluetoothInfo>[];
    if (!mounted) return;
    setState(() {
      _devices = devices;
      _isLoadingDevices = false;
    });
    if (!isReady) context.showErrorSnack('Bluetooth is off or the permission was refused. Turn Bluetooth on and allow nearby devices, then tap Refresh.');
  }

  void _setPrinter(PrinterSettings settings) {
    setState(() => _printer = settings);
    if (settings.isThermal && _devices.isEmpty && !_isLoadingDevices) unawaited(_loadPrinters());
  }

  Future<void> _save() async {
    SoftKeyboard.dismiss();
    if (_phones.isEmpty || _phones.any((String phone) => !Validators.isValidPhone(phone))) {
      context.showErrorSnack('Enter at least one phone number, each 10 digits starting with 0. Nothing has been saved yet.');
      return;
    }
    if (!Validators.isValidEmail(_emailController.text)) {
      context.showErrorSnack('Enter a valid email address, like name@example.com. Nothing has been saved yet.');
      return;
    }
    if (_prefixController.text.trim().isEmpty || !Validators.isValidDeviceId(_deviceIdController.text.trim().toUpperCase())) {
      context.showErrorSnack('Enter an invoice prefix and a single-letter device ID, like INV and A. Nothing has been saved yet.');
      return;
    }
    final BusinessProfile existing = ref.read(settingsRepositoryProvider).profile;
    final BusinessProfile profile = BusinessProfile(
      addressBuilding: _buildingController.text.trim(),
      addressCity: _cityController.text.trim(),
      addressNo: _noController.text.trim(),
      addressStreet: _streetController.text.trim(),
      deviceId: _deviceIdController.text.trim().toUpperCase(),
      invoicePrefix: _prefixController.text.trim().toUpperCase(),
      logoPath: _logoPath,
      name: _nameController.text.trim(),
      ownerEmail: _emailController.text.trim(),
      phones: _phones,
      terms: _terms,
    );
    await ref.read(printerRepositoryProvider).save(_printer);
    await ref.read(settingsRepositoryProvider).saveRetentionDays(_retentionDays);
    await ref.read(settingsControllerProvider.notifier).save(profile);
    if (existing.logoPath != _logoPath) await _deleteLogoFile(existing.logoPath);
    if (!mounted) return;
    ref.invalidate(printerSettingsProvider);
    ref.invalidate(recentControllerProvider);
    if (existing.deviceId != profile.deviceId || existing.invoicePrefix != profile.invoicePrefix) ref.invalidate(billingControllerProvider);
    context.showSuccessSnack('Settings saved. The changes appear on the next receipt you print.');
    Navigator.of(context).pop();
  }

  Future<void> _resetSetup() async {
    SoftKeyboard.dismiss();
    await ref.read(settingsRepositoryProvider).resetSetup();
    await ref.read(authRepositoryProvider).clearCredentials();
    if (!mounted) return;
    ref.invalidate(billingControllerProvider);
    ref.invalidate(settingsControllerProvider);
    await Navigator.of(context).pushAndRemoveUntil(Routes.setup(), (Route<dynamic> route) => false);
  }

  ProfileTextField _field({required TextEditingController controller, required FocusNode focusNode, required String label, bool isUpperCase = true, FocusNode? nextFocus, TextInputType? keyboardType}) {
    return ProfileTextField(controller: controller, focusNode: focusNode, isUpperCase: isUpperCase, keyboardType: keyboardType, label: label, nextFocus: nextFocus, onDone: SoftKeyboard.dismiss);
  }

  ProfileTextField _phoneField(TextEditingController controller, FocusNode focusNode, String label, {FocusNode? nextFocus}) {
    return ProfileTextField.phone(controller: controller, focusNode: focusNode, label: label, nextFocus: nextFocus, onDone: SoftKeyboard.dismiss);
  }

  Widget _retentionField() {
    return AppTextField(
      controller: _retentionController,
      inputFormatters: <TextInputFormatter>[FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      label: 'Days to Keep Invoices',
      maxLength: retentionMaxDigits,
      onSubmitted: (String _) => SoftKeyboard.dismiss(),
      textInputAction: TextInputAction.done,
    );
  }

  Widget _inset(List<Widget> children) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding),
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: children),
  );

  Widget _form() {
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.only(bottom: AppSpacing.xl, top: AppSpacing.lg),
      children: <Widget>[
        _inset(<Widget>[
          const SectionHeader(label: 'RECEIPT LOGO'),
          LogoSection(logoPath: _logoPath, onPick: () => unawaited(_pickLogo()), onRemove: _removeLogo),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(label: 'BUSINESS'),
          _field(controller: _nameController, focusNode: _nameFocus, label: 'Business Name', nextFocus: _phone1Focus),
          const SizedBox(height: AppSpacing.md),
          _phoneField(_phone1Controller, _phone1Focus, 'Phone 1', nextFocus: _phone2Focus),
          const SizedBox(height: AppSpacing.md),
          _phoneField(_phone2Controller, _phone2Focus, 'Phone 2 (Optional)', nextFocus: _phone3Focus),
          const SizedBox(height: AppSpacing.md),
          _phoneField(_phone3Controller, _phone3Focus, 'Phone 3 (Optional)', nextFocus: _emailFocus),
          const SizedBox(height: AppSpacing.md),
          _field(controller: _emailController, focusNode: _emailFocus, isUpperCase: false, keyboardType: TextInputType.emailAddress, label: 'Email', nextFocus: _noFocus),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(label: 'ADDRESS'),
          _field(controller: _noController, focusNode: _noFocus, label: 'No', nextFocus: _streetFocus),
          const SizedBox(height: AppSpacing.md),
          _field(controller: _streetController, focusNode: _streetFocus, label: 'Street', nextFocus: _cityFocus),
          const SizedBox(height: AppSpacing.md),
          _field(controller: _cityController, focusNode: _cityFocus, label: 'City', nextFocus: _buildingFocus),
          const SizedBox(height: AppSpacing.md),
          _field(controller: _buildingController, focusNode: _buildingFocus, label: 'Building (Optional)'),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(label: 'TERMS AND CONDITIONS'),
          TermsSection(isEditing: _isEditingTerms, terms: _terms, onChanged: (List<String> terms) => _terms = terms, onToggle: () => setState(() => _isEditingTerms = !_isEditingTerms)),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(label: 'RECEIPT PRINTER'),
        ]),
        PrinterSection(
          devices: _devices,
          isLoadingDevices: _isLoadingDevices,
          settings: _printer,
          onPaperChanged: (ThermalPaper paper) => _setPrinter(_printer.copyWith(paper: paper)),
          onRefreshDevices: () => unawaited(_loadPrinters()),
          onSelectDevice: (String address) => _setPrinter(_printer.copyWith(address: address, name: _devices.firstWhere((BluetoothInfo device) => device.macAdress == address).name)),
          onTargetChanged: (PrintTarget target) => _setPrinter(_printer.copyWith(target: target)),
        ),
        _inset(<Widget>[
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(label: 'INVOICE NUMBERING'),
          NumberingSection(
            deviceIdController: _deviceIdController,
            deviceIdFocus: _deviceIdFocus,
            nextInvoiceNumber: _nextInvoiceNumber,
            prefixController: _prefixController,
            prefixFocus: _prefixFocus,
            onChanged: _refresh,
            onDone: SoftKeyboard.dismiss,
          ),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(label: 'INVOICE HISTORY'),
          const Text('Printed invoices stay in the Recent list for this many days, then drop off. Saved PDF files in Downloads are never deleted.', style: AppTextStyles.listSecondary),
          const SizedBox(height: AppSpacing.md),
          _retentionField(),
          const SizedBox(height: AppSpacing.xl),
          const SectionHeader(label: 'SECURITY'),
          SecuritySection(
            currentPinController: _currentPinController,
            currentPinFocus: _currentPinFocus,
            isResettable: kDebugMode,
            newPinController: _newPinController,
            newPinFocus: _newPinFocus,
            onChangePin: () => unawaited(_changePin()),
            onReset: () => unawaited(_resetSetup()),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton(onPressed: () => unawaited(_save()), child: const Text('Save', maxLines: 1)),
          const SizedBox(height: AppSpacing.xl),
          Text(_appVersion, style: AppTextStyles.listSecondary, textAlign: TextAlign.center),
        ]),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    final BusinessProfile profile = ref.read(settingsRepositoryProvider).profile;
    _buildingController.text = profile.addressBuilding;
    _cityController.text = profile.addressCity;
    _deviceIdController.text = profile.deviceId;
    _emailController.text = profile.ownerEmail;
    _nameController.text = profile.name;
    _noController.text = profile.addressNo;
    _prefixController.text = profile.invoicePrefix;
    _streetController.text = profile.addressStreet;
    final List<String> phones = profile.printablePhones;
    _phone1Controller.text = phones.isNotEmpty ? phones[0] : '';
    _phone2Controller.text = phones.length > 1 ? phones[1] : '';
    _phone3Controller.text = phones.length > 2 ? phones[2] : '';
    _retentionController.text = '${ref.read(settingsRepositoryProvider).retentionDays}';
    _logoPath = profile.logoPath;
    _printer = ref.read(printerRepositoryProvider).settings;
    _terms = profile.terms;
    unawaited(_loadVersion());
  }

  @override
  void dispose() {
    _buildingFocus.dispose();
    _cityFocus.dispose();
    _currentPinFocus.dispose();
    _deviceIdFocus.dispose();
    _emailFocus.dispose();
    _nameFocus.dispose();
    _newPinFocus.dispose();
    _noFocus.dispose();
    _phone1Focus.dispose();
    _phone2Focus.dispose();
    _phone3Focus.dispose();
    _prefixFocus.dispose();
    _streetFocus.dispose();
    _buildingController.dispose();
    _cityController.dispose();
    _currentPinController.dispose();
    _deviceIdController.dispose();
    _emailController.dispose();
    _nameController.dispose();
    _newPinController.dispose();
    _noController.dispose();
    _phone1Controller.dispose();
    _phone2Controller.dispose();
    _phone3Controller.dispose();
    _prefixController.dispose();
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
