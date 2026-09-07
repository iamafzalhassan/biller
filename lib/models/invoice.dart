import 'invoice_item.dart';

class Invoice {
  final int advanceCents;

  final String customerName;
  final String invoiceNumber;
  final String? customerPhone;

  final List<InvoiceItem> items;

  final DateTime createdAt;

  const Invoice({required this.advanceCents, required this.customerName, required this.invoiceNumber, this.customerPhone, required this.items, required this.createdAt});

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    advanceCents: json['advanceCents'] as int? ?? 0,
    customerName: json['customerName'] as String? ?? '',
    invoiceNumber: json['invoiceNumber'] as String? ?? '',
    customerPhone: json['customerPhone'] as String?,
    items: (json['items'] as List<dynamic>? ?? <dynamic>[]).map((dynamic e) => InvoiceItem.fromJson(e as Map<String, dynamic>)).toList(),
    createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  int get balanceCents => totalCents - advanceCents;

  bool get isPrintable => items.any((InvoiceItem i) => i.isPrintable);

  List<InvoiceItem> get printableItems => items.where((InvoiceItem i) => i.isPrintable).toList();

  bool get showsAdvance => advanceCents > 0;

  int get totalCents => items.where((InvoiceItem i) => i.isPrintable).fold(0, (int sum, InvoiceItem i) => sum + i.amountCents);

  Invoice copyWith({int? advanceCents, String? customerName, String? invoiceNumber, String? customerPhone, List<InvoiceItem>? items, DateTime? createdAt}) => Invoice(
    advanceCents: advanceCents ?? this.advanceCents,
    customerName: customerName ?? this.customerName,
    invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    customerPhone: customerPhone ?? this.customerPhone,
    items: items ?? this.items,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'advanceCents': advanceCents,
    'customerName': customerName,
    'invoiceNumber': invoiceNumber,
    'customerPhone': customerPhone,
    'items': items.map((InvoiceItem i) => i.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  bool _sameItems(List<InvoiceItem> other) {
    if (other.length != items.length) return false;
    for (int index = 0; index < items.length; index++) {
      if (other[index] != items[index]) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) =>
      other is Invoice && other.advanceCents == advanceCents && other.customerName == customerName && other.invoiceNumber == invoiceNumber && other.customerPhone == customerPhone && other.createdAt == createdAt && _sameItems(other.items);

  @override
  int get hashCode => Object.hash(advanceCents, customerName, invoiceNumber, customerPhone, createdAt, Object.hashAll(items));

  @override
  String toString() => 'Invoice($invoiceNumber, $customerName, $totalCents)';
}
