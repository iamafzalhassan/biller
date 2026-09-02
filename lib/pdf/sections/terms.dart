import 'package:pdf/widgets.dart' as pw;

import '../pdf_theme.dart';

pw.Widget buildTerms(List<String> terms) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: <pw.Widget>[
      pw.SizedBox(height: 18),
      if (terms.isNotEmpty) pw.Text('TERMS AND CONDITIONS', style: PdfTheme.label),
      if (terms.isNotEmpty) pw.SizedBox(height: 4),
      for (final String term in terms) _term(term),
      pw.SizedBox(height: 28),
      pw.Align(alignment: pw.Alignment.centerRight, child: _signatureLine()),
    ],
  );
}

pw.Widget _term(String term) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: 2),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.SizedBox(width: 8, child: pw.Text('-', style: PdfTheme.footer)),
        pw.Expanded(child: pw.Text(term, style: PdfTheme.footer)),
      ],
    ),
  );
}

pw.Widget _signatureLine() {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: <pw.Widget>[
      pw.Container(
        width: 150,
        decoration: const pw.BoxDecoration(
          border: pw.Border(top: pw.BorderSide(color: PdfTheme.hairline, width: 0.7)),
        ),
      ),
      pw.SizedBox(height: 3),
      pw.Text('AUTHORISED SIGNATURE', style: PdfTheme.label),
    ],
  );
}
