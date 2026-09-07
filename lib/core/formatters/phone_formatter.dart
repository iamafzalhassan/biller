import 'package:flutter/services.dart';

class SriLankaPhoneFormatter extends TextInputFormatter {
  static const int length = 10;

  static const String countryCode = '94';

  const SriLankaPhoneFormatter();

  static String normalise(String value) {
    String digits = value.replaceAll(RegExp('[^0-9]'), '');
    if (digits.startsWith(countryCode) && digits.length > 9) digits = digits.substring(countryCode.length);
    if (digits.isNotEmpty && !digits.startsWith('0')) digits = '0$digits';
    return digits.length > length ? digits.substring(0, length) : digits;
  }

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String formatted = normalise(newValue.text);
    final int cursorFromEnd = newValue.text.length - newValue.selection.baseOffset;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: (formatted.length - cursorFromEnd).clamp(0, formatted.length)),
    );
  }
}
