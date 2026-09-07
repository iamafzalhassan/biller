import 'package:pdf/widgets.dart' as pw;

import '../pdf_theme.dart';

const double _termsWrapChars = 72;

const int _termsMaxLines = 3;

int termLineCount(String term) {
  final int lines = (term.trim().length / _termsWrapChars).ceil();
  if (lines < 1) return 1;
  return lines > _termsMaxLines ? _termsMaxLines : lines;
}

pw.Widget buildTerms(List<String> terms) {
  if (terms.isEmpty) return pw.SizedBox();
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    mainAxisSize: pw.MainAxisSize.min,
    children: <pw.Widget>[
      pw.Text('TERMS AND CONDITIONS', maxLines: 1, style: PdfTheme.label),
      pw.SizedBox(height: PdfTheme.gapSm),
      for (int index = 0; index < terms.length; index++) _term(index + 1, terms[index]),
    ],
  );
}

pw.Widget _term(int number, String term) {
  return pw.Padding(
    padding: const pw.EdgeInsets.only(bottom: PdfTheme.gapXs),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: <pw.Widget>[
        pw.SizedBox(
          width: PdfTheme.gapLg,
          child: pw.Text('$number.', maxLines: 1, style: PdfTheme.terms),
        ),
        pw.Expanded(
          child: pw.Text(term, maxLines: _termsMaxLines, overflow: pw.TextOverflow.clip, style: PdfTheme.terms),
        ),
      ],
    ),
  );
}
