import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:intl/intl.dart';

import '../core/extensions/cents_formatting_ext.dart';
import '../models/business_profile.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../models/thermal_paper.dart';

abstract final class ThermalReceiptBuilder {
  static const int _charDots = 12;
  static const int _chars58 = 32;
  static const int _chars80 = 48;
  static const int _columnGapDots = 5;
  static const int _firstColumnGapDots = 6;
  static const int _itemAmountWidth = 5;
  static const int _itemLabelWidth = 7;
  static const int _metaLabelWidth = 4;
  static const int _metaValueWidth = 8;
  static const int _totalAmountWidth = 6;
  static const int _totalLabelWidth = 6;

  static const String _invoiceHeading = 'INVOICE';
  static const String _signatureLabel = 'CUSTOMER SIGNATURE';
  static const String _signatureRule = '________________________';
  static const String _termsHeading = 'TERMS AND CONDITIONS';

  static const PosStyles _centered = PosStyles(align: PosAlign.center);
  static const PosStyles _centeredBold = PosStyles(align: PosAlign.center, bold: true);
  static const PosStyles _label = PosStyles(align: PosAlign.left, bold: true);
  static const PosStyles _value = PosStyles(align: PosAlign.right);
  static const PosStyles _valueBold = PosStyles(align: PosAlign.right, bold: true);

  static final DateFormat _dateFormat = DateFormat('dd MMM yy h:mm a');

  static Future<List<int>> build({required BusinessProfile profile, required Invoice invoice, required ThermalPaper paper}) async {
    final CapabilityProfile capability = await CapabilityProfile.load();
    final Generator generator = Generator(_paperSize(paper), capability);
    final List<int> bytes = <int>[];
    bytes.addAll(generator.reset());
    bytes.addAll(_header(generator, profile, paper));
    bytes.addAll(_meta(generator, invoice, paper));
    bytes.addAll(_items(generator, invoice.printableItems, paper));
    bytes.addAll(_totals(generator, invoice));
    bytes.addAll(_terms(generator, profile.printableTerms, paper));
    bytes.addAll(_footer(generator));
    return bytes;
  }

  static List<int> _header(Generator generator, BusinessProfile profile, ThermalPaper paper) {
    final List<int> bytes = <int>[];
    final int lineChars = _lineChars(paper);
    final PosStyles nameStyle = _businessNameStyle(paper);
    for (final String line in _wrap(profile.name, paper == ThermalPaper.mm58 ? lineChars : lineChars ~/ 2)) {
      bytes.addAll(generator.text(line, styles: nameStyle));
    }
    if (profile.addressLine.isNotEmpty) {
      for (final String line in _wrap(profile.addressLine, lineChars)) {
        bytes.addAll(generator.text(line, styles: _centered));
      }
    }
    if (profile.phoneLine.isNotEmpty) {
      for (final String line in _wrap(profile.phoneLine, lineChars)) {
        bytes.addAll(generator.text(line, styles: _centered));
      }
    }
    bytes.addAll(generator.hr());
    bytes.addAll(generator.text(_invoiceHeading, styles: _centeredBold));
    return bytes;
  }

  static List<int> _meta(Generator generator, Invoice invoice, ThermalPaper paper) {
    final List<int> bytes = <int>[];
    bytes.addAll(generator.hr());
    bytes.addAll(_pair(generator, 'NO', invoice.invoiceNumber, paper));
    bytes.addAll(_pair(generator, 'DATE', _dateFormat.format(invoice.createdAt).toUpperCase(), paper));
    bytes.addAll(_pair(generator, 'BILL TO', invoice.customerName, paper));
    final String? phone = invoice.customerPhone;
    if (phone != null && phone.trim().isNotEmpty) bytes.addAll(_pair(generator, 'PHONE', phone.trim(), paper));
    return bytes;
  }

  static List<int> _items(Generator generator, List<InvoiceItem> items, ThermalPaper paper) {
    final List<int> bytes = <int>[];
    final int lineChars = _lineChars(paper);
    final int qtyChars = _columnChars(paper, start: 0, width: _itemLabelWidth);
    bytes.addAll(generator.hr());
    for (int index = 0; index < items.length; index++) {
      final InvoiceItem item = items[index];
      final String prefix = '${index + 1}. ';
      if (index > 0) bytes.addAll(generator.emptyLines(1));
      for (final String line in _wrapIndented(prefix, item.description, lineChars)) {
        bytes.addAll(generator.text(line, styles: _label));
      }
      final List<String> qtyLines = _wrapIndented(' ' * prefix.length, '${item.qty.asQty} x ${item.unitPriceCents.asAmount}', qtyChars);
      for (int line = 0; line < qtyLines.length; line++) {
        bytes.addAll(generator.row(<PosColumn>[PosColumn(text: qtyLines[line], styles: PosStyles.defaults(), width: _itemLabelWidth), PosColumn(text: line == 0 ? item.amountCents.asAmount : '', styles: _value, width: _itemAmountWidth)]));
      }
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

  static List<int> _terms(Generator generator, List<String> terms, ThermalPaper paper) {
    if (terms.isEmpty) return <int>[];
    final List<int> bytes = <int>[];
    final int lineChars = _lineChars(paper);
    bytes.addAll(generator.text(_termsHeading, styles: _label));
    for (int index = 0; index < terms.length; index++) {
      for (final String line in _wrapIndented('${index + 1}. ', terms[index], lineChars)) {
        bytes.addAll(generator.text(line));
      }
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

  static List<int> _pair(Generator generator, String label, String value, ThermalPaper paper) {
    final List<int> bytes = <int>[];
    final List<String> lines = _wrap(value, _columnChars(paper, start: _metaLabelWidth, width: _metaValueWidth));
    for (int index = 0; index < lines.length; index++) {
      bytes.addAll(generator.row(<PosColumn>[PosColumn(text: index == 0 ? label : '', styles: _label, width: _metaLabelWidth), PosColumn(text: lines[index], styles: _value, width: _metaValueWidth)]));
    }
    return bytes;
  }

  static List<int> _amount(Generator generator, String label, String value, {required bool isBold}) =>
      generator.row(<PosColumn>[PosColumn(text: label, styles: _label, width: _totalLabelWidth), PosColumn(text: value, styles: isBold ? _valueBold : _value, width: _totalAmountWidth)]);

  static List<String> _wrapIndented(String prefix, String text, int width) {
    final String padding = ' ' * prefix.length;
    final List<String> wrapped = _wrap(text, width - prefix.length);
    return <String>[for (int index = 0; index < wrapped.length; index++) index == 0 ? '$prefix${wrapped[index]}' : '$padding${wrapped[index]}'];
  }

  static List<String> _wrap(String text, int width) {
    final String source = text.trim();
    if (width < 1 || source.isEmpty) return <String>[source];
    final List<String> lines = <String>[];
    String current = '';
    for (final String word in source.split(RegExp(r'\s+'))) {
      String pending = word;
      while (pending.length > width) {
        if (current.isNotEmpty) {
          lines.add(current);
          current = '';
        }
        lines.add(pending.substring(0, width));
        pending = pending.substring(width);
      }
      if (pending.isEmpty) continue;
      if (current.isEmpty) {
        current = pending;
      } else if (current.length + 1 + pending.length <= width) {
        current = '$current $pending';
      } else {
        lines.add(current);
        current = pending;
      }
    }
    if (current.isNotEmpty) lines.add(current);
    return lines.isEmpty ? <String>[source] : lines;
  }

  static int _lineChars(ThermalPaper paper) => paper == ThermalPaper.mm58 ? _chars58 : _chars80;

  static int _columnChars(ThermalPaper paper, {required int start, required int width}) => (_lineChars(paper) * width - (start == 0 ? _firstColumnGapDots : _columnGapDots)) ~/ _charDots;

  static PaperSize _paperSize(ThermalPaper paper) => paper == ThermalPaper.mm58 ? PaperSize.mm58 : PaperSize.mm80;

  static PosStyles _businessNameStyle(ThermalPaper paper) =>
      paper == ThermalPaper.mm58 ? const PosStyles(align: PosAlign.center, bold: true) : const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2, width: PosTextSize.size2);
}
