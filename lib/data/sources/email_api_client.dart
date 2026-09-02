import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/app_config.dart';

class EmailApiClient {
  static const Duration timeout = Duration(seconds: 20);

  final http.Client _client;

  EmailApiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<bool> send(Map<String, dynamic> payload) async {
    if (!AppConfig.isEmailConfigured) return false;
    try {
      final http.Response response = await _client
          .post(
            Uri.parse('${AppConfig.receiptEndpoint}/sendReceipt'),
            headers: <String, String>{'content-type': 'application/json', AppConfig.secretHeader: AppConfig.receiptSecret},
            body: jsonEncode(payload),
          )
          .timeout(timeout);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
