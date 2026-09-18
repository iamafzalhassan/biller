import 'package:intl/intl.dart';

final NumberFormat _lkrFormat = NumberFormat('#,##0.00', 'en_US');

extension CentsFormatting on int {
  String get asLkr => 'Rs. $asAmount';

  String get asAmount => _lkrFormat.format(this / 100);
}

extension RupeeParsing on String {
  int? get asCentsOrNull {
    final double? rupees = double.tryParse(replaceAll(',', '').trim());
    return rupees == null ? null : (rupees * 100).round();
  }
}

extension QtyFormatting on num {
  String get asQty => this == truncate() ? truncate().toString() : toString();
}
