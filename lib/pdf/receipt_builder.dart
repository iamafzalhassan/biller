import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/business_profile.dart';
import '../models/invoice.dart';
import 'pdf_theme.dart';
import 'sections/header.dart';
import 'sections/items_table.dart';
import 'sections/meta_row.dart';
import 'sections/page_footer.dart';
import 'sections/terms.dart';
import 'sections/totals.dart';

abstract final class ReceiptBuilder {
  static const double marginPt = 24;

  static Future<Uint8List> build({required BusinessProfile profile, required Invoice invoice}) async =>
      (await buildDocument(profile: profile, invoice: invoice)).save();

  static Future<pw.Document> buildDocument({required BusinessProfile profile, required Invoice invoice}) async {
    await PdfTheme.ensureFontsLoaded();
    final pw.MemoryImage? logo = await _loadLogo(profile);
    final pw.Document document = pw.Document(title: invoice.invoiceNumber);
    document.addPage(
      pw.MultiPage(
        footer: buildPageFooter,
        header: (pw.Context context) =>
            pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: <pw.Widget>[buildHeader(profile, logo), buildMetaRow(invoice)]),
        margin: const pw.EdgeInsets.all(marginPt),
        pageFormat: PdfPageFormat.a5,
        theme: pw.ThemeData.withFont(base: PdfTheme.regular, bold: PdfTheme.bold),
        build: (pw.Context context) => <pw.Widget>[buildItemsTable(invoice.printableItems), buildTotals(invoice), buildTerms(profile.printableTerms)],
      ),
    );
    return document;
  }

  static Future<pw.MemoryImage?> _loadLogo(BusinessProfile profile) async {
    if (!profile.hasLogo) return null;
    final File file = File(profile.logoPath);
    if (!file.existsSync()) return null;
    return pw.MemoryImage(await file.readAsBytes());
  }
}
