import 'package:pdf/widgets.dart' as pw;

import '../../core/extensions/cents_formatting_ext.dart';
import '../../models/invoice.dart';
import '../pdf_theme.dart';

pw.Widget buildTotals(Invoice invoice) {
  final bool showsAdvance = invoice.showsAdvance;
  return pw.Container(
    alignment: pw.Alignment.centerRight,
    margin: const pw.EdgeInsets.only(top: 10),
    child: pw.Container(
      decoration: const pw.BoxDecoration(color: PdfTheme.fill),
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      width: 220,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          _line('TOTAL', invoice.totalCents.asLkr, valueStyle: showsAdvance ? PdfTheme.bodyStrong : PdfTheme.total),
          if (showsAdvance) _rule(),
          if (showsAdvance) _line('ADVANCE', invoice.advanceCents.asLkr, valueStyle: PdfTheme.bodyStrong),
          if (showsAdvance) _rule(),
          if (showsAdvance) _line('BALANCE', invoice.balanceCents.asLkr, valueStyle: PdfTheme.total),
        ],
      ),
    ),
  );
}

pw.Widget _line(String label, String value, {required pw.TextStyle valueStyle}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: 3),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: <pw.Widget>[
        pw.Text(label, maxLines: 1, style: PdfTheme.label),
        pw.Text(value, maxLines: 1, style: valueStyle),
      ],
    ),
  );
}

pw.Widget _rule() => pw.Divider(color: PdfTheme.hairline, height: 5, thickness: 0.5);
