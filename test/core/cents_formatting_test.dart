import 'package:biller/core/extensions/cents_formatting_ext.dart';
import 'package:biller/core/utils/invoice_number_gen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CentsFormatting', () {
    test('formats with a thousands separator and two decimals', () {
      expect(1200000.asLkr, 'Rs. 12,000.00');
    });

    test('never rounds to whole rupees', () {
      expect(1250.asLkr, 'Rs. 12.50');
      expect(1.asLkr, 'Rs. 0.01');
    });

    test('formats a negative balance', () {
      expect((-50000).asLkr, 'Rs. -500.00');
    });
  });

  group('RupeeParsing', () {
    test('parses plain and grouped input into cents', () {
      expect('12000'.asCentsOrNull, 1200000);
      expect('12,000.50'.asCentsOrNull, 1200050);
    });

    test('returns null for junk and for empty input', () {
      expect('abc'.asCentsOrNull, isNull);
      expect(''.asCentsOrNull, isNull);
    });
  });

  group('QtyFormatting', () {
    test('drops a trailing zero but keeps a real fraction', () {
      expect(2.asQty, '2');
      expect(2.0.asQty, '2');
      expect(0.5.asQty, '0.5');
    });
  });

  group('InvoiceNumberGen', () {
    test('pads the sequence to four digits', () {
      expect(InvoiceNumberGen.build(sequence: 42, deviceId: 'A', prefix: 'INV'), 'INV-A-0042');
    });

    test('does not truncate a sequence past four digits', () {
      expect(InvoiceNumberGen.build(sequence: 12345, deviceId: 'B', prefix: 'INV'), 'INV-B-12345');
    });
  });
}
