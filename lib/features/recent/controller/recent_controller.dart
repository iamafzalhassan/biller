import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../models/business_profile.dart';
import '../../../models/invoice.dart';
import '../../../pdf/receipt_builder.dart';

class RecentController extends AsyncNotifier<List<Invoice>> {
  @override
  Future<List<Invoice>> build() => ref.read(recentInvoicesRepositoryProvider).load();

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => ref.read(recentInvoicesRepositoryProvider).load());
  }

  Future<Uint8List> buildPdf(Invoice invoice) => ReceiptBuilder.build(profile: ref.read(settingsRepositoryProvider).profile, invoice: invoice);

  Future<void> resendEmail(Invoice invoice) async {
    final BusinessProfile profile = ref.read(settingsRepositoryProvider).profile;
    final Uint8List bytes = await ReceiptBuilder.build(profile: profile, invoice: invoice);
    await ref.read(emailRepositoryProvider).enqueue(invoice: invoice, ownerEmail: profile.ownerEmail, pdfBytes: bytes);
  }
}
