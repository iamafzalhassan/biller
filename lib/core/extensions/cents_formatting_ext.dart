import 'package:intl/intl.dart';

final NumberFormat _lkrFormat = NumberFormat('#,##0.00', 'en_US');

extension CentsFormatting on int {
  String get asLkr => 'Rs. ${_lkrFormat.format(this / 100)}';

  String get asAmount => _lkrFormat.format(this / 100);
}

extension RupeeParsing on String {
  int? get asCentsOrNull {
    final String cleaned = replaceAll(',', '').trim();
    if (cleaned.isEmpty) return null;
    final double? rupees = double.tryParse(cleaned);
    if (rupees == null) return null;
    return (rupees * 100).round();
  }
}

extension QtyFormatting on num {
  String get asQty => this == truncate() ? truncate().toString() : toString();
}
