import 'package:flutter/services.dart';

class UpperCaseFormatter extends TextInputFormatter {
  const UpperCaseFormatter();

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

class DecimalFormatter extends TextInputFormatter {
  const DecimalFormatter({this.decimalPlaces = 2});

  final int decimalPlaces;

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String text = newValue.text;
    if (text.isEmpty) return newValue;
    if (!RegExp('^[0-9]*[.]?[0-9]{0,$decimalPlaces}\$').hasMatch(text)) return oldValue;
    return newValue;
  }
}
