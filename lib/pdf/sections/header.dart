import 'package:pdf/widgets.dart' as pw;

import '../../models/business_profile.dart';
import '../pdf_theme.dart';

pw.Widget buildHeader(BusinessProfile profile, pw.MemoryImage? logo) {
  final String address = profile.addressLine;
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: <pw.Widget>[
      if (logo != null)
        pw.Container(
          height: 38,
          margin: const pw.EdgeInsets.only(bottom: 6),
          child: pw.Image(logo, alignment: pw.Alignment.centerLeft),
        ),
      pw.Text(profile.name, maxLines: 1, style: PdfTheme.businessName),
      if (address.isNotEmpty) pw.SizedBox(height: 3),
      if (address.isNotEmpty) pw.Text(address, maxLines: 2, style: PdfTheme.meta),
      if (profile.phone.isNotEmpty) pw.Text(profile.phone, maxLines: 1, style: PdfTheme.meta),
      pw.SizedBox(height: 8),
      pw.Divider(color: PdfTheme.hairline, height: 1, thickness: 0.7),
    ],
  );
}
