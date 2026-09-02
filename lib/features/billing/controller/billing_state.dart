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

  bool get canPrint => invoice.isPrintable && !isPrinting;

  String get blockingReason {
    if (invoice.customerName.trim().isEmpty) return 'Enter the customer name first';
    if (invoice.printableItems.isEmpty) return 'Add at least one item with a quantity';
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
