import 'dart:math';

import '../../core/utils/pin_hasher.dart';
import '../sources/secure_storage_source.dart';

class AuthRepository {
  static const int recoveryCodeLength = 10;

  static const String recoveryAlphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

  final Random _random = Random.secure();

  final SecureStorageSource _storage;

  AuthRepository(this._storage);

  Future<String> setPin(String pin) async {
    final String recoveryCode = _generateRecoveryCode();
    await _storage.write(SecureStorageSource.keyPin, PinHasher.hash(pin));
    await _storage.write(SecureStorageSource.keyRecoveryCode, PinHasher.hash(recoveryCode));
    return recoveryCode;
  }

  Future<bool> verifyPin(String pin) => _verify(SecureStorageSource.keyPin, pin);

  Future<bool> changePin({required String currentPin, required String newPin}) async {
    if (!await verifyPin(currentPin)) return false;
    await _storage.write(SecureStorageSource.keyPin, PinHasher.hash(newPin));
    return true;
  }

  Future<bool> resetPinWithRecoveryCode({required String code, required String newPin}) async {
    if (!await _verify(SecureStorageSource.keyRecoveryCode, code.trim().toUpperCase())) return false;
    await _storage.write(SecureStorageSource.keyPin, PinHasher.hash(newPin));
    return true;
  }

  Future<void> clearCredentials() async {
    await _storage.delete(SecureStorageSource.keyPin);
    await _storage.delete(SecureStorageSource.keyRecoveryCode);
  }

  Future<bool> _verify(String key, String value) async {
    final String? stored = await _storage.read(key);
    if (stored == null) return false;
    if (PinHasher.isHashed(stored)) return PinHasher.matches(value, stored);
    if (stored != value) return false;
    await _storage.write(key, PinHasher.hash(value));
    return true;
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
