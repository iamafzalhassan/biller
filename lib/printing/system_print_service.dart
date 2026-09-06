import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

abstract final class SystemPrintService {
  static Future<bool> layout(Uint8List bytes, {required String name}) => Printing.layoutPdf(format: PdfPageFormat.a5, name: name, onLayout: (PdfPageFormat format) => bytes);
}
