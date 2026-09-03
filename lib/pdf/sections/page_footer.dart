import 'package:pdf/widgets.dart' as pw;

import '../pdf_theme.dart';

pw.Widget buildPageFooter(pw.Context context) {
  if (context.pagesCount <= 1) return pw.SizedBox();
  return pw.Container(
    alignment: pw.Alignment.centerRight,
    margin: const pw.EdgeInsets.only(top: PdfTheme.gapSm),
    child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}', maxLines: 1, style: PdfTheme.footer),
  );
}
