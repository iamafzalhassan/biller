import 'dart:convert';

import '../../models/invoice.dart';
import '../sources/sqflite_source.dart';

class RecentInvoicesRepository {
  final SqfliteSource _source;

  RecentInvoicesRepository(this._source);

  Future<void> purge({required int retentionDays}) => _source.purgeOlderThan(DateTime.now().subtract(Duration(days: retentionDays)).millisecondsSinceEpoch);

  Future<List<Invoice>> load({required int retentionDays}) async {
    await purge(retentionDays: retentionDays);
    final List<Map<String, Object?>> rows = await _source.readAll();
    return rows.map((Map<String, Object?> row) => Invoice.fromJson(jsonDecode(row[SqfliteSource.columnPayload]! as String) as Map<String, dynamic>)).toList();
  }

  Future<void> save(Invoice invoice) => _source.upsert(<String, Object?>{
    SqfliteSource.columnInvoiceNumber: invoice.invoiceNumber,
    SqfliteSource.columnCustomerName: invoice.customerName,
    SqfliteSource.columnTotalCents: invoice.totalCents,
    SqfliteSource.columnCreatedAt: invoice.createdAt.millisecondsSinceEpoch,
    SqfliteSource.columnPayload: jsonEncode(invoice.toJson()),
  });
}
