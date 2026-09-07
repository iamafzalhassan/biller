import 'package:uuid/uuid.dart';

import '../../models/invoice_item.dart';

abstract final class MockItems {
  static const int count = 19;

  static const List<int> _prices = <int>[45000, 125000, 87550, 1250000, 32500, 999900, 65000];

  static const List<num> _quantities = <num>[1, 2, 0.5, 12, 6, 3, 24];

  static const List<String> _descriptions = <String>[
    'LADIES WALLET BLACK',
    'GENTS LEATHER WALLET BROWN LARGE SIZE',
    'LADIES SHOULDER HANDBAG BLACK WITH GOLD CHAIN STRAP AND SIDE POCKET',
    'CLUTCH PURSE RED',
    'SCHOOL BAG BLUE',
    'TRAVEL DUFFEL BAG',
    'COIN POUCH SMALL',
    'LAPTOP SLEEVE GREY PADDED',
    'CARD HOLDER TAN',
    'TOTE BAG CANVAS NATURAL',
  ];

  static const Uuid _uuid = Uuid();

  static List<InvoiceItem> generate() => List<InvoiceItem>.generate(
    count,
    (int index) => InvoiceItem(unitPriceCents: _prices[index % _prices.length], qty: _quantities[index % _quantities.length], description: '${_descriptions[index % _descriptions.length]} ${index + 1}', id: _uuid.v4()),
  );
}
