import 'package:pdf/widgets.dart' as pw;

import '../../core/extensions/cents_formatting_ext.dart';
import '../../models/invoice.dart';
import '../pdf_theme.dart';

pw.Widget buildTotals(Invoice invoice) {
  final bool showsAdvance = invoice.showsAdvance;
  return pw.Container(
    alignment: pw.Alignment.centerRight,
    margin: const pw.EdgeInsets.only(top: PdfTheme.gapMd),
    child: pw.Container(
      decoration: const pw.BoxDecoration(color: PdfTheme.fill),
      padding: const pw.EdgeInsets.symmetric(horizontal: PdfTheme.cellPadX, vertical: PdfTheme.gapSm),
      width: PdfTheme.totalsWidth,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.stretch,
        mainAxisSize: pw.MainAxisSize.min,
        children: <pw.Widget>[
          _line('TOTAL', invoice.totalCents.asLkr, valueStyle: PdfTheme.totalsFigureBold),
          if (showsAdvance) _rule(),
          if (showsAdvance) _line('ADVANCE', invoice.advanceCents.asLkr, valueStyle: PdfTheme.totalsFigure),
          if (showsAdvance) _rule(),
          if (showsAdvance) _line('BALANCE', invoice.balanceCents.asLkr, valueStyle: PdfTheme.totalsFigure),
        ],
      ),
    ),
  );
}

pw.Widget _line(String label, String value, {required pw.TextStyle valueStyle}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.symmetric(vertical: PdfTheme.gapXs),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: <pw.Widget>[
        pw.Text(label, maxLines: 1, style: PdfTheme.label),
        pw.SizedBox(width: PdfTheme.gapSm),
        pw.Expanded(
          child: pw.Text(value, maxLines: 1, style: valueStyle, textAlign: pw.TextAlign.right),
        ),
      ],
    ),
  );
}

pw.Widget _rule() => pw.Divider(color: PdfTheme.hairline, height: PdfTheme.gapSm, thickness: PdfTheme.ruleThin);
