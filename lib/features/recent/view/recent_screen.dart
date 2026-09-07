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
import '../../../printing/print_outcome.dart';
import '../widgets/invoice_actions_sheet.dart';
import '../widgets/recent_invoice_tile.dart';

class RecentScreen extends ConsumerWidget {
  const RecentScreen({super.key});

  static const int noteLines = 2;

  Future<void> _openActions(BuildContext context, WidgetRef ref, Invoice invoice) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext sheetContext) => InvoiceActionsSheet(
        invoice: invoice,
        onReprint: () {
          Navigator.of(sheetContext).pop();
          unawaited(_reprint(context, ref, invoice));
        },
        onSaveCopy: () {
          Navigator.of(sheetContext).pop();
          unawaited(_saveCopy(context, ref, invoice));
        },
      ),
      showDragHandle: true,
    );
  }

  Future<void> _reprint(BuildContext context, WidgetRef ref, Invoice invoice) async {
    PrintOutcome outcome;
    try {
      final Uint8List bytes = await ref.read(recentControllerProvider.notifier).buildPdf(invoice);
      outcome = await ref.read(printDispatcherProvider).send(profile: ref.read(settingsRepositoryProvider).profile, invoice: invoice, bytes: bytes);
    } catch (_) {
      outcome = PrintOutcome.buildFailed;
    }
    if (!context.mounted || outcome.isSilent) return;
    context.showErrorSnack(outcome.message(invoice.invoiceNumber));
  }

  Future<void> _saveCopy(BuildContext context, WidgetRef ref, Invoice invoice) async {
    try {
      await ref.read(recentControllerProvider.notifier).saveCopy(invoice);
      if (!context.mounted) return;
      context.showSuccessSnack('Copy saved. Open it from your Files app under Downloads.');
    } catch (_) {
      if (!context.mounted) return;
      context.showErrorSnack('${invoice.invoiceNumber} could not be saved to Downloads. Check the phone storage and try again.');
    }
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
          const Icon(Icons.schedule_outlined, color: AppColors.textSecondary, size: AppSpacing.iconHint),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text('Invoices are kept for $days days, then removed from this list.', maxLines: noteLines, overflow: TextOverflow.ellipsis, style: AppTextStyles.listSecondary),
          ),
        ],
      ),
    );
  }

  Widget _emptyList(int days) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) => ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: _emptyState(days),
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
            child: const Icon(Icons.receipt_long_outlined, color: AppColors.textTertiary, size: AppSpacing.iconEmptyState),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text('No invoices yet', maxLines: 1, style: AppTextStyles.listPrimary),
          const SizedBox(height: AppSpacing.sm),
          Text('Every bill you print appears here for $days days, ready to reprint or save again.', style: AppTextStyles.listSecondary, textAlign: TextAlign.center),
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
                data: (List<Invoice> data) => RefreshIndicator(
                  onRefresh: ref.read(recentControllerProvider.notifier).refresh,
                  child: data.isEmpty
                      ? _emptyList(days)
                      : ListView.builder(
                          itemBuilder: (BuildContext context, int index) => RecentInvoiceTile(invoice: data[index], onTap: () => unawaited(_openActions(context, ref, data[index]))),
                          itemCount: data.length,
                          padding: const EdgeInsets.fromLTRB(AppSpacing.screenPadding, AppSpacing.lg, AppSpacing.screenPadding, AppSpacing.xl),
                          physics: const AlwaysScrollableScrollPhysics(),
                        ),
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
