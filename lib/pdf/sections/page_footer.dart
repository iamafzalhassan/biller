import 'package:pdf/widgets.dart' as pw;

import '../pdf_theme.dart';

pw.Widget buildPageFooter(int pageNumber, int pageCount) {
  if (pageCount <= 1) return pw.SizedBox();
  return pw.Container(
    alignment: pw.Alignment.centerRight,
    margin: const pw.EdgeInsets.only(top: PdfTheme.gapSm),
    child: pw.Text('Page $pageNumber of $pageCount', maxLines: 1, style: PdfTheme.footer),
  );
}
