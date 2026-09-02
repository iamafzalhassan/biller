import 'dart:math';

import '../sources/secure_storage_source.dart';

class AuthRepository {
  static const int recoveryCodeLength = 10;

  static const String recoveryAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  final Random _random = Random.secure();

  final SecureStorageSource _storage;

  AuthRepository(this._storage);

  Future<bool> hasPin() async => (await _storage.read(SecureStorageSource.keyPin)) != null;

  Future<String> setPin(String pin) async {
    final String recoveryCode = _generateRecoveryCode();
    await _storage.write(SecureStorageSource.keyPin, pin);
    await _storage.write(SecureStorageSource.keyRecoveryCode, recoveryCode);
    return recoveryCode;
  }

  Future<bool> verifyPin(String pin) async => (await _storage.read(SecureStorageSource.keyPin)) == pin;

  Future<bool> changePin({required String currentPin, required String newPin}) async {
    if (!await verifyPin(currentPin)) return false;
    await _storage.write(SecureStorageSource.keyPin, newPin);
    return true;
  }

  Future<bool> resetPinWithRecoveryCode({required String code, required String newPin}) async {
    final String? stored = await _storage.read(SecureStorageSource.keyRecoveryCode);
    if (stored == null || stored != code.trim().toUpperCase()) return false;
    await _storage.write(SecureStorageSource.keyPin, newPin);
    return true;
  }

  Future<void> clearCredentials() async {
    await _storage.delete(SecureStorageSource.keyPin);
    await _storage.delete(SecureStorageSource.keyRecoveryCode);
  }

  String _generateRecoveryCode() {
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < recoveryCodeLength; i++) {
      if (i == 5) buffer.write('-');
      buffer.write(recoveryAlphabet[_random.nextInt(recoveryAlphabet.length)]);
    }
    return buffer.toString();
  }
}
