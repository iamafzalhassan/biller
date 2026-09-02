import 'invoice_item.dart';

class Invoice {
  final bool isRevised;

  final int advanceCents;
  final int? previousTotalCents;

  final String customerName;
  final String invoiceNumber;
  final String? customerPhone;

  final List<InvoiceItem> items;

  final DateTime createdAt;

  const Invoice({
    required this.isRevised,
    required this.advanceCents,
    this.previousTotalCents,
    required this.customerName,
    required this.invoiceNumber,
    this.customerPhone,
    required this.items,
    required this.createdAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    isRevised: json['isRevised'] as bool? ?? false,
    advanceCents: json['advanceCents'] as int? ?? 0,
    previousTotalCents: json['previousTotalCents'] as int?,
    customerName: json['customerName'] as String? ?? '',
    invoiceNumber: json['invoiceNumber'] as String? ?? '',
    customerPhone: json['customerPhone'] as String?,
    items: (json['items'] as List<dynamic>? ?? <dynamic>[]).map((dynamic e) => InvoiceItem.fromJson(e as Map<String, dynamic>)).toList(),
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  int get totalCents => printableItems.fold(0, (int sum, InvoiceItem i) => sum + i.amountCents);

  int get balanceCents => totalCents - advanceCents;

  bool get showsAdvance => advanceCents > 0;

  bool get isPrintable => customerName.trim().isNotEmpty && printableItems.isNotEmpty;

  List<InvoiceItem> get printableItems => items.where((InvoiceItem i) => i.isPrintable).toList();

  Invoice copyWith({
    bool? isRevised,
    int? advanceCents,
    int? previousTotalCents,
    bool clearPreviousTotal = false,
    String? customerName,
    String? invoiceNumber,
    String? customerPhone,
    List<InvoiceItem>? items,
    DateTime? createdAt,
  }) => Invoice(
    isRevised: isRevised ?? this.isRevised,
    advanceCents: advanceCents ?? this.advanceCents,
    previousTotalCents: clearPreviousTotal ? null : previousTotalCents ?? this.previousTotalCents,
    customerName: customerName ?? this.customerName,
    invoiceNumber: invoiceNumber ?? this.invoiceNumber,
    customerPhone: customerPhone ?? this.customerPhone,
    items: items ?? this.items,
    createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => <String, dynamic>{
    'isRevised': isRevised,
    'advanceCents': advanceCents,
    'previousTotalCents': previousTotalCents,
    'customerName': customerName,
    'invoiceNumber': invoiceNumber,
    'customerPhone': customerPhone,
    'items': items.map((InvoiceItem i) => i.toJson()).toList(),
    'createdAt': createdAt.toIso8601String(),
  };

  @override
  String toString() => 'Invoice($invoiceNumber, $customerName, $totalCents)';
}
