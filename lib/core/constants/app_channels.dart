import 'package:flutter/services.dart';

abstract final class AppChannels {
  static const MethodChannel receipts = MethodChannel('biller/receipts');
}
