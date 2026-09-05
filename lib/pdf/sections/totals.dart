import 'package:pdf/widgets.dart' as pw;

import '../../core/extensions/cents_formatting_ext.dart';
import '../../models/invoice.dart';
import '../pdf_theme.dart';

const Map<int, pw.TableColumnWidth> _columnWidths = <int, pw.TableColumnWidth>{0: pw.FlexColumnWidth(), 1: pw.FixedColumnWidth(PdfTheme.amountColumn)};

const pw.BorderSide _rule = pw.BorderSide(color: PdfTheme.hairline, width: PdfTheme.ruleThin);

const pw.TableBorder _tableBorder = pw.TableBorder(bottom: _rule, horizontalInside: _rule);

pw.Widget buildTotals(Invoice invoice) {
  return pw.Table(
    border: _tableBorder,
    columnWidths: _columnWidths,
    children: <pw.TableRow>[
      _row('TOTAL', invoice.totalCents.asAmount, PdfTheme.bodyBold),
      if (invoice.showsAdvance) _row('ADVANCE', invoice.advanceCents.asAmount, PdfTheme.body),
      if (invoice.showsAdvance) _row('BALANCE', invoice.balanceCents.asAmount, PdfTheme.body),
    ],
  );
}

pw.TableRow _row(String label, String value, pw.TextStyle valueStyle) {
  return pw.TableRow(
    decoration: const pw.BoxDecoration(color: PdfTheme.fill),
    children: <pw.Widget>[
      pw.Container(
        alignment: pw.Alignment.centerLeft,
        height: PdfTheme.rowHeight,
        padding: const pw.EdgeInsets.symmetric(horizontal: PdfTheme.cellPadX),
        child: pw.Text(label, maxLines: 1, style: PdfTheme.label),
      ),
      pw.Container(
        alignment: pw.Alignment.centerRight,
        height: PdfTheme.rowHeight,
        padding: const pw.EdgeInsets.symmetric(horizontal: PdfTheme.cellPadX),
        child: pw.Text(value, maxLines: 1, style: valueStyle, textAlign: pw.TextAlign.right),
      ),
    ],
  );
}
