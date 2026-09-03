import 'package:pdf/widgets.dart' as pw;

import '../../core/extensions/cents_formatting_ext.dart';
import '../../models/invoice_item.dart';
import '../pdf_theme.dart';

const Map<int, pw.TableColumnWidth> _columnWidths = <int, pw.TableColumnWidth>{
  0: pw.FixedColumnWidth(26),
  1: pw.FlexColumnWidth(),
  2: pw.FixedColumnWidth(34),
  3: pw.FixedColumnWidth(58),
  4: pw.FixedColumnWidth(66),
};

pw.Widget buildItemsTable(List<InvoiceItem> items) {
  return pw.Table(
    border: const pw.TableBorder(
      horizontalInside: pw.BorderSide(color: PdfTheme.hairline, width: 0.5),
      top: pw.BorderSide(color: PdfTheme.hairline, width: 0.5),
    ),
    columnWidths: _columnWidths,
    children: <pw.TableRow>[
      pw.TableRow(
        repeat: true,
        decoration: const pw.BoxDecoration(color: PdfTheme.fill),
        children: <pw.Widget>[
          _headerCell('NO', align: pw.TextAlign.center),
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
    verticalAlignment: pw.TableCellVerticalAlignment.top,
    children: <pw.Widget>[
      _cell(pw.Text('$index', maxLines: 1, style: PdfTheme.body, textAlign: pw.TextAlign.center)),
      _cell(pw.Text(item.description, maxLines: 2, overflow: pw.TextOverflow.clip, style: PdfTheme.body)),
      _cell(pw.Text(item.qty.asQty, maxLines: 1, style: PdfTheme.body, textAlign: pw.TextAlign.right)),
      _cell(pw.Text(item.unitPriceCents.asAmount, maxLines: 1, style: PdfTheme.body, textAlign: pw.TextAlign.right)),
      _cell(pw.Text(item.amountCents.asAmount, maxLines: 1, style: PdfTheme.bodyStrong, textAlign: pw.TextAlign.right)),
    ],
  );
}

pw.Widget _headerCell(String text, {pw.TextAlign align = pw.TextAlign.left}) => _cell(pw.Text(text, maxLines: 1, style: PdfTheme.label, textAlign: align));

pw.Widget _cell(pw.Widget child) => pw.Padding(padding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 5), child: child);
