import 'package:pdf/widgets.dart' as pw;

import '../pdf_theme.dart';

pw.Widget buildTerms(List<String> terms) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: PdfTheme.gapLg),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: <pw.Widget>[
        if (terms.isNotEmpty) pw.Text('TERMS AND CONDITIONS', maxLines: 1, style: PdfTheme.label),
        if (terms.isNotEmpty) pw.SizedBox(height: PdfTheme.gapSm),
        for (final String term in terms) _term(term),
        pw.SizedBox(height: PdfTheme.gapXl),
        pw.Align(alignment: pw.Alignment.centerRight, child: _signatureLine()),
      ],
    ),
  );
}

pw.Widget _term(String term) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: PdfTheme.gapXs),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.SizedBox(
          width: PdfTheme.gapMd,
          child: pw.Text('-', style: PdfTheme.terms),
        ),
        pw.Expanded(child: pw.Text(term, style: PdfTheme.terms)),
      ],
    ),
  );
}

pw.Widget _signatureLine() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    mainAxisSize: pw.MainAxisSize.min,
    children: <pw.Widget>[
      pw.Container(
        width: PdfTheme.signatureWidth,
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            top: pw.BorderSide(color: PdfTheme.hairline, width: PdfTheme.ruleStrong),
          ),
        ),
      ),
      pw.SizedBox(height: PdfTheme.gapXs),
      pw.Text('AUTHORISED SIGNATURE', maxLines: 1, style: PdfTheme.label),
    ],
  );
}
