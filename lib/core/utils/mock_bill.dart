import '../../models/invoice.dart';
import '../../models/invoice_item.dart';

abstract final class MockBill {
  static const String customerName = 'NIMAL TRADERS (PVT) LTD';
  static const String customerPhone = '0771234567';

  static const int advanceCents = 2500000;

  static const List<(String, num, int)> lines = <(String, num, int)>[
    ('LADIES LEATHER WALLET - BLACK', 12, 185000),
    ('LADIES LEATHER WALLET - TAN', 12, 185000),
    ('GENTS BIFOLD WALLET - BROWN', 24, 145000),
    ('GENTS BIFOLD WALLET - BLACK', 24, 145000),
    ('GENTS TRIFOLD WALLET - NAVY', 18, 162500),
    ('CARD HOLDER SLIM - ASSORTED', 36, 62500),
    ('COIN PURSE ZIP - ASSORTED', 48, 47500),
    ('TRAVEL PASSPORT HOLDER', 12, 210000),
    ('SHOULDER BAG MEDIUM - BEIGE', 6, 485000),
    ('SHOULDER BAG MEDIUM - BLACK', 6, 485000),
    ('SHOULDER BAG LARGE - MAROON', 6, 565000),
    ('TOTE BAG CANVAS - NATURAL', 12, 325000),
    ('TOTE BAG CANVAS - OLIVE', 12, 325000),
    ('SLING BAG COMPACT - BLACK', 12, 275000),
    ('SLING BAG COMPACT - GREY', 12, 275000),
    ('CLUTCH EVENING - GOLD TRIM', 8, 395000),
    ('CLUTCH EVENING - SILVER TRIM', 8, 395000),
    ('BACKPACK LEATHER - TAN', 4, 875000),
    ('BACKPACK LEATHER - BLACK', 4, 875000),
    ('LAPTOP SLEEVE 15 INCH', 10, 245000),
    ('BELT GENTS FORMAL - BLACK', 24, 118000),
    ('BELT GENTS FORMAL - BROWN', 24, 118000),
    ('BELT LADIES SLIM - ASSORTED', 18, 95000),
    ('KEY POUCH LEATHER', 30, 55000),
    ('MOBILE POUCH UNIVERSAL', 36, 68000),
    ('GIFT BOX SET - WALLET AND BELT', 6, 445000),
    ('DUFFEL BAG WEEKEND - CHARCOAL', 4, 725000),
    ('SATCHEL BAG CLASSIC - COGNAC', 5, 615000),
    ('WALLET GIFT SLEEVE - KRAFT', 40, 22500),
    ('HALF DOZEN SAMPLE PACK', 0.5, 380000),
  ];

  static Invoice build(String invoiceNumber) => Invoice(
    isRevised: false,
    advanceCents: advanceCents,
    customerName: customerName,
    invoiceNumber: invoiceNumber,
    customerPhone: customerPhone,
    items: items(),
    createdAt: DateTime.now(),
  );

  static List<InvoiceItem> items() => <InvoiceItem>[
    for (int index = 0; index < lines.length; index++)
      InvoiceItem(unitPriceCents: lines[index].$3, qty: lines[index].$2, description: lines[index].$1, id: 'mock-$index'),
  ];
}
