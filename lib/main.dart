import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'app/providers.dart';
import 'data/sources/prefs_source.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final PrefsSource prefs = PrefsSource();
  await prefs.init();
  runApp(ProviderScope(overrides: <Override>[prefsSourceProvider.overrideWithValue(prefs)], child: const BillerApp()));
}
