import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

abstract final class ActivationCodec {
  static const int bitsPerByte = 8;
  static const int bitsPerCharacter = 5;
  static const int deviceGroupLength = 4;
  static const int hexDigitsPerByte = 2;
  static const int keyGroupLength = 5;

  static const String alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
  static const String groupSeparator = '-';
  static const String messagePrefix = 'BILLER-ACTIVATION:';

  static final RegExp _nonAlphabet = RegExp('[^A-Z2-7]');
  static final RegExp _nonHex = RegExp('[^0-9A-F]');

  static String bytesToHex(List<int> bytes) => bytes.map((int byte) => byte.toRadixString(16).padLeft(hexDigitsPerByte, '0')).join().toUpperCase();

  static Uint8List decodeKey(String key) => _base32Decode(normalizeKey(key));

  static String normalizeKey(String key) => key.toUpperCase().replaceAll(_nonAlphabet, '');

  static String encodeKey(List<int> signature) => _group(_base32Encode(signature), keyGroupLength);

  static String formatDeviceCode(String deviceCode) => _group(normalizeDeviceCode(deviceCode), deviceGroupLength);

  static Uint8List hexToBytes(String hex) {
    final String digits = hex.toUpperCase().replaceAll(_nonHex, '');
    return Uint8List.fromList(List<int>.generate(digits.length ~/ hexDigitsPerByte, (int index) => int.parse(digits.substring(index * hexDigitsPerByte, (index + 1) * hexDigitsPerByte), radix: 16)));
  }

  static Uint8List message(String deviceCode) => utf8.encode('$messagePrefix${normalizeDeviceCode(deviceCode)}');

  static String normalizeDeviceCode(String deviceCode) => deviceCode.toUpperCase().replaceAll(_nonHex, '');

  static Uint8List _base32Decode(String text) {
    final List<int> bytes = <int>[];
    int bitCount = 0;
    int buffer = 0;
    for (final int unit in text.codeUnits) {
      buffer = (buffer << bitsPerCharacter) | alphabet.indexOf(String.fromCharCode(unit));
      bitCount += bitsPerCharacter;
      if (bitCount < bitsPerByte) continue;
      bitCount -= bitsPerByte;
      bytes.add((buffer >> bitCount) & ((1 << bitsPerByte) - 1));
      buffer &= (1 << bitCount) - 1;
    }
    return Uint8List.fromList(bytes);
  }

  static String _base32Encode(List<int> bytes) {
    final StringBuffer text = StringBuffer();
    int bitCount = 0;
    int buffer = 0;
    for (final int byte in bytes) {
      buffer = (buffer << bitsPerByte) | byte;
      bitCount += bitsPerByte;
      while (bitCount >= bitsPerCharacter) {
        bitCount -= bitsPerCharacter;
        text.write(alphabet[(buffer >> bitCount) & (alphabet.length - 1)]);
      }
      buffer &= (1 << bitCount) - 1;
    }
    if (bitCount > 0) text.write(alphabet[(buffer << (bitsPerCharacter - bitCount)) & (alphabet.length - 1)]);
    return text.toString();
  }

  static String _group(String text, int groupLength) => <String>[for (int start = 0; start < text.length; start += groupLength) text.substring(start, min(start + groupLength, text.length))].join(groupSeparator);
}
