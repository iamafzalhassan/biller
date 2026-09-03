import 'package:pdf/widgets.dart' as pw;

import '../../core/extensions/cents_formatting_ext.dart';
import '../../models/invoice_item.dart';
import '../pdf_theme.dart';

const Map<int, pw.TableColumnWidth> _columnWidths = <int, pw.TableColumnWidth>{
  0: pw.FixedColumnWidth(PdfTheme.indexColumn),
  1: pw.FlexColumnWidth(),
  2: pw.FixedColumnWidth(PdfTheme.qtyColumn),
  3: pw.FixedColumnWidth(PdfTheme.priceColumn),
  4: pw.FixedColumnWidth(PdfTheme.amountColumn),
};

pw.Widget buildItemsTable(List<InvoiceItem> items, int startIndex) {
  return pw.Table(
    border: const pw.TableBorder(
      horizontalInside: pw.BorderSide(color: PdfTheme.hairline, width: PdfTheme.ruleThin),
      top: pw.BorderSide(color: PdfTheme.hairline, width: PdfTheme.ruleThin),
    ),
    columnWidths: _columnWidths,
    children: <pw.TableRow>[
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfTheme.fill),
        children: <pw.Widget>[
          _headerCell('NO', align: pw.TextAlign.center),
          _headerCell('DESCRIPTION'),
          _headerCell('QTY', align: pw.TextAlign.right),
          _headerCell('PRICE', align: pw.TextAlign.right),
          _headerCell('AMOUNT', align: pw.TextAlign.right),
        ],
      ),
      for (int i = 0; i < items.length; i++) _itemRow(startIndex + i, items[i]),
    ],
  );
}

pw.TableRow _itemRow(int number, InvoiceItem item) {
  return pw.TableRow(
    children: <pw.Widget>[
      _cell(pw.Text('$number', maxLines: 1, style: PdfTheme.body, textAlign: pw.TextAlign.center)),
      _cell(pw.Text(item.description, maxLines: 1, overflow: pw.TextOverflow.clip, style: PdfTheme.body)),
      _cell(pw.Text(item.qty.asQty, maxLines: 1, style: PdfTheme.body, textAlign: pw.TextAlign.right)),
      _cell(pw.Text(item.unitPriceCents.asAmount, maxLines: 1, style: PdfTheme.body, textAlign: pw.TextAlign.right)),
      _cell(pw.Text(item.amountCents.asAmount, maxLines: 1, style: PdfTheme.bodyStrong, textAlign: pw.TextAlign.right)),
    ],
  );
}

pw.Widget _headerCell(String text, {pw.TextAlign align = pw.TextAlign.left}) {
  return pw.Container(
    alignment: align == pw.TextAlign.center
        ? pw.Alignment.center
        : align == pw.TextAlign.right
        ? pw.Alignment.centerRight
        : pw.Alignment.centerLeft,
    height: PdfTheme.headerRowHeight,
    padding: const pw.EdgeInsets.symmetric(horizontal: PdfTheme.cellPadX),
    child: pw.Text(text, maxLines: 1, style: PdfTheme.label, textAlign: align),
  );
}

pw.Widget _cell(pw.Text child) {
  return pw.Container(
    alignment: child.textAlign == pw.TextAlign.center
        ? pw.Alignment.center
        : child.textAlign == pw.TextAlign.right
        ? pw.Alignment.centerRight
        : pw.Alignment.centerLeft,
    height: PdfTheme.rowHeight,
    padding: const pw.EdgeInsets.symmetric(horizontal: PdfTheme.cellPadX),
    child: child,
  );
}
