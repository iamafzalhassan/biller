import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/invoice.dart';
import '../pdf_theme.dart';

final DateFormat _dateFormat = DateFormat('dd MMM yyyy  h:mm a');

pw.Widget buildMetaRow(Invoice invoice) {
  return pw.Column(
    children: <pw.Widget>[
      pw.SizedBox(height: 8),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: <pw.Widget>[
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: <pw.Widget>[
              pw.Text('BILL TO', style: PdfTheme.label),
              pw.SizedBox(height: 2),
              pw.Text(invoice.customerName, style: PdfTheme.metaStrong),
              if (invoice.customerPhone != null && invoice.customerPhone!.isNotEmpty) pw.Text(invoice.customerPhone!, style: PdfTheme.meta),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: <pw.Widget>[
              pw.Row(
                children: <pw.Widget>[
                  if (invoice.isRevised) _revisedTag(),
                  pw.Text(invoice.invoiceNumber, style: PdfTheme.metaStrong),
                ],
              ),
              pw.SizedBox(height: 2),
              pw.Text(_dateFormat.format(invoice.createdAt), style: PdfTheme.meta),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 10),
    ],
  );
}

pw.Widget _revisedTag() {
  return pw.Container(
    margin: const pw.EdgeInsets.only(right: 5),
    padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfTheme.ink, width: 0.7),
      borderRadius: pw.BorderRadius.circular(2),
    ),
    child: pw.Text('REVISED', style: PdfTheme.label),
  );
}
