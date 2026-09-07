import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

final NumberFormat _groups = NumberFormat('#,##0', 'en_US');

class ThousandsFormatter extends TextInputFormatter {
  final int decimalPlaces;

  const ThousandsFormatter({this.decimalPlaces = 2});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final String raw = newValue.text.replaceAll(',', '');
    if (raw.isEmpty) return newValue.copyWith(text: '');
    if (!RegExp('^[0-9]*[.]?[0-9]*\$').hasMatch(raw)) return oldValue;
    final int dot = raw.indexOf('.');
    final String whole = dot < 0 ? raw : raw.substring(0, dot);
    final String fraction = dot < 0 ? '' : raw.substring(dot + 1);
    if (fraction.length > decimalPlaces) return oldValue;
    final int? value = whole.isEmpty ? 0 : int.tryParse(whole);
    if (value == null) return oldValue;
    final String grouped = whole.isEmpty ? '' : _groups.format(value);
    final String formatted = dot < 0 ? grouped : '$grouped.$fraction';
    final int cursorFromEnd = newValue.text.length - newValue.selection.baseOffset;
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: (formatted.length - cursorFromEnd).clamp(0, formatted.length)),
    );
  }
}
