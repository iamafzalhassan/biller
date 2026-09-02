import 'package:biller/models/business_profile.dart';
import 'package:biller/models/invoice.dart';
import 'package:biller/models/invoice_item.dart';
import 'package:biller/pdf/receipt_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;

const BusinessProfile profile = BusinessProfile(
  addressBuilding: 'SILVA BUILDING',
  addressCity: 'COLOMBO 11',
  addressNo: '142',
  addressStreet: 'SEA STREET',
  deviceId: 'A',
  invoicePrefix: 'INV',
  name: 'SILVA WHOLESALE',
  ownerEmail: 'owner@example.com',
  phone: '0112345678',
  terms: BusinessProfile.defaultTerms,
);

Invoice invoiceOf(int itemCount, {bool isRevised = false, int advanceCents = 0}) => Invoice(
  isRevised: isRevised,
  advanceCents: advanceCents,
  customerName: 'NIMAL TRADERS',
  invoiceNumber: 'INV-A-0042',
  items: <InvoiceItem>[
    for (int i = 0; i < itemCount; i++) InvoiceItem(unitPriceCents: 150000 + i, qty: 2, description: 'LEATHER WALLET MODEL $i', id: 'id-$i'),
  ],
  createdAt: DateTime(2026, 9, 2, 14, 14),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ReceiptBuilder', () {
    test('a short bill fits on a single A5 page', () async {
      final pw.Document document = await ReceiptBuilder.buildDocument(profile: profile, invoice: invoiceOf(3));
      await document.save();
      expect(document.document.pdfPageList.pages.length, 1);
    });

    test('a 40-item bill paginates rather than overflowing', () async {
      final pw.Document document = await ReceiptBuilder.buildDocument(profile: profile, invoice: invoiceOf(40));
      await document.save();
      expect(document.document.pdfPageList.pages.length, greaterThan(1));
    });

    test('produces non-empty PDF bytes with an advance and a revision marker', () async {
      final Uint8List bytes = await ReceiptBuilder.build(profile: profile, invoice: invoiceOf(5, advanceCents: 250000, isRevised: true));
      expect(bytes.length, greaterThan(1000));
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });
  });
}
