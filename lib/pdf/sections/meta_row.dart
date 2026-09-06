import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../models/invoice.dart';
import '../pdf_theme.dart';

final DateFormat _dateFormat = DateFormat('dd MMM yyyy  h:mm a');

pw.Widget buildMetaRow(Invoice invoice) {
  final String? phone = invoice.customerPhone;
  return pw.Column(
    children: <pw.Widget>[
      pw.SizedBox(height: PdfTheme.gapMd),
      pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: <pw.Widget>[
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: <pw.Widget>[
                pw.Text('BILL TO', maxLines: 1, style: PdfTheme.label),
                pw.SizedBox(height: PdfTheme.gapXs),
                pw.Text(invoice.customerName, maxLines: 1, style: PdfTheme.metaStrong),
                if (phone != null && phone.isNotEmpty) pw.Text(phone, maxLines: 1, style: PdfTheme.meta),
              ],
            ),
          ),
          pw.SizedBox(width: PdfTheme.gapMd),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: <pw.Widget>[
              pw.Text(invoice.invoiceNumber, maxLines: 1, style: PdfTheme.metaStrong),
              pw.SizedBox(height: PdfTheme.gapXs),
              pw.Text(_dateFormat.format(invoice.createdAt), maxLines: 1, style: PdfTheme.meta),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: PdfTheme.gapMd),
    ],
  );
}
