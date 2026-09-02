abstract final class AppConfig {
  static const String receiptEndpoint = String.fromEnvironment('RECEIPT_ENDPOINT');

  static const String receiptSecret = String.fromEnvironment('RECEIPT_SECRET');

  static const String secretHeader = 'x-biller-secret';

  static bool get isEmailConfigured => receiptEndpoint.isNotEmpty;
}
