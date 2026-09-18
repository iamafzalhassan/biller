import '../../../core/utils/validators.dart';
import '../../../models/invoice.dart';

class BillingState {
  final bool isPrinting;
  final bool isRestorable;

  final int formSeed;

  final String pendingInvoiceNumber;

  final DateTime? draftSavedAt;

  final Invoice invoice;

  const BillingState({required this.isPrinting, required this.isRestorable, required this.formSeed, required this.pendingInvoiceNumber, this.draftSavedAt, required this.invoice});

  String get blockingReason {
    if (Validators.isBlank(invoice.customerName)) return 'Enter the customer name before printing. It is printed at the top of the bill.';
    if (invoice.printableItems.isEmpty) return 'Add at least one item before printing. Tap Add Item to start this bill.';
    if (!Validators.isValidPhone(invoice.customerPhone ?? '')) return 'The phone number must be 10 digits starting with 0, or left empty.';
    return '';
  }

  bool get canPrint => blockingReason.isEmpty && !isPrinting;

  BillingState copyWith({bool? isPrinting, bool? isRestorable, int? formSeed, String? pendingInvoiceNumber, DateTime? draftSavedAt, Invoice? invoice}) => BillingState(
    isPrinting: isPrinting ?? this.isPrinting,
    isRestorable: isRestorable ?? this.isRestorable,
    formSeed: formSeed ?? this.formSeed,
    pendingInvoiceNumber: pendingInvoiceNumber ?? this.pendingInvoiceNumber,
    draftSavedAt: draftSavedAt ?? this.draftSavedAt,
    invoice: invoice ?? this.invoice,
  );
}
