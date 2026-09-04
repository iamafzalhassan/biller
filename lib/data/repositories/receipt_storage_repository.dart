import 'package:flutter/foundation.dart';

import '../../models/invoice.dart';
import '../sources/receipt_file_source.dart';

class ReceiptStorageRepository {
  final ReceiptFileSource _source;

  ReceiptStorageRepository(this._source);

  String fileNameFor(Invoice invoice) => '${invoice.invoiceNumber}.pdf';

  Future<String> save(Invoice invoice, Uint8List bytes) => _source.write(fileNameFor(invoice), bytes);
}
