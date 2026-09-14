import 'dart:typed_data';

import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;

import '../../core/licensing/activation_codec.dart';
import '../../core/licensing/activation_public_key.dart';
import '../sources/device_source.dart';
import '../sources/prefs_source.dart';

class ActivationRepository {
  final DeviceSource _device;

  final PrefsSource _prefs;

  ActivationRepository(this._device, this._prefs);

  bool get isActivated => isValidKey(_prefs.getString(PrefsSource.keyActivationKey) ?? '');

  String get deviceCode => ActivationCodec.formatDeviceCode(_device.androidId);

  Future<void> saveKey(String key) => _prefs.setString(PrefsSource.keyActivationKey, ActivationCodec.normalizeKey(key));

  bool isValidKey(String key) {
    final Uint8List publicKey = ActivationCodec.hexToBytes(ActivationPublicKey.hex);
    final Uint8List signature = ActivationCodec.decodeKey(key);
    if (ActivationCodec.normalizeDeviceCode(_device.androidId).isEmpty || publicKey.length != ed.PublicKeySize || signature.length != ed.SignatureSize) return false;
    try {
      return ed.verify(ed.PublicKey(publicKey), ActivationCodec.message(_device.androidId), signature);
    } catch (_) {
      return false;
    }
  }
}
