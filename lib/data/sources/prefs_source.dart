import 'package:shared_preferences/shared_preferences.dart';

class PrefsSource {
  static const String keyDraft = 'draft_invoice';
  static const String keyProfile = 'business_profile';
  static const String keyRetentionDays = 'history_retention_days';
  static const String keySequence = 'invoice_sequence';
  static const String keySetupComplete = 'setup_complete';

  late final SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  bool getBool(String key, {bool fallback = false}) => _prefs.getBool(key) ?? fallback;

  int getInt(String key, {int fallback = 0}) => _prefs.getInt(key) ?? fallback;

  String? getString(String key) => _prefs.getString(key);

  List<String> getStringList(String key) => _prefs.getStringList(key) ?? <String>[];

  Future<void> setBool(String key, bool value) => _prefs.setBool(key, value);

  Future<void> setInt(String key, int value) => _prefs.setInt(key, value);

  Future<void> setString(String key, String value) => _prefs.setString(key, value);

  Future<void> setStringList(String key, List<String> value) => _prefs.setStringList(key, value);

  Future<void> remove(String key) => _prefs.remove(key);
}
