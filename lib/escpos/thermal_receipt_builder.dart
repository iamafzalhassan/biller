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
    final Generator generator = Generator(_paperSize(paper), await CapabilityProfile.load());
    return <int>[
      ...generator.reset(),
      ..._header(generator, profile, paper),
      ..._meta(generator, invoice, paper),
      ..._items(generator, invoice.printableItems, paper),
      ..._totals(generator, invoice),
      ..._terms(generator, profile.printableTerms, paper),
      ..._footer(generator),
    ];
  }

  static List<int> _header(Generator generator, BusinessProfile profile, ThermalPaper paper) {
    final int lineChars = _lineChars(paper);
    return <int>[
      for (final String line in _wrap(profile.name, paper == ThermalPaper.mm58 ? lineChars : lineChars ~/ 2)) ...generator.text(line, styles: _businessNameStyle(paper)),
      for (final String detail in <String>[profile.addressLine, profile.phoneLine])
        if (detail.isNotEmpty)
          for (final String line in _wrap(detail, lineChars)) ...generator.text(line, styles: _centered),
      ...generator.hr(),
      ...generator.text(_invoiceHeading, styles: _centeredBold),
    ];
  }

  static List<int> _meta(Generator generator, Invoice invoice, ThermalPaper paper) {
    final String phone = invoice.customerPhone?.trim() ?? '';
    return <int>[
      ...generator.hr(),
      ..._pair(generator, 'NO', invoice.invoiceNumber, paper),
      ..._pair(generator, 'DATE', _dateFormat.format(invoice.createdAt).toUpperCase(), paper),
      ..._pair(generator, 'BILL TO', invoice.customerName, paper),
      if (phone.isNotEmpty) ..._pair(generator, 'PHONE', phone, paper),
    ];
  }

  static List<int> _items(Generator generator, List<InvoiceItem> items, ThermalPaper paper) => <int>[
    ...generator.hr(),
    for (final (int index, InvoiceItem item) in items.indexed) ...<int>[if (index > 0) ...generator.emptyLines(1), ..._item(generator, '${index + 1}. ', item, paper)],
  ];

  static List<int> _item(Generator generator, String prefix, InvoiceItem item, ThermalPaper paper) {
    final List<String> qtyLines = _wrapIndented(' ' * prefix.length, '${item.qty.asQty} x ${item.unitPriceCents.asAmount}', _columnChars(paper, start: 0, width: _itemLabelWidth));
    return <int>[
      for (final String line in _wrapIndented(prefix, item.description, _lineChars(paper))) ...generator.text(line, styles: _label),
      for (final (int index, String line) in qtyLines.indexed)
        ...generator.row(<PosColumn>[PosColumn(text: line, styles: PosStyles.defaults(), width: _itemLabelWidth), PosColumn(text: index == 0 ? item.amountCents.asAmount : '', styles: _value, width: _itemAmountWidth)]),
    ];
  }

  static List<int> _totals(Generator generator, Invoice invoice) => <int>[
    ...generator.hr(),
    ..._amount(generator, 'TOTAL', invoice.totalCents.asAmount, isBold: true),
    if (invoice.showsAdvance) ..._amount(generator, 'ADVANCE', invoice.advanceCents.asAmount, isBold: false),
    if (invoice.showsAdvance) ..._amount(generator, 'BALANCE', invoice.balanceCents.asAmount, isBold: true),
    ...generator.hr(),
  ];

  static List<int> _terms(Generator generator, List<String> terms, ThermalPaper paper) => <int>[
    if (terms.isNotEmpty) ...generator.text(_termsHeading, styles: _label),
    for (final (int index, String term) in terms.indexed)
      for (final String line in _wrapIndented('${index + 1}. ', term, _lineChars(paper))) ...generator.text(line),
    if (terms.isNotEmpty) ...generator.hr(),
  ];

  static List<int> _footer(Generator generator) => <int>[...generator.feed(2), ...generator.text(_signatureRule, styles: _centered), ...generator.text(_signatureLabel, styles: _centered), ...generator.feed(2), ...generator.cut()];

  static List<int> _pair(Generator generator, String label, String value, ThermalPaper paper) => <int>[
    for (final (int index, String line) in _wrap(value, _columnChars(paper, start: _metaLabelWidth, width: _metaValueWidth)).indexed)
      ...generator.row(<PosColumn>[PosColumn(text: index == 0 ? label : '', styles: _label, width: _metaLabelWidth), PosColumn(text: line, styles: _value, width: _metaValueWidth)]),
  ];

  static List<int> _amount(Generator generator, String label, String value, {required bool isBold}) =>
      generator.row(<PosColumn>[PosColumn(text: label, styles: _label, width: _totalLabelWidth), PosColumn(text: value, styles: isBold ? _valueBold : _value, width: _totalAmountWidth)]);

  static List<String> _wrapIndented(String prefix, String text, int width) => <String>[for (final (int index, String line) in _wrap(text, width - prefix.length).indexed) '${index == 0 ? prefix : ' ' * prefix.length}$line'];

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
