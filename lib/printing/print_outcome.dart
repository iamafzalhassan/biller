enum PrintOutcome {
  sent,
  cancelled,
  noPrinterSelected,
  bluetoothUnavailable,
  connectFailed,
  buildFailed;

  bool get isSilent => this == PrintOutcome.sent || this == PrintOutcome.cancelled;

  String message(String invoiceNumber) => switch (this) {
    PrintOutcome.sent => '',
    PrintOutcome.cancelled => '',
    PrintOutcome.noPrinterSelected => 'No thermal printer is chosen yet. Open Settings and pick your paired printer, or switch back to WiFi printing.',
    PrintOutcome.bluetoothUnavailable => 'Bluetooth is off or not allowed. Turn Bluetooth on, then print $invoiceNumber again from Recent invoices.',
    PrintOutcome.connectFailed => 'Could not reach the thermal printer. Check that it is on and paired, then print $invoiceNumber again from Recent invoices.',
    PrintOutcome.buildFailed => '$invoiceNumber could not be sent to the printer. It is saved, so you can reprint it from Recent invoices.',
  };
}
