import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageSource {
  static const String keyPin = 'admin_pin';
  static const String keyRecoveryCode = 'recovery_code';

  final FlutterSecureStorage _storage = const FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

  Future<String?> read(String key) => _storage.read(key: key);

  Future<void> write(String key, String value) => _storage.write(key: key, value: value);

  Future<void> delete(String key) => _storage.delete(key: key);
}
