import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

abstract final class PdfTheme {
  static const double bodySize = 9;
  static const double footerSize = 7.5;
  static const double headingSize = 14;
  static const double labelSize = 7.5;
  static const double metaSize = 8.5;
  static const double totalSize = 12;

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

  static pw.TextStyle get bodyStrong => pw.TextStyle(color: ink, font: semiBold, fontSize: bodySize);

  static pw.TextStyle get businessName => pw.TextStyle(color: ink, font: bold, fontSize: headingSize);

  static pw.TextStyle get footer => pw.TextStyle(color: inkMuted, font: regular, fontSize: footerSize);

  static pw.TextStyle get label => pw.TextStyle(color: inkMuted, font: semiBold, fontSize: labelSize, letterSpacing: 0.6);

  static pw.TextStyle get meta => pw.TextStyle(color: ink, font: regular, fontSize: metaSize);

  static pw.TextStyle get metaStrong => pw.TextStyle(color: ink, font: semiBold, fontSize: metaSize);

  static pw.TextStyle get total => pw.TextStyle(color: ink, font: bold, fontSize: totalSize);

  static Future<void> ensureFontsLoaded() async {
    if (_regular != null) return;
    _regular = pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-Regular.ttf'));
    _semiBold = pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-SemiBold.ttf'));
    _bold = pw.Font.ttf(await rootBundle.load('assets/fonts/Inter-Bold.ttf'));
  }
}
