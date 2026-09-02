class InvoiceItem {
  final int unitPriceCents;

  final num qty;

  final String description;
  final String id;

  const InvoiceItem({required this.unitPriceCents, required this.qty, required this.description, required this.id});

  factory InvoiceItem.fromJson(Map<String, dynamic> json) =>
      InvoiceItem(unitPriceCents: json['unitPriceCents'] as int, qty: json['qty'] as num, description: json['description'] as String, id: json['id'] as String);

  int get amountCents => (qty * unitPriceCents).round();

  bool get isPrintable => description.trim().isNotEmpty && qty > 0;

  bool get isEmpty => description.trim().isEmpty && qty == 0 && unitPriceCents == 0;

  InvoiceItem copyWith({int? unitPriceCents, num? qty, String? description, String? id}) =>
      InvoiceItem(unitPriceCents: unitPriceCents ?? this.unitPriceCents, qty: qty ?? this.qty, description: description ?? this.description, id: id ?? this.id);

  Map<String, dynamic> toJson() => <String, dynamic>{'unitPriceCents': unitPriceCents, 'qty': qty, 'description': description, 'id': id};

  @override
  bool operator ==(Object other) =>
      other is InvoiceItem && other.unitPriceCents == unitPriceCents && other.qty == qty && other.description == description && other.id == id;

  @override
  int get hashCode => Object.hash(unitPriceCents, qty, description, id);

  @override
  String toString() => 'InvoiceItem($id, $description, $qty x $unitPriceCents)';
}
