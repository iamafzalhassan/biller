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

  String get blockingReason => invoice.printableItems.isEmpty ? 'Add at least one item before printing' : '';

  BillingState copyWith({bool? isPrinting, bool? isRestorable, int? formRevision, String? pendingInvoiceNumber, Invoice? invoice}) => BillingState(
    isPrinting: isPrinting ?? this.isPrinting,
    isRestorable: isRestorable ?? this.isRestorable,
    formRevision: formRevision ?? this.formRevision,
    pendingInvoiceNumber: pendingInvoiceNumber ?? this.pendingInvoiceNumber,
    invoice: invoice ?? this.invoice,
  );
}
