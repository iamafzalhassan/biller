abstract final class InvoiceNumberGen {
  static const int padWidth = 4;

  static String build({required int sequence, required String deviceId, required String prefix}) {
    final String seq = sequence.toString().padLeft(padWidth, '0');
    return '$prefix-$deviceId-$seq';
  }
}
