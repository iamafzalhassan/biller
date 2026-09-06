import 'package:flutter/foundation.dart';

import '../data/repositories/printer_repository.dart';
import '../escpos/thermal_receipt_builder.dart';
import '../models/business_profile.dart';
import '../models/invoice.dart';
import '../models/printer_settings.dart';
import 'print_outcome.dart';
import 'system_print_service.dart';

class PrintDispatcher {
  final PrinterRepository _printers;

  PrintDispatcher(this._printers);

  Future<PrintOutcome> send({required BusinessProfile profile, required Invoice invoice, required Uint8List bytes}) async {
    if (!_printers.settings.isThermal) return _layout(bytes, invoice.invoiceNumber);
    return _thermal(profile: profile, invoice: invoice);
  }

  Future<PrintOutcome> _layout(Uint8List bytes, String name) async {
    try {
      return await SystemPrintService.layout(bytes, name: name) ? PrintOutcome.sent : PrintOutcome.cancelled;
    } catch (_) {
      return PrintOutcome.buildFailed;
    }
  }

  Future<PrintOutcome> _thermal({required BusinessProfile profile, required Invoice invoice}) async {
    final PrinterSettings printer = _printers.settings;
    if (!printer.hasDevice) return PrintOutcome.noPrinterSelected;
    try {
      if (!await _printers.isBluetoothReady()) return PrintOutcome.bluetoothUnavailable;
      final List<int> bytes = await ThermalReceiptBuilder.build(profile: profile, invoice: invoice, paper: printer.paper);
      return await _printers.send(bytes) ? PrintOutcome.sent : PrintOutcome.connectFailed;
    } catch (_) {
      return PrintOutcome.connectFailed;
    }
  }
}
