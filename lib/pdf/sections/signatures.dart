import 'package:pdf/widgets.dart' as pw;

import '../pdf_theme.dart';

pw.Widget buildSignatures() {
  return pw.Row(
    crossAxisAlignment: pw.CrossAxisAlignment.end,
    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
    children: <pw.Widget>[_signature('CUSTOMER SIGNATURE'), _signature('AUTHORISED SIGNATURE')],
  );
}

pw.Widget _signature(String label) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    mainAxisSize: pw.MainAxisSize.min,
    children: <pw.Widget>[
      pw.SizedBox(height: PdfTheme.signatureSpace),
      pw.Container(
        width: PdfTheme.signatureWidth,
        decoration: const pw.BoxDecoration(
          border: pw.Border(
            top: pw.BorderSide(color: PdfTheme.hairline, width: PdfTheme.ruleStrong),
          ),
        ),
      ),
      pw.SizedBox(height: PdfTheme.gapXs),
      pw.Text(label, maxLines: 1, style: PdfTheme.label),
    ],
  );
}
