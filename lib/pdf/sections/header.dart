import 'package:pdf/widgets.dart' as pw;

import '../../models/business_profile.dart';
import '../pdf_theme.dart';

pw.Widget buildHeader(BusinessProfile profile) {
  final String address = profile.addressLine;
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: <pw.Widget>[
      pw.Text(profile.name, style: PdfTheme.businessName),
      if (address.isNotEmpty) pw.SizedBox(height: 2),
      if (address.isNotEmpty) pw.Text(address, style: PdfTheme.meta),
      if (profile.phone.isNotEmpty) pw.Text(profile.phone, style: PdfTheme.meta),
      pw.SizedBox(height: 8),
      pw.Divider(color: PdfTheme.hairline, height: 1, thickness: 0.7),
    ],
  );
}
