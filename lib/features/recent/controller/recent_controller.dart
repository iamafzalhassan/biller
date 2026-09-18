import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../models/invoice.dart';
import '../../../pdf/receipt_builder.dart';
import '../../../printing/print_outcome.dart';

class RecentController extends AsyncNotifier<List<Invoice>> {
  Future<void> refresh() async => state = await AsyncValue.guard(_load);

  Future<PrintOutcome> reprint(Invoice invoice) async {
    try {
      return await ref.read(printDispatcherProvider).send(bytes: await _buildPdf(invoice), invoice: invoice, profile: ref.read(settingsRepositoryProvider).profile);
    } catch (_) {
      return PrintOutcome.buildFailed;
    }
  }

  Future<String> saveCopy(Invoice invoice) async => ref.read(receiptStorageRepositoryProvider).save(invoice, await _buildPdf(invoice));

  Future<Uint8List> _buildPdf(Invoice invoice) => ReceiptBuilder.build(profile: ref.read(settingsRepositoryProvider).profile, invoice: invoice);

  Future<List<Invoice>> _load() => ref.read(recentInvoicesRepositoryProvider).load(retentionDays: ref.read(settingsRepositoryProvider).retentionDays);

  @override
  Future<List<Invoice>> build() => _load();
}
