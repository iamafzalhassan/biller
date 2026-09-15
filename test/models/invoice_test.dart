import 'package:biller/models/invoice.dart';
import 'package:biller/models/invoice_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const InvoiceItem wallets = InvoiceItem(unitPriceCents: 150000, qty: 2, description: 'LEATHER WALLET', id: 'item-1');
  const InvoiceItem handbag = InvoiceItem(unitPriceCents: 1999, qty: 1.5, description: 'HANDBAG STRAP', id: 'item-2');
  const InvoiceItem blank = InvoiceItem(unitPriceCents: 50000, qty: 3, description: '   ', id: 'item-3');

  Invoice invoice({int advanceCents = 0}) => Invoice(advanceCents: advanceCents, customerName: 'NIMAL STORES', invoiceNumber: 'INV-A-0001', items: const <InvoiceItem>[wallets, handbag, blank], createdAt: DateTime(2026, 9, 15, 10, 30));

  group('Invoice', () {
    test('totals printable items in integer cents and ignores blank lines', () {
      expect(wallets.amountCents, 300000);
      expect(handbag.amountCents, 2999);
      expect(invoice().printableItems, <InvoiceItem>[wallets, handbag]);
      expect(invoice().totalCents, 302999);
    });

    test('subtracts the advance from the total to give the balance', () {
      final Invoice withAdvance = invoice(advanceCents: 100000);

      expect(withAdvance.showsAdvance, isTrue);
      expect(withAdvance.balanceCents, 202999);
      expect(invoice().showsAdvance, isFalse);
      expect(invoice().balanceCents, 302999);
    });

    test('survives a JSON round trip unchanged', () {
      final Invoice original = invoice(advanceCents: 100000).copyWith(customerPhone: '0771234567');

      expect(Invoice.fromJson(original.toJson()), original);
    });
  });
}
