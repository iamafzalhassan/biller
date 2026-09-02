import 'package:pdf/widgets.dart' as pw;

import '../../core/extensions/cents_formatting_ext.dart';
import '../../models/invoice.dart';
import '../pdf_theme.dart';

pw.Widget buildTotals(Invoice invoice) {
  final bool showsAdvance = invoice.showsAdvance;
  return pw.Container(
    alignment: pw.Alignment.centerRight,
    margin: const pw.EdgeInsets.only(top: 12),
    child: pw.SizedBox(
      width: 210,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        children: <pw.Widget>[
          _rule(thick: !showsAdvance),
          _line('TOTAL', invoice.totalCents.asLkr, valueStyle: showsAdvance ? PdfTheme.bodyStrong : PdfTheme.total),
          if (showsAdvance) _line('ADVANCE', invoice.advanceCents.asLkr, valueStyle: PdfTheme.bodyStrong),
          if (showsAdvance) _rule(thick: true),
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
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: <pw.Widget>[
        pw.Text(label, style: PdfTheme.label),
        pw.Text(value, style: valueStyle),
      ],
    ),
  );
}

pw.Widget _rule({bool thick = false}) => pw.Divider(color: PdfTheme.hairline, height: 6, thickness: thick ? 1.1 : 0.5);
