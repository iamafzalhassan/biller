import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/business_profile.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import 'pdf_theme.dart';
import 'sections/header.dart';
import 'sections/items_table.dart';
import 'sections/meta_row.dart';
import 'sections/page_footer.dart';
import 'sections/signatures.dart';
import 'sections/terms.dart';
import 'sections/totals.dart';

abstract final class ReceiptBuilder {
  static const double addressLineHeight = 11;
  static const double addressWrapChars = 70;
  static const double bodyHeight = pageHeight - marginPt * 2;
  static const double businessNameHeight = 17;
  static const double dividerBandHeight = PdfTheme.gapMd * 2 + PdfTheme.ruleThin;
  static const double headerRuleBandHeight = PdfTheme.gapMd + 1;
  static const double logoBlockHeight = PdfTheme.logoHeight + PdfTheme.gapSm;
  static const double marginPt = 24;
  static const double metaBlockHeight = 52;
  static const double pageFooterHeight = 15;
  static const double pageHeight = 595.28;
  static const double safetyMargin = PdfTheme.rowHeight;
  static const double signaturesHeight = PdfTheme.signatureSpace + PdfTheme.ruleStrong + PdfTheme.gapXs + 9;
  static const double termsHeadingHeight = 9 + PdfTheme.gapSm;
  static const double termsLineHeight = 11;

  static String _logoStamp = '';

  static pw.MemoryImage? _logoCache;

  static Future<Uint8List> build({required BusinessProfile profile, required Invoice invoice}) async {
    await PdfTheme.ensureFontsLoaded();
    final pw.MemoryImage? logo = await _loadLogo(profile);
    final double usable = bodyHeight - _headerHeight(profile, hasLogo: logo != null) - pageFooterHeight - safetyMargin;
    final List<List<InvoiceItem>> pages = _paginate(
      items: invoice.printableItems,
      pageRows: _rowsPerPage(usable),
      lastPageRows: _rowsOnLastPage(usable, invoice: invoice, terms: profile.printableTerms),
    );
    final pw.Document document = pw.Document(title: invoice.invoiceNumber);
    int startIndex = 1;
    for (int page = 0; page < pages.length; page++) {
      final int firstNumber = startIndex;
      startIndex += pages[page].length;
      document.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(marginPt),
          pageFormat: PdfPageFormat.a5,
          theme: pw.ThemeData.withFont(base: PdfTheme.regular, bold: PdfTheme.bold),
          build: (pw.Context context) => _page(
            profile: profile,
            invoice: invoice,
            logo: logo,
            items: pages[page],
            firstNumber: firstNumber,
            isLastPage: page == pages.length - 1,
            pageNumber: page + 1,
            pageCount: pages.length,
          ),
        ),
      );
    }
    return document.save();
  }

  static Future<pw.MemoryImage?> _loadLogo(BusinessProfile profile) async {
    if (!profile.hasLogo) return null;
    final File file = File(profile.logoPath);
    if (!file.existsSync()) return null;
    final String stamp = '${profile.logoPath}|${file.lastModifiedSync().millisecondsSinceEpoch}';
    if (stamp == _logoStamp) return _logoCache;
    _logoCache = pw.MemoryImage(await file.readAsBytes());
    _logoStamp = stamp;
    return _logoCache;
  }

  static double _headerHeight(BusinessProfile profile, {required bool hasLogo}) {
    final String address = profile.addressLine;
    final int addressLines = address.isEmpty ? 0 : (address.length > addressWrapChars ? 2 : 1);
    return (hasLogo ? logoBlockHeight : 0) +
        businessNameHeight +
        addressLines * addressLineHeight +
        (profile.phoneLine.isEmpty ? 0 : addressLineHeight) +
        headerRuleBandHeight +
        metaBlockHeight;
  }

  static int _rowsPerPage(double usable) => math.max(1, (usable - PdfTheme.headerRowHeight) ~/ PdfTheme.rowHeight);

  static int _rowsOnLastPage(double usable, {required Invoice invoice, required List<String> terms}) {
    final double totals = (invoice.showsAdvance ? 3 : 1) * PdfTheme.rowHeight;
    final double closing = PdfTheme.headerRowHeight + totals + signaturesHeight + dividerBandHeight + _termsHeight(terms);
    return math.max(1, (usable - closing) ~/ PdfTheme.rowHeight);
  }

  static double _termsHeight(List<String> terms) {
    if (terms.isEmpty) return 0;
    double height = termsHeadingHeight;
    for (final String term in terms) {
      height += termLineCount(term) * termsLineHeight + PdfTheme.gapXs;
    }
    return height;
  }

  static List<List<InvoiceItem>> _paginate({required List<InvoiceItem> items, required int pageRows, required int lastPageRows}) {
    if (items.length <= lastPageRows) return <List<InvoiceItem>>[items];
    final List<List<InvoiceItem>> pages = <List<InvoiceItem>>[];
    int index = 0;
    while (items.length - index > lastPageRows) {
      final int take = math.max(1, math.min(pageRows, items.length - index - 1));
      pages.add(items.sublist(index, index + take));
      index += take;
    }
    pages.add(items.sublist(index));
    return pages;
  }

  static pw.Widget _page({
    required bool isLastPage,
    required int firstNumber,
    required int pageCount,
    required int pageNumber,
    required List<InvoiceItem> items,
    required BusinessProfile profile,
    required Invoice invoice,
    required pw.MemoryImage? logo,
  }) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: <pw.Widget>[
        buildHeader(profile, logo),
        buildMetaRow(invoice),
        buildItemsTable(items, firstNumber),
        if (isLastPage) buildTotals(invoice),
        pw.Spacer(),
        if (isLastPage) buildSignatures(),
        if (isLastPage) pw.SizedBox(height: PdfTheme.gapMd),
        if (isLastPage) pw.Divider(color: PdfTheme.hairline, height: PdfTheme.ruleThin, thickness: PdfTheme.ruleThin),
        if (isLastPage) pw.SizedBox(height: PdfTheme.gapMd),
        if (isLastPage) buildTerms(profile.printableTerms),
        buildPageFooter(pageNumber, pageCount),
      ],
    );
  }
}
