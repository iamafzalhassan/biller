import 'dart:convert';

import '../../core/utils/invoice_number_gen.dart';
import '../../models/business_profile.dart';
import '../sources/prefs_source.dart';

class SettingsRepository {
  final PrefsSource _prefs;

  SettingsRepository(this._prefs);

  bool get isSetupComplete => _prefs.getBool(PrefsSource.keySetupComplete);

  BusinessProfile get profile {
    final String? raw = _prefs.getString(PrefsSource.keyProfile);
    if (raw == null) return BusinessProfile.empty;
    return BusinessProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  String get pendingInvoiceNumber {
    final BusinessProfile p = profile;
    return InvoiceNumberGen.build(sequence: _prefs.getInt(PrefsSource.keySequence) + 1, deviceId: p.deviceId, prefix: p.invoicePrefix);
  }

  Future<void> saveProfile(BusinessProfile profile) => _prefs.setString(PrefsSource.keyProfile, jsonEncode(profile.toJson()));

  Future<void> markSetupComplete() => _prefs.setBool(PrefsSource.keySetupComplete, true);

  Future<void> resetSetup() async {
    await _prefs.remove(PrefsSource.keyProfile);
    await _prefs.remove(PrefsSource.keySetupComplete);
    await _prefs.remove(PrefsSource.keySequence);
    await _prefs.remove(PrefsSource.keyDraft);
    await _prefs.remove(PrefsSource.keyOutbox);
  }

  Future<String> consumeInvoiceNumber() async {
    final int next = _prefs.getInt(PrefsSource.keySequence) + 1;
    await _prefs.setInt(PrefsSource.keySequence, next);
    final BusinessProfile p = profile;
    return InvoiceNumberGen.build(sequence: next, deviceId: p.deviceId, prefix: p.invoicePrefix);
  }
}
