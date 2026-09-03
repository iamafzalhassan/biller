import '../../../core/utils/validators.dart';
import '../../../models/invoice.dart';

class BillingState {
  final bool isPrinting;
  final bool isRestorable;

  final int formRevision;

  final String pendingInvoiceNumber;

  final Invoice invoice;

  const BillingState({
    required this.isPrinting,
    required this.isRestorable,
    required this.formRevision,
    required this.pendingInvoiceNumber,
    required this.invoice,
  });

  bool get canPrint => blockingReason.isEmpty && !isPrinting;

  String get blockingReason {
    if (Validators.isBlank(invoice.customerName)) return 'Enter the customer name before printing. It is printed at the top of the bill.';
    if (invoice.printableItems.isEmpty) return 'Add at least one item before printing. Tap Add Item to start this bill.';
    if (!Validators.isValidPhone(invoice.customerPhone ?? '')) return 'The phone number must be 10 digits starting with 0, or left empty.';
    return '';
  }

  BillingState copyWith({bool? isPrinting, bool? isRestorable, int? formRevision, String? pendingInvoiceNumber, Invoice? invoice}) => BillingState(
    isPrinting: isPrinting ?? this.isPrinting,
    isRestorable: isRestorable ?? this.isRestorable,
    formRevision: formRevision ?? this.formRevision,
    pendingInvoiceNumber: pendingInvoiceNumber ?? this.pendingInvoiceNumber,
    invoice: invoice ?? this.invoice,
  );
}
