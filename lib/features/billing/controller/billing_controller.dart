import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/providers.dart';
import '../../../core/utils/mock_items.dart';
import '../../../models/business_profile.dart';
import '../../../models/invoice.dart';
import '../../../models/invoice_item.dart';
import '../../../pdf/receipt_builder.dart';
import 'billing_state.dart';

class BillingController extends Notifier<BillingState> {
  static const Uuid _uuid = Uuid();

  void restoreDraft() {
    final Invoice? draft = ref.read(draftRepositoryProvider).draft;
    if (draft == null) return;
    state = state.copyWith(isRestorable: false, formSeed: state.formSeed + 1, invoice: draft);
  }

  Future<void> discardDraft() async {
    await ref.read(draftRepositoryProvider).clear();
    state = state.copyWith(isRestorable: false);
  }

  void setCustomerName(String value) => _update(state.invoice.copyWith(customerName: value));

  void setCustomerPhone(String value) => _update(state.invoice.copyWith(customerPhone: value));

  void setAdvance(int cents) => _update(state.invoice.copyWith(advanceCents: cents));

  void addMockItems() {
    if (!kDebugMode) return;
    _update(state.invoice.copyWith(items: <InvoiceItem>[...state.invoice.items, ...MockItems.generate()]));
  }

  void addItem({required String description, required num qty, required int unitPriceCents}) {
    final InvoiceItem item = InvoiceItem(unitPriceCents: unitPriceCents, qty: qty, description: description, id: _uuid.v4());
    _update(state.invoice.copyWith(items: <InvoiceItem>[...state.invoice.items, item]));
  }

  void updateItem({required String id, required String description, required num qty, required int unitPriceCents}) {
    _update(
      state.invoice.copyWith(
        items: state.invoice.items.map((InvoiceItem i) => i.id == id ? i.copyWith(unitPriceCents: unitPriceCents, qty: qty, description: description) : i).toList(),
      ),
    );
  }

  (int, InvoiceItem)? removeItem(String id) {
    final List<InvoiceItem> items = <InvoiceItem>[...state.invoice.items];
    final int index = items.indexWhere((InvoiceItem i) => i.id == id);
    if (index < 0) return null;
    final InvoiceItem removed = items.removeAt(index);
    _update(state.invoice.copyWith(items: items));
    return (index, removed);
  }

  void reinsertItem(int index, InvoiceItem item) {
    final List<InvoiceItem> items = <InvoiceItem>[...state.invoice.items];
    items.insert(index.clamp(0, items.length), item);
    _update(state.invoice.copyWith(items: items));
  }

  Future<Uint8List> buildPreviewPdf() => ReceiptBuilder.build(profile: ref.read(settingsRepositoryProvider).profile, invoice: state.invoice);

  Future<Uint8List> commit() async {
    state = state.copyWith(isPrinting: true);
    try {
      final BusinessProfile profile = ref.read(settingsRepositoryProvider).profile;
      final Invoice invoice = state.invoice.copyWith(invoiceNumber: ref.read(settingsRepositoryProvider).pendingInvoiceNumber, createdAt: DateTime.now());
      final Uint8List bytes = await ReceiptBuilder.build(profile: profile, invoice: invoice);
      await ref.read(settingsRepositoryProvider).commitPendingInvoiceNumber();
      await ref.read(recentInvoicesRepositoryProvider).save(invoice);
      ref.invalidate(recentControllerProvider);
      await _archive(invoice, bytes);
      await ref.read(draftRepositoryProvider).clear();
      state = state.copyWith(isPrinting: false, invoice: invoice);
      return bytes;
    } catch (_) {
      state = state.copyWith(isPrinting: false);
      rethrow;
    }
  }

  void startNewBill() {
    final String pending = ref.read(settingsRepositoryProvider).pendingInvoiceNumber;
    state = BillingState(isPrinting: false, isRestorable: false, formSeed: state.formSeed + 1, pendingInvoiceNumber: pending, invoice: _blankInvoice(pending));
  }

  Future<void> _archive(Invoice invoice, Uint8List bytes) async {
    try {
      await ref.read(receiptStorageRepositoryProvider).save(invoice, bytes);
    } catch (_) {
      return;
    }
  }

  void _update(Invoice invoice) {
    state = state.copyWith(invoice: invoice);
    ref.read(draftRepositoryProvider).saveDebounced(invoice);
  }

  Invoice _blankInvoice(String invoiceNumber) => Invoice(advanceCents: 0, customerName: '', invoiceNumber: invoiceNumber, items: const <InvoiceItem>[], createdAt: DateTime.now());

  @override
  BillingState build() {
    final String pending = ref.read(settingsRepositoryProvider).pendingInvoiceNumber;
    final Invoice? draft = ref.read(draftRepositoryProvider).draft;
    return BillingState(isPrinting: false, isRestorable: draft != null, formSeed: 0, pendingInvoiceNumber: pending, draftSavedAt: draft?.createdAt, invoice: _blankInvoice(pending));
  }
}
