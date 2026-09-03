import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

abstract final class PdfTheme {
  static const double bodySize = 9;
  static const double titleSize = 17;
  static const double footerSize = 7.5;
  static const double termsSize = 8.5;
  static const double headingSize = 14;
  static const double labelSize = 7.5;
  static const double metaSize = 8.5;
  static const double totalsSize = 11;

  static const double gapXs = 3;
  static const double gapSm = 6;
  static const double gapMd = 10;
  static const double gapLg = 16;
  static const double gapXl = 24;

  static const double chipPadX = 4;
  static const double chipPadY = 1.5;

  static const double rowHeight = 22;
  static const double headerRowHeight = 20;
  static const double signatureSpace = 22;

  static const double cellPadX = 5;
  static const double cellPadY = 5;

  static const double logoHeight = 34;
  static const double ruleStrong = 0.7;
  static const double ruleThin = 0.5;
  static const double signatureWidth = 130;
  static const double totalsWidth = 168;

  static const double amountColumn = 84;
  static const double indexColumn = 26;
  static const double priceColumn = 62;
  static const double qtyColumn = 34;

  static const PdfColor fill = PdfColor.fromInt(0xFFF2F2F2);
  static const PdfColor hairline = PdfColor.fromInt(0xFFBFBFBF);
  static const PdfColor ink = PdfColor.fromInt(0xFF111111);
  static const PdfColor inkMuted = PdfColor.fromInt(0xFF666666);
  static const PdfColor paper = PdfColor.fromInt(0xFFFFFFFF);

  static pw.Font? _bold;
  static pw.Font? _regular;
  static pw.Font? _semiBold;

  static pw.Font get bold => _bold!;

  static pw.Font get regular => _regular!;

  static pw.Font get semiBold => _semiBold!;

  static pw.TextStyle get body => pw.TextStyle(color: ink, font: regular, fontSize: bodySize);

  static pw.TextStyle get bodyBold => pw.TextStyle(color: ink, font: bold, fontSize: bodySize);

  static pw.TextStyle get bodyStrong => pw.TextStyle(color: ink, font: semiBold, fontSize: bodySize);

  static pw.TextStyle get documentTitle => pw.TextStyle(color: ink, font: bold, fontSize: titleSize, letterSpacing: 2);

  static pw.TextStyle get businessName => pw.TextStyle(color: ink, font: bold, fontSize: headingSize);

  static pw.TextStyle get terms => pw.TextStyle(color: PdfTheme.ink, font: regular, fontSize: termsSize, lineSpacing: 1.2);

  static pw.TextStyle get footer => pw.TextStyle(color: inkMuted, font: regular, fontSize: footerSize);

  static pw.TextStyle get label => pw.TextStyle(color: inkMuted, font: semiBold, fontSize: labelSize, letterSpacing: 0.6);

  static pw.TextStyle get meta => pw.TextStyle(color: ink, font: regular, fontSize: metaSize);

  static pw.TextStyle get metaStrong => pw.TextStyle(color: ink, font: semiBold, fontSize: metaSize);

  static pw.TextStyle get totalsFigure => pw.TextStyle(color: ink, font: regular, fontSize: totalsSize);

  static pw.TextStyle get totalsFigureBold => pw.TextStyle(color: ink, font: bold, fontSize: totalsSize);

  static Future<void> ensureFontsLoaded() async {
    if (_regular != null) return;
    _regular = pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-Regular.ttf'));
    _semiBold = pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-SemiBold.ttf'));
    _bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-Bold.ttf'));
  }
}
