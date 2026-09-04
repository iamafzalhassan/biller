import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

abstract final class PinHasher {
  static const int iterations = 10000;
  static const int saltBytes = 16;

  static const String separator = ':';

  static final Random _random = Random.secure();

  static bool isHashed(String stored) => stored.contains(separator);

  static String hash(String value) => _compose(value, _newSalt());

  static bool matches(String value, String stored) {
    final int index = stored.indexOf(separator);
    if (index < 0) return false;
    return _isEqual(stored, _compose(value, stored.substring(0, index)));
  }

  static String _newSalt() => base64Url.encode(List<int>.generate(saltBytes, (int _) => _random.nextInt(256)));

  static String _compose(String value, String salt) {
    List<int> digest = utf8.encode('$salt$value');
    for (int round = 0; round < iterations; round++) {
      digest = sha256.convert(digest).bytes;
    }
    return '$salt$separator${base64Url.encode(digest)}';
  }

  static bool _isEqual(String a, String b) {
    if (a.length != b.length) return false;
    int difference = 0;
    for (int index = 0; index < a.length; index++) {
      difference |= a.codeUnitAt(index) ^ b.codeUnitAt(index);
    }
    return difference == 0;
  }
}
