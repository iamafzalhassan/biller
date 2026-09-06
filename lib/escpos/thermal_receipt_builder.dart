import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';

import '../core/extensions/cents_formatting_ext.dart';
import '../models/business_profile.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/thermal_paper.dart';

abstract final class ThermalReceiptBuilder {
  static const int _labelColumns = 7;
  static const int _valueColumns = 5;

  static const String _invoiceHeading = 'INVOICE';
  static const String _signatureLabel = 'CUSTOMER SIGNATURE';
  static const String _signatureRule = '________________________';
  static const String _termsHeading = 'TERMS AND CONDITIONS';

  static const PosStyles _centered = PosStyles(align: PosAlign.center);
  static const PosStyles _centeredBold = PosStyles(align: PosAlign.center, bold: true);
  static const PosStyles _label = PosStyles(align: PosAlign.left, bold: true);
  static const PosStyles _value = PosStyles(align: PosAlign.right);
  static const PosStyles _valueBold = PosStyles(align: PosAlign.right, bold: true);

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy  h:mm a');

  static Future<List<int>> build({required BusinessProfile profile, required Invoice invoice, required ThermalPaper paper}) async {
    final CapabilityProfile capability = await CapabilityProfile.load();
    final Generator generator = Generator(_paperSize(paper), capability);
    final List<int> bytes = <int>[];
    bytes.addAll(generator.reset());
    bytes.addAll(_header(generator, profile, paper));
    bytes.addAll(_meta(generator, invoice));
    bytes.addAll(_items(generator, invoice.printableItems));
    bytes.addAll(_totals(generator, invoice));
    bytes.addAll(_terms(generator, profile.printableTerms));
    bytes.addAll(_footer(generator));
    return bytes;
  }

  static List<int> _header(Generator generator, BusinessProfile profile, ThermalPaper paper) {
    final List<int> bytes = <int>[];
    bytes.addAll(generator.text(profile.name, styles: _businessNameStyle(paper)));
    if (profile.addressLine.isNotEmpty) bytes.addAll(generator.text(profile.addressLine, styles: _centered));
    if (profile.phoneLine.isNotEmpty) bytes.addAll(generator.text(profile.phoneLine, styles: _centered));
    bytes.addAll(generator.hr());
    bytes.addAll(generator.text(_invoiceHeading, styles: _centeredBold));
    return bytes;
  }

  static List<int> _meta(Generator generator, Invoice invoice) {
    final List<int> bytes = <int>[];
    bytes.addAll(generator.hr());
    bytes.addAll(_pair(generator, 'NO', invoice.invoiceNumber));
    bytes.addAll(_pair(generator, 'DATE', _dateFormat.format(invoice.createdAt)));
    bytes.addAll(_pair(generator, 'BILL TO', invoice.customerName));
    final String? phone = invoice.customerPhone;
    if (phone != null && phone.trim().isNotEmpty) bytes.addAll(_pair(generator, 'PHONE', phone.trim()));
    return bytes;
  }

  static List<int> _items(Generator generator, List<InvoiceItem> items) {
    final List<int> bytes = <int>[];
    bytes.addAll(generator.hr());
    for (int index = 0; index < items.length; index++) {
      final InvoiceItem item = items[index];
      bytes.addAll(generator.text('${index + 1}. ${item.description}', styles: _label));
      bytes.addAll(
        generator.row(<PosColumn>[
          PosColumn(text: '   ${item.qty.asQty} x ${item.unitPriceCents.asAmount}', styles: PosStyles.defaults(), width: _labelColumns),
          PosColumn(text: item.amountCents.asAmount, styles: _value, width: _valueColumns),
        ]),
      );
    }
    return bytes;
  }

  static List<int> _totals(Generator generator, Invoice invoice) {
    final List<int> bytes = <int>[];
    bytes.addAll(generator.hr());
    bytes.addAll(_amount(generator, 'TOTAL', invoice.totalCents.asAmount, isBold: true));
    if (invoice.showsAdvance) bytes.addAll(_amount(generator, 'ADVANCE', invoice.advanceCents.asAmount, isBold: false));
    if (invoice.showsAdvance) bytes.addAll(_amount(generator, 'BALANCE', invoice.balanceCents.asAmount, isBold: true));
    bytes.addAll(generator.hr());
    return bytes;
  }

  static List<int> _terms(Generator generator, List<String> terms) {
    if (terms.isEmpty) return <int>[];
    final List<int> bytes = <int>[];
    bytes.addAll(generator.text(_termsHeading, styles: _label));
    for (int index = 0; index < terms.length; index++) {
      bytes.addAll(generator.text('${index + 1}. ${terms[index]}'));
    }
    bytes.addAll(generator.hr());
    return bytes;
  }

  static List<int> _footer(Generator generator) {
    final List<int> bytes = <int>[];
    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.text(_signatureRule, styles: _centered));
    bytes.addAll(generator.text(_signatureLabel, styles: _centered));
    bytes.addAll(generator.feed(2));
    bytes.addAll(generator.cut());
    return bytes;
  }

  static List<int> _pair(Generator generator, String label, String value) => generator.row(<PosColumn>[
    PosColumn(text: label, styles: _label, width: _labelColumns - 2),
    PosColumn(text: value, styles: _value, width: _valueColumns + 2),
  ]);

  static List<int> _amount(Generator generator, String label, String value, {required bool isBold}) => generator.row(<PosColumn>[
    PosColumn(text: label, styles: _label, width: _labelColumns),
    PosColumn(text: value, styles: isBold ? _valueBold : _value, width: _valueColumns),
  ]);

  static PaperSize _paperSize(ThermalPaper paper) => paper == ThermalPaper.mm58 ? PaperSize.mm58 : PaperSize.mm80;

  static PosStyles _businessNameStyle(ThermalPaper paper) => paper == ThermalPaper.mm58
      ? const PosStyles(align: PosAlign.center, bold: true)
      : const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2);
}
