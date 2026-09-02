import 'package:sqflite/sqflite.dart';

class SqfliteSource {
  static const int maxRows = 20;
  static const int schemaVersion = 1;

  static const String columnCreatedAt = 'created_at';
  static const String columnCustomerName = 'customer_name';
  static const String columnInvoiceNumber = 'invoice_number';
  static const String columnPayload = 'payload';
  static const String columnTotalCents = 'total_cents';
  static const String databaseName = 'biller.db';
  static const String tableRecent = 'recent_invoices';

  Database? _db;

  Future<void> init() async {
    _db ??= await openDatabase(
      databaseName,
      version: schemaVersion,
      onCreate: (Database db, int version) => db.execute(
        'CREATE TABLE $tableRecent ('
        '$columnInvoiceNumber TEXT PRIMARY KEY, '
        '$columnCustomerName TEXT NOT NULL, '
        '$columnTotalCents INTEGER NOT NULL, '
        '$columnCreatedAt INTEGER NOT NULL, '
        '$columnPayload TEXT NOT NULL)',
      ),
    );
  }

  Future<List<Map<String, Object?>>> readAll() async {
    final Database db = await _open();
    return db.query(tableRecent, orderBy: '$columnCreatedAt DESC', limit: maxRows);
  }

  Future<void> upsert(Map<String, Object?> row) async {
    final Database db = await _open();
    await db.insert(tableRecent, row, conflictAlgorithm: ConflictAlgorithm.replace);
    await _trim(db);
  }

  Future<Database> _open() async {
    await init();
    return _db!;
  }

  Future<void> _trim(Database db) async {
    await db.execute(
      'DELETE FROM $tableRecent WHERE $columnInvoiceNumber NOT IN ('
      'SELECT $columnInvoiceNumber FROM $tableRecent '
      'ORDER BY $columnCreatedAt DESC LIMIT $maxRows)',
    );
  }
}
