import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/billing/view/billing_screen.dart';
import '../features/setup/view/setup_screen.dart';
import 'app_theme.dart';
import 'providers.dart';
import 'router.dart';

class BillerApp extends ConsumerStatefulWidget {
  const BillerApp({super.key});

  @override
  ConsumerState<BillerApp> createState() => _BillerAppState();
}

class _BillerAppState extends ConsumerState<BillerApp> with WidgetsBindingObserver {
  Future<void> _purgeExpiredInvoices() async {
    try {
      await ref.read(recentInvoicesRepositoryProvider).purge(retentionDays: ref.read(settingsRepositoryProvider).retentionDays);
    } catch (_) {
      return;
    }
  }

  Widget _dismissOnTapOutside(Widget? child) => GestureDetector(behavior: HitTestBehavior.translucent, onTap: () => FocusManager.instance.primaryFocus?.unfocus(), child: child);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_purgeExpiredInvoices());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_purgeExpiredInvoices());
  }

  @override
  Widget build(BuildContext context) {
    final bool isSetUp = ref.watch(settingsRepositoryProvider).isSetupComplete;
    return MaterialApp(
      builder: (BuildContext context, Widget? child) => _dismissOnTapOutside(child),
      debugShowCheckedModeBanner: false,
      home: isSetUp ? const BillingScreen() : const SetupScreen(),
      routes: Routes.map,
      theme: AppTheme.light,
      title: 'Biller',
    );
  }
}
