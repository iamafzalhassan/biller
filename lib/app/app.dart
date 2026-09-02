import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/billing/view/billing_screen.dart';
import '../features/setup/view/setup_screen.dart';
import 'app_theme.dart';
import 'providers.dart';
import 'router.dart';

class BillerApp extends ConsumerWidget {
  const BillerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isSetUp = ref.watch(settingsRepositoryProvider).isSetupComplete;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: isSetUp ? const BillingScreen() : const SetupScreen(),
      routes: Routes.map,
      theme: AppTheme.light,
      title: 'Biller',
    );
  }
}
