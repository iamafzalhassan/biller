import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../app/providers.dart';
import '../../../core/utils/mock_bill.dart';
import '../../../models/business_profile.dart';
import '../../../models/invoice.dart';
import '../../../models/invoice_item.dart';
import '../../../pdf/receipt_builder.dart';
import 'billing_state.dart';

class BillingController extends Notifier<BillingState> {
  static const Uuid _uuid = Uuid();

  @override
  BillingState build() {
    final String pending = ref.read(settingsRepositoryProvider).pendingInvoiceNumber;
    final bool hasDraft = ref.read(draftRepositoryProvider).draft != null;
    if (kDebugMode && !hasDraft) return _mockState(pending, 0);
    return BillingState(isPrinting: false, isRestorable: hasDraft, formRevision: 0, pendingInvoiceNumber: pending, invoice: _blankInvoice(pending));
  }

  void restoreDraft() {
    final Invoice? draft = ref.read(draftRepositoryProvider).draft;
    if (draft == null) return;
    state = state.copyWith(isRestorable: false, formRevision: state.formRevision + 1, invoice: draft);
  }

  Future<void> discardDraft() async {
    await ref.read(draftRepositoryProvider).clear();
    state = state.copyWith(isRestorable: false);
  }

  void setCustomerName(String value) => _update(state.invoice.copyWith(customerName: value));

  void setCustomerPhone(String value) => _update(state.invoice.copyWith(customerPhone: value));

  void setAdvance(int cents) => _update(state.invoice.copyWith(advanceCents: cents));

  void addItem({required String description, required num qty, required int unitPriceCents}) {
    final InvoiceItem item = InvoiceItem(unitPriceCents: unitPriceCents, qty: qty, description: description, id: _uuid.v4());
    _update(state.invoice.copyWith(items: <InvoiceItem>[...state.invoice.items, item]));
  }

  void updateItem({required String id, required String description, required num qty, required int unitPriceCents}) {
    _updateItem(id, (InvoiceItem i) => i.copyWith(unitPriceCents: unitPriceCents, qty: qty, description: description));
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

  void loadForEdit(Invoice original) {
    state = state.copyWith(
      isRestorable: false,
      formRevision: state.formRevision + 1,
      invoice: original.copyWith(isRevised: true, previousTotalCents: original.totalCents),
    );
  }

  void loadMockBill() {
    state = _mockState(state.pendingInvoiceNumber, state.formRevision + 1);
    ref.read(draftRepositoryProvider).saveDebounced(state.invoice);
  }

  Future<Uint8List> buildPreviewPdf() => ReceiptBuilder.build(profile: ref.read(settingsRepositoryProvider).profile, invoice: state.invoice);

  Future<Uint8List> commit() async {
    state = state.copyWith(isPrinting: true);
    final BusinessProfile profile = ref.read(settingsRepositoryProvider).profile;
    final Invoice invoice = state.invoice.isRevised
        ? state.invoice
        : state.invoice.copyWith(invoiceNumber: await ref.read(settingsRepositoryProvider).consumeInvoiceNumber(), createdAt: DateTime.now());
    final Uint8List bytes = await ReceiptBuilder.build(profile: profile, invoice: invoice);
    await ref.read(recentInvoicesRepositoryProvider).save(invoice);
    ref.invalidate(recentControllerProvider);
    await ref.read(receiptStorageRepositoryProvider).save(invoice, bytes);
    await ref.read(draftRepositoryProvider).clear();
    state = state.copyWith(isPrinting: false, invoice: invoice);
    return bytes;
  }

  void startNewBill() {
    final String pending = ref.read(settingsRepositoryProvider).pendingInvoiceNumber;
    state = BillingState(
      isPrinting: false,
      isRestorable: false,
      formRevision: state.formRevision + 1,
      pendingInvoiceNumber: pending,
      invoice: _blankInvoice(pending),
    );
  }

  void _updateItem(String id, InvoiceItem Function(InvoiceItem) transform) {
    _update(state.invoice.copyWith(items: state.invoice.items.map((InvoiceItem i) => i.id == id ? transform(i) : i).toList()));
  }

  void _update(Invoice invoice) {
    state = state.copyWith(invoice: invoice);
    ref.read(draftRepositoryProvider).saveDebounced(invoice);
  }

  BillingState _mockState(String pending, int formRevision) {
    final Invoice mock = MockBill.build(pending);
    return BillingState(isPrinting: false, isRestorable: false, formRevision: formRevision, pendingInvoiceNumber: pending, invoice: mock);
  }

  Invoice _blankInvoice(String invoiceNumber) =>
      Invoice(isRevised: false, advanceCents: 0, customerName: '', invoiceNumber: invoiceNumber, items: const <InvoiceItem>[], createdAt: DateTime.now());
}
