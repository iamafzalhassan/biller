import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/extensions/context_ext.dart';
import '../../../models/invoice.dart';
import '../../preview/controller/print_service.dart';
import '../widgets/invoice_actions_sheet.dart';
import '../widgets/recent_invoice_tile.dart';

class RecentScreen extends ConsumerWidget {
  const RecentScreen({super.key});

  Future<void> _openActions(BuildContext context, WidgetRef ref, Invoice invoice) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => InvoiceActionsSheet(
        invoice: invoice,
        onEditAndReprint: () {
          Navigator.of(sheetContext).pop();
          ref.read(billingControllerProvider.notifier).loadForEdit(invoice);
          Navigator.of(context).pop();
        },
        onReprint: () {
          Navigator.of(sheetContext).pop();
          unawaited(_reprint(ref, invoice));
        },
        onSaveCopy: () {
          Navigator.of(sheetContext).pop();
          unawaited(_saveCopy(context, ref, invoice));
        },
      ),
      showDragHandle: true,
    );
  }

  Future<void> _saveCopy(BuildContext context, WidgetRef ref, Invoice invoice) async {
    final String path = await ref.read(recentControllerProvider.notifier).saveCopy(invoice);
    if (!context.mounted) return;
    context.showBriefSnack('Saved to $path');
  }

  Future<void> _reprint(WidgetRef ref, Invoice invoice) async {
    final Uint8List bytes = await ref.read(recentControllerProvider.notifier).buildPdf(invoice);
    await PrintService.layout(bytes, name: invoice.invoiceNumber);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Invoice>> invoices = ref.watch(recentControllerProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Recent', maxLines: 1)),
      body: SafeArea(
        child: invoices.when(
          data: (List<Invoice> data) => data.isEmpty
              ? const Center(child: Text('No invoices yet', maxLines: 1, style: AppTextStyles.listSecondary))
              : ListView.builder(
                  itemBuilder: (BuildContext context, int index) =>
                      RecentInvoiceTile(invoice: data[index], onTap: () => unawaited(_openActions(context, ref, data[index]))),
                  itemCount: data.length,
                  padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.xl),
                ),
          error: (Object error, StackTrace stack) => Padding(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Center(
              child: Text('Could not load invoices: $error', style: AppTextStyles.listSecondary, textAlign: TextAlign.center),
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}
