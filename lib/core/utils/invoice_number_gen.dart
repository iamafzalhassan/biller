abstract final class InvoiceNumberGen {
  static const int padWidth = 4;

  static String build({required int sequence, required String deviceId, required String prefix}) => '$prefix-$deviceId-${sequence.toString().padLeft(padWidth, '0')}';
}
