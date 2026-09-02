import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme.dart';
import 'providers.dart';
import 'router.dart';

class BillerApp extends ConsumerStatefulWidget {
  const BillerApp({super.key});

  @override
  ConsumerState<BillerApp> createState() => _BillerAppState();
}

class _BillerAppState extends ConsumerState<BillerApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(ref.read(emailRepositoryProvider).flush());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSetUp = ref.watch(settingsRepositoryProvider).isSetupComplete;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: isSetUp ? Routes.billing : Routes.setup,
      routes: Routes.map,
      theme: AppTheme.light,
      title: 'Biller',
    );
  }
}
