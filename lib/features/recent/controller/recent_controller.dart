import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../models/business_profile.dart';
import '../../../models/invoice.dart';
import '../../../pdf/receipt_builder.dart';

class RecentController extends AsyncNotifier<List<Invoice>> {
  Future<void> refresh() async {
    state = await AsyncValue.guard(_load);
  }

  Future<Uint8List> buildPdf(Invoice invoice) => ReceiptBuilder.build(profile: ref.read(settingsRepositoryProvider).profile, invoice: invoice);

  Future<String> saveCopy(Invoice invoice) async {
    final BusinessProfile profile = ref.read(settingsRepositoryProvider).profile;
    final Uint8List bytes = await ReceiptBuilder.build(profile: profile, invoice: invoice);
    return ref.read(receiptStorageRepositoryProvider).save(invoice, bytes);
  }

  Future<List<Invoice>> _load() => ref.read(recentInvoicesRepositoryProvider).load(retentionDays: ref.read(settingsRepositoryProvider).retentionDays);

  @override
  Future<List<Invoice>> build() => _load();
}
