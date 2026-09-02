import 'package:biller/models/invoice.dart';
import 'package:biller/models/invoice_item.dart';
import 'package:flutter_test/flutter_test.dart';

InvoiceItem item({required int priceCents, required num qty, String description = 'WALLET'}) =>
    InvoiceItem(unitPriceCents: priceCents, qty: qty, description: description, id: 'id-$qty-$priceCents');

Invoice invoice(List<InvoiceItem> items, {int advanceCents = 0}) => Invoice(
  isRevised: false,
  advanceCents: advanceCents,
  customerName: 'NIMAL TRADERS',
  invoiceNumber: 'INV-A-0042',
  items: items,
  createdAt: DateTime(2026, 9, 2, 14, 14),
);

void main() {
  group('InvoiceItem', () {
    test('amount is qty times unit price, in cents', () {
      expect(item(priceCents: 150000, qty: 3).amountCents, 450000);
    });

    test('a half-dozen qty rounds to whole cents', () {
      expect(item(priceCents: 125, qty: 0.5).amountCents, 63);
    });

    test('a blank row is not printable', () {
      expect(item(priceCents: 0, qty: 0, description: '').isPrintable, isFalse);
    });

    test('a row with a description but no qty is not printable', () {
      expect(item(priceCents: 150000, qty: 0).isPrintable, isFalse);
    });
  });

  group('Invoice totals', () {
    test('total sums only the printable rows, so the trailing blank row is ignored', () {
      final Invoice bill = invoice(<InvoiceItem>[
        item(priceCents: 150000, qty: 3),
        item(priceCents: 250000, qty: 2, description: 'HANDBAG'),
        item(priceCents: 0, qty: 0, description: ''),
      ]);
      expect(bill.totalCents, 950000);
    });

    test('balance is total minus advance', () {
      final Invoice bill = invoice(<InvoiceItem>[item(priceCents: 150000, qty: 8)], advanceCents: 250000);
      expect(bill.totalCents, 1200000);
      expect(bill.balanceCents, 950000);
    });

    test('advance is hidden when it is zero', () {
      expect(invoice(<InvoiceItem>[item(priceCents: 150000, qty: 1)]).showsAdvance, isFalse);
    });

    test('advance is shown when above zero', () {
      expect(invoice(<InvoiceItem>[item(priceCents: 150000, qty: 1)], advanceCents: 1).showsAdvance, isTrue);
    });

    test('a bill with no customer name cannot be printed', () {
      final Invoice bill = invoice(<InvoiceItem>[item(priceCents: 150000, qty: 1)]).copyWith(customerName: '  ');
      expect(bill.isPrintable, isFalse);
    });

    test('a bill with a name and one valid row can be printed', () {
      expect(invoice(<InvoiceItem>[item(priceCents: 150000, qty: 1)]).isPrintable, isTrue);
    });
  });

  group('Invoice serialisation', () {
    test('a round trip preserves every field', () {
      final Invoice original = invoice(<InvoiceItem>[
        item(priceCents: 150000, qty: 3),
      ], advanceCents: 50000).copyWith(customerPhone: '0771234567', isRevised: true, previousTotalCents: 500000);
      final Invoice restored = Invoice.fromJson(original.toJson());
      expect(restored.advanceCents, original.advanceCents);
      expect(restored.createdAt, original.createdAt);
      expect(restored.customerPhone, original.customerPhone);
      expect(restored.isRevised, isTrue);
      expect(restored.items.first, original.items.first);
      expect(restored.previousTotalCents, 500000);
      expect(restored.totalCents, original.totalCents);
    });
  });
}
