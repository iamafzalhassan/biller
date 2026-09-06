import 'dart:async';

import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import '../../core/constants/app_channels.dart';

class BluetoothPrinterSource {
  static const Duration callTimeout = Duration(seconds: 12);

  Future<bool> requestPermission() => _guard(AppChannels.receipts.invokeMethod<bool>('requestBluetoothPermission').then((bool? granted) => granted ?? false), false);

  Future<bool> isPermissionGranted() => _guard(PrintBluetoothThermal.isPermissionBluetoothGranted, false);

  Future<bool> isBluetoothEnabled() => _guard(PrintBluetoothThermal.bluetoothEnabled, false);

  Future<bool> isConnected() => _guard(PrintBluetoothThermal.connectionStatus, false);

  Future<List<BluetoothInfo>> pairedDevices() => _guard(PrintBluetoothThermal.pairedBluetooths, <BluetoothInfo>[]);

  Future<bool> connect(String address) => _guard(PrintBluetoothThermal.connect(macPrinterAddress: address), false);

  Future<bool> write(List<int> bytes) => _guard(PrintBluetoothThermal.writeBytes(bytes), false);

  Future<T> _guard<T>(Future<T> call, T fallback) async {
    try {
      return await call.timeout(callTimeout);
    } catch (_) {
      return fallback;
    }
  }
}
