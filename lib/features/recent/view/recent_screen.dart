import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/constants/app_colors.dart';
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
    context.showSuccessSnack('Copy saved to $path. Open it from your Files app under Downloads.');
  }

  Future<void> _reprint(WidgetRef ref, Invoice invoice) async {
    final Uint8List bytes = await ref.read(recentControllerProvider.notifier).buildPdf(invoice);
    await PrintService.layout(bytes, name: invoice.invoiceNumber);
  }

  Widget _retentionNote(int days) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.divider)),
        color: AppColors.surfaceSunken,
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenPadding, vertical: AppSpacing.md),
      child: Row(
        children: <Widget>[
          const Icon(Icons.schedule_outlined, color: AppColors.textSecondary, size: 16),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Invoices are kept for $days days, then removed from this list.',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.listSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState(int days) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: AppColors.surfaceField, shape: BoxShape.circle),
            height: AppSpacing.emptyStateIcon,
            width: AppSpacing.emptyStateIcon,
            child: const Icon(Icons.receipt_long_outlined, color: AppColors.textTertiary, size: 32),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('No invoices yet', maxLines: 1, style: AppTextStyles.listPrimary),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Every bill you print appears here for $days days, ready to reprint or save again.',
            style: AppTextStyles.listSecondary,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<Invoice>> invoices = ref.watch(recentControllerProvider);
    final int days = ref.read(settingsRepositoryProvider).retentionDays;
    return Scaffold(
      appBar: AppBar(title: const Text('Recent', maxLines: 1)),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _retentionNote(days),
            Expanded(
              child: invoices.when(
                data: (List<Invoice> data) => data.isEmpty
                    ? _emptyState(days)
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
          ],
        ),
      ),
    );
  }
}
