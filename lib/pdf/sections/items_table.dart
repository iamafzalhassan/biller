import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/extensions/cents_formatting_ext.dart';
import '../../models/invoice_item.dart';
import '../pdf_theme.dart';

const Map<int, pw.TableColumnWidth> _columnWidths = <int, pw.TableColumnWidth>{
  0: pw.FixedColumnWidth(18),
  1: pw.FlexColumnWidth(),
  2: pw.FixedColumnWidth(34),
  3: pw.FixedColumnWidth(58),
  4: pw.FixedColumnWidth(66),
};

pw.Widget buildItemsTable(List<InvoiceItem> items) {
  return pw.Table(
    border: pw.TableBorder(
      bottom: const pw.BorderSide(color: PdfTheme.hairline, width: 0.5),
      horizontalInside: const pw.BorderSide(color: PdfTheme.hairline, width: 0.5),
      top: const pw.BorderSide(color: PdfTheme.hairline, width: 0.5),
    ),
    columnWidths: _columnWidths,
    children: <pw.TableRow>[
      pw.TableRow(
        repeat: true,
        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFF2F2F2)),
        children: <pw.Widget>[
          _headerCell('No'),
          _headerCell('DESCRIPTION'),
          _headerCell('QTY', align: pw.TextAlign.right),
          _headerCell('PRICE', align: pw.TextAlign.right),
          _headerCell('AMOUNT', align: pw.TextAlign.right),
        ],
      ),
      for (int i = 0; i < items.length; i++) _itemRow(i + 1, items[i]),
    ],
  );
}

pw.TableRow _itemRow(int index, InvoiceItem item) {
  return pw.TableRow(
    children: <pw.Widget>[
      _cell(pw.Text('$index', style: PdfTheme.body)),
      _cell(pw.Text(item.description, maxLines: 2, overflow: pw.TextOverflow.clip, style: PdfTheme.body)),
      _cell(pw.Text(item.qty.asQty, style: PdfTheme.body, textAlign: pw.TextAlign.right)),
      _cell(pw.Text(item.unitPriceCents.asAmount, style: PdfTheme.body, textAlign: pw.TextAlign.right)),
      _cell(pw.Text(item.amountCents.asAmount, style: PdfTheme.bodyStrong, textAlign: pw.TextAlign.right)),
    ],
  );
}

pw.Widget _headerCell(String text, {pw.TextAlign align = pw.TextAlign.left}) => _cell(pw.Text(text, style: PdfTheme.label, textAlign: align));

pw.Widget _cell(pw.Widget child) => pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4), child: child);
