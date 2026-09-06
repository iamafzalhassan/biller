import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../models/printer_settings.dart';
import '../../models/thermal_paper.dart';
import '../sources/bluetooth_printer_source.dart';
import '../sources/prefs_source.dart';

class PrinterRepository {
  final BluetoothPrinterSource _bluetooth;

  final PrefsSource _prefs;

  PrinterRepository(this._bluetooth, this._prefs);

  PrinterSettings get settings => PrinterSettings(
    address: _prefs.getString(PrefsSource.keyPrinterAddress) ?? '',
    name: _prefs.getString(PrefsSource.keyPrinterName) ?? '',
    paper: ThermalPaper.fromName(_prefs.getString(PrefsSource.keyPrinterPaper)),
    target: _prefs.getString(PrefsSource.keyPrintTarget) == PrintTarget.thermal.name ? PrintTarget.thermal : PrintTarget.system,
  );

  Future<bool> isBluetoothReady() async {
    if (!await _bluetooth.isPermissionGranted() && !await _bluetooth.requestPermission()) return false;
    return _bluetooth.isBluetoothEnabled();
  }

  Future<List<BluetoothInfo>> pairedDevices() => _bluetooth.pairedDevices();

  Future<void> save(PrinterSettings settings) async {
    await _prefs.setString(PrefsSource.keyPrinterAddress, settings.address);
    await _prefs.setString(PrefsSource.keyPrinterName, settings.name);
    await _prefs.setString(PrefsSource.keyPrinterPaper, settings.paper.name);
    await _prefs.setString(PrefsSource.keyPrintTarget, settings.target.name);
  }

  Future<bool> send(List<int> bytes) async {
    final PrinterSettings current = settings;
    if (!current.hasDevice) return false;
    if (!await _bluetooth.isConnected() && !await _bluetooth.connect(current.address)) return false;
    return _bluetooth.write(bytes);
  }
}
