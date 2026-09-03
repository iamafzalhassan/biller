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
    children: <pw.TableRow>[_headerRow(), for (int i = 0; i < items.length; i++) _itemRow(startIndex + i, items[i])],
  );
}

pw.TableRow _headerRow() {
  return pw.TableRow(
    decoration: const pw.BoxDecoration(color: PdfTheme.fill),
    children: <pw.Widget>[
      _cell('NO', PdfTheme.label, pw.TextAlign.center, PdfTheme.headerRowHeight),
      _cell('DESCRIPTION', PdfTheme.label, pw.TextAlign.left, PdfTheme.headerRowHeight),
      _cell('QTY', PdfTheme.label, pw.TextAlign.right, PdfTheme.headerRowHeight),
      _cell('PRICE', PdfTheme.label, pw.TextAlign.right, PdfTheme.headerRowHeight),
      _cell('AMOUNT (LKR)', PdfTheme.label, pw.TextAlign.right, PdfTheme.headerRowHeight),
    ],
  );
}

pw.TableRow _itemRow(int number, InvoiceItem item) {
  return pw.TableRow(
    children: <pw.Widget>[
      _cell('$number', PdfTheme.body, pw.TextAlign.center, PdfTheme.rowHeight),
      _cell(item.description, PdfTheme.body, pw.TextAlign.left, PdfTheme.rowHeight),
      _cell(item.qty.asQty, PdfTheme.body, pw.TextAlign.right, PdfTheme.rowHeight),
      _cell(item.unitPriceCents.asAmount, PdfTheme.body, pw.TextAlign.right, PdfTheme.rowHeight),
      _cell(item.amountCents.asAmount, PdfTheme.bodyStrong, pw.TextAlign.right, PdfTheme.rowHeight),
    ],
  );
}

pw.Widget _cell(String text, pw.TextStyle style, pw.TextAlign align, double height) {
  return pw.Container(
    alignment: align == pw.TextAlign.center
        ? pw.Alignment.center
        : align == pw.TextAlign.right
        ? pw.Alignment.centerRight
        : pw.Alignment.centerLeft,
    height: height,
    padding: const pw.EdgeInsets.symmetric(horizontal: PdfTheme.cellPadX),
    child: pw.Text(text, maxLines: 1, overflow: pw.TextOverflow.clip, style: style, textAlign: align),
  );
}
