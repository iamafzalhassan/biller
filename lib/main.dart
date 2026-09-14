import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'data/sources/device_source.dart';
import 'data/sources/prefs_source.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final DeviceSource device = DeviceSource();
  final PrefsSource prefs = PrefsSource();
  await Future.wait(<Future<void>>[device.init(), prefs.init()]);
  runApp(ProviderScope(overrides: <Override>[deviceSourceProvider.overrideWithValue(device), prefsSourceProvider.overrideWithValue(prefs)], child: const BillerApp()));
}
